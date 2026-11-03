
create or replace function public.create_recipe(
    p_household_id uuid,
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
    v_recipe_id uuid;
    v_ingredient_id uuid;
    v_item jsonb;
    v_name text;
    v_quantity numeric;
    v_unit_id uuid;
    v_position integer := 0;
begin
    -- Only household members can create recipes.
    if not public.is_household_member(p_household_id) then
        raise exception 'Not authorized for this household';
    end if;

    if nullif(btrim(p_title), '') is null then
        raise exception 'Recipe title is required';
    end if;

    if p_ingredients is null
       or jsonb_typeof(p_ingredients) <> 'array' then
        raise exception 'Ingredients must be an array';
    end if;

    insert into public.recipes (
        household_id,
        title,
        description,
        yield_description,
        instructions,
        notes,
        source_url
    )
    values (
        p_household_id,
        btrim(p_title),
        p_description,
        p_yield_description,
        coalesce(p_instructions, ''),
        p_notes,
        p_source_url
    )
    returning id into v_recipe_id;

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

        -- Reuse an ingredient if it already exists.
        insert into public.ingredients (
            household_id,
            name,
            normalized_name
        )
        values (
            p_household_id,
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
            p_household_id,
            v_recipe_id,
            v_ingredient_id,
            v_name,
            v_quantity,
            v_unit_id,
            nullif(btrim(v_item->>'preparation'), ''),
            v_position
        );

        v_position := v_position + 1;
    end loop;

    return v_recipe_id;
end;
$$;

revoke all on function public.create_recipe(
    uuid, text, text, text, text, text, text, jsonb
) from public, anon;

grant execute on function public.create_recipe(
    uuid, text, text, text, text, text, text, jsonb
) to authenticated;
