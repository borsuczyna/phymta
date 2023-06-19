local box = Box(Vector3(-2417.99609, -609.40497, 132.5625), Vector3(1, 1, 1))

addEventHandler('onClientRender', root, function()
    box:renderDebug()
end)

addEventHandler('onClientPreRender', root, function(dt)
    box:update(dt)
end)

bindKey('b', 'down', function()
    local matrix = getElementMatrix(getCamera())
    box.position = Vector3(getElementPosition(getCamera())) + Vector3(matrix[2][1], matrix[2][2], matrix[2][3]) * 5
    box.rotation = Vector3(getElementRotation(getCamera()))
    box.velocity = Vector3(matrix[2][1], matrix[2][2], matrix[2][3]) * 10
    box.isStill = false
end)