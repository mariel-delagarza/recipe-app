
-- 001: Foundation
-- Household and membership tables

create table public.households (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    created_at timestamptz not null default now()
);

create table public.household_members (
    id uuid primary key default gen_random_uuid(),

    household_id uuid not null
        references public.households(id)
        on delete cascade,

    user_id uuid not null
        references auth.users(id)
        on delete cascade,

    created_at timestamptz not null default now(),

    unique (household_id, user_id),
    unique (id, household_id)
);

-- Enable Row Level Security immediately.
alter table public.households
    enable row level security;

alter table public.household_members
    enable row level security;


create function public.normalize_item_name(input_name text)
returns text
language sql
immutable
set search_path = ''
as $$
    select lower(
        btrim(
            regexp_replace(input_name, '\s+', ' ', 'g')
        )
    );
$$;


-- Household-owned ingredient catalog

create table public.ingredients (
    id uuid primary key default gen_random_uuid(),

    household_id uuid not null
        references public.households(id)
        on delete cascade,

    name text not null,
    normalized_name text not null,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    unique (household_id, normalized_name),
    unique (id, household_id)
);

create table public.ingredient_aliases (
    id uuid primary key default gen_random_uuid(),

    household_id uuid not null
        references public.households(id)
        on delete cascade,

    ingredient_id uuid not null,

    alias text not null,
    normalized_alias text not null,

    foreign key (ingredient_id, household_id)
        references public.ingredients(id, household_id)
        on delete cascade,

    unique (household_id, normalized_alias)
);

alter table public.ingredients
    enable row level security;

alter table public.ingredient_aliases
    enable row level security;


-- Measurement reference data

create table public.measurement_units (
    id uuid primary key default gen_random_uuid(),

    name text not null unique,
    abbreviation text not null unique,

    dimension text not null check (
        dimension in ('mass', 'volume', 'count', 'package')
    ),

    conversion_to_base numeric
        check (conversion_to_base > 0),

    created_at timestamptz not null default now()
);

alter table public.measurement_units
    enable row level security;


-- Stores belong to a household.
-- Store assignment is a preference, not a shopping-item identity.

create table public.stores (
    id uuid primary key default gen_random_uuid(),

    household_id uuid not null
        references public.households(id)
        on delete cascade,

    name text not null,

    created_at timestamptz not null default now(),

    unique (household_id, name),
    unique (id, household_id)
);

-- Departments are shared reference data.
-- They help organize the shopping list by aisle/section.

create table public.departments (
    id uuid primary key default gen_random_uuid(),

    name text not null unique,
    default_sort_order integer not null default 0
);

alter table public.stores
    enable row level security;

alter table public.departments
    enable row level security;


-- Reusable household shopping catalog

create table public.household_items (
    id uuid primary key default gen_random_uuid(),

    household_id uuid not null
        references public.households(id)
        on delete cascade,

    ingredient_id uuid,

    name text not null,
    normalized_name text not null,

    item_type text not null check (
        item_type in ('food', 'household_supply')
    ),

    default_quantity numeric
        check (default_quantity > 0),

    default_unit_id uuid
        references public.measurement_units(id),

    default_store_id uuid,
    default_department_id uuid
        references public.departments(id),

    default_notes text,

    revision integer not null default 1
        check (revision > 0),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    unique (household_id, normalized_name),
    unique (id, household_id),

    -- Needed to enforce food-only pantry references later.
    unique (id, household_id, item_type),

    -- Ingredient must belong to the same household.
    foreign key (ingredient_id, household_id)
        references public.ingredients(id, household_id),

    -- Preferred store must belong to the same household.
    foreign key (default_store_id, household_id)
        references public.stores(id, household_id),

    -- Household supplies cannot reference food ingredients.
    constraint food_ingredient_relationship check (
        item_type = 'food'
        or ingredient_id is null
    ),

    -- A default quantity must have a unit, and vice versa.
    constraint default_quantity_unit_pair check (
        (default_quantity is null and default_unit_id is null)
        or
        (default_quantity is not null and default_unit_id is not null)
    )
);

alter table public.household_items
    enable row level security;


