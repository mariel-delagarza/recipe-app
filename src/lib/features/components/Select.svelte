<script>
	import { tick } from 'svelte';

	let {
		options = [],
		value = '',
		placeholder = 'Select an option',
		searchPlaceholder = 'Search...',
		searchable = false,
		openOnFocus = false,
		onChange
	} = $props();

	let open = $state(false);
	let search = $state('');
	let activeIndex = $state(0);
	let container;
	let searchInput = $state(null);
	let trigger;
	let optionsList;

	let selectedOption = $derived(options.find((option) => option.value === value));

	let filteredOptions = $derived(
		searchable && search.trim()
			? options.filter((option) => option.label.toLowerCase().includes(search.trim().toLowerCase()))
			: options
	);

	function closeMenu() {
		open = false;
		search = '';
		activeIndex = 0;
	}

	async function openMenu() {
		search = '';

		activeIndex = Math.max(
			0,
			options.findIndex((option) => option.value === value)
		);

		open = true;

		if (searchable) {
			await tick();
			searchInput?.focus();
		}

		await tick();
		scrollToActiveOption();
	}

	function scrollToActiveOption() {
		const activeOption = optionsList?.querySelectorAll('.option')[activeIndex];

		activeOption?.scrollIntoView({
			block: 'nearest',
			behavior: 'instant'
		});
	}

	function handleTriggerFocus(event) {
		if (openOnFocus && !open && event.relatedTarget !== searchInput) {
			openMenu();
		}
	}

	function selectOption(option) {
		onChange?.(option.value);
		closeMenu();
		trigger?.focus();
	}

	function handleTriggerKeydown(event) {
		if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
			event.preventDefault();

			if (!open) {
				openMenu();
			} else if (searchable) {
				searchInput?.focus();
			}
		}
	}

	function handleMenuKeydown(event) {
		if (event.key === 'Escape') {
			event.preventDefault();
			closeMenu();
			trigger?.focus();
			return;
		}

		if (event.key === 'ArrowDown') {
			event.preventDefault();

			activeIndex = Math.min(activeIndex + 1, filteredOptions.length - 1);

			tick().then(scrollToActiveOption);
		}

		if (event.key === 'ArrowUp') {
			event.preventDefault();

			activeIndex = Math.max(activeIndex - 1, 0);

			tick().then(scrollToActiveOption);
		}

		if (event.key === 'Enter' && filteredOptions[activeIndex]) {
			event.preventDefault();
			selectOption(filteredOptions[activeIndex]);
		}
	}

	function handleFocusOut(event) {
		if (!container?.contains(event.relatedTarget)) {
			closeMenu();
		}
	}
</script>

