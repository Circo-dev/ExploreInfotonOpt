using Circo.Monitor

module Commons

using Circo, Circo.Monitor

export TestActor, RunMedium, RunSlow, STOP, STEP, SLOW, MEDIUM, FULLSPEED

abstract type TestActor{TCore} <: Actor{TCore} end

# Non-standard Debug messages handled by the Coordinator (See also module Circo.Debug)
struct RunSlow a::UInt8 end# TODO fix MsgPack to allow empty structs
registermsg(RunSlow; ui=true)

struct RunMedium a::UInt8 end# TODO Create UI to allow parametrized messages
registermsg(RunMedium; ui=true)

const STOP = 0
const STEP = 1
const SLOW = 20
const MEDIUM = 98
const FULLSPEED = 100

end