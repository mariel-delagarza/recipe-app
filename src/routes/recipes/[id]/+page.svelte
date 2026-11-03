
<script>
    import { onMount } from 'svelte';
    import { page } from '$app/state';
    import { resolve } from '$app/paths';

    import { session } from '#lib/state/session.svelte.js';
    import { getRecipe } from '#lib/services/recipes.js';
    import RecipeDetail from '#lib/features/recipes/RecipeDetail.svelte';

    let recipe = $state(null);
    let loading = $state(true);
    let errorMessage = $state('');

    onMount(async () => {
        try {
            recipe = await getRecipe(
                page.params.id,
                session.household.id
            );
        } catch (error) {
            errorMessage = error.message;
        } finally {
            loading = false;
        }
    });
</script>

<main>
    <nav>
        <a href={resolve('/recipes')}>Back to recipes</a>
    </nav>

    {#if loading}
        <p>Loading recipe...</p>
    {:else if errorMessage}
        <p role="alert">{errorMessage}</p>
    {:else if recipe}
        <RecipeDetail {recipe} />
    {/if}
</main>
