Box = class()

local gravity = Vector3(0, 0, -9.81)
local posRotationChange = 0.2
local rotateObject01 = createObject(1337, 0, 0, 0, 0, 0, 0)
setElementCollisionsEnabled(rotateObject01, false)
setElementAlpha(rotateObject01, 0)

function Vector3:compare( comparison, precision )
	if not comparison or not type( comparison.getLength ) == 'function' then return false end

	if ( not precision ) then
		if ( self:getX( ) ~= comparison:getX( ) ) or
		   ( self:getY( ) ~= comparison:getY( ) ) or
		   ( self:getZ( ) ~= comparison:getZ( ) ) then
			return false
		end
	else
		if ( math.abs( self:getX( ) - comparison:getX( ) ) > precision ) or
		   ( math.abs( self:getY( ) - comparison:getY( ) ) > precision ) or
		   ( math.abs( self:getZ( ) - comparison:getZ( ) ) > precision ) then
			return false
		end
	end

	return true
end

--[[
    LineOutput {
        hit: boolean;
        position: Vector3;
        hitPosition?: Vector3;
        normal?: Vector3;
        element?: Element;
    }
]]

-- position: Vector3, size: Vector3, rotation?: Vector3
function Box:init(position, size, rotation)
	self.position = position
    self.size = size
    self.rotation = rotation or Vector3(0, 0, 0)
    self.velocity = Vector3(0, 0, 0)
    self.stillCount = 0
    self.isStill = false
    self.lastStill = {
        position = position,
        rotation = rotation,
        velocity = Vector3(0, 0, 0)
    }
end

Box:set({
    matrix = {
        get = function(self)
            local position = self.position
            local rotation = self.rotation

            return generateMatrix(position.x, position.y, position.z, rotation.x, rotation.y, rotation.z)
        end
    }
})

-- start: Vector3, target: Vector3, relative: Vector3 | : LineOutput
function Box:processLine(start, target, relative)
    local hit, hitX, hitY, hitZ, hitElement, normalX, normalY, normalZ, material, lighting, piece, worldModelID = processLineOfSight(start.x, start.y, start.z, target.x, target.y, target.z, true, true, true, true, false, false, false, false, undefined, true, false);
    if hit then
        return {
            hit = true,
            position = relative,
            hitPosition = Vector3(hitX, hitY, hitZ),
            normal = Vector3(normalX, normalY, normalZ),
            element = hitElement
        }
    end

    return {
        hit = false,
        position = relative
    }
end

-- x: Vector3 | number, y?: number, z?: number
function Box:rotate(x, y, z)
    local offset;

    if type(x) == 'number' then
        offset = Vector3(x, y, z)
    else
        offset = x
    end

    local rotateObject02 = createObject(1337, 0, 0, 0, 0, 0, 0)
    local rotation = self.rotation
    setElementRotation(rotateObject01, rotation.x, rotation.y, rotation.z)
    attachElements(rotateObject02, rotateObject01, 0, 0, 0, offset.x, offset.y, offset.z)
    local rx, ry, rz = getElementRotation(rotateObject02)
    destroyElement(rotateObject02)
    self.rotation = Vector3(rx, ry, rz)
end

-- x: Vector3 | number, y?: number, z?: number | : Vector3
function Box:getOffset(x, y, z, matrix)
    local offset;

    if type(x) == 'number' then
        offset = Vector3(x, y, z)
    else
        offset = x
    end

    local matrix = matrix or self.matrix
    x = matrix[1][1] * offset.x + matrix[2][1] * offset.y + matrix[3][1] * offset.z + matrix[4][1]
    y = matrix[1][2] * offset.x + matrix[2][2] * offset.y + matrix[3][2] * offset.z + matrix[4][2]
    z = matrix[1][3] * offset.x + matrix[2][3] * offset.y + matrix[3][3] * offset.z + matrix[4][3]

    return Vector3(x, y, z)
end

-- void
function Box:renderDebug()
    local center = self.position
    local matrix = self.matrix
    local right = self:getOffset(Vector3(1, 0, 0), matrix)
    local front = self:getOffset(Vector3(0, 1, 0), matrix)
    local up = self:getOffset(Vector3(0, 0, 1), matrix)

    dxDrawLine3D(center, right, 0xFFFF0000)
    dxDrawLine3D(center, front, 0xFF00FF00)
    dxDrawLine3D(center, up, 0xFF0000FF)
