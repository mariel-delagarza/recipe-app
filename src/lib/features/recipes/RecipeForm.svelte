<script>
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { supabase } from '#lib/supabase.js';
	import { parseQuantity, displayQuantity } from '#lib/utils/quantities.js';
	import { session } from '#lib/state/session.svelte.js';
	import { createRecipe, updateRecipe } from '#lib/services/recipes.js';
	import IngredientRow from './IngredientRow.svelte';
	import BackLink from '../components/BackLink.svelte';

	let { recipe = null } = $props();

	let isEditing = $derived(recipe !== null);

	function newIngredient() {
		return {
			id: crypto.randomUUID(),
			name: '',
			quantityDisplay: '',
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
					quantityDisplay: displayQuantity(ingredient.quantity, ingredient.quantity_display),
					unitId: ingredient.measurement_units?.id ?? '',
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

		if (!session.household) {
			errorMessage = 'No household is available.';
			return;
		}

		if (form.ingredients.length === 0) {
			errorMessage = 'Add at least one ingredient.';
			return;
		}

		const eachUnit = units.find((unit) => unit.name === 'each');

		const preparedIngredients = form.ingredients.map((ingredient) => {
			const quantityDisplay = ingredient.quantityDisplay.trim();
			const quantity = parseQuantity(quantityDisplay);

			return {
				name: ingredient.name.trim(),
				quantity,
				quantityDisplay: quantityDisplay || null,
				unitId: quantity != null && !ingredient.unitId ? eachUnit?.id : ingredient.unitId,
				preparation: ingredient.preparation.trim()
			};
		});

		// Reject invalid quantities before saving.
		const invalidIndex = preparedIngredients.findIndex(
			(ingredient) => ingredient.quantityDisplay && ingredient.quantity === null
		);

		if (invalidIndex !== -1) {
			errorMessage = `Ingredient ${invalidIndex + 1} has an invalid quantity. Use a number or fraction like 1/2 or 1 1/2.`;
			return;
		}

		const recipeData = {
			title: form.title,
			description: form.description,
			yieldDescription: form.yieldDescription,
			instructions: form.instructions,
			notes: form.notes,
			sourceUrl: form.sourceUrl,
			ingredients: preparedIngredients
		};

		saving = true;

		try {
			let recipeId;

			if (isEditing) {
				recipeId = recipe.id;
				await updateRecipe(recipeId, recipeData);
			} else {
				recipeId = await createRecipe(session.household.id, recipeData);
			}

			await goto(resolve('/recipes/[id]', { id: recipeId }));
		} catch (error) {
			errorMessage = error.message;
		} finally {
			saving = false;
		}
	}
</script>

<form class="recipe-form" onsubmit={handleSubmit}>
	<header class="form-header">
		<BackLink href="/recipes" />
		<h1>{isEditing ? 'Edit Recipe' : 'New Recipe'}</h1>
	</header>

	<section class="form-section recipe-basics" aria-label="Recipe details">
		<label>
			Recipe title
			<input bind:value={form.title} required placeholder="e.g. Chicken Parmesan" />
		</label>

		<label>
			Description
			<textarea
				bind:value={form.description}
				rows="2"
				placeholder="A little about this recipe (optional)"></textarea>
		</label>

		<div class="details-grid">
			<label>
				Yield
				<input bind:value={form.yieldDescription} placeholder="e.g. 4 servings" />
			</label>

			<label>
				Source URL
				<input
					type="url"
					bind:value={form.sourceUrl}
					placeholder="https://..."
					class="source-url-input"
				/>
			</label>
		</div>
	</section>

	<section class="form-section ingredients-section">
		<h2>Ingredients</h2>

		<div class="ingredient-list">
			{#each form.ingredients as ingredient, index (ingredient.id)}
				<IngredientRow
					{ingredient}
					{units}
					number={index + 1}
					onUpdate={updateIngredient}
					onRemove={() => removeIngredient(ingredient.id)}
				/>
			{/each}
		</div>

		<button class="add-ingredient" type="button" onclick={addIngredient}>
			<span aria-hidden="true">+</span>
			Add ingredient
		</button>
	</section>

	<section class="form-section method-section">
		<h2>Instructions</h2>

		<label>
			<p class="field-hint">Write each step as a separate paragraph.</p>
			<textarea
				bind:value={form.instructions}
				rows="6"
				placeholder="Describe how to make this recipe..."></textarea>
		</label>
	</section>

	<section class="form-section notes-section">
		<h2>Notes</h2>
		<p class="field-hint">Substitutions, adjustments, or anything worth remembering.</p>
		<label>
			<textarea bind:value={form.notes} rows="4" placeholder="Optional notes..."></textarea>
		</label>
	</section>

	{#if errorMessage}
		<p class="form-error" role="alert">{errorMessage}</p>
	{/if}

	<div class="form-actions">
		<button class="save-button" type="submit" disabled={saving || loading}>
			{saving ? 'Saving...' : isEditing ? 'Save changes' : 'Save recipe'}
		</button>
	</div>
</form>

<style>
	.recipe-form {
		display: flex;
		flex-direction: column;
		gap: var(--space-5);
		max-width: 760px;
		padding-bottom: var(--space-4);
	}

	.form-header {
		display: flex;
		flex-direction: column;
		gap: var(--space-4);
	}

	.form-header + .recipe-basics {
		margin-top: calc(-1 * var(--space-3));
	}

	h1,
	h2 {
		font-family: var(--font-display);
		font-weight: 400;
		color: var(--color-text);
		line-height: 1.2;
	}

	h1 {
		margin: 0;
		font-size: clamp(2.25rem, 7vw, 3rem);
		letter-spacing: -0.035em;
	}

	h2 {
		margin: 0;
		font-size: clamp(1.6rem, 5vw, 1.85rem);
		letter-spacing: -0.025em;
	}

	.form-section {
		display: flex;
		flex-direction: column;
		gap: var(--space-4);
		min-width: 0;
	}

	.form-section + .form-section {
		border-top: 1px solid var(--color-border);
		padding-top: var(--space-5);
	}

	.recipe-basics {
		gap: var(--space-4);
	}

	label {
		display: flex;
		flex-direction: column;
		gap: var(--space-2);
		min-width: 0;
		font-size: var(--font-size-label);
		font-weight: 600;
		color: var(--color-text);
	}

	input,
	textarea {
		display: block;
		width: 100%;
		min-width: 0;
		box-sizing: border-box;
		border: 1px solid var(--color-border);
		border-radius: var(--radius-md);
		padding: 0.875rem 1rem;
		background: var(--color-surface);
		color: var(--color-text);
		font-family: var(--font-body);
		font-size: var(--font-size-body);
		font-weight: 400;
		line-height: 1.5;
	}

	input {
		min-height: var(--control-height);
	}

	textarea {
		resize: vertical;
	}

	input::placeholder,
	textarea::placeholder {
		color: var(--color-text-muted);
		opacity: 0.75;
	}

	input:focus-visible,
	textarea:focus-visible {
		outline: 2px solid var(--color-olive);
		outline-offset: 2px;
	}

	.source-url-input {
		text-overflow: ellipsis;
	}

	.details-grid {
		display: grid;
		grid-template-columns: repeat(2, minmax(0, 1fr));
		gap: var(--space-3);
	}

	.ingredient-list {
		display: flex;
		flex-direction: column;
	}

	.add-ingredient {
		display: flex;
		align-items: center;
		justify-content: center;
		gap: var(--space-2);
		width: 100%;
		min-height: var(--control-height);
		padding: var(--space-3);
		border: 1px dashed #c9b4b9;
		border-radius: var(--radius-md);
		background: transparent;
		color: var(--color-burgundy);
		font-family: var(--font-body);
		font-size: var(--font-size-body);
		font-weight: 600;
		cursor: pointer;
	}

	.add-ingredient:hover {
		background: var(--color-surface-muted);
	}

	.add-ingredient span {
		font-size: 1.4rem;
		line-height: 1;
		font-weight: 400;
	}

	.field-hint {
		font-size: var(--font-size-small);
		font-weight: 400;
		color: var(--color-text-muted);
	}

	.form-error {
		margin: 0;
		color: var(--color-error);
		font-size: var(--font-size-small);
	}

	.form-actions {
		display: flex;
		flex-direction: column;
		gap: var(--space-3);
	}

	.save-button {
		width: 100%;
		min-height: 56px;
		padding: var(--space-3) var(--space-5);
		border: 1px solid var(--color-burgundy);
		border-radius: var(--radius-md);
		background: var(--color-burgundy);
		color: #fffdf9;
		font-family: var(--font-body);
		font-size: var(--font-size-body);
		font-weight: 600;
		cursor: pointer;
	}

	.save-button:hover:not(:disabled) {
		background: var(--color-burgundy-dark);
	}

	.save-button:disabled {
		opacity: 0.55;
		cursor: not-allowed;
	}

	@media (min-width: 700px) {
		.save-button {
			width: auto;
			min-width: 200px;
			align-self: flex-start;
		}
	}
</style>
