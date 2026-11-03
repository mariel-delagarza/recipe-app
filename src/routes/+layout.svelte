
<script>
    import { onMount } from 'svelte';
    import { session, initializeSession, signIn } from '#lib/state/session.svelte.js';
    import '#lib/styles/global.css';

    let { children } = $props();

    let email = $state('');
    let password = $state('');

    onMount(() => {
        initializeSession();
    });

    async function handleSignIn(event) {
        event.preventDefault();

        await signIn(email, password);

        if (session.user) {
            password = '';
        }
    }
</script>

{#if session.loading}
    <p>Loading...</p>
{:else if !session.user}
    <main>
        <h1>Our Kitchen</h1>

        <form onsubmit={handleSignIn}>
            <label for="email">Email</label>
            <input
                id="email"
                type="email"
                bind:value={email}
                required
            />

            <label for="password">Password</label>
            <input
                id="password"
                type="password"
                bind:value={password}
                required
            />

            <button type="submit">Sign in</button>
        </form>

        {#if session.errorMessage}
            <p role="alert">{session.errorMessage}</p>
        {/if}
    </main>
{:else if !session.household}
    <main>
        <h1>Our Kitchen</h1>
        <p>We couldn't load your household.</p>

        {#if session.errorMessage}
            <p role="alert">{session.errorMessage}</p>
        {/if}
    </main>
{:else}
    {@render children()}
{/if}
