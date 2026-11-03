<script>
	let { recipe } = $props();

	function formatQuantity(quantity) {
		if (quantity == null) return '';

		return Number(quantity).toLocaleString('en-US', {
			maximumFractionDigits: 3
		});
	}
</script>

<article class="recipe-detail">
	<header>
		<h1>{recipe.title}</h1>

		{#if recipe.description}
			<p class="description">{recipe.description}</p>
		{/if}

		{#if recipe.yield_description}
			<p class="yield">Makes {recipe.yield_description}</p>
		{/if}
	</header>

	<section>
		<h2>Ingredients</h2>

		<ul class="ingredients">
			{#each recipe.recipe_ingredients as ingredient (ingredient.id)}
				<li>
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

					<span>{ingredient.ingredient_text}</span>

					{#if ingredient.preparation}
						<span class="preparation">
							, {ingredient.preparation}
						</span>
					{/if}
				</li>
			{/each}
		</ul>
	</section>

	{#if recipe.instructions}
		<section>
			<h2>Instructions</h2>
			<div class="instructions">{recipe.instructions}</div>
		</section>
	{/if}

	{#if recipe.notes}
		<section>
			<h2>Notes</h2>
			<p class="notes">{recipe.notes}</p>
		</section>
	{/if}

	{#if recipe.source_url}
		<footer>
			<!-- eslint-disable-next-line svelte/no-navigation-without-resolve -->
			<a href={recipe.source_url} target="_blank" rel="noopener noreferrer"> Original recipe </a>
		</footer>
	{/if}
</article>

<style>
	.recipe-detail {
		max-width: 760px;
		display: grid;
		gap: 2rem;
	}

	header h1 {
		margin-bottom: 0.5rem;
	}

	.description {
		color: #655b56;
	}

	.yield {
		font-weight: 600;
	}

	.ingredients {
		display: grid;
		gap: 0.75rem;
		padding-left: 1.5rem;
	}

	.quantity,
	.unit {
		font-weight: 600;
	}

	.instructions {
		white-space: pre-line;
		line-height: 1.7;
	}

	.notes {
		white-space: pre-line;
	}

	a {
		color: #722f42;
	}
</style>
