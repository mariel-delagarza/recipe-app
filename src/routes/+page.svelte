<script>
	import { resolve } from '$app/paths';
</script>

<div class="home-page">
	<header class="home-heading">
		<span class="eyebrow">YOUR KITCHEN AT A GLANCE</span>
		<h1>What's cooking?</h1>
		<p>Everything you need to keep the kitchen running.</p>
	</header>

	<section class="dashboard" aria-label="Kitchen dashboard">
		<!-- Shopping list -->
		<div class="shopping-card">
			<div class="card-top">
				<span class="card-label">SHOPPING LIST</span>

				<svg
					aria-hidden="true"
					width="24"
					height="24"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="1.75"
					stroke-linecap="round"
					stroke-linejoin="round"
				>
					<path d="m3 9 2 11h14l2-11H3Z" />
					<path d="m9 9 3-6 3 6" />
					<path d="M9 13v4M15 13v4" />
				</svg>
			</div>

			<div class="shopping-content">
				<h2>Your next grocery run</h2>
				<p>Your shopping list will live here.</p>
			</div>

			<span class="coming-soon shopping-status">Coming soon</span>
		</div>

		<div class="secondary-cards">
			<!-- Recipes -->
			<a class="feature-card recipes-card" href={resolve('/recipes')}>
				<svg
					aria-hidden="true"
					width="26"
					height="26"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="1.75"
					stroke-linecap="round"
					stroke-linejoin="round"
				>
					<path d="M12 7v14" />
					<path d="M3 18V5a2 2 0 0 1 2-2h3a4 4 0 0 1 4 4 4 4 0 0 1 4-4h3a2 2 0 0 1 2 2v13" />
					<path d="M3 18h5a4 4 0 0 1 4 3 4 4 0 0 1 4-3h5" />
				</svg>

				<div class="feature-content">
					<h2>Recipes</h2>
					<p>All your favorite dishes in one place.</p>
				</div>

				<span class="feature-link">
					Browse recipes
				</span>
			</a>

			<!-- Pantry -->
			<div class="feature-card pantry-card">
				<svg
					aria-hidden="true"
					width="26"
					height="26"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="1.75"
					stroke-linecap="round"
					stroke-linejoin="round"
				>
					<rect x="4" y="3" width="16" height="18" rx="2" />
					<path d="M4 12h16M9 7v2M15 16v2" />
				</svg>

				<div class="feature-content">
					<h2>Pantry</h2>
					<p>Know what you have before you shop.</p>
				</div>

				<span class="coming-soon">Coming soon</span>
			</div>
		</div>
	</section>
</div>

<style>
	.home-page {
		display: flex;
		flex-direction: column;
		gap: var(--space-7);
		max-width: 900px;
		margin-inline: auto;
	}

	/* Heading */

	.home-heading {
		display: flex;
		flex-direction: column;
		gap: var(--space-2);
	}

	.eyebrow {
		color: var(--color-olive);
		font-size: 0.6875rem;
		font-weight: 600;
		letter-spacing: 0.12em;
	}

	.home-heading h1 {
		margin: 0;
		font-size: clamp(2.25rem, 7vw, 3.5rem);
	}

	.home-heading p {
		margin: 0;
		color: var(--color-text-muted);
		font-size: 0.9375rem;
	}

	/* Dashboard */

	.dashboard {
		display: flex;
		flex-direction: column;
		gap: var(--space-4);
	}

	/* Shopping card */

	.shopping-card {
		display: flex;
		flex-direction: column;
		justify-content: space-between;
		gap: var(--space-6);
		min-height: 210px;
		padding: var(--space-5);
		background: var(--color-burgundy);
		border-radius: var(--radius-lg);
		color: var(--color-cream);
	}

	.card-top {
		display: flex;
		align-items: center;
		justify-content: space-between;
	}

	.card-label {
		font-size: 0.6875rem;
		font-weight: 600;
		letter-spacing: 0.12em;
		color: #e1bfc7;
	}

	.shopping-content h2 {
		margin: 0 0 var(--space-2);
		color: var(--color-cream);
		font-size: clamp(1.5rem, 5vw, 2rem);
	}

	.shopping-content p {
		margin: 0;
		color: #f0dfe3;
		font-size: 0.9375rem;
	}

	.shopping-status {
		color: #f0dfe3;
	}

	/* Secondary cards */

	.secondary-cards {
		display: grid;
		grid-template-columns: repeat(2, minmax(0, 1fr));
		gap: var(--space-3);
	}

	.feature-card {
		display: flex;
		flex-direction: column;
		align-items: flex-start;
		gap: var(--space-4);
		min-width: 0;
		min-height: 205px;
		padding: var(--space-4);
		border-radius: var(--radius-md);
		text-decoration: none;
	}

	.recipes-card {
		background: var(--color-surface);
		border: 1px solid var(--color-border);
		color: var(--color-burgundy);
		transition: border-color 150ms ease;
	}

	.recipes-card:hover {
		border-color: var(--color-burgundy);
		color: var(--color-burgundy);
	}

	.pantry-card {
		background: var(--color-sage);
		color: var(--color-olive);
	}

	.feature-content {
		flex: 1;
	}

	.feature-content h2 {
		margin: 0 0 var(--space-2);
		color: var(--color-espresso);
		font-size: 1.5rem;
	}

	.feature-content p {
		margin: 0;
		color: var(--color-text-muted);
		font-size: 0.8125rem;
		line-height: 1.5;
	}

	.feature-link {
		display: inline-flex;
		align-items: center;
		gap: var(--space-2);
		font-size: 0.8125rem;
		font-weight: 600;
	}

	.feature-link span {
		font-size: 1.125rem;
	}

	.coming-soon {
		font-size: 0.75rem;
		font-weight: 500;
	}

	/* Desktop */

	@media (min-width: 700px) {
		.secondary-cards {
			gap: var(--space-4);
		}

		.feature-card {
			min-height: 220px;
			padding: var(--space-5);
		}

		.shopping-card {
			padding: var(--space-6);
		}
	}
</style>
