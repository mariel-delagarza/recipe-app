import { browser } from '$app/environment';
import { session, initializeSession } from '#lib/state/session.svelte.js';
import { getRecipes } from '#lib/services/recipes.js';

export async function load() {
    if (!browser) {
        return { recipes: [] };
    }

    await initializeSession();

    if (!session.household) {
        throw new Error('No household is available.');
    }

    const recipes = await getRecipes(session.household.id);

    return { recipes };
}