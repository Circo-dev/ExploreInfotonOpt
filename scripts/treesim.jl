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