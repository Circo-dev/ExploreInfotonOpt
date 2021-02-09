using DataFrames

function local_rate(host; clear=true)
    stats = hoststats(host; clear = clear);
    return sum(stats[!,2]) / sum(stats[!,3])
end

function hoststats(host; clear=true)
    return DataFrame(map(host.schedulers) do scheduler
        msgstats = scheduler.plugins[:msgstats]
        if clear
            reset_hoststats(host)
        end
        return (actorcount = length(scheduler.actorcache),
            local_msgs = msgstats.local_count,
            total_msgs = msgstats.total_count,
            local_rate = msgstats.local_count / msgstats.total_count,
            )
    end)
end

function reset_hoststats(host)
    for scheduler in host.schedulers
        msgstats = scheduler.plugins[:msgstats]
        send(scheduler, msgstats.helper, Circo.Debug.ResetStats())
    end
end