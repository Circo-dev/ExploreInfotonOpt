using DrWatson, Circo
@quickactivate "ExploreInfotonOpt"

const sim = :tree # :tree, :list, :workerpool

if sim == :tree
    include("../src/searchtree.jl")
    using .SearchTreeTest
elseif sim == :list
    include("../src/linkedlist.jl")
    using .LinkedListTest
elseif sim == :workerpool
    include("../src/workerpool.jl")
    using .WorkerPool
end

include("../src/stats.jl")

plugins(;options...) = [Debug.MsgStats]
profile(;options...) = Circo.Profiles.ClusterProfile(;options...)

# Run
ctx = CircoContext(;profilefn = profile, userpluginsfn = plugins)
coordinator = Coordinator(emptycore(ctx))

host = Host(ctx, conf[].SCHEDULER_COUNT; zygote=[coordinator])
@async host()

p = Threads.nthreads() == 1 # Print stats only if single-threaded

@info "Waiting for Circo node to start up"
@async begin
    sleep(15.0)
    @info "Running the simulation"
    send(host, coordinator, Circo.Debug.Run())
    if p
        sleep(15.0)
        @info "Periodically printing stats. Stop with p = false"
        t = @async while true
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
    else
        @info "Stats printing is not thread-safe, disabled."
    end
end

# Pause the simulation:
#send(host, coordinator, Circo.Debug.Stop())

# Rate of local messages
# local_rate(host)

# Dataframe with simple stats
# stats = hoststats(host) # also resets stats by default

# Change config (works for infoton opt and view) while the simulation is running
# setconf(:TARGET_DISTANCE, 230.0)

# stop/restart when code changed (better to restart Julia for now)
# shutdown!(host)
# @async host()
