import { supabase } from '#lib/supabase.js';

export async function getRecipes(householdId) {
	const { data, error } = await supabase
		.from('recipes')
		.select('id, title, description, yield_description, updated_at')
		.eq('household_id', householdId)
		.order('title', { ascending: true });

	if (error) {
		throw error;
	}

	return data;
}

export async function createRecipe(householdId, recipe) {
	const { data, error } = await supabase.rpc('create_recipe', {
		p_household_id: householdId,
		p_title: recipe.title,
		p_description: recipe.description || null,
		p_yield_description: recipe.yieldDescription || null,
		p_instructions: recipe.instructions || '',
		p_notes: recipe.notes || null,
		p_source_url: recipe.sourceUrl || null,
    p_cooking_methods: recipe.cookingMethods ?? [],
		p_ingredients: recipe.ingredients.map((ingredient) => ({
			name: ingredient.name,
			quantity: ingredient.quantity ?? null,
			quantity_display: ingredient.quantityDisplay ?? null,
      is_optional: ingredient.isOptional ?? false,
			unit_id: ingredient.unitId || null,
			preparation: ingredient.preparation || null
		}))
	});

	if (error) {
		throw error;
	}

	return data;
}

export async function getRecipe(recipeId, householdId) {
	const { data, error } = await supabase
		.from('recipes')
		.select(
			`
            id,
            title,
            description,
            yield_description,
            instructions,
            notes,
            source_url,
            cooking_methods,
            recipe_ingredients (
                id,
                ingredient_text,
                quantity,
                quantity_display,
                is_optional,
                preparation,
                sort_order,
                measurement_units (
                    id,
                    name,
                    abbreviation,
                    dimension
                )
            )
        `
		)
		.eq('id', recipeId)
		.eq('household_id', householdId)
		.single();

	if (error) {
		throw error;
	}

	return {
		...data,
		recipe_ingredients: [...data.recipe_ingredients].sort((a, b) => a.sort_order - b.sort_order)
	};
}

export async function updateRecipe(recipeId, recipe) {
	const { data, error } = await supabase.rpc('update_recipe', {
		p_recipe_id: recipeId,
		p_title: recipe.title,
		p_description: recipe.description || null,
		p_yield_description: recipe.yieldDescription || null,
		p_instructions: recipe.instructions || '',
		p_notes: recipe.notes || null,
		p_source_url: recipe.sourceUrl || null,
    p_cooking_methods: recipe.cookingMethods ?? [],
		p_ingredients: recipe.ingredients.map((ingredient) => ({
			name: ingredient.name,
			quantity: ingredient.quantity ?? null,
			quantity_display: ingredient.quantityDisplay ?? null,
      is_optional: ingredient.isOptional ?? false,
			unit_id: ingredient.unitId || null,
			preparation: ingredient.preparation || null
		}))
	});

	if (error) {
		throw error;
	}

	return data;
}

export async function deleteRecipe(recipeId, householdId) {
	const { data, error } = await supabase
		.from('recipes')
		.delete()
		.eq('id', recipeId)
		.eq('household_id', householdId)
		.select('id')
		.single();

	if (error) throw error;

	return data;
}
