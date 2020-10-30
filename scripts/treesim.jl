using DrWatson, Circo
@quickactivate "ExploreInfotonOpt"

include("../src/searchtree.jl")

# Config
const SCHEDULER_COUNT = 6

zygote(ctx) = [SearchTreeTest.Coordinator(emptycore(ctx)) for i = 1:1]
plugins(;options...) = [Debug.MsgStats(;options...)]
profile(;options...) = Circo.Profiles.ClusterProfile(;options...)

# Run
ctx = CircoContext(;profilefn = profile, userpluginsfn = plugins)
host = Host(ctx, SCHEDULER_COUNT; zygote=zygote(ctx))
@async host()

