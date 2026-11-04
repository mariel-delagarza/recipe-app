import { browser } from '$app/environment';
import { session, initializeSession } from '#lib/state/session.svelte.js';
import { getRecipe } from '#lib/services/recipes.js';

export async function load({ params }) {
    if (!browser) {
        return { recipe: null };
    }

    await initializeSession();

    if (!session.household) {
        throw new Error('No household is available.');
    }

    const recipe = await getRecipe(params.id, session.household.id);

    return { recipe };
}