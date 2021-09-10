local function newDotSwitch(x, y, r, options)
    options = options or {}
    local dotColor = options.dotColor or {0.5}

    local dotSwitch = display.newGroup()
    dotSwitch.x = x
    dotSwitch.y = y
    dotSwitch.anchorChildren = true
    dotSwitch.state = false

    local switch = display.newCircle(dotSwitch,0,0,r)
    switch.strokeWidth = 2
    switch:setStrokeColor(0.8)

    local dot = display.newCircle(dotSwitch,0,0,0.8*r)
    dot.isVisible = false
    dot.isHitTestable = true
    dot:setFillColor(unpack(dotColor))

    function dotSwitch:tap(event)
        dot.isVisible = not dot.isVisible
        dotSwitch.state = not dotSwitch.state
        return true
    end
    dotSwitch:addEventListener("tap", dotSwitch)

    return dotSwitch
end

return newDotSwitch
