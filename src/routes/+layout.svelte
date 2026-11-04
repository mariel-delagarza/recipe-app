<script>
	import { onMount } from 'svelte';
	import { page } from '$app/state';
	import { resolve } from '$app/paths';
	import { session, initializeSession, signIn } from '#lib/state/session.svelte.js';
	import '#lib/styles/global.css';

	let { children } = $props();

	let email = $state('');
	let password = $state('');

	let isSigningIn = $state(false);

	onMount(() => {
		initializeSession();
	});

	async function handleSignIn(event) {
		event.preventDefault();

		isSigningIn = true;

		try {
			await signIn(email, password);

			if (session.user) {
				password = '';
			}
		} finally {
			isSigningIn = false;
		}
	}

	let isRecipesPage = $derived(
		page.url.pathname === '/recipes' || page.url.pathname.startsWith('/recipes/')
	);
</script>

{#if session.loading}
	<div class="loading-screen">
		<p>Preparing your kitchen...</p>
	</div>
{:else if !session.user}
	<main class="auth-screen">
		<div class="auth-card">
			<div class="auth-heading">
				<span class="eyebrow">WELCOME HOME</span>
				<h1>Our Kitchen</h1>
				<p>Good food, good company, and everything in its place.</p>
			</div>

			<form onsubmit={handleSignIn}>
				<div class="form-field">
					<label for="email">Email</label>
					<input id="email" type="email" bind:value={email} autocomplete="email" required />
				</div>

				<div class="form-field">
					<label for="password">Password</label>
					<input
						id="password"
						type="password"
						bind:value={password}
						autocomplete="current-password"
						required
					/>
				</div>

				<button type="submit" class="btn btn-primary sign-in-button" disabled={isSigningIn}>
					{isSigningIn ? 'Signing in...' : 'Sign in'}
				</button>

				{#if session.errorMessage}
					<p class="error-message" role="alert">
						{session.errorMessage}
					</p>
				{/if}
			</form>
		</div>
	</main>
{:else if !session.household}
	<main class="auth-screen">
		<div class="auth-card">
			<h1>Our Kitchen</h1>
			<p>We couldn't load your household.</p>

			{#if session.errorMessage}
				<p class="error-message" role="alert">
					{session.errorMessage}
				</p>
			{/if}
		</div>
	</main>
{:else}
	<div class="app-shell">
		<!-- Desktop navigation -->
		<aside class="sidebar">
			<div class="sidebar-brand">
				<span class="brand-eyebrow">THE EVERYDAY COOKBOOK</span>
				<a href={resolve('/')}>Our Kitchen</a>
				<span class="brand-divider"></span>
			</div>

			<nav class="sidebar-nav" aria-label="Main navigation">
				<a
					href={resolve('/recipes')}
					class:active={isRecipesPage}
					aria-current={isRecipesPage ? 'page' : undefined}
				>
					Recipes
				</a>

				<span class="nav-placeholder">Shopping list</span>
				<span class="nav-placeholder">Pantry</span>
			</nav>

			<div class="sidebar-footer">
				<span>Made for our table.</span>
				<a href={resolve('/settings')}> Settings </a>
			</div>
		</aside>

		<div class="app-main">
			<header class="mobile-header">
				<a href={resolve('/')} class="mobile-brand"> Our Kitchen </a>

				<a
					href={resolve('/settings')}
					class="header-settings"
					aria-label="Settings"
					title="Settings"
				>
					<span class="settings-icon" aria-hidden="true"></span>
				</a>
			</header>

			<main class="page-content">
				{@render children()}
			</main>
		</div>

		<!-- Mobile navigation -->
		<nav class="bottom-nav" aria-label="Mobile navigation">
			<a
				href={resolve('/recipes')}
				class:active={isRecipesPage}
				aria-current={isRecipesPage ? 'page' : undefined}
			>
				<span class="nav-icon" aria-hidden="true">▤</span>
				<span>Recipes</span>
			</a>

			<span class="nav-disabled">
				<span class="nav-icon" aria-hidden="true">☷</span>
				<span>Shopping</span>
			</span>

			<span class="nav-disabled">
				<span class="nav-icon" aria-hidden="true">◫</span>
				<span>Pantry</span>
			</span>
		</nav>
	</div>
{/if}

<style>
	/* Authentication */

	.loading-screen,
	.auth-screen {
		min-height: 100vh;
		min-height: 100dvh;
		display: flex;
		align-items: center;
		justify-content: center;
		padding: var(--space-5);
	}

	.loading-screen {
		color: var(--color-text-muted);
	}

	.auth-card {
		width: 100%;
		max-width: 420px;
		padding: var(--space-6);
		background: var(--color-surface);
		border: 1px solid var(--color-border);
		border-radius: var(--radius-lg);
	}

	.auth-heading {
		margin-bottom: var(--space-6);
		text-align: center;
	}

	.eyebrow,
	.brand-eyebrow {
		font-family: var(--font-body);
		font-size: 0.6875rem;
		font-weight: 600;
		letter-spacing: 0.15em;
	}

	.eyebrow {
		color: var(--color-olive);
	}

	.auth-heading h1 {
		margin: var(--space-3) 0;
		color: var(--color-burgundy);
	}

	.auth-heading p {
		margin: 0;
		color: var(--color-text-muted);
		font-size: 0.9375rem;
	}

	.form-field {
		display: flex;
		flex-direction: column;
		gap: var(--space-2);
		margin-bottom: var(--space-4);
	}

	.sign-in-button {
		width: 100%;
		margin-top: var(--space-2);
	}

	.error-message {
		margin-top: var(--space-4);
		color: var(--color-error);
		font-size: 0.875rem;
	}

	/* App shell: mobile first */

	.app-shell {
		min-height: 100vh;
		min-height: 100dvh;
	}

	.sidebar {
		display: none;
	}

	.app-main {
		min-width: 0;
	}

	/* Mobile header */

	.mobile-header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: var(--space-3);
		min-height: 56px;
		padding: 0 var(--space-4);
		border-bottom: 1px solid var(--color-border);
		background: var(--color-cream);
	}

	.mobile-brand {
		font-family: var(--font-display);
		font-size: 1.25rem;
		font-weight: 700;
		color: var(--color-burgundy);
		text-decoration: none;
	}

	.header-settings {
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		width: 44px;
		height: 44px;
		border-radius: var(--radius-sm);
		color: var(--color-burgundy);
		text-decoration: none;
	}

	.header-settings:hover {
		background: var(--color-oat);
	}

	/* Page content */

	.page-content {
		width: min(100%, var(--content-width));
		margin-inline: auto;
		padding: var(--space-5) var(--space-4);
		padding-bottom: calc(100px + env(safe-area-inset-bottom));
	}

	/* Mobile bottom navigation */

	.bottom-nav {
		position: fixed;
		bottom: 0;
		left: 0;
		right: 0;
		z-index: 20;
		display: grid;
		grid-template-columns: repeat(3, 1fr);
		min-height: 72px;
		padding-bottom: env(safe-area-inset-bottom);
		background: var(--color-surface);
		border-top: 1px solid var(--color-border);
	}

	.bottom-nav a,
	.bottom-nav .nav-disabled {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 4px;
		min-height: 64px;
		font-size: 0.75rem;
		font-weight: 500;
		text-decoration: none;
		color: var(--color-text-muted);
	}

	.bottom-nav a.active {
		color: var(--color-burgundy);
		font-weight: 600;
	}

	.nav-icon {
		font-size: 1.5rem;
		line-height: 1;
	}

	.bottom-nav .nav-disabled {
		opacity: 0.4;
	}

	.settings-icon {
		display: block;
		width: 22px;
		height: 22px;
		background-color: currentColor;

		mask: url('/images/gear-svgrepo-com.svg') center / contain no-repeat;
	}

	/* Desktop */

	@media (min-width: 900px) {
		.app-shell {
			display: grid;
			grid-template-columns: 260px minmax(0, 1fr);
		}

		.sidebar {
			position: sticky;
			top: 0;
			display: flex;
			flex-direction: column;
			height: 100vh;
			height: 100dvh;
			padding: var(--space-6) var(--space-5);
			background: var(--color-burgundy);
			color: var(--color-cream);
		}

		.sidebar-brand {
			display: flex;
			flex-direction: column;
			gap: var(--space-2);
			margin-bottom: var(--space-7);
		}

		.brand-eyebrow {
			color: #e1bfbf;
		}

		.sidebar-brand a {
			font-family: var(--font-display);
			font-size: 1.75rem;
			font-weight: 700;
			line-height: 1.2;
			color: var(--color-cream);
			text-decoration: none;
		}

		.brand-divider {
			width: 48px;
			height: 1px;
			margin-top: var(--space-4);
			background: var(--color-clay);
		}

		.sidebar-nav {
			display: flex;
			flex-direction: column;
			gap: var(--space-2);
		}

		.sidebar-nav a,
		.sidebar-nav .nav-placeholder {
			display: flex;
			align-items: center;
			min-height: 44px;
			padding: 0 var(--space-4);
			border-radius: var(--radius-sm);
			font-size: 0.9375rem;
			font-weight: 500;
			color: var(--color-cream);
			text-decoration: none;
		}

		.sidebar-nav a:hover {
			background: rgb(255 255 255 / 10%);
		}

		.sidebar-nav a.active {
			background: var(--color-cream);
			color: var(--color-burgundy);
			font-weight: 600;
		}

		.sidebar-nav .nav-placeholder {
			opacity: 0.45;
		}

		/* Desktop sidebar footer */

		.sidebar-footer {
			display: flex;
			flex-direction: column;
			align-items: flex-start;
			gap: var(--space-4);
			margin-top: auto;
			padding: var(--space-4);
			border-top: 1px solid rgb(255 255 255 / 20%);
		}

		.sidebar-footer > span {
			font-family: var(--font-display);
			font-size: 0.9375rem;
			font-style: italic;
			color: #e1bfbf;
		}

		/* Hide mobile navigation on desktop */

		.mobile-header,
		.bottom-nav {
			display: none;
		}

		.page-content {
			padding: var(--space-7);
		}
	}
</style>
