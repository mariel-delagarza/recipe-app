
import { supabase } from '#lib/supabase.js';

export const session = $state({
    user: null,
    household: null,
    loading: true,
    errorMessage: ''
});

async function loadHousehold(currentUser) {
    const { data, error } = await supabase
        .from('household_members')
        .select('household_id, households(id, name)')
        .eq('user_id', currentUser.id)
        .single();

    if (error) {
        session.errorMessage = error.message;
        session.household = null;
        return;
    }

    session.household = data.households;
}

export async function initializeSession() {
    session.loading = true;
    session.errorMessage = '';

    const { data, error } = await supabase.auth.getUser();

    if (error && error.name !== 'AuthSessionMissingError') {
        session.errorMessage = error.message;
    }

    if (data.user) {
        session.user = data.user;
        await loadHousehold(data.user);
    } else {
        session.user = null;
        session.household = null;
    }

    session.loading = false;
}

export async function signIn(email, password) {
    session.loading = true;
    session.errorMessage = '';

    const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
    });

    if (error) {
        session.errorMessage = error.message;
    } else {
        session.user = data.user;
        await loadHousehold(data.user);
    }

    session.loading = false;
}

export async function signOut() {
    session.errorMessage = '';

    const { error } = await supabase.auth.signOut();

    if (error) {
        session.errorMessage = error.message;
        return;
    }

    session.user = null;
    session.household = null;
}
