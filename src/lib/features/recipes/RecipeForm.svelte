<script>
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { supabase } from '#lib/supabase.js';
	import { session } from '#lib/state/session.svelte.js';
	import { createRecipe } from '#lib/services/recipes.js';
	import IngredientRow from './IngredientRow.svelte';

	let title = $state('');
	let description = $state('');
	let yieldDescription = $state('');
	let instructions = $state('');
	let notes = $state('');
	let sourceUrl = $state('');

	let units = $state([]);
	let ingredients = $state([newIngredient()]);

	let saving = $state(false);
	let errorMessage = $state('');

	function newIngredient() {
		return {
			id: crypto.randomUUID(),
			name: '',
			quantity: undefined,
			unitId: '',
			preparation: ''
		};
	}

	function addIngredient() {
		ingredients.push(newIngredient());
	}

	function removeIngredient(id) {
		ingredients = ingredients.filter((ingredient) => ingredient.id !== id);
	}

	onMount(async () => {
		const { data, error } = await supabase
			.from('measurement_units')
			.select('id, name, abbreviation, dimension')
			.order('name');

		if (error) {
			errorMessage = error.message;
			return;
		}

		units = data;
	});

	async function handleSubmit(event) {
		event.preventDefault();
		errorMessage = '';

		if (!session.household) {
			errorMessage = 'No household is available.';
			return;
		}

		if (ingredients.length === 0) {
			errorMessage = 'Add at least one ingredient.';
			return;
		}

		const eachUnit = units.find((unit) => unit.name === 'each');

		const preparedIngredients = ingredients.map((ingredient) => ({
			name: ingredient.name.trim(),
			quantity: ingredient.quantity,
			unitId: ingredient.quantity && !ingredient.unitId ? eachUnit?.id : ingredient.unitId,
			preparation: ingredient.preparation.trim()
		}));

		saving = true;

		try {
			await createRecipe(session.household.id, {
				title,
				description,
				yieldDescription,
				instructions,
				notes,
				sourceUrl,
				ingredients: preparedIngredients
			});

			await goto(resolve('/recipes'));
		} catch (error) {
			errorMessage = error.message;
		} finally {
			saving = false;
		}
	}
</script>

<form onsubmit={handleSubmit}>
	<h2>New Recipe</h2>

	<label>
		Recipe title
		<input bind:value={title} required placeholder="e.g. Chicken Parmesan" />
	</label>

	<label>
		Description
		<textarea bind:value={description} rows="2"></textarea>
	</label>

	<label>
		Yield
		<input bind:value={yieldDescription} placeholder="e.g. 4 servings" />
	</label>

	<label>
		Source URL
		<input type="url" bind:value={sourceUrl} placeholder="https://..." />
	</label>

	<fieldset>
		<legend>Ingredients</legend>

		{#each ingredients as ingredient (ingredient.id)}
			<IngredientRow {ingredient} {units} onRemove={() => removeIngredient(ingredient.id)} />
		{/each}

		<button type="button" onclick={addIngredient}> + Add ingredient </button>
	</fieldset>

	<label>
		Instructions
		<textarea bind:value={instructions} rows="8"></textarea>
	</label>

	<label>
		Notes
		<textarea bind:value={notes} rows="3"></textarea>
	</label>

	{#if errorMessage}
		<p role="alert">{errorMessage}</p>
	{/if}

	<button type="submit" disabled={saving}>
		{saving ? 'Saving...' : 'Save Recipe'}
	</button>
</form>

<style>
	form {
		display: grid;
		gap: 1.5rem;
		max-width: 850px;
	}

	label {
		display: grid;
		gap: 0.35rem;
	}

	input,
	textarea {
		width: 100%;
		box-sizing: border-box;
	}

	fieldset {
		border: 1px solid #d8c9c1;
		border-radius: 0.5rem;
		padding: 1rem;
	}
</style>
