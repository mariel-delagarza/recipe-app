<script>
	import { onMount } from 'svelte';
	import { resolve } from '$app/paths';
	import { session } from '#lib/state/session.svelte.js';
	import { getRecipes } from '#lib/services/recipes.js';
	import RecipeList from '#lib/features/recipes/RecipeList.svelte';

	let recipes = $state([]);
	let loading = $state(true);
	let errorMessage = $state('');

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

<main>
	<h1>Recipes</h1>

	{#if loading}
		<p>Loading recipes...</p>
	{:else if errorMessage}
		<p role="alert">{errorMessage}</p>
	{:else}
		<a href={resolve('/recipes/new')}>+ Add Recipe</a>
		<RecipeList {recipes} />
	{/if}
</main>
