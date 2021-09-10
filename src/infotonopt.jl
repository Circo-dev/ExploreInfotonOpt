using LinearAlgebra
using CircoCore, Circo, Circo.Migration, Circo.InfotonOpt, Plugins
using ..Commons

mutable struct ConfigurableInfotonOptimizer <: InfotonOpt.CustomOptimizer
    scheduler_load::Float32
    centroid::Pos
    fieldvect::Pos
    accepts_migrants::Bool
    migration::Migration.MigrationService
    ConfigurableInfotonOptimizer(migration;options...) = new(0.0f1, Pos(0,0,0), Pos(0,0,0), true, migration)
end

@inline @fastmath Circo.actor_activity_sparse16(optimizer::ConfigurableInfotonOptimizer, scheduler, targetactor) = begin
    actorpos = pos(targetactor)
    if !(actorpos[1] < 1) && !(actorpos[1] > 0) # TODO check why isnan isn't working here (for messages coming from the js client)
        return false
    end
    optimizer.centroid = optimizer.centroid * 0.9999 + actorpos * 0.0001
    optimizer.fieldvect = (pos(scheduler) - optimizer.centroid) * conf[].FIELD_STRENGTH
    return false
end

# CircoCore.Positioning.hostrelative_schedulerpos(positioner::CircoCore.Positioner, postcode) = begin
#     p = port(postcode)
#     return @show Pos(p - 24721 - 3.5, 0, 0) * 1000
# end

Circo.monitorextra(actor::Circo.Monitor.MonitorActor) = (
    actorcount = UInt32(actor.monitor.scheduler.actorcount),
    load = floor(actor.monitor.scheduler.plugins[:infoton_optimizer].scheduler_load)
)

Circo.Monitor._updatepos(me::Circo.Monitor.MonitorActor) = begin
    me.core.pos = me.monitor.scheduler.plugins[:infoton_optimizer].centroid
end

# Schedulers pull/push their actors based on their load(message queue length).
# SCHEDULER_TARGET_LOAD configures the target load .
@inline @fastmath function Circo.InfotonOpt.scheduler_infoton(optimizer::ConfigurableInfotonOptimizer, scheduler, actor::TestActor)
    #dist = norm(scheduler.pos - actor.core.pos)
    posdiff = scheduler.pos - actor.core.pos # optimizer.centroid - actor.core.pos
    dist = norm(posdiff)
    loaddiff = Float64(conf[].SCHEDULER_TARGET_LOAD - optimizer.scheduler_load)
    (loaddiff == 0.0 || dist == 0.0) && return Infoton(scheduler.pos, 0.0)
    energy = sign(loaddiff) * log(abs(loaddiff)) * conf[].SCHEDULER_LOAD_FORCE_STRENGTH
    !isnan(energy) || error("Scheduler infoton energy is NaN")

    actor.core.pos = actor.core.pos + optimizer.fieldvect

    return Infoton(scheduler.pos, energy)
end

@inline Circo.Migration.check_migration(me::TestActor, alternatives::MigrationAlternatives, service) = begin
    #if length(alternatives) < conf[].SCHEDULER_COUNT - 1 && rand(UInt16) < 10
    #    @warn "Only $(length(alternatives)) alternatives at $(box(me)) :"# $alternatives"
    #end
    migrate_to_nearest(me, alternatives, service)
    return nothing
end

@inline @fastmath function Circo.InfotonOpt.apply_infoton(::ConfigurableInfotonOptimizer, targetactor::TestActor, infoton::Infoton)
    diff = infoton.sourcepos - targetactor.core.pos
    difflen = norm(diff)
    difflen == 0 && return nothing
    energy = infoton.energy
    !isnan(energy) || error("Incoming infoton energy is NaN")
    if energy > 0 && difflen < conf[].TARGET_DISTANCE# || energy < 0 && difflen > conf[].TARGET_DISTANCE * 0.10
        return nothing # Comment out this line to preserve (absolute) energy. This version seems to work better.
        #energy = -energy
    end
    stepvect = diff / difflen * energy * conf[].I
    all(x -> !isnan(x), stepvect) || error("stepvect $stepvect contains NaN")
    targetactor.core.pos += stepvect
    return nothing
end
