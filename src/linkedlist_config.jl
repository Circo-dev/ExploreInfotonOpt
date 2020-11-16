module SearchTreeConf

export conf, setconf


const conf = Ref(
    (
        SCHEDULER_COUNT = 6,

        # List parameters
        LIST_LENGTH = 1000,
        PARALLELISM = 100, # Number of parallel Reduce operations (firstly started in a single batch, but later they smooth out)

        # Infoton optimization parameters
        I = 1.0,
        TARGET_DISTANCE = 180.0,
        SCHEDULER_TARGET_LOAD = 20,
        SCHEDULER_LOAD_FORCE_STRENGTH = 0.01,

        # View parameters
    )
)

setconf(changeset::NamedTuple)  = begin
    global conf
    conf[] = merge(conf[], changeset)
end

setconf(var::Symbol, value) = setconf((;var => value))

end