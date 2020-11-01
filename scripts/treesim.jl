using DrWatson, Circo
@quickactivate "ExploreInfotonOpt"

include("../src/searchtree.jl")
using .SearchTreeTest

include("../src/stats.jl")

plugins(;options...) = [Debug.MsgStats(;options...)]
profile(;options...) = Circo.Profiles.ClusterProfile(;options...)

# Run
ctx = CircoContext(;profilefn = profile, userpluginsfn = plugins)
coordinator = SearchTreeTest.Coordinator(emptycore(ctx))

host = Host(ctx, conf[].SCHEDULER_COUNT; zygote=[coordinator])
@async host()

p = true # Print stats

@info "Waiting for Circo node to start up"
@async begin
    sleep(12.0)
    @info "Running the simulation"
    send(host, coordinator, Circo.Debug.Run())        

    @info "Periodically printing stats. Stop with p = false"
    t = @async while true
        if p
            while p
                println("")
                @info "Searches/sec since last report: $(round(coordinator.resultcount * 1e9 / (time_ns() - coordinator.lastreportts)))"
                coordinator.resultcount = 0
                coordinator.lastreportts = time_ns()
                println(hoststats(host;clear=false))
                println("$(Int(round(local_rate(host) * 100)))% local messages")
                sleep(10)
            end
        else
            sleep(1)
        end
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
