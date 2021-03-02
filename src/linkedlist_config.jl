module LinkedListConf

export conf, setconf


const conf = Ref(
    (
        SCHEDULER_COUNT = 20,
        
        # List parameters
        LIST_LENGTH = 1000,
        PARALLELISM = 1000, # Number of parallel Reduce operations (firstly started in a single batch, but later they smooth out)

        # Infoton optimization parameters
        I = 0.2,
        TARGET_DISTANCE = 20.0,
        SCHEDULER_TARGET_LOAD = 18,
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