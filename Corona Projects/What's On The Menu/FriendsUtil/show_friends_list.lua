local app_network = require("lib.network.library")
local globalData  = require("globalData")
local widget      = require("widget")
local tinker      = require("Tinker")
local palette     = require("Palette")
local app_colors  = require("AppColours")

local cX = display.contentCenterX
local cY = globalData.centerScreen
local W  = display.contentWidth
local H  = display.contentHeight

local function showFriendsList(listener, canSelectMultiple)
    -- Default tap function does nothing
    listener = listener or function(event) return true end
    
    -- Create a group to be the entire object
    local group = display.newGroup()
    if canSelectMultiple then group.switches = {} end

    -- Create a panel to show all of the friends on
    local panel = display.newRoundedRect(group, cX, cY, 0.9*W, 0.9*(H - globalData.tab_bar.height), 0.05*W);

    -- Create a scroll view to store the friends
    local scroll_view = widget.newScrollView({x = cX, y = cY,
                                             width = panel.width, height = 0.85*panel.height,
                                             backgroundColor = {1},
                                             hideScrollBar = true,
                                             horizontalScrollDisabled = true});
    group:insert(scroll_view)

    local y_level = 0.05*scroll_view.height
    for _, name_info in pairs(app_network.friends) do
        -- Create a new horizontal space for each friend
        local strip = display.newRect(0.5*panel.width, y_level, W, 0.07*H)
        strip.name  = name_info.name
        strip.email = name_info.email
        strip.alpha = 0.01

        -- Create the text of the friend's name
        local option = display.newText({parent = group,      x = strip.x, width  = 0.9*panel.width, font     = native.systemFontBold,
                                        text   = strip.name, y = strip.y, height = 0,               fontSize = globalData.titleFontSize})
        option:setFillColor(0)

        -- Create a dividing line to look nice
        local div_line = display.newLine(-W, y_level + 0.5*strip.height, W, y_level + 0.5*strip.height)
        div_line.strokeWidth = 3
        div_line:setStrokeColor(0.8)
        
        scroll_view:insert(strip)
        scroll_view:insert(option)
        scroll_view:insert(div_line)
        
        -- If multi-select is enabled, add a switch to the friend label
        if canSelectMultiple then
            local switch = tinker.newDotSwitch(0.9*scroll_view.width, y_level, 0.2*strip.height, {dotColor = palette.green})
            group.switches[strip.email] = switch
            scroll_view:insert(switch)

            strip:addEventListener("tap", function(event) switch:dispatchEvent({name = "tap"}) end)
        else
            strip:addEventListener("tap", function(event) listener(strip.name, strip.email) end)
        end

        y_level = y_level + strip.height
    end

    -- Have an additional "submit" button if multiple can be selected
    if canSelectMultiple then
        local function onSubmit(event)
            listener(group.switches)
            group:removeSelf()
            group = nil
        end

        local submit_params = {label = "\n\nSubmit", color = palette.dark.blue, labelColor = {0.8}, tap_func = onSubmit, radius = 0.05*W}
        local submit_button = tinker.newButton(cX, panel.y + 0.4*panel.height, panel.width, 0.2*panel.height, submit_params)

        group:insert(submit_button)
        scroll_view:toFront()
    end

    return group
end

return showFriendsList
