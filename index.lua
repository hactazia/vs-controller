local physic = require("physic")
local vec3 = require("vector3")
local quat = require("quaternion")
local ang = require("angle")
local screen = require("screen")

screen.clear()
screen.write("Starting...", 1, 1)

local constants_rotation = {
    acceleration = 100,
    speed = 0.30
}

local constants_position = {
    acceleration = 2500,
    speed = 10,
    min_angular_speed = ang.deg.to_rad(45),
    speed_limit = function(x, a)
        return (x <= 0 and 1) or (x >= a and 0) or (-1 / (a ^ a) * (x ^ a) + 1)
    end
}

local STOP_DISTANCE = 50
local update_delay = 0

local smooth_time_left = {}
local smooth_time_left_size = 512

local function coords(vec)
    return string.format("%d %d", vec.x, vec.z)
end

local function smooth_time_left_add(value)
    table.insert(smooth_time_left, value)
    if #smooth_time_left > smooth_time_left_size then
        table.remove(smooth_time_left, 1)
    end
end

local function smooth_time_left_get()
    if #smooth_time_left == 0 then
        return 0
    end

    local sum = 0
    local total = 0

    for i = 1, #smooth_time_left do
        if smooth_time_left[i] > 0.1 and smooth_time_left[i] < 10000 then
            sum = sum + smooth_time_left[i]
            total = total + 1
        end
    end
    if total == 0 then
        return 0
    end
    return sum / total
end

local target = vec3.from(0, 150, 0)

-- prompt for target
print("Enter target position")
print("x:")
target.x = tonumber(io.read())
print("z:")
target.z = tonumber(io.read())

local arrived = false
local lastTime = os.clock()
local startAt = os.clock()

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

repeat
    local currentTime = os.clock()
    local deltaTime = currentTime - lastTime
    lastTime = currentTime

    term.clear()
    term.setCursorPos(1, 1)

    local pos = physic.get_position()
    target = vec3.from(target.x, pos.y, target.z)
    local distance = vec3.distance(pos, target)

    print("Position: " .. coords(pos))
    print("Target: " .. coords(target))
    print("")
    print("Speed: " .. round(physic.get_velocity().length() * 3.6, 2) .. " km/h") 
    print("Distance: " .. math.floor(distance))

    screen.clear()
    screen.write("Position: " .. coords(pos), 1, 1)
    screen.write("Target: " .. coords(target), 1, 2)
    screen.write("Distance: " .. math.floor(distance), 1, 4)
    screen.write("Speed: " .. round(physic.get_velocity().length() * 3.6, 2) .. " km/h", 1, 5)

    if distance > STOP_DISTANCE then

        local time_left = physic.get_time_left(target)
        smooth_time_left_add(time_left)
        time_left = smooth_time_left_get()

        if time_left > 0 then
            local hours = math.floor(time_left / 3600)
            local minutes = math.floor((time_left - hours * 3600) / 60)
            local seconds = time_left - hours * 3600 - minutes * 60
    
            print(string.format("Time left: %02d:%02d:%02d", hours, minutes, seconds))
            screen.write(string.format("Time left: %02d:%02d:%02d", hours, minutes, seconds), 1, 6)
        else 
            print("Time left: N/A")
            screen.write("Time left: N/A", 1, 6)
        end

        local time_elapsed = currentTime - startAt
        local hours = math.floor(time_elapsed / 3600)
        local minutes = math.floor((time_elapsed - hours * 3600) / 60)
        local seconds = time_elapsed - hours * 3600 - minutes * 60

        print(string.format("Time elapsed: %02d:%02d:%02d", hours, minutes, seconds))
        screen.write(string.format("Time elapsed: %02d:%02d:%02d", hours, minutes, seconds), 1, 7)
        
        local has_good_angular_speed = physic.get_angular_velocity().length() > constants_rotation.speed
        local look_target = physic.looking_angle_at(target).to_euler().length();
        local look_correctly = look_target < constants_position.min_angular_speed
        
        local limitation = constants_position.speed_limit(look_target, constants_position.min_angular_speed)
        local has_good_velocity_speed = physic.get_velocity().length() > constants_position.speed * limitation

        if not has_good_angular_speed then
            physic.look_at(target, deltaTime * constants_rotation.acceleration)
        end

        if not has_good_velocity_speed and look_correctly then
            physic.move_forward(deltaTime * constants_position.acceleration * limitation)
        end
    else
        arrived = true
    end

    sleep(update_delay)
until arrived


print("Arrived")
screen.write("Arrived", 1, 8)



