local params = {}

-- Default Parameters for Portrait Mode Recipe Viewing

-- Info Bar
params.info_bar_height = 0.05*display.contentHeight

-- Title Banner
params.title_banner_height = 0.10*display.contentHeight
params.title_banner_bottom = params.title_banner_height + params.info_bar_height

-- Scroll Views
params.v_spacing = 0.02*display.contentHeight -- vertical spacing
params.h_spacing = 0.02*display.contentWidth  -- horizontal spacing

params.scroll_view_top = params.title_banner_bottom + params.v_spacing/2
params.scroll_view_height = display.contentHeight - params.scroll_view_top - params.v_spacing/2

params.scroll_view_left_1 = params.h_spacing
params.scroll_view_width_1 = 0.45*display.contentWidth

params.scroll_view_left_2 = params.scroll_view_left_1 + params.scroll_view_width_1 + params.h_spacing
params.scroll_view_width_2 = display.contentWidth - params.scroll_view_width_1 - 3*params.h_spacing

-- Item Spacing
params.div_y  = 0.15*display.contentHeight
params.div_x1 = 0.30*display.contentWidth
params.div_x2 = params.div_x1 + 0.13*display.contentWidth

params.ingredient_level_delta = 0.1*display.contentHeight

params.step_level_delta = 0.015*display.contentHeight


-- Default Parameters for Landscape Mode Recipe Viewing
params.landscape = {}
local landscape = params.landscape

landscape.info_bar_height = 0.05*display.contentWidth
landscape.title_banner_height = 0.10*display.contentWidth

landscape.v_spacing = params.v_spacing

return params
