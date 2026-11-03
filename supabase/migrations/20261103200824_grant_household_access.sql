
-- Allow signed-in users to read household and membership records.
-- RLS still determines which household's rows they can see.

grant select on public.households
    to authenticated;

grant select on public.household_members
    to authenticated;

-- Allow signed-in household members to manage catalog data.
-- Existing RLS policies restrict access to their own household.

grant select, insert, update, delete
    on public.ingredients,
       public.ingredient_aliases,
       public.stores,
       public.household_items
    to authenticated;
