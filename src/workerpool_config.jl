module WorkerPoolConf

export conf, setconf

const conf = Ref(
    (
        SCHEDULER_COUNT = 20,

        # Worker pool parameters
        POOL_COUNT = 120,
        POOL_SIZE = 20,
        PARALLELISM = 20, # Number of parallel operations per pool (firstly started in a single batch)

        # Infoton optimization parameters
        I = 0.6,
        TARGET_DISTANCE = 200.0,
        SCHEDULER_TARGET_LOAD = 18,
        SCHEDULER_LOAD_FORCE_STRENGTH = 0.1,

        # View parameters
    )
)

setconf(changeset::NamedTuple)  = begin
    global conf
    conf[] = merge(conf[], changeset)
end

setconf(var::Symbol, value) = setconf((;var => value))

end