<div class="select-container" bind:this={container} onfocusout={handleFocusOut}>
	<button
		type="button"
		class="select-trigger"
		class:open
		aria-haspopup="listbox"
		aria-expanded={open}
		onfocus={handleTriggerFocus}
		onclick={() => (open ? closeMenu() : openMenu())}
		onkeydown={handleTriggerKeydown}
		bind:this={trigger}
	>
		<span class:placeholder={!selectedOption || value === ''}>
			{selectedOption?.label ?? placeholder}
		</span>

		<svg
			class:rotated={open}
			width="18"
			height="18"
			viewBox="0 0 24 24"
			fill="none"
			stroke="currentColor"
			stroke-width="2"
			stroke-linecap="round"
			stroke-linejoin="round"
			aria-hidden="true"
		>
			<path d="m6 9 6 6 6-6" />
		</svg>
	</button>

	{#if open}
		<div class="select-menu" role="listbox" tabindex="-1" onkeydown={handleMenuKeydown}>
			{#if searchable}
				<div class="search-wrapper">
					<svg
						width="17"
						height="17"
						viewBox="0 0 24 24"
						fill="none"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
						aria-hidden="true"
					>
						<circle cx="11" cy="11" r="8" />
						<path d="m21 21-4.35-4.35" />
					</svg>

					<input
						class="search-input"
						type="search"
						placeholder={searchPlaceholder}
						bind:value={search}
						bind:this={searchInput}
						oninput={() => (activeIndex = 0)}
					/>
				</div>
			{/if}

			<div class="options-list" bind:this={optionsList}>
				{#each filteredOptions as option, index (option.value)}
					<button
						type="button"
						class="option"
						class:active={index === activeIndex}
						role="option"
						aria-selected={option.value === value}
						onclick={() => selectOption(option)}
					>
						<span>{option.label}</span>

						{#if option.value === value}
							<svg
								width="16"
								height="16"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								stroke-linecap="round"
								stroke-linejoin="round"
								aria-hidden="true"
							>
								<path d="m20 6-11 11-5-5" />
							</svg>
						{/if}
					</button>
				{:else}
					<p class="no-results">No matching options</p>
				{/each}
			</div>
		</div>
	{/if}
</div>

<style>
	.select-container {
		position: relative;
		width: 100%;
		min-width: 0;
	}

	.select-trigger {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: var(--space-3);
		width: 100%;
		min-height: var(--control-height);
		padding: 0.875rem 1rem;
		border: 1px solid var(--color-border);
		border-radius: var(--radius-md);
		background: var(--color-surface);
		color: var(--color-text);
		font-family: var(--font-body);
		font-size: var(--font-size-body);
		font-weight: 400;
		text-align: left;
		cursor: pointer;
		line-height: 1.5;
	}

	.select-trigger.open {
		border-color: var(--color-olive);
	}

	.select-trigger span {
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.select-trigger .placeholder {
		color: var(--color-text-muted);
		opacity: 0.75;
	}

	.select-trigger svg {
		flex-shrink: 0;
		color: var(--color-burgundy);
		transition: transform 150ms ease;
	}

	.select-trigger svg.rotated {
		transform: rotate(180deg);
	}

	.select-menu {
		position: absolute;
		z-index: 20;
		top: calc(100% + 6px);
		left: 0;
		width: max(100%, 260px);
		max-width: min(340px, calc(100vw - 2rem));
		padding: var(--space-2);
		border: 1px solid var(--color-border);
		border-radius: var(--radius-md);
		background: var(--color-surface);
		box-shadow: 0 10px 30px rgb(48 41 35 / 10%);
	}

	.search-wrapper {
		display: flex;
		align-items: center;
		gap: var(--space-2);
		padding: 0 var(--space-2);
		border-bottom: 1px solid var(--color-border);
		color: var(--color-text-muted);
	}

	.search-wrapper svg {
		flex-shrink: 0;
	}

	.search-input {
		flex: 1;
		width: 100%;
		min-width: 0;
		min-height: 48px;
		padding: var(--space-2) 0;
		border: 0;
		border-radius: 0;
		background: transparent;
		box-shadow: none;
		font-family: var(--font-body);
		font-size: var(--font-size-body);
		font-weight: 400;
	}

	.search-input:focus {
		outline: none;
		border: 0;
	}

	.options-list {
		max-height: 220px;
		overflow-y: auto;
		overscroll-behavior: contain;
		scrollbar-width: thin;
		scrollbar-color: var(--color-border) transparent;
	}

	.options-list::-webkit-scrollbar {
		width: 5px;
	}

	.options-list::-webkit-scrollbar-thumb {
		background: var(--color-border);
		border-radius: 10px;
	}

	.options-list::-webkit-scrollbar-track {
		background: transparent;
	}

	.option {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: var(--space-2);
		width: 100%;
		min-height: 48px;
		padding: 0.75rem;
		border: 0;
		border-radius: var(--radius-sm);
		background: transparent;
		color: var(--color-text);
		font-family: var(--font-body);
		font-size: var(--font-size-body);
		font-weight: 400;
		text-align: left;
		cursor: pointer;
	}

	.option:hover,
	.option.active {
		background: var(--color-sage);
	}

	.option[aria-selected='true'] {
		color: var(--color-olive);
		font-weight: 500;
	}

	.option svg {
		flex-shrink: 0;
		color: var(--color-olive);
	}

	.no-results {
		margin: 0;
		padding: var(--space-3);
		color: var(--color-text-muted);
		font-size: var(--font-size-small);
		text-align: center;
	}

	@media (max-width: 699px) {
		.select-menu {
			left: auto;
			right: 0;
			width: max(100%, 260px);
			max-width: calc(100vw - 2rem);
		}
	}
</style>
