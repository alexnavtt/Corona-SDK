local measurements = {}

-- Density is measured in gram/Cup
measurements.densities  =  {["flour"]			= 120,
							["baking powder"] 	= 12,
							["baking soda"] 	= 2*48*3,
							["bread crumbs"] 	= 4*28,
							["brown sugar"]		= 213,
							["butter"] 			= 2*113,
							["buttermilk"] 		= 227,
							["parmesan cheese"] = 2*50,
							["chocolate chips"] = 170,
							["cinnamon sugar"] 	= 4*50,
							["coconut oil"] 	= 2*113,
							["cornmeal"] 		= 150,
							["cornstarch"] 		= 4*28,
							["cream"] 			= 227,
							["heavy whipping cream"] = 227,
							["light cream"] 	= 227,
							["half and half"] 	= 227,
							["cream cheese"] 	= 227,
							["eggs"]			= 220,
							["garlic"] 			= 8*28,
							["granola"] 		= 113,
							["honey"] 			= 16*21,
							["lard"]			= 2*113,
							["marshmallow"] 	= 43,
							["mashed potato"] 	= 213,
							["mayonnaise"]		= 2*113,
							["mayo"] 			= 2*113,
							["milk"] 			= 227,
							["olive oil"] 		= 200,
							["olives"] 			= 142,
							["onions"]			= 142,
							["peanut butter"] 	= 2*135,
							["pumpkin"] 		= 227,
							["raisins"] 		= 149,
							["rice"] 			= 198,
							["salt"] 			= 16*18,
							["sour cream"] 		= 227,
							["sugar"] 			= 198,
							["vanilla extract"] = 16*14,
							["vegetable oil"] 	= 198,
							["water"] 			= 227,
							["yeast"] 			= (1/2.25)*48*7}

measurements.essential_units = {"cup", "tsp", "tbsp", "fl oz", "ml", "g", "oz", "lb", "count"}

measurements.volumes =  {cup 	= true,
					 tsp 	= true,
					 tbsp 	= true,
				 ["fl oz"]  = true,
					 ml 	= true,
					 l 		= true,
					 pint 	= true,
					 quart 	= true,
					 gallon = true,
					 dash 	= true,
					 pinch 	= true}

measurements.masses =  {g  = true,
					oz = true,
					kg = true,
					lb = true}

measurements.convertFromCup  = {cup 	= 1,
					   		tsp 	= 48,
					   		tbsp 	= 16,
						["fl oz"] 	= 8,
							ml 		= 236.6,
							l 		= 0.2366,
							pint 	= 0.5,
							quart  	= 0.25,
							gallon 	= 0.0625,
							dash 	= 385,	
							pinch	= 768}

measurements.convertFromGram = {g 	= 1,
					   		kg 	= 0.001,
					   		oz 	= 1/28.35,
					   		lb  = 0.0022}

return measurements
