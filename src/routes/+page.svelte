
<script>
    import { onMount } from 'svelte';
    import { supabase } from '#lib/supabase.js';

    let email = $state('');
    let password = $state('');
    let user = $state(null);
    let household = $state(null);
    let errorMessage = $state('');
    let loading = $state(false);

    async function loadHousehold(currentUser) {
        const { data, error } = await supabase
            .from('household_members')
            .select('household_id, households(id, name)')
            .eq('user_id', currentUser.id)
            .single();

        if (error) {
            errorMessage = error.message;
            return;
        }

        household = data.households;
    }

    async function signIn() {
        loading = true;
        errorMessage = '';

        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (error) {
            errorMessage = error.message;
        } else {
            user = data.user;
            await loadHousehold(data.user);
        }

        loading = false;
    }

    async function signOut() {
        const { error } = await supabase.auth.signOut();

        if (error) {
            errorMessage = error.message;
            return;
        }

        user = null;
        household = null;
    }

    onMount(async () => {
        const { data, error } = await supabase.auth.getUser();

        if (error && error.name !== 'AuthSessionMissingError') {
            errorMessage = error.message;
        }

        if (data.user) {
            user = data.user;
            await loadHousehold(data.user);
        }
    });
</script>

<main>
    <h1>Our Kitchen</h1>

    {#if user}
        <p>Signed in as {user.email}</p>

        {#if household}
            <p>Household: {household.name}</p>
            <p>Supabase connection successful!</p>
        {/if}

        <button onclick={signOut}>Sign out</button>
    {:else}
        <form
            onsubmit={(event) => {
                event.preventDefault();
                signIn();
            }}
        >
            <label for="email">Email</label>
            <input id="email" type="email" bind:value={email} required />

            <label for="password">Password</label>
            <input id="password" type="password" bind:value={password} required />

            <button type="submit" disabled={loading}>
                {loading ? 'Signing in...' : 'Sign in'}
            </button>
        </form>
    {/if}

    {#if errorMessage}
        <p role="alert">{errorMessage}</p>
    {/if}
</main>
