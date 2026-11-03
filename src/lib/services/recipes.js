
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
