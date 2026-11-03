<script>
	import { session, signOut } from '#lib/state/session.svelte.js';
	import { resolve } from '$app/paths';
</script>

<main>
	<h1>Our Kitchen</h1>

	<p>Welcome to {session.household?.name}!</p>
	<p>Signed in as {session.user?.email}</p>

	<nav>
		<a href={resolve('/recipes')}>View recipes</a>
	</nav>

	<button onclick={signOut}>Sign out</button>
</main>
