local quat = require("quaternion")
local vec3 = require("vector3")
local ang = require("angle")

local physic = {}

physic.native = ship

function physic.get_velocity()
    return vec3.from_table(ship.getVelocity())
end

function physic.get_angular_velocity()
    return vec3.from_table(ship.getOmega())
end

function physic.get_rotation()
    return quat.from_table(ship.getQuaternion())
end

function physic.get_position()
    return vec3.from_table(ship.getWorldspacePosition())
end

function physic.get_mass()
    return ship.getMass()
end

function physic.get_time_left(target)
    local distance = vec3.distance(physic.get_position(), target)
    local speed = physic.get_velocity().length()
    return distance / speed
end

function physic.apply_force(vec)
    local force = vec3.scale(vec, physic.get_mass())
    ship.applyRotDependentForce(-force.z, force.y, -force.x)
end

function physic.apply_torque(euler)
    local torque = vec3.scale(euler, physic.get_mass())
    ship.applyRotDependentTorque(torque.x, torque.y, torque.z)
end

function physic.looking_angle_at(target)
    local direction = vec3.sub(target, physic.get_position()).normalize()
    local target_rotation = quat.look_rotation(direction)
    target_rotation = quat.mul(target_rotation, quat.from_euler(vec3.from(0, ang.deg.to_rad(90), 0)))
    local delta_rotation = quat.mul(target_rotation, physic.get_rotation().inverse())
    return delta_rotation
end

function physic.look_at(target, factor)
    local euler = physic.looking_angle_at(target).to_euler()
    physic.apply_torque(vec3.scale(euler, factor))
end

function physic.move_forward(factor)
    physic.apply_force(vec3.scale(vec3.forward, factor))
end



return physic
