function generateMatrix(x, y, z, rX, rY, rZ)
    x = tonumber(x); y = tonumber(y); z = tonumber(z); rX = tonumber(rX); rY = tonumber(rY); rZ = tonumber(rZ);
    rX = math.pi * rX / 180; rY = math.pi * rY / 180; rZ = math.pi * rZ / 180;

    return {
        {
            math.cos(rZ) * math.cos(rY) - math.sin(rZ) * math.sin(rX) * math.sin(rY),
            math.cos(rY) * math.sin(rZ) + math.cos(rZ) * math.sin(rX) * math.sin(rY),
            -math.cos(rX) * math.sin(rY),
            0
        },
        {
            -math.cos(rX) * math.sin(rZ),
            math.cos(rZ) * math.cos(rX),
            math.sin(rX),
            0
        },
        {
            math.cos(rZ) * math.sin(rY) + math.cos(rY) * math.sin(rZ) * math.sin(rX),
            math.sin(rZ) * math.sin(rY) - math.cos(rZ) * math.cos(rY) * math.sin(rX),
            math.cos(rX) * math.cos(rY),
            0
        },
        {
            x, y, z, 1
        }
    }
end