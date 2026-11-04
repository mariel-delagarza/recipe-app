<script>
	import { onMount } from 'svelte';
	import { page } from '$app/state';
	import { session } from '#lib/state/session.svelte.js';
	import { getRecipe } from '#lib/services/recipes.js';
	import RecipeForm from '#lib/features/recipes/RecipeForm.svelte';

	let recipe = $state(null);
	let loading = $state(true);
	let errorMessage = $state('');

	onMount(async () => {
		try {
			if (!session.household) {
				throw new Error('No household is available.');
			}

			recipe = await getRecipe(page.params.id, session.household.id);
		} catch (error) {
			errorMessage = error.message;
		} finally {
			loading = false;
		}
	});
</script>

{#if loading}
	<p>Loading recipe...</p>
{:else if errorMessage}
	<p role="alert">{errorMessage}</p>
{:else if recipe}
	<RecipeForm {recipe} />
{/if}