create function public.set_normalized_name()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
    if tg_table_name = 'ingredient_aliases' then
        new.normalized_alias :=
            public.normalize_item_name(new.alias);
    else
        new.normalized_name :=
            public.normalize_item_name(new.name);
    end if;

    return new;
end;
$$;

create trigger normalize_ingredients
before insert or update on public.ingredients
for each row execute function public.set_normalized_name();

create trigger normalize_ingredient_aliases
before insert or update on public.ingredient_aliases
for each row execute function public.set_normalized_name();

create trigger normalize_household_items
before insert or update on public.household_items
for each row execute function public.set_normalized_name();

-- Common household-scoped lookups

create index ingredients_household_idx
    on public.ingredients(household_id);

create index household_items_household_type_idx
    on public.household_items(household_id, item_type);

create index household_items_ingredient_idx
    on public.household_items(household_id, ingredient_id);

create index stores_household_idx
    on public.stores(household_id);


-- Check whether the current authenticated user belongs to a household.
-- SECURITY DEFINER avoids recursive RLS checks on household_members.

create function public.is_household_member(
    target_household_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.household_members hm
        where hm.household_id = target_household_id
          and hm.user_id = (select auth.uid())
    );
$$;

revoke all on function public.is_household_member(uuid) from public;
grant execute on function public.is_household_member(uuid)
    to authenticated;


-- Household records
create policy "Members can view their household"
on public.households
for select to authenticated
using (public.is_household_member(id));

-- Household membership
create policy "Members can view household memberships"
on public.household_members
for select to authenticated
using (public.is_household_member(household_id));

-- Ingredients
create policy "Members can manage ingredients"
on public.ingredients
for all to authenticated
using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));

-- Ingredient aliases
create policy "Members can manage ingredient aliases"
on public.ingredient_aliases
for all to authenticated
using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));

-- Stores
create policy "Members can manage stores"
on public.stores
for all to authenticated
using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));

-- Household shopping catalog
create policy "Members can manage household items"
on public.household_items
for all to authenticated
using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));


create policy "Authenticated users can read measurement units"
on public.measurement_units
for select to authenticated
using (true);

create policy "Authenticated users can read departments"
on public.departments
for select to authenticated
using (true);


-- Base units:
-- volume = milliliter
-- mass   = gram
-- count  = each

insert into public.measurement_units
    (name, abbreviation, dimension, conversion_to_base)
values
    ('milliliter', 'mL', 'volume', 1),
    ('liter', 'L', 'volume', 1000),
    ('teaspoon', 'tsp', 'volume', 4.92892159375),
    ('tablespoon', 'tbsp', 'volume', 14.78676478125),
    ('fluid ounce', 'fl oz', 'volume', 29.5735295625),
    ('cup', 'cup', 'volume', 236.5882365),
    ('pint', 'pt', 'volume', 473.176473),
    ('quart', 'qt', 'volume', 946.352946),
    ('gallon', 'gal', 'volume', 3785.411784),

    ('gram', 'g', 'mass', 1),
    ('kilogram', 'kg', 'mass', 1000),
    ('ounce', 'oz', 'mass', 28.349523125),
    ('pound', 'lb', 'mass', 453.59237),

    ('each', 'ea', 'count', 1),
    ('dozen', 'doz', 'count', 12),

    ('can', 'can', 'package', null),
    ('package', 'pkg', 'package', null),
    ('bottle', 'btl', 'package', null),
    ('bag', 'bag', 'package', null);

insert into public.departments
    (name, default_sort_order)
values
    ('Produce', 10),
    ('Meat & Seafood', 20),
    ('Dairy & Eggs', 30),
    ('Bakery', 40),
    ('Pantry & Dry Goods', 50),
    ('Baking & Spices', 60),
    ('Canned & Jarred', 70),
    ('Frozen', 80),
    ('Beverages', 90),
    ('Household', 100),
    ('Personal Care', 110),
    ('Other', 999);


-- Reference tables are readable but not editable by app users.

revoke all on public.measurement_units
    from anon, authenticated;

revoke all on public.departments
    from anon, authenticated;

grant select on public.measurement_units
    to authenticated;

grant select on public.departments
    to authenticated;
