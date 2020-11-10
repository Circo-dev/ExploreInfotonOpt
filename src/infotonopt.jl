# Schedulers pull/push their actors based on their load(message queue length).
# SCHEDULER_TARGET_LOAD configures the target load .
@inline @fastmath function load_scheduler_infoton(scheduler, actor::TestActor)
    dist = norm(scheduler.pos - actor.core.pos)
    loaddiff = Float64(conf[].SCHEDULER_TARGET_LOAD - length(scheduler.msgqueue))
    (loaddiff == 0.0 || dist == 0.0) && return Infoton(scheduler.pos, 0.0)
    energy = sign(loaddiff) * log(abs(loaddiff)) * conf[].SCHEDULER_LOAD_FORCE_STRENGTH
    !isnan(energy) || error("Scheduler infoton energy is NaN")
    return Infoton(scheduler.pos, energy)
end

Circo.scheduler_infoton(scheduler, actor::TestActor) = load_scheduler_infoton(scheduler, actor)

@inline Circo.check_migration(me::TestActor, alternatives::MigrationAlternatives, service) = begin
    if length(alternatives) < conf[].SCHEDULER_COUNT - 1 && rand(UInt8) == 0
        @warn "Only $(length(alternatives)) alternatives at $(box(me)) : $alternatives"
    end
    migrate_to_nearest(me, alternatives, service)
    return nothing
end

@inline @fastmath Circo.apply_infoton(targetactor::TestActor, infoton::Infoton) = begin
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
