
create or replace function public.update_recipe(
    p_recipe_id uuid,
    p_title text,
    p_description text,
    p_yield_description text,
    p_instructions text,
    p_notes text,
    p_source_url text,
    p_ingredients jsonb
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
    v_household_id uuid;
    v_ingredient_id uuid;
    v_item jsonb;
    v_name text;
    v_quantity numeric;
    v_unit_id uuid;
    v_position integer := 0;
begin
    -- Find the recipe and lock it during the update.
    select household_id
    into v_household_id
    from public.recipes
    where id = p_recipe_id
    for update;

    if v_household_id is null then
        raise exception 'Recipe not found';
    end if;

    if not public.is_household_member(v_household_id) then
        raise exception 'Not authorized for this household';
    end if;

    if nullif(btrim(p_title), '') is null then
        raise exception 'Recipe title is required';
    end if;

    if p_ingredients is null
       or jsonb_typeof(p_ingredients) <> 'array' then
        raise exception 'Ingredients must be an array';
    end if;

    -- Update the recipe details.
    update public.recipes
    set
        title = btrim(p_title),
        description = p_description,
        yield_description = p_yield_description,
        instructions = coalesce(p_instructions, ''),
        notes = p_notes,
        source_url = p_source_url,
        updated_at = now()
    where id = p_recipe_id;

    -- Replace the recipe's ingredient associations.
    delete from public.recipe_ingredients
    where recipe_id = p_recipe_id;

    for v_item in
        select value
        from jsonb_array_elements(p_ingredients)
    loop
        v_name := nullif(btrim(v_item->>'name'), '');

        if v_name is null then
            raise exception 'Ingredient name is required';
        end if;

        v_quantity := nullif(v_item->>'quantity', '')::numeric;
        v_unit_id := nullif(v_item->>'unit_id', '')::uuid;

        -- Reuse an existing household ingredient when possible.
        insert into public.ingredients (
            household_id,
            name,
            normalized_name
        )
        values (
            v_household_id,
            v_name,
            public.normalize_item_name(v_name)
        )
        on conflict (household_id, normalized_name)
        do update set name = public.ingredients.name
        returning id into v_ingredient_id;

        insert into public.recipe_ingredients (
            household_id,
            recipe_id,
            ingredient_id,
            ingredient_text,
            quantity,
            unit_id,
            preparation,
            sort_order
        )
        values (
            v_household_id,
            p_recipe_id,
            v_ingredient_id,
            v_name,
            v_quantity,
            v_unit_id,
            nullif(btrim(v_item->>'preparation'), ''),
            v_position
        );

        v_position := v_position + 1;
    end loop;

    return p_recipe_id;
end;
$$;

revoke all on function public.update_recipe(
    uuid, text, text, text, text, text, text, jsonb
) from public, anon;

grant execute on function public.update_recipe(
    uuid, text, text, text, text, text, text, jsonb
) to authenticated;
