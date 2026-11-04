<script>
    import RecipeDetail from '#lib/features/recipes/RecipeDetail.svelte';

    let { data } = $props();
</script>

<main>
    {#if data.recipe}
        <RecipeDetail recipe={data.recipe} />
    {/if}
</main>