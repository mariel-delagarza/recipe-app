
-- Recipes belong to a household.

create table public.recipes (
    id uuid primary key default gen_random_uuid(),

    household_id uuid not null
        references public.households(id)
        on delete cascade,

    title text not null,
    description text,

    -- Original recipe yield, e.g. "4 servings" or "1 loaf".
    yield_description text,

    instructions text not null default '',
    notes text,
    source_url text,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    unique (id, household_id)
);

alter table public.recipes enable row level security;

-- Each ingredient is one line in a recipe.
-- We preserve the original wording for display.

create table public.recipe_ingredients (
    id uuid primary key default gen_random_uuid(),

    household_id uuid not null,
    recipe_id uuid not null,

    ingredient_id uuid,
    ingredient_text text not null,

    quantity numeric check (quantity > 0),
    unit_id uuid references public.measurement_units(id),

    preparation text,
    sort_order integer not null default 0,

    foreign key (recipe_id, household_id)
        references public.recipes(id, household_id)
        on delete cascade,

    foreign key (ingredient_id, household_id)
        references public.ingredients(id, household_id),

    constraint quantity_unit_pair check (
        quantity is null or unit_id is not null
    )
);

alter table public.recipe_ingredients enable row level security;

create index recipes_household_idx
    on public.recipes(household_id);

create index recipe_ingredients_recipe_idx
    on public.recipe_ingredients(recipe_id, sort_order);


-- Household members can manage their shared recipes.

create policy "Members can manage recipes"
on public.recipes
for all to authenticated
using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));

create policy "Members can manage recipe ingredients"
on public.recipe_ingredients
for all to authenticated
using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));

grant select, insert, update, delete
on public.recipes, public.recipe_ingredients
to authenticated;
