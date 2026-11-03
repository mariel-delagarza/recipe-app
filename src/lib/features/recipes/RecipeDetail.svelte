<script>
	import { resolve } from '$app/paths';
	let { recipe } = $props();

	function formatQuantity(quantity) {
		if (quantity == null) return '';

		return Number(quantity).toLocaleString('en-US', {
			maximumFractionDigits: 3
		});
	}

	let instructionSteps = $derived(
		(recipe.instructions ?? '')
			.split(/\n\s*\n/)
			.map((step) => step.trim())
			.filter(Boolean)
	);
</script>

<article class="recipe-detail">
	<nav class="recipe-actions" aria-label="Recipe navigation">
		<a href={resolve('/recipes')} class="back-link">
			<svg
				width="16"
				height="16"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="2"
				stroke-linecap="round"
				stroke-linejoin="round"
				aria-hidden="true"
			>
				<path d="m12 19-7-7 7-7" />
				<path d="M19 12H5" />
			</svg>
			All recipes
		</a>
	</nav>
	<header class="recipe-header">
		<h1>{recipe.title}</h1>

		{#if recipe.description}
			<p class="description">{recipe.description}</p>
		{/if}

		{#if recipe.yield_description}
			<p class="yield">
				<span class="yield-label">Yield:</span>
				{recipe.yield_description}
			</p>
		{/if}
	</header>

	<section class="recipe-section">
		<h2>Ingredients</h2>

		<ul class="ingredients">
			{#each recipe.recipe_ingredients as ingredient (ingredient.id)}
				<li>
					<span class="ingredient-marker" aria-hidden="true"></span>

					<span class="ingredient-content">
						{#if ingredient.quantity != null}
							<span class="quantity">
								{formatQuantity(ingredient.quantity)}
							</span>
						{/if}

						{#if ingredient.measurement_units?.dimension !== 'count'}
							<span class="unit">
								{ingredient.measurement_units?.abbreviation}
							</span>
						{/if}

						<span class="ingredient-name">
							{ingredient.ingredient_text}
						</span>

						{#if ingredient.preparation}
							<span class="preparation">, {ingredient.preparation}</span>
						{/if}
					</span>
				</li>
			{/each}
		</ul>
	</section>

	{#if instructionSteps.length > 0}
		<section class="recipe-section">
			<h2>Instructions</h2>

			<ol class="instruction-list">
				{#each instructionSteps as step, index (index)}
					<li>
						<span class="step-number" aria-hidden="true">
							{index + 1}
						</span>

						<p class="step-text">{step}</p>
					</li>
				{/each}
			</ol>
		</section>
	{/if}

	{#if recipe.notes}
		<section class="recipe-section">
			<div class="section-heading">
				<h2>Notes</h2>
			</div>

			<p class="notes">{recipe.notes}</p>
		</section>
	{/if}

	{#if recipe.source_url}
		<footer class="recipe-footer">
			<!-- eslint-disable svelte/no-navigation-without-resolve -->
			<a href={recipe.source_url} target="_blank" rel="noopener noreferrer">
				View original recipe
				<span aria-hidden="true">↗</span>
			</a>
			<!-- eslint-enable svelte/no-navigation-without-resolve -->
		</footer>
	{/if}
</article>

<style>
	.recipe-detail {
		display: flex;
		flex-direction: column;
		gap: var(--space-5);
		width: 100%;
		max-width: 760px;
	}

	/* Navigation */

	.recipe-actions {
		display: flex;
		align-items: center;
		justify-content: space-between;
	}

	.back-link {
		display: inline-flex;
		align-items: center;
		gap: var(--space-2);
		color: var(--color-burgundy);
		font-size: 1rem;
		font-weight: 600;
		text-decoration: none;
	}

	.back-link:hover {
		text-decoration: underline;
	}

	/* Recipe header */

	.recipe-header {
		display: flex;
		flex-direction: column;
		align-items: flex-start;
		gap: var(--space-2);
	}

	.recipe-header h1 {
		margin: 0;
		font-family: var(--font-display);
		font-size: clamp(1.75rem, 5vw, 2.5rem);
		font-weight: 700;
		line-height: 1.2;
		letter-spacing: -0.025em;
		color: var(--color-text);
		overflow-wrap: break-word;
	}

	.description {
		margin: 0;
		color: var(--color-text-muted);
		font-size: 0.9375rem;
		line-height: 1.65;
	}

	.yield {
		display: flex;
		align-items: baseline;
		gap: var(--space-2);
		margin: 0;
		color: var(--color-text-muted);
		font-size: 1rem;
	}

	.yield-label {
		color: var(--color-olive);
		font-size: 0.75rem;
		font-weight: 700;
		letter-spacing: 0.1em;
		text-transform: uppercase;
	}

	/* Sections */

	.recipe-section {
		display: flex;
		flex-direction: column;
		gap: var(--space-4);
		padding-top: var(--space-5);
		border-top: 1px solid var(--color-border);
	}

	.recipe-section h2 {
		margin: 0;
		font-family: var(--font-display);
		font-size: 1.75rem;
		font-weight: 400;
		line-height: 1.3;
		color: var(--color-text);
	}

	/* Ingredients */

	.ingredients {
		display: flex;
		flex-direction: column;
		gap: var(--space-2);
		margin: 0;
		padding: 0;
		list-style: none;
	}

	.ingredients li {
		display: flex;
		align-items: baseline;
		gap: var(--space-3);
		padding: var(--space-2) 0;
		font-size: 1.125rem; /* 18px */
		line-height: 1.7;
	}

	.ingredient-marker {
		flex-shrink: 0;
		width: 6px;
		height: 6px;
		margin-top: 0.55em;
		border-radius: 50%;
		background: var(--color-olive);
	}

	.ingredient-content {
		flex: 1;
		min-width: 0;
	}

	.quantity,
	.unit {
		font-weight: 600;
		color: var(--color-text);
	}

	.ingredient-name {
		color: var(--color-text);
	}

	.preparation {
		color: var(--color-text-muted);
		font-style: italic;
	}

	/* Instructions */

	.instruction-list {
		display: flex;
		flex-direction: column;
		gap: var(--space-5);
		margin: 0;
		padding: 0;
		list-style: none;
	}

	.instruction-list li {
		display: flex;
		align-items: flex-start;
		gap: var(--space-3);
	}

	.step-number {
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		width: 38px;
		height: 38px;
		border-radius: 50%;
		background: var(--color-sage);
		color: var(--color-olive);
		font-size: 1rem;
		font-weight: 600;
	}

	.step-text {
		flex: 1;
		min-width: 0;
		margin: 0;
		padding-top: 2px;
		white-space: pre-line;
		font-size: 1.1875rem; /* 19px */
		line-height: 1.7;
		color: var(--color-text);
	}

	/* Notes */

	.notes {
		margin: 0;
		padding: var(--space-4);
		border-left: 3px solid var(--color-olive);
		background: var(--color-sage);
		border-radius: 0 var(--radius-sm) var(--radius-sm) 0;
		white-space: pre-line;
		font-size: 0.875rem;
		line-height: 1.75;
		color: var(--color-text);
	}

	/* Source */

	.recipe-footer {
		padding-top: var(--space-4);
		border-top: 1px solid var(--color-border);
	}

	.recipe-footer a {
		display: inline-flex;
		align-items: center;
		gap: var(--space-2);
		color: var(--color-burgundy);
		font-size: 0.875rem;
		font-weight: 600;
		text-decoration: none;
	}

	.recipe-footer a:hover {
		text-decoration: underline;
	}

	/* Desktop */

	@media (min-width: 700px) {
		.recipe-detail {
			gap: var(--space-6);
		}

		.recipe-section {
			gap: var(--space-5);
		}
	}
</style>
