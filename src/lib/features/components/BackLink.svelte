<script>
    import { resolve } from '$app/paths';

    let { href, label = 'All recipes' } = $props();
</script>

<a href={resolve(href)} class="back-link">
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
        <path d="m12 19-7-7 7-7" />
        <path d="M19 12H5" />
    </svg>

    {label}
</a>

<style>
    .back-link {
        display: inline-flex;
        align-items: center;
        gap: var(--space-2);
        align-self: flex-start;
        color: var(--color-burgundy);
        font-size: 0.875rem;
        font-weight: 600;
        text-decoration: none;
    }

    .back-link:hover {
        text-decoration: underline;
    }
</style>