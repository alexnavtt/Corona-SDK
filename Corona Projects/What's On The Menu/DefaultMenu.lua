local defaultMenu = {}

defaultMenu["Classic Waffle"] = 
{
ingredients = {
	{name = "Flour", amount = 1, unit = "cup", text_amount = "1"},
	{name = "Sugar", amount = 1, unit = "tbsp", text_amount = "1"},
	{name = "Baking Powder", amount = 2, unit = "tbsp", text_amount = "2"},
	{name = "Salt", amount = 0.25, unit = "tps", text_amount = "1/4"},
	{name = "Eggs", amount = 1, unit = "count", text_amount = "1"},
	{name = "Milk", amount = 1, unit = "cup", text_amount = "1"},
	{name = "Melted Butter/Vegetable Oil", amount = 2, unit = "tbsp", text_amount = "2"}},

steps = {"Sift together flour, sugar, baking powder, and salt",
		 "Whisk egg, milk, and melted butter in a separate bowl",
		 "Add wet ingredients to dry and mix",
		 "Cook in waffle maker until golden brown"},

prep_time = "5 min",
cook_time = "15 min"
}

defaultMenu["Banana Bread"] = 
{
ingredients = {
	{name = "Flour", amount = 2, unit = "cup", text_amount = "2"},
	{name = "Baking Soda", amount = 1, unit = "tsp", text_amount = "1"},
	{name = "Salt", amount = 0.25, unit = "tsp", text_amount = "1/4"},
	{name = "Butter", amount = 0.5, unit = "cup", text_amount = "1/2"},
	{name = "Brown Sugar", amount = 0.75, unit = "cup", text_amount = "3/4"},
	{name = "Eggs", amount = 2, unit = "count", text_amount = "2"},
	{name = "Overripe Bananas", amount = 2.333333, unit = "cup", text_amount = "2 1/3"}},

steps = {"Preheat oven to 350 degrees F (175 degrees C). Lightly grease a 9x5 inch loaf pan",
		 "In a large bowl, combine flour, baking soda and salt. In a separate bowl, cream together butter and brown sugar. Stir in eggs and mashed bananas until well blended. Stir banana mixture into flour mixture; stir just to moisten. Pour batter into prepared loaf pan",
		 "Bake in preheated oven for 60 to 65 minutes, until a toothpick inserted into center of the loaf comes out clean. Let bread cool in pan for 10 minutes, then turn out onto a wire rack"},

prep_time = "10 min",
cook_time = "65 min"
}

defaultMenu["Hot Chocolate"] = 
{
ingredients = {
	{name = "Milk", amount = 4, unit = "cup", text_amount = "4"},
	{name = "Unsweetened Cocoa", amount = 0.25, unit = "cup", text_amount = "1/4"},
	{name = "Granulated Sugar", amount = 0.25, unit = "cup", text_amount = "1/4"},
	{name = "Semisweet Chocolate Chips", amount = 0.5, unit = "cup", text_amount = "1/2"},
	{name = "Vanilla Extract", amount = 0.25, unit = "tsp", text_amount = "1/4"}},

steps = {"Place milk, cocoa powder and sugar in a small saucepan. Heat over medium/medium-low heat, whisking frequently, until warm (but not boiling)",
		 "Add chocolate chips and whisk constantly until the chocolate chips melt and distribute evenly into the milk",
		 "Whisk in vanilla extract, serve immediately"},

prep_time = "1 min",
cook_time = "10 min"
}

return defaultMenu