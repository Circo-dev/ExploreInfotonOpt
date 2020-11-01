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

@info "Waiting for Circo node to start up"
sleep(12.0)

@info "Running the simulation"
send(host, coordinator, Circo.Debug.Run())
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

# Periodically print stats. Stop with p = false 
# p = true
# t = @async while p
#     println("")
#     @info "Searches/sec since last report: $(round(coordinator.resultcount * 1e9 / (time_ns() - coordinator.lastreportts)))"
#     coordinator.resultcount = 0
#     coordinator.lastreportts = time_ns()
#     println(hoststats(host;clear=false))
#     println(local_rate(host))
#     sleep(10)
# end