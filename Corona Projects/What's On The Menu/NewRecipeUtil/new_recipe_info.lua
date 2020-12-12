local recipe_info = {}

-- These variables help to move things between pages
recipe_info.newRecipeTitle = "Untitled Recipe"
recipe_info.newRecipeIngredientList = {}
recipe_info.newRecipeSteps = {}
recipe_info.newRecipeKeywords = {}
recipe_info.newRecipeParams = {}

-- Keeps track of whether the new recipe page is being backed out of or proceeded in to
recipe_info.is_editing = false

return recipe_info
