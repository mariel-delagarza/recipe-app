
<script>
    import { resolve } from '$app/paths';

    let { recipes = [] } = $props();
</script>

<section class="recipe-list">
    <div class="section-heading">
        <div class="heading-text">
            <span class="eyebrow">YOUR COLLECTION</span>
            <h2>Saved Recipes</h2>
        </div>

        <span class="recipe-count">
            {recipes.length} {recipes.length === 1 ? 'recipe' : 'recipes'}
        </span>
    </div>

    {#if recipes.length === 0}
        <div class="empty-state">
            <p>No recipes saved yet.</p>
            <p>Start collecting the dishes you love to make.</p>
        </div>
    {:else}
        <div class="recipe-grid">
            {#each recipes as recipe (recipe.id)}
                <a
                    class="recipe"
                    href={resolve('/recipes/[id]', { id: recipe.id })}
                >
                    <div class="recipe-content">
                        <h3>{recipe.title}</h3>

                        {#if recipe.description}
                            <p class="recipe-description">
                                {recipe.description}
                            </p>
                        {/if}

                        {#if recipe.yield_description}
                            <span class="recipe-yield">
                                {recipe.yield_description}
                            </span>
                        {/if}
                    </div>

                    <span class="recipe-arrow" aria-hidden="true">→</span>
                </a>
            {/each}
        </div>
    {/if}
</section>

<style>
    .recipe-list {
        margin-top: var(--space-7);
    }

    .section-heading {
        display: flex;
        flex-wrap: wrap;
        align-items: end;
        justify-content: space-between;
        gap: var(--space-3);
        margin-bottom: var(--space-5);
        padding-bottom: var(--space-4);
        border-bottom: 1px solid var(--color-border);
    }

    .heading-text {
        display: flex;
        flex-direction: column;
        gap: var(--space-2);
    }

    .eyebrow {
        color: var(--color-olive);
        font-family: var(--font-body);
        font-size: 0.6875rem;
        font-weight: 600;
        letter-spacing: 0.12em;
    }

    .section-heading h2 {
        margin: 0;
        font-size: clamp(1.5rem, 4vw, 2rem);
    }

    .recipe-count {
        color: var(--color-text-muted);
        font-size: 0.8125rem;
        white-space: nowrap;
    }

    .recipe-grid {
        display: grid;
        grid-template-columns: minmax(0, 1fr);
        gap: var(--space-3);
    }

    .recipe {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: var(--space-4);
        min-width: 0;
        min-height: 110px;
        padding: var(--space-5);
        border: 1px solid var(--color-border);
        border-radius: var(--radius-md);
        background: var(--color-surface);
        color: var(--color-text);
        text-decoration: none;
        transition:
            border-color 150ms ease,
            background-color 150ms ease;
    }

    .recipe:hover {
        border-color: var(--color-clay);
        background: #fffaf3;
        color: var(--color-text);
    }

    .recipe:focus-visible {
        outline: 2px solid var(--color-olive);
        outline-offset: 3px;
    }

    .recipe-content {
        min-width: 0;
    }

    .recipe h3 {
        margin: 0;
        font-size: clamp(1.25rem, 3vw, 1.5rem);
        line-height: 1.25;
    }

    .recipe-description {
        margin: var(--space-2) 0 0;
        color: var(--color-text-muted);
        font-size: 0.9375rem;
        line-height: 1.5;
    }

    .recipe-yield {
        display: inline-block;
        margin-top: var(--space-3);
        color: var(--color-olive);
        font-size: 0.8125rem;
        font-weight: 600;
    }

    .recipe-arrow {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        width: 32px;
        height: 32px;
        border: 1px solid var(--color-border);
        border-radius: 50%;
        color: var(--color-burgundy);
        font-size: 1.125rem;
        transition:
            background-color 150ms ease,
            color 150ms ease;
    }

    .recipe:hover .recipe-arrow {
        background: var(--color-burgundy);
        color: white;
    }

    .empty-state {
        padding: var(--space-7) var(--space-5);
        border: 1px dashed var(--color-border);
        border-radius: var(--radius-md);
        text-align: center;
        background: var(--color-surface);
    }

    .empty-state p {
        margin: 0;
    }

    .empty-state p + p {
        margin-top: var(--space-2);
        color: var(--color-text-muted);
        font-size: 0.875rem;
    }

    @media (min-width: 700px) {
        .recipe-grid {
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: var(--space-4);
        }

        .recipe {
            min-height: 140px;
        }
    }
</style>
