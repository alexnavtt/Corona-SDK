P = {}

P.black 		= {0,0,0}
P.white 		= {1,1,1}
P.grey			= {0.5,0.5,0.5}

P.off_white 	= {1.00, 0.98, 0.94}

P.dark 			= {}
P.dark.blue 	= {0.0, 0.2, 0.4}
P.dark.red 		= {0.6, 0.1, 0.1}
P.dark.green 	= {0.1, 0.4, 0.1}
P.dark.purple 	= {0.3, 0.0, 0.3}
P.dark.pink 	= {0.5, 0.0, 0.3}
P.dark.orange 	= {255/255, 140/255, 000/255}
P.dark.grey 	= {0.3, 0.3, 0.3}
P.dark.wine 	= {0.24, 0.10, 0.11}
P.dark.violet 	= {0.31, 0.25, 0.38}

P.light 		= {}
P.light.grey 	= {0.80, 0.80, 0.80}
P.light.purple 	= {0.85, 0.75, 0.85}

P.purple 		= {0.60, 0.00, 0.60}
P.pink   		= {0.90, 0.00, 0.60}
P.blue   		= {0.00, 0.00, 0.80}
P.red 			= {0.90, 0.10, 0.10}
P.orange 		= {1.00, 0.65, 0.00}
P.green  		= {0.20, 0.80, 0.20}
P.brown  		= {0.40, 0.20, 0.00}

P.bright = {}
P.bright.red 	= {0.9, 0.0, 0.15}

P.pure 			= {}
P.pure.blue 	= {0,0,1}
P.pure.red  	= {1,0,0}
P.pure.green 	= {0,1,0}
P.pure.cyan 	= {0,1,1}
P.pure.yellow 	= {1,1,0}
P.pure.magenta 	= {1,0,1}

P.pastel = {}
P.pastel.red 	= {1.0, 0.6, 0.6}
P.pastel.green 	= {0.0, 1.0, 0.4}
P.pastel.blue 	= {0.6, 0.8, 0.9}
-- P.pastel.purple = 

-- ---------------------
-- Special Colours
-- ---------------------

-- Blue
P.sky_blue 	 	= {0.53, 0.81, 0.92}
P.steel_blue 	= {0.69, 0.77, 0.87}
P.midnight_blue	= {0.10, 0.10, 0.44}
P.white_blue	= {0.67, 0.85, 0.90}
P.dark_blue_2 	= {000/255, 000/255, 139/255}
P.teal 			= {0.37, 0.62, 0.63}
P.deep_sky_blue = {000/255, 191/255, 255/255}

-- Red
P.wine 		= {0.45, 0.18, 0.22}
P.maroon 	= {0.50, 0.00, 0.00}
P.crimson 	= {0.86, 0.08, 0.24}
P.salmon 	= {0.95, 0.50, 0.45}
P.tomato 	= {1.00, 0.39, 0.28}
P.grey_pink = {195/255, 144/255, 155/255}
P.burgundy	= {141/255, 2/255, 31/255}

-- Orange
P.light_bronze = {1.0, 0.64, 0.33}
P.orange_red   = {255/255, 69/255, 0/255}

-- Green
P.sea_green = {0.56, 0.74, 0.56}
P.light_sea_green = {32/255, 178/255, 70/255}

-- Yellow
P.mellow_yellow = {0.97, 0.87, 0.49}
P.cyber_yellow  = {255/255, 211/255, 0/255}

-- Purple
P.magenta = {0.55, 0.00, 0.55}

function P.darken(color, iter)
	local iter = iter or 1
	local color = {unpack(color)}

	for i = 1,#color,1 do
		-- color[i] = color[i]*(0.9^iter)
		color[i] = math.max(0,color[i] - 0.05*iter)
	end

	return color
end

function P.lighten(color, iter)
	local iter = iter or 1
	local color = {unpack(color)}

	for i = 1,#color,1 do
		-- color[i] = math.min(color[i]*(1.1^iter),1)
		color[i] = math.min(color[i]+0.05*iter,1)
	end

	return color
end

function P.mix(color1, color2, weight)
	local c1, c2
	weight = math.min(math.max(weight, 0), 1)

	if #color1 == 1 then
		local val = unpack(color1)
		c1 = {val, val, val}
	else
		c1 = {unpack(color1)}
	end

	if #color2 == 1 then
		local val = unpack(color2)
		c2 = {val, val, val}
	else
		c2 = {unpack(color2)}
	end

	local c3 = {0,0,0}

	for i = 1,3,1 do
		c3[i] = weight*c1[i] + (1-weight)*c2[i]
	end

	return c3
end

return P