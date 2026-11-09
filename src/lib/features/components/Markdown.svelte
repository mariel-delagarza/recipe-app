<script>
	import { browser } from '$app/environment';
	import { marked } from 'marked';
	import DOMPurify from 'dompurify';

	let { content = '' } = $props();

	let html = $derived.by(() => {
		if (!browser) return '';

		const rendered = marked.parse(content ?? '', {
			breaks: true,
			gfm: true
		});

		return DOMPurify.sanitize(rendered);
	});
</script>

<div class="recipe-markdown">
	<!-- eslint-disable-next-line svelte/no-at-html-tags -->
	{@html html}
</div>

<style>
	.recipe-markdown :global(ol) {
		list-style: none;
		counter-reset: recipe-step;
		padding-left: 0;
		margin: 0;
	}

	.recipe-markdown :global(ol > li) {
		counter-increment: recipe-step;
		position: relative;
		padding-left: 3.5rem;
		margin-bottom: var(--space-5);
		min-height: 2.5rem;
	}

	.recipe-markdown :global(ol > li::before) {
		content: counter(recipe-step);
		position: absolute;
		top: 0;
		left: 0;

		display: flex;
		align-items: center;
		justify-content: center;

		width: 2.5rem;
		height: 2.5rem;
		border-radius: 50%;

		background: var(--color-sage);
		color: var(--color-olive);
		font-weight: 600;
		font-size: 0.875rem;
	}

	.recipe-markdown :global(ol > li:last-child) {
		margin-bottom: 0;
	}
</style>
