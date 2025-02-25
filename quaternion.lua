local vec3 = require("vector3")

local quaternion = {}

function quaternion.from(x, y, z, w)
    local q = {
		type = "quaternion",
    	x = x or 0, 
    	y = y or 0, 
    	z = z or 0, 
    	w = w or 1
  	}

   	function q.to_string()
		return quaternion.to_string(q)
  	end

   	function q.to_euler()
		return quaternion.to_euler(q)
  	end

	function q.normalize()
		return quaternion.normalize(q)
	end

	function q.inverse()
		return quaternion.inverse(q)
	end

  	return q
end

quaternion.identity = quaternion.from(0, 0, 0, 1)

function quaternion.from_table(t)
  return quaternion.from(t.x, t.y, t.z, t.w)
end

function quaternion.from_list(l)
  return quaternion.from(l[1], l[2], l[3], l[4])
end

function quaternion.from_euler(vec)
	local halfY = vec.y * 0.5
	local halfX = vec.x * 0.5
	local halfZ = vec.z * 0.5

  	local cy, sy = math.cos(halfY), math.sin(halfY)
  	local cx, sx = math.cos(halfX), math.sin(halfX)
  	local cz, sz = math.cos(halfZ), math.sin(halfZ)

  	-- Rotation order Y -> X -> Z
  	local w = cy * cx * cz + sy * sx * sz
  	local x = cy * sx * cz + sy * cx * sz
  	local y = sy * cx * cz - cy * sx * sz
 	local z = cy * cx * sz - sy * sx * cz

  	return quaternion.from(x, y, z, w)
end

function quaternion.to_euler(q)
  local x = math.atan2(2 * (q.w * q.x + q.y * q.z), 1 - 2 * (q.x * q.x + q.y * q.y))
  local y = math.asin(2 * (q.w * q.y - q.z * q.x))
  local z = math.atan2(2 * (q.w * q.z + q.x * q.y), 1 - 2 * (q.y * q.y + q.z * q.z))

  return vec3.from(x, y, z)
end

function quaternion.to_string(q)
  return string.format("quaternion(%f, %f, %f, %f)", q.x, q.y, q.z, q.w)
end

function quaternion.look_rotation(forward, up)
	-- Default up vector
	up = up or vec3.up

  	-- Normalize forward and compute a right vector from up and forward
  	local f = forward.normalize()
  	local r = vec3.cross(up, f).normalize()
  	local u = vec3.cross(f, r)

  	-- Calculate quaternion from the basis vectors
  	local trace = r.x + u.y + f.z
  	local w, x, y, z

  	if trace > 0 then
    	local s = 0.5 / math.sqrt(trace + 1.0)
    	w = 0.25 / s
    	x = (u.z - f.y) * s
    	y = (f.x - r.z) * s
    	z = (r.y - u.x) * s
  	else 
		if r.x > u.y and r.x > f.z then
      		local s = 2.0 * math.sqrt(1.0 + r.x - u.y - f.z)
      		w = (u.z - f.y) / s
      		x = 0.25 * s
      		y = (r.y + u.x) / s
      		z = (r.z + f.x) / s
    	elseif u.y > f.z then
      		local s = 2.0 * math.sqrt(1.0 + u.y - r.x - f.z)
      		w = (f.x - r.z) / s
      		x = (r.y + u.x) / s
      		y = 0.25 * s
      		z = (u.z + f.y) / s
    	else
      		local s = 2.0 * math.sqrt(1.0 + f.z - r.x - u.y)
      		w = (r.y - u.x) / s
      		x = (r.z + f.x) / s
      		y = (u.z + f.y) / s
      		z = 0.25 * s
    	end
  	end

  	-- Use the existing 'from' constructor to return a quaternion table
  	return quaternion.from(x, y, z, w)
end

function quaternion.slerp(q1, q2, t)
  local dot = q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w

  if dot < 0 then
    q2 = quaternion.from(-q2.x, -q2.y, -q2.z, -q2.w)
    dot = -dot
  end

  if dot > 0.9995 then
    return quaternion.lerp(q1, q2, t)
  end

  local theta_0 = math.acos(dot)
  local theta = theta_0 * t

  local q3 = quaternion.from(
    q2.x - q1.x * dot,
    q2.y - q1.y * dot,
    q2.z - q1.z * dot,
    q2.w - q1.w * dot
  ).normalize()

  return quaternion.from(
    q1.x * math.cos(theta) + q3.x * math.sin(theta),
    q1.y * math.cos(theta) + q3.y * math.sin(theta),
    q1.z * math.cos(theta) + q3.z * math.sin(theta),
    q1.w * math.cos(theta) + q3.w * math.sin(theta)
  )
end

function quaternion.lerp(q1, q2, t)
  return quaternion.from(
    q1.x * (1 - t) + q2.x * t,
    q1.y * (1 - t) + q2.y * t,
    q1.z * (1 - t) + q2.z * t,
    q1.w * (1 - t) + q2.w * t
  ).normalize()
end

function quaternion.normalize(q)
  local mag = math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w)
  return quaternion.from(q.x / mag, q.y / mag, q.z / mag, q.w / mag)
end

function quaternion.inverse(q)
  return quaternion.from(-q.x, -q.y, -q.z, q.w)
end

function quaternion.mul(q1, q2)
  local x = q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y
  local y = q1.w * q2.y - q1.x * q2.z + q1.y * q2.w + q1.z * q2.x
  local z = q1.w * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.w
  local w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z

  return quaternion.from(x, y, z, w)
end

return quaternion