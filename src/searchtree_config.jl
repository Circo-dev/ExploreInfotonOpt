module SearchTreeConf

export conf, setconf

const ITEMS_PER_LEAF = 1000
const conf = Ref(
    (
        SCHEDULER_COUNT = 6,

        # Tree parameters
        ITEM_COUNT = 200_000,
        ITEMS_PER_LEAF = ITEMS_PER_LEAF,
        FILL_RATE = 0.01,
        FULLSPEED_PARALLELISM = 1000,
        SEARCHKEY_SPACE_DIV = 1, # searches will run for keys generated by rand(UInt32) / SEARCHKEY_SPACE_DIV

        # Infoton optimization parameters
        I = 1.0,
        TARGET_DISTANCE = 180.0,
        SCHEDULER_TARGET_LOAD = 20,
        SCHEDULER_LOAD_FORCE_STRENGTH = 0.01,

        SIBLINGINFO_FREQ = 1, # 0..255
        SIBLINGINFO_ENERGY = -1.0,

        # View parameters
        RED_AFTER = ITEMS_PER_LEAF * 0.95 - 1,
        NODESCALE_FACTOR = 1 / ITEMS_PER_LEAF / 2,
        SHOW_SIBLING_CONN = false,
    )
)

setconf(changeset::NamedTuple)  = begin
    global conf
    conf[] = merge(conf[], changeset)
end

setconf(var::Symbol, value) = setconf((;var => value))

end