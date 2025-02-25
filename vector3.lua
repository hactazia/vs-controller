local vec3 = {}

function vec3.from(x, y, z)
    local v = {
        type = "vector3",
        x = x or 0, 
        y = y or 0,
        z = z or 0
    }

    function v.to_string()
        return vec3.to_string(v)
    end

    function v.length()
        return vec3.length(v)
    end

    function v.normalize()
        return vec3.normalize(v)
    end

    function v.inverse()
        return vec3.inverse(v)
    end

    return v
end

vec3.up = vec3.from(0, 1, 0)
vec3.down = vec3.from(0, -1, 0)
vec3.left = vec3.from(-1, 0, 0)
vec3.right = vec3.from(1, 0, 0)
vec3.forward = vec3.from(0, 0, 1)
vec3.back = vec3.from(0, 0, -1)
vec3.zero = vec3.from(0, 0, 0)

function vec3.from_table(t)
  return vec3.from(t.x, t.y, t.z)
end

function vec3.from_list(l)
  return vec3.from(l[1], l[2], l[3])
end

function vec3.to_string(v)
    return string.format("vector3(%f, %f, %f)", v.x, v.y, v.z)
end

function vec3.add(a, b)
    return vec3.from(a.x + b.x, a.y + b.y, a.z + b.z)
end

function vec3.sub(a, b)
    return vec3.from(a.x - b.x, a.y - b.y, a.z - b.z)
end

function vec3.mul(a, b)
    return vec3.from(a.x * b.x, a.y * b.y, a.z * b.z)
end

function vec3.div(a, b)
    return vec3.from(a.x / b.x, a.y / b.y, a.z / b.z)
end

function vec3.scale(a, s)
    return vec3.from(a.x * s, a.y * s, a.z * s)
end

function vec3.dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

function vec3.cross(a, b)
    return vec3.from(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
end

function vec3.length(a)
    return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

function vec3.normalize(a)
    local l = a.length()
    return vec3.from(a.x / l, a.y / l, a.z / l)
end

function vec3.distance(a, b)
    return vec3.sub(a, b).length()
end

function vec3.inverse(a)
    return vec3.from(-a.x, -a.y, -a.z)
end

return vec3