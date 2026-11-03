<script>
	import { resolve } from '$app/paths';

	let { recipes = [] } = $props();
</script>

<section class="recipe-list">
	{#if recipes.length === 0}
		<div class="empty-state">
			<p>No recipes saved yet.</p>
			<p>Start collecting the dishes you love to make.</p>
		</div>
	{:else}
		<div class="recipe-grid">
			{#each recipes as recipe (recipe.id)}
				<a class="recipe" href={resolve('/recipes/[id]', { id: recipe.id })}>
					<div class="recipe-content">
						<h3>{recipe.title}</h3>

						{#if recipe.description}
							<p class="recipe-description">
								{recipe.description}
							</p>
						{/if}

						{#if recipe.yield_description}
							<span class="recipe-yield">
								<span class="yield-label">Yield:</span>
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
		display: inline-flex;
		flex-wrap: wrap;
		gap: 0.35rem;
		margin-top: var(--space-3);
		color: var(--color-text-muted);
		font-size: 0.875rem;
		font-weight: 400;
	}

	.yield-label {
		color: var(--color-olive);
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
