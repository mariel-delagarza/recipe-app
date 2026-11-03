<script>
	import { session } from '#lib/state/session.svelte.js';
	import { resolve } from '$app/paths';
</script>

<main>
	<h1>Recipes</h1>
	<p>Household: {session.household?.name}</p>

	<a href={resolve('/')}>Back home</a>
</main>
