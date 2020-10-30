module SearchTreeConf

export conf, setconf

const ITEMS_PER_LEAF = 1000
const conf = Ref(
    (
        SCHEDULER_COUNT = 6,

        # Tree parameters
        ITEM_COUNT = 200_000,
        ITEMS_PER_LEAF = ITEMS_PER_LEAF,
        FULLSPEED_PARALLELISM = 1000,

        # Infoton optimization parameters
        I = 1.0,
        TARGET_DISTANCE = 180.0,
        SCHEDULER_TARGET_LOAD = 20,
        SCHEDULER_LOAD_FORCE_STRENGTH = 2e-2,
        #SCHEDULER_TARGET_ACTORCOUNT = 100.0,
        #SCHEDULER_FORCE_STRENGTH = 1.3e-2,
        SIBLINGINFO_FREQ = 1, # 0..255
        SIBLINGINFO_ENERGY = -1.0,

        # View parameters
        RED_AFTER = ITEMS_PER_LEAF * 0.95 - 1,
        NODESCALE_FACTOR = 1 / ITEMS_PER_LEAF / 2,
    )
)

setconf(changeset::NamedTuple)  = begin
    global conf
    conf[] = merge(conf[], changeset)
end

setconf(var::Symbol, value) = setconf((;var => value))

end