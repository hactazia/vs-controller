local angle = {}
angle.deg = {}
angle.rad = {}

function angle.deg.to_rad(deg)
    return angle.rad.normalize(deg * math.pi / 180)
end

function angle.rad.to_deg(rad)
    return angle.deg.normalize(rad * 180 / math.pi)
end

function angle.deg.normalize(deg)
    return deg % 360
end

function angle.rad.normalize(rad)
    return rad % (2 * math.pi)
end

return angle
