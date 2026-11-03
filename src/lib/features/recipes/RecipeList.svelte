<script>
	import { resolve } from '$app/paths';
	let { recipes = [] } = $props();
</script>

<section class="recipe-list">
	<h2>Saved Recipes</h2>

	{#if recipes.length === 0}
		<p>No recipes saved yet.</p>
	{:else}
		{#each recipes as recipe (recipe.id)}
			<a class="recipe" href={resolve('/recipes/[id]', { id: recipe.id })}>
				<h3>{recipe.title}</h3>

				{#if recipe.description}
					<p>{recipe.description}</p>
				{/if}

				{#if recipe.yield_description}
					<small>{recipe.yield_description}</small>
				{/if}
			</a>
		{/each}
	{/if}
</section>

<style>
	.recipe-list {
		display: grid;
		gap: 1rem;
	}

	.recipe {
		padding: 1rem;
		border: 1px solid #d8c9c1;
		border-radius: 0.5rem;
		background: #fffaf4;

		display: block;
		color: inherit;
		text-decoration: none;
	}

	.recipe h3 {
		margin: 0 0 0.5rem;
	}
	.recipe:hover {
		border-color: #722f42;
	}
</style>
