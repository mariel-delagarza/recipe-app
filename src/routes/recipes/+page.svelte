
<script>
    import { onMount } from 'svelte';
    import { resolve } from '$app/paths';
    import { session } from '#lib/state/session.svelte.js';
    import { getRecipes } from '#lib/services/recipes.js';
    import RecipeList from '#lib/features/recipes/RecipeList.svelte';

    let recipes = $state([]);
    let loading = $state(true);
    let errorMessage = $state('');
    let searchQuery = $state('');

    let filteredRecipes = $derived(
        recipes.filter((recipe) => {
            const query = searchQuery.trim().toLowerCase();

            return (
                recipe.title?.toLowerCase().includes(query) ||
                recipe.description?.toLowerCase().includes(query)
            );
        })
    );

    onMount(async () => {
        try {
            recipes = await getRecipes(session.household.id);
        } catch (error) {
            errorMessage = error.message;
        } finally {
            loading = false;
        }
    });
</script>

<div class="recipes-page">
    <header class="page-header">
        <h1>Recipes</h1>

        <a class="btn btn-primary add-recipe" href={resolve('/recipes/new')}>
            <span aria-hidden="true">+</span>
            Add recipe
        </a>
    </header>

    {#if loading}
        <p class="status-message">Loading recipes...</p>
    {:else if errorMessage}
        <p class="error-message" role="alert">{errorMessage}</p>
    {:else}
        <div class="search-field">
            <svg
                aria-hidden="true"
                width="20"
                height="20"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
            >
                <circle cx="11" cy="11" r="8" />
                <path d="m21 21-4.35-4.35" />
            </svg>

            <input
                type="search"
                aria-label="Search recipes"
                placeholder="Search recipes..."
                bind:value={searchQuery}
            />
        </div>

        <p class="recipe-count">
            {#if searchQuery.trim()}
                {filteredRecipes.length} of {recipes.length} recipes
            {:else}
                {recipes.length} {recipes.length === 1 ? 'recipe' : 'recipes'}
            {/if}
        </p>

        {#if searchQuery.trim() && filteredRecipes.length === 0}
            <div class="no-results">
                <p>No recipes match "{searchQuery}".</p>
            </div>
        {:else}
            <RecipeList recipes={filteredRecipes} />
        {/if}
    {/if}
</div>

<style>
    .recipes-page {
        display: flex;
        flex-direction: column;
        gap: var(--space-4);
    }

    .page-header {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        justify-content: space-between;
        gap: var(--space-4);
        margin-bottom: var(--space-2);
    }

    .page-header h1 {
        margin: 0;
    }

    .add-recipe {
        flex-shrink: 0;
        white-space: nowrap;
    }

    .add-recipe span {
        font-size: 1.25rem;
        font-weight: 400;
        line-height: 1;
    }

    .search-field {
        position: relative;
        display: flex;
        align-items: center;
        color: var(--color-olive);
    }

    .search-field svg {
        position: absolute;
        left: var(--space-4);
        pointer-events: none;
    }

    .search-field input {
        width: 100%;
        min-height: 52px;
        padding-left: 3rem;
        border-radius: var(--radius-md);
        background: var(--color-surface);
        font-size: 1rem;
    }

    .search-field input::-webkit-search-cancel-button {
        cursor: pointer;
    }

    .recipe-count {
        margin: 0;
        color: var(--color-text-muted);
        font-size: 0.875rem;
    }

    .status-message {
        color: var(--color-text-muted);
    }

    .error-message {
        color: var(--color-error);
    }

    .no-results {
        padding: var(--space-7) var(--space-4);
        border: 1px dashed var(--color-border);
        border-radius: var(--radius-md);
        text-align: center;
    }

    .no-results p {
        margin: 0;
        color: var(--color-text-muted);
    }

    @media (max-width: 480px) {
        .page-header h1 {
            font-size: 2.5rem;
        }

        .add-recipe {
            padding: 0.75rem 1rem;
            font-size: 0.875rem;
        }
    }
</style>
