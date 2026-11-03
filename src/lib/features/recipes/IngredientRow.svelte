
<script>
    let {
        ingredient,
        units = [],
        number,
        onUpdate,
        onRemove
    } = $props();

    function updateField(field, value) {
        onUpdate({
            ...ingredient,
            [field]: value
        });
    }
</script>

<div class="ingredient-row">
    <div class="ingredient-header">
        <span class="ingredient-number">Ingredient {number}</span>

        <button
            class="remove-button"
            type="button"
            onclick={onRemove}
            aria-label={`Remove ingredient ${number}`}
        >
            Remove
        </button>
    </div>

    <div class="ingredient-fields">
        <label class="name-field">
            Ingredient
            <input
                type="text"
                value={ingredient.name}
                oninput={(event) =>
                    updateField('name', event.currentTarget.value)}
                placeholder="e.g. All-purpose flour"
                required
            />
        </label>

        <label class="quantity-field">
            Quantity
            <input
                type="number"
                min="0.01"
                step="any"
                value={ingredient.quantity ?? ''}
                oninput={(event) => {
                    const value = event.currentTarget.value;
                    updateField(
                        'quantity',
                        value === '' ? null : Number(value)
                    );
                }}
            />
        </label>

        <label class="unit-field">
            Unit
            <select
                value={ingredient.unitId}
                onchange={(event) =>
                    updateField('unitId', event.currentTarget.value)}
            >
                <option value="">No unit</option>

                {#each units as unit (unit.id)}
                    <option value={unit.id}>{unit.name}</option>
                {/each}
            </select>
        </label>

        <label class="preparation-field">
            Preparation
            <input
                type="text"
                value={ingredient.preparation}
                oninput={(event) =>
                    updateField('preparation', event.currentTarget.value)}
                placeholder="e.g. finely chopped"
            />
        </label>
    </div>
</div>

<style>
    .ingredient-row {
        display: flex;
        flex-direction: column;
        gap: var(--space-3);
        padding: var(--space-4) 0;
        border-bottom: 1px solid var(--color-border);
    }

    .ingredient-row:first-child {
        padding-top: 0;
    }

    .ingredient-row:last-child {
        border-bottom: 0;
    }

    .ingredient-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: var(--space-3);
    }

    .ingredient-number {
        font-size: 0.75rem;
        font-weight: 600;
        letter-spacing: 0.075em;
        text-transform: uppercase;
        color: var(--color-text-muted);
    }

    .remove-button {
        min-height: 44px;
        padding: 0 var(--space-2);
        border: 0;
        border-radius: var(--radius-sm);
        background: transparent;
        color: var(--color-burgundy);
        font: inherit;
        font-size: 0.875rem;
        font-weight: 500;
        cursor: pointer;
    }

    .remove-button:hover {
        background: var(--color-surface-muted);
    }

    .ingredient-fields {
        display: grid;
        grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
        gap: var(--space-3);
    }

    label {
        display: flex;
        flex-direction: column;
        gap: var(--space-2);
        min-width: 0;
        color: var(--color-text);
        font-size: 0.95rem;
        font-weight: 600;
    }

    .name-field,
    .preparation-field {
        grid-column: 1 / -1;
    }

    input,
    select {
        display: block;
        width: 100%;
        min-width: 0;
        min-height: 48px;
        box-sizing: border-box;
        padding: 0.85rem 1rem;
        border: 1px solid var(--color-border);
        border-radius: var(--radius-md);
        background: var(--color-surface);
        color: var(--color-text);
        font: inherit;
        font-weight: 400;
        line-height: 1.5;
    }

    input::placeholder {
        color: var(--color-text-muted);
        opacity: 0.75;
    }

    input:focus-visible,
    select:focus-visible,
    .remove-button:focus-visible {
        outline: 2px solid var(--color-burgundy);
        outline-offset: 2px;
    }

    @media (min-width: 850px) {
        .ingredient-fields {
            grid-template-columns:
                minmax(0, 2fr)
                minmax(85px, 0.8fr)
                minmax(110px, 1fr)
                minmax(0, 1.5fr);
        }

        .name-field,
        .preparation-field {
            grid-column: auto;
        }
    }
</style>