end

-- dt: number
function Box:update(dt)
    local dt = dt / 1000
    local rdt = dt * 100
    local matrix = self.matrix

    self.velocity = self.velocity + (gravity * dt)
    local size = self.size

    local bottomLeftDown = self:getOffset(Vector3(-size.x / 2, -size.y / 2, -size.z / 2), matrix)
    local bottomRightDown = self:getOffset(Vector3(size.x / 2, -size.y / 2, -size.z / 2), matrix)
    local bottomLeftUp = self:getOffset(Vector3(-size.x / 2, size.y / 2, -size.z / 2), matrix)
    local bottomRightUp = self:getOffset(Vector3(size.x / 2, size.y / 2, -size.z / 2), matrix)
    local topLeftDown = self:getOffset(Vector3(-size.x / 2, -size.y / 2, size.z / 2), matrix)
    local topRightDown = self:getOffset(Vector3(size.x / 2, -size.y / 2, size.z / 2), matrix)
    local topLeftUp = self:getOffset(Vector3(-size.x / 2, size.y / 2, size.z / 2), matrix)
    local topRightUp = self:getOffset(Vector3(size.x / 2, size.y / 2, size.z / 2), matrix)

    dxDrawLine3D(bottomLeftDown, bottomRightDown, 0xFFFF0000)
    dxDrawLine3D(bottomRightDown, bottomRightUp, 0xFFFF0000)
    dxDrawLine3D(bottomRightUp, bottomLeftUp, 0xFFFF0000)
    dxDrawLine3D(bottomLeftUp, bottomLeftDown, 0xFFFF0000)

    dxDrawLine3D(topLeftDown, topRightDown, 0xFFFF0000)
    dxDrawLine3D(topRightDown, topRightUp, 0xFFFF0000)
    dxDrawLine3D(topRightUp, topLeftUp, 0xFFFF0000)
    dxDrawLine3D(topLeftUp, topLeftDown, 0xFFFF0000)

    dxDrawLine3D(bottomLeftDown, topLeftDown, 0xFFFF0000)
    dxDrawLine3D(bottomRightDown, topRightDown, 0xFFFF0000)
    dxDrawLine3D(bottomRightUp, topRightUp, 0xFFFF0000)
    dxDrawLine3D(bottomLeftUp, topLeftUp, 0xFFFF0000)

    if not self.isStill then
        local velocity = self.velocity * dt
        local length = velocity:getLength()
        if length < 0.05 then
            velocity = velocity * (1 / length * 0.05)
        end

        local bottomLeftDownTarget = bottomLeftDown + velocity
        local bottomRightDownTarget = bottomRightDown + velocity
        local bottomLeftUpTarget = bottomLeftUp + velocity
        local bottomRightUpTarget = bottomRightUp + velocity
        local topLeftDownTarget = topLeftDown + velocity
        local topRightDownTarget = topRightDown + velocity
        local topLeftUpTarget = topLeftUp + velocity
        local topRightUpTarget = topRightUp + velocity

        local bottomLeftDownHit = self:processLine(bottomLeftDown, bottomLeftDownTarget, Vector3(-size.x / 2, -size.y / 2, -size.z / 2))
        local bottomRightDownHit = self:processLine(bottomRightDown, bottomRightDownTarget, Vector3(size.x / 2, -size.y / 2, -size.z / 2))
        local bottomLeftUpHit = self:processLine(bottomLeftUp, bottomLeftUpTarget, Vector3(-size.x / 2, size.y / 2, -size.z / 2))
        local bottomRightUpHit = self:processLine(bottomRightUp, bottomRightUpTarget, Vector3(size.x / 2, size.y / 2, -size.z / 2))
        local topLeftDownHit = self:processLine(topLeftDown, topLeftDownTarget, Vector3(-size.x / 2, -size.y / 2, size.z / 2))
        local topRightDownHit = self:processLine(topRightDown, topRightDownTarget, Vector3(size.x / 2, -size.y / 2, size.z / 2))
        local topLeftUpHit = self:processLine(topLeftUp, topLeftUpTarget, Vector3(-size.x / 2, size.y / 2, size.z / 2))
        local topRightUpHit = self:processLine(topRightUp, topRightUpTarget, Vector3(size.x / 2, size.y / 2, size.z / 2))

        dxDrawLine3D(bottomLeftDown, bottomLeftDownTarget, bottomLeftDownHit.hit and 0xFFFF0000 or 0xFF00FF00)
        dxDrawLine3D(bottomRightDown, bottomRightDownTarget, bottomRightDownHit.hit and 0xFFFF0000 or 0xFF00FF00)
        dxDrawLine3D(bottomLeftUp, bottomLeftUpTarget, bottomLeftUpHit.hit and 0xFFFF0000 or 0xFF00FF00)
        dxDrawLine3D(bottomRightUp, bottomRightUpTarget, bottomRightUpHit.hit and 0xFFFF0000 or 0xFF00FF00)
        dxDrawLine3D(topLeftDown, topLeftDownTarget, topLeftDownHit.hit and 0xFFFF0000 or 0xFF00FF00)
        dxDrawLine3D(topRightDown, topRightDownTarget, topRightDownHit.hit and 0xFFFF0000 or 0xFF00FF00)
        dxDrawLine3D(topLeftUp, topLeftUpTarget, topLeftUpHit.hit and 0xFFFF0000 or 0xFF00FF00)
        dxDrawLine3D(topRightUp, topRightUpTarget, topRightUpHit.hit and 0xFFFF0000 or 0xFF00FF00)

        local hit = {}
        for k,v in pairs({bottomLeftDownHit, bottomRightDownHit, bottomLeftUpHit, bottomRightUpHit, topLeftDownHit, topRightDownHit, topLeftUpHit, topRightUpHit}) do
            if v.hit then
                table.insert(hit, v)
            end
        end

        if #hit == 0 then
            self.position = self.position + velocity
        elseif #hit == 1 or #hit == 2 then
            local x, y, z;

            local xDot = math.abs(matrix[3][1])
            local yDot = math.abs(matrix[3][2])
            local zDot = math.abs(matrix[3][3])

            if #hit == 2 then
                local hitPosition1, hitPosition2 = hit[1].position, hit[2].position
                x, y, z = interpolateBetween(hitPosition1.x, hitPosition1.y, hitPosition1.z, hitPosition2.x, hitPosition2.y, hitPosition2.z, 0.5, 'Linear')
            else
                x, y, z = hit[1].position.x, hit[1].position.y, hit[1].position.z
            end

            local relative = Vector3(x, y, z)
            local zNormalized = relative.z > 0 and 1 or -1
            local yNormalized = relative.y > 0 and 1 or -1

            self:rotate(Vector3(relative.y, relative.x * zNormalized, 0) * (rdt * zDot))
            self:rotate(Vector3(relative.y, -relative.z, 0) * (rdt * xDot))
            self:rotate(Vector3(relative.z * yNormalized, 0, -relative.x * yNormalized) * (rdt * yDot))

            local sx, sy = getScreenFromWorldPosition(self:getOffset(relative, matrix))
            if sx and sy then
                dxDrawCircle(sx, sy, 10, 0, 360, 0xFFFF0000)
            end

            self.position.z = self.position.z + posRotationChange * dt

            local hitNormal = self:getOffset(relative, matrix) - self.position
            hitNormal:normalize()
            self.velocity = Vector3(
                self.velocity.x * (1 - math.abs(hitNormal.x)),
                self.velocity.y * (1 - math.abs(hitNormal.y)),
                self.velocity.z * (1 - math.abs(hitNormal.z))
            )
        else
            local hitNormal = self:getOffset(hit[1].position, matrix) - self.position
            hitNormal:normalize()
            self.velocity = Vector3(self.velocity.x * (1-math.abs(hitNormal.x)), self.velocity.y * (1-math.abs(hitNormal.y)), self.velocity.z * (1-math.abs(hitNormal.z)))
        end

        if self.position:compare(self.lastStill.position) and self.rotation:compare(self.lastStill.rotation) and self.velocity:compare(self.lastStill.velocity, 0.03) then
            self.stillCount = self.stillCount + 1
            if self.stillCount > 60 then
                self.isStill = true
            end
        else
            self.stillCount = 0
            self.isStill = false

            self.lastStill = {
                position = Vector3(self.position.x, self.position.y, self.position.z),
                rotation = Vector3(self.rotation.x, self.rotation.y, self.rotation.z),
                velocity = Vector3(self.velocity.x, self.velocity.y, self.velocity.z)
            }
        end
    end
end