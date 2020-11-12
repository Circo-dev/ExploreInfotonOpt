module LinkedListConf

export conf, setconf


const conf = Ref(
    (
        SCHEDULER_COUNT = 6,

        # List parameters
        LIST_LENGTH = 4000,
        PARALLELISM = 10, # Number of concurrent Reduce operations (firstly started in a single batch, but later they smooth out)

        # Infoton optimization parameters
        I = 1.0,
        TARGET_DISTANCE = 50.0,
        SCHEDULER_TARGET_LOAD = 20,
        SCHEDULER_LOAD_FORCE_STRENGTH = 0.02,

        # View parameters
    )
)

setconf(changeset::NamedTuple)  = begin
    global conf
    conf[] = merge(conf[], changeset)
end

setconf(var::Symbol, value) = setconf((;var => value))

end