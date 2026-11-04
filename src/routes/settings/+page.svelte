
<script>
    import { session, signOut } from '#lib/state/session.svelte.js';
</script>

<div class="settings-page">
    <header class="page-heading">
        <h1>Settings</h1>
        <p>Your account and kitchen preferences.</p>
    </header>

    <section class="settings-section">
        <h2>Account</h2>

        <div class="settings-card">
            <div class="setting-row">
                <span class="setting-label">Signed in as</span>
                <span class="setting-value">{session.user?.email}</span>
            </div>

            <div class="setting-row">
                <span class="setting-label">Household</span>
                <span class="setting-value">{session.household?.name}</span>
            </div>

            <div class="setting-actions">
                <button class="btn btn-secondary" onclick={signOut}>
                    Sign out
                </button>
            </div>
        </div>
    </section>
</div>

<style>
    .settings-page {
        display: flex;
        flex-direction: column;
        gap: var(--space-6);
        max-width: 680px;
    }

    .page-heading h1 {
        margin: 0 0 var(--space-2);
    }

    .page-heading p {
        margin: 0;
        color: var(--color-text-muted);
        font-size: 0.9375rem;
    }

    .settings-section h2 {
        margin-bottom: var(--space-4);
        font-size: 1.5rem;
    }

    .settings-card {
        background: var(--color-surface);
        border: 1px solid var(--color-border);
        border-radius: var(--radius-md);
        overflow: hidden;
    }

    .setting-row {
        display: flex;
        flex-direction: column;
        gap: var(--space-2);
        padding: var(--space-4);
        border-bottom: 1px solid var(--color-border);
    }

    .setting-label {
        color: var(--color-text-muted);
        font-size: 0.8125rem;
    }

    .setting-value {
        overflow-wrap: anywhere;
        font-size: 0.9375rem;
        font-weight: 500;
    }

    .setting-actions {
        padding: var(--space-4);
    }

    @media (min-width: 600px) {
        .setting-row {
            flex-direction: row;
            align-items: center;
            justify-content: space-between;
        }
    }
</style>
