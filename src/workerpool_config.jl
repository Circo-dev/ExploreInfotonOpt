module WorkerPoolConf

export conf, setconf

const conf = Ref(
    (
        SCHEDULER_COUNT = 6,

        # Worker pool parameters
        POOL_COUNT = 6,
        POOL_SIZE = 100,
        PARALLELISM = 10, # Number of parallel operations per pool (firstly started in a single batch)

        # Infoton optimization parameters
        I = 0.2,
        TARGET_DISTANCE = 200.0,
        SCHEDULER_TARGET_LOAD = 28,
        SCHEDULER_LOAD_FORCE_STRENGTH = 0.05,

        # View parameters
    )
)

setconf(changeset::NamedTuple)  = begin
    global conf
    conf[] = merge(conf[], changeset)
end

setconf(var::Symbol, value) = setconf((;var => value))

end