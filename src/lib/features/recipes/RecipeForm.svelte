<script>
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { supabase } from '#lib/supabase.js';
	import { session } from '#lib/state/session.svelte.js';
	import { createRecipe } from '#lib/services/recipes.js';
	import IngredientRow from './IngredientRow.svelte';

	let { recipe = null } = $props();

	let isEditing = $derived(recipe !== null);

	function newIngredient() {
		return {
			id: crypto.randomUUID(),
			name: '',
			quantity: undefined,
			unitId: '',
			preparation: ''
		};
	}

	let form = $state({
		title: '',
		description: '',
		yieldDescription: '',
		instructions: '',
		notes: '',
		sourceUrl: '',
		ingredients: [newIngredient()]
	});

	let units = $state([]);
	let loading = $state(true);
	let saving = $state(false);
	let errorMessage = $state('');

	function addIngredient() {
		form.ingredients.push(newIngredient());
	}

	function removeIngredient(id) {
		form.ingredients = form.ingredients.filter((ingredient) => ingredient.id !== id);
	}

	function updateIngredient(updatedIngredient) {
		form.ingredients = form.ingredients.map((ingredient) =>
			ingredient.id === updatedIngredient.id ? updatedIngredient : ingredient
		);
	}

	onMount(async () => {
		// Initialize editable state from the loaded recipe once.
		// Later prop changes will not overwrite unsaved edits.
		if (recipe) {
			form = {
				title: recipe.title ?? '',
				description: recipe.description ?? '',
				yieldDescription: recipe.yield_description ?? '',
				instructions: recipe.instructions ?? '',
				notes: recipe.notes ?? '',
				sourceUrl: recipe.source_url ?? '',
				ingredients: recipe.recipe_ingredients.map((ingredient) => ({
					id: ingredient.id,
					name: ingredient.ingredient_text,
					quantity: ingredient.quantity ?? undefined,
					unitId: ingredient.unit_id ?? '',
					preparation: ingredient.preparation ?? ''
				}))
			};
		}

		const { data, error } = await supabase
			.from('measurement_units')
			.select('id, name, abbreviation, dimension')
			.order('name');

		if (error) {
			errorMessage = error.message;
		} else {
			units = data;
		}

		loading = false;
	});

	async function handleSubmit(event) {
		event.preventDefault();
		errorMessage = '';

		if (isEditing) {
			errorMessage = 'Saving recipe edits is not implemented yet.';
			return;
		}

		if (!session.household) {
			errorMessage = 'No household is available.';
			return;
		}

		if (form.ingredients.length === 0) {
			errorMessage = 'Add at least one ingredient.';
			return;
		}

		const eachUnit = units.find((unit) => unit.name === 'each');

		const preparedIngredients = form.ingredients.map((ingredient) => ({
			name: ingredient.name.trim(),
			quantity: ingredient.quantity,
			unitId: ingredient.quantity && !ingredient.unitId ? eachUnit?.id : ingredient.unitId,
			preparation: ingredient.preparation.trim()
		}));

		saving = true;

		try {
			await createRecipe(session.household.id, {
				title: form.title,
				description: form.description,
				yieldDescription: form.yieldDescription,
				instructions: form.instructions,
				notes: form.notes,
				sourceUrl: form.sourceUrl,
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
	<h2>{isEditing ? 'Edit Recipe' : 'New Recipe'}</h2>

	<label>
		Recipe title
		<input bind:value={form.title} required placeholder="e.g. Chicken Parmesan" />
	</label>

	<label>
		Description
		<textarea bind:value={form.description} rows="2"></textarea>
	</label>

	<label>
		Yield
		<input bind:value={form.yieldDescription} placeholder="e.g. 4 servings" />
	</label>

	<label>
		Source URL
		<input type="url" bind:value={form.sourceUrl} placeholder="https://..." />
	</label>

	<fieldset>
		<legend>Ingredients</legend>

		{#each form.ingredients as ingredient (ingredient.id)}
			<IngredientRow
				{ingredient}
				{units}
				onUpdate={updateIngredient}
				onRemove={() => removeIngredient(ingredient.id)}
			/>
		{/each}

		<button type="button" onclick={addIngredient}> + Add ingredient </button>
	</fieldset>

	<label>
		Instructions
		<textarea bind:value={form.instructions} rows="8"></textarea>
	</label>

	<label>
		Notes
		<textarea bind:value={form.notes} rows="3"></textarea>
	</label>

	{#if errorMessage}
		<p role="alert">{errorMessage}</p>
	{/if}

	<button type="submit" disabled={saving || loading || isEditing}>
		{saving ? 'Saving...' : isEditing ? 'Save changes' : 'Save recipe'}
	</button>

	{#if isEditing}
		<p class="form-notice">
			Recipe editing will be available once the database update operation is implemented.
		</p>
	{/if}
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

	.form-notice {
		color: var(--color-text-muted);
		font-size: 0.875rem;
	}
</style>
