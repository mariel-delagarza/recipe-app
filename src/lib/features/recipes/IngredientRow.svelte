<script>
	let { ingredient, units = [], onUpdate, onRemove } = $props();

	function updateField(field, value) {
		onUpdate({
			...ingredient,
			[field]: value
		});
	}
</script>

<div class="ingredient-row">
	<div class="ingredient-fields">
		<label>
			Ingredient
			<input
				type="text"
				value={ingredient.name}
				oninput={(event) => updateField('name', event.currentTarget.value)}
				placeholder="e.g. All-purpose flour"
				required
			/>
		</label>

		<label>
			Quantity
			<input
				type="number"
				min="0.01"
				step="any"
				value={ingredient.quantity ?? ''}
				oninput={(event) => {
					const value = event.currentTarget.value;
					updateField('quantity', value === '' ? null : Number(value));
				}}
			/>
		</label>

		<label>
			Unit
			<select
				value={ingredient.unitId}
				onchange={(event) => updateField('unitId', event.currentTarget.value)}
			>
				<option value="">No unit</option>
				{#each units as unit (unit.id)}
					<option value={unit.id}>{unit.name}</option>
				{/each}
			</select>
		</label>

		<label>
			Preparation
			<input
				type="text"
				value={ingredient.preparation}
				oninput={(event) => updateField('preparation', event.currentTarget.value)}
				placeholder="e.g. finely chopped"
			/>
		</label>
	</div>

	<button type="button" onclick={onRemove}> Remove </button>
</div>

<style>
	.ingredient-row {
		padding: 1rem 0;
		border-bottom: 1px solid #e0d5cf;
	}

	.ingredient-fields {
		display: grid;
		grid-template-columns: minmax(0, 2fr) 0.7fr 1fr 1.5fr;
		gap: 0.75rem;
	}

	label {
		display: grid;
		gap: 0.35rem;
	}

	input,
	select {
		width: 100%;
		min-width: 0;
		box-sizing: border-box;
	}

	@media (max-width: 700px) {
		.ingredient-fields {
			grid-template-columns: 1fr 1fr;
		}

		.ingredient-fields label:first-child,
		.ingredient-fields label:last-child {
			grid-column: 1 / -1;
		}
	}
</style>
