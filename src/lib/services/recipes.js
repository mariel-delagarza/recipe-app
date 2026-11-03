
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
        p_ingredients: recipe.ingredients.map((ingredient) => ({
            name: ingredient.name,
            quantity: ingredient.quantity || null,
            unit_id: ingredient.unitId || null,
            preparation: ingredient.preparation || null
        }))
    });

    if (error) {
        throw error;
    }

    return data;
}
