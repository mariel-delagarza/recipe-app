<script>
	import { resolve } from '$app/paths';
	import { goto } from '$app/navigation';
	import { session } from '#lib/state/session.svelte.js';
	import { deleteRecipe } from '#lib/services/recipes.js';
	import { displayQuantity } from '#lib/utils/quantities.js';
	import BackLink from '../components/BackLink.svelte';

	let { recipe } = $props();

	let instructionSteps = $derived(
		(recipe.instructions ?? '')
			.split(/\n\s*\n/)
			.map((step) => step.trim())
			.filter(Boolean)
	);

	let deleting = $state(false);
	let deleteError = $state('');

	let deleteDialog;

	function handleDelete() {
		deleteDialog.showModal();
	}

	async function confirmDelete() {
		deleteError = '';

		if (!session.household) {
			deleteError = 'No household is available.';
			deleteDialog.close();
			return;
		}

		deleting = true;

		try {
			await deleteRecipe(recipe.id, session.household.id);
			deleteDialog.close();
			await goto(resolve('/recipes'));
		} catch (error) {
			deleteError = error.message;
			deleteDialog.close();
		} finally {
			deleting = false;
		}
	}
</script>

<article class="recipe-detail">
	<!-- Navigation -->
	<nav class="recipe-actions" aria-label="Recipe navigation">
		<BackLink href="/recipes" />

		<a class="edit-link" href={resolve('/recipes/[id]/edit', { id: recipe.id })}>
			<svg
				width="17"
				height="17"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="1.8"
				stroke-linecap="round"
				stroke-linejoin="round"
				aria-hidden="true"
			>
				<path d="M12 20h9" />
				<path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L9 17l-4 1 1-4Z" />
			</svg>

			Edit recipe
		</a>
	</nav>

	<!-- Recipe header -->
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
		{#if recipe.cooking_methods?.length}
			<div class="recipe-methods" aria-label="Cooking methods">
				{#each recipe.cooking_methods as method (method)}
					<span class="recipe-method">
						{method === 'Pressure cooker / Instant Pot' ? 'Pressure cooker' : method}
					</span>
				{/each}
			</div>
		{/if}
	</header>

	<!-- Shopping list action -->
	<div class="recipe-shopping-action">
		<button class="shopping-button" disabled>
			<svg
				width="20"
				height="20"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="1.8"
				stroke-linecap="round"
				stroke-linejoin="round"
				aria-hidden="true"
			>
				<path d="m3 9 2 11h14l2-11H3Z" />
				<path d="m9 9 3-6 3 6" />
				<path d="M9 13v4" />
				<path d="M15 13v4" />
			</svg>
			Add to shopping list
		</button>
	</div>

	<!-- Ingredients -->
	<section class="recipe-section">
		<h2>Ingredients</h2>

		<ul class="ingredients">
			{#each recipe.recipe_ingredients as ingredient (ingredient.id)}
				<li>
					<label class="ingredient-label">
						<input
							type="checkbox"
							class="ingredient-checkbox"
							aria-label={`Mark ${ingredient.ingredient_text} as used`}
						/>

						<span class="ingredient-content">
							{#if ingredient.quantity != null}
								<span class="quantity">
									{displayQuantity(ingredient.quantity, ingredient.quantity_display)}
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
								<span class="preparation">
									, {ingredient.preparation}
								</span>
							{/if}
							{#if ingredient.is_optional}
								<span class="optional-tag">Optional</span>
							{/if}
						</span>
					</label>
				</li>
			{/each}
		</ul>
	</section>

	<!-- Instructions -->
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

	<!-- Notes -->
	{#if recipe.notes}
		<section class="recipe-section">
			<h2>Notes</h2>
			<p class="notes">{recipe.notes}</p>
		</section>
	{/if}

	<!-- Original source -->
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
	<div class="delete-action">
		{#if deleteError}
			<p class="delete-error" role="alert">{deleteError}</p>
		{/if}

		<button type="button" class="delete-button" disabled={deleting} onclick={handleDelete}>
			Delete recipe
		</button>
	</div>

	<dialog
		bind:this={deleteDialog}
		class="delete-dialog"
		oncancel={(event) => {
			if (deleting) event.preventDefault();
		}}
	>
		<h2>Delete this recipe?</h2>

		<p>
			Are you sure you want to delete <strong>{recipe.title}</strong>? This cannot be undone.
		</p>

		<div class="dialog-actions">
			<button
				type="button"
				class="cancel-button"
				disabled={deleting}
				onclick={() => deleteDialog.close()}
			>
				Cancel
			</button>

			<button
				type="button"
				class="confirm-delete-button"
				disabled={deleting}
				onclick={confirmDelete}
			>
				{deleting ? 'Deleting...' : 'Delete recipe'}
			</button>
		</div>
	</dialog>
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

	.recipe-methods {
		display: flex;
		flex-wrap: wrap;
		gap: var(--space-2);
		margin-top: var(--space-1);
	}

	.recipe-method {
		display: inline-flex;
		align-items: center;
		padding: 0.3rem 0.75rem;
		border: none;
		border-radius: var(--radius-sm);
		background: var(--color-sage);
		color: var(--color-olive);
		font-size: 0.8125rem;
		font-weight: 500;
		line-height: 1.3;
	}

	/* Shopping list action */

	.recipe-shopping-action {
		display: flex;
	}

	.shopping-button {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		gap: var(--space-2);
		width: 100%;
		min-height: 44px;
		padding: var(--space-2) var(--space-4);
		border: none;
		border-radius: var(--radius-lg);
		background: #eeede5;
		color: var(--color-text-muted);
		font-family: var(--font-body);
		font-size: 0.9375rem;
		font-weight: 500;
		cursor: pointer;
	}

	.shopping-button:disabled {
		opacity: 1;
		cursor: not-allowed;
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
		padding: 0;
	}

	.ingredient-label {
		display: flex;
		align-items: center;
		gap: var(--space-3);
		width: 100%;
		min-height: 48px;
		padding: var(--space-2) 0;
		cursor: pointer;
		font-size: 1.125rem;
		line-height: 1.7;
	}

	.ingredient-checkbox {
		appearance: none;
		box-sizing: border-box;
		display: block;
		flex: 0 0 22px;
		width: 22px;
		height: 22px;
		min-width: 22px;
		min-height: 0;
		max-width: 22px;
		max-height: 22px;
		margin: 0;
		padding: 0;
		border: 1.5px solid var(--color-border);
		border-radius: var(--radius-sm);
		background: var(--color-surface);
		cursor: pointer;
	}

	.ingredient-checkbox:checked {
		background: var(--color-olive);
		border-color: var(--color-olive);
	}

	.ingredient-checkbox:checked::after {
		content: '✓';
		display: block;
		color: white;
		font-size: 16px;
		line-height: 19px;
		text-align: center;
	}

	.ingredient-checkbox:focus-visible {
		outline: 2px solid var(--color-burgundy);
		outline-offset: 3px;
	}

	.ingredient-content {
		flex: 1;
		min-width: 0;
	}

	.quantity {
		font-weight: 600;
		color: var(--color-text);
	}

	.unit {
		font-weight: 400;
		color: var(--color-text);
	}

	.ingredient-name {
		color: var(--color-text);
	}

	.preparation {
		color: var(--color-text-muted);
		font-style: italic;
	}

	.optional-tag {
		display: inline-block;
		margin-left: var(--space-2);
		padding: 0.125rem 0.5rem;
		border-radius: var(--radius-sm);
		background: var(--color-sage);
		color: var(--color-olive);
		font-size: 0.75rem;
		font-weight: 600;
		line-height: 1.5;
		vertical-align: middle;
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
		font-size: 1.1875rem;
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

	.edit-link {
		display: inline-flex;
		align-items: center;
		gap: var(--space-2);
		align-self: flex-start;
		color: var(--color-burgundy);
		font-size: 0.875rem;
		font-weight: 600;
		text-decoration: none;
		white-space: nowrap;
	}

	.edit-link:hover {
		text-decoration: underline;
	}

	.edit-link svg {
		flex-shrink: 0;
	}

	.delete-action {
		display: flex;
		flex-direction: column;
		align-items: flex-start;
		gap: var(--space-3);
		padding-top: var(--space-5);
		border-top: 1px solid var(--color-border);
	}

	.delete-button {
		min-height: 44px;
		padding: var(--space-2) var(--space-4);
		border: 1px solid var(--color-error);
		border-radius: var(--radius-md);
		background: transparent;
		color: var(--color-error);
		font-family: var(--font-body);
		font-size: 0.875rem;
		font-weight: 600;
		cursor: pointer;
	}

	.delete-button:hover:not(:disabled) {
		background: var(--color-surface-muted);
	}

	.delete-button:disabled {
		opacity: 0.55;
		cursor: not-allowed;
	}

	.delete-error {
		margin: 0;
		color: var(--color-error);
		font-size: 0.875rem;
	}

	.delete-dialog {
		width: min(90vw, 420px);
		max-height: 90vh;
		padding: var(--space-5);
		border: 1px solid var(--color-border);
		border-radius: var(--radius-lg);
		background: var(--color-surface);
		color: var(--color-text);
		box-shadow: 0 16px 48px rgb(0 0 0 / 0.18);
	}

	.delete-dialog::backdrop {
		background: rgb(20 10 12 / 0.55);
	}

	.delete-dialog h2 {
		margin: 0 0 var(--space-3);
		font-family: var(--font-display);
		font-size: 1.75rem;
		font-weight: 400;
	}

	.delete-dialog p {
		margin: 0;
		line-height: 1.6;
		color: var(--color-text-muted);
	}

	.dialog-actions {
		display: flex;
		justify-content: flex-end;
		gap: var(--space-3);
		margin-top: var(--space-5);
	}

	.dialog-actions button {
		min-height: 44px;
		padding: var(--space-2) var(--space-4);
		border-radius: var(--radius-md);
		font-family: var(--font-body);
		font-size: 0.875rem;
		font-weight: 600;
		cursor: pointer;
	}

	.cancel-button {
		border: 1px solid var(--color-border);
		background: var(--color-surface);
		color: var(--color-text);
	}

	.confirm-delete-button {
		border: 1px solid var(--color-error);
		background: var(--color-error);
		color: white;
	}

	.confirm-delete-button:disabled {
		opacity: 0.55;
		cursor: not-allowed;
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
