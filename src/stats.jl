using DataFrames

function local_rate(host; clear=true)
    stats = hoststats(host; clear = clear);
    return sum(stats[!,2]) / sum(stats[!,3])
end

function hoststats(host; clear=true)
    return DataFrame(map(host.schedulers) do scheduler
        msgstats = scheduler.plugins[:msgstats]
        optimizer = scheduler.plugins[:infoton_optimizer]
        if clear
            reset_hoststats(host)
        end
        return (actorcount = length(scheduler.actorcache),
            local_msgs = msgstats.local_count,
            total_msgs = msgstats.total_count,
            local_rate = msgstats.local_count / msgstats.total_count,
            load = isnothing(optimizer) ? -1.0f0 : optimizer.scheduler_load,
            accepts_migrants = isnothing(optimizer) ? false : optimizer.accepts_migrants
            )
    end)
end

function reset_hoststats(host)
    for scheduler in host.schedulers
        msgstats = scheduler.plugins[:msgstats]
        send(scheduler, msgstats.helper, Circo.Debug.ResetStats())
    end
end

function start_stats_printer(coordinator, host)
    return @async while true
        global p
        if p
            while p
                try
                    println("")
                    @info "Searches or Reduces/sec since last report: $(round(coordinator.resultcount * 1e9 / (time_ns() - coordinator.lastreportts)))"
                    coordinator.resultcount = 0
                    coordinator.lastreportts = time_ns()
                    stats = hoststats(host;clear=false)
                    println(stats)
                    println("$(sum(stats[!, :actorcount])) actors, $(Int(round(local_rate(host) * 100)))% local messages")
                    sleep(10)
                catch e
                    @show e
                end
            end
        else
            sleep(1)
        end
    end
end