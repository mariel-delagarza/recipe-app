ALTER TABLE public.recipe_ingredients
ADD COLUMN is_optional boolean NOT NULL DEFAULT false;

CREATE OR REPLACE FUNCTION public.create_recipe(
    p_household_id uuid,
    p_title text,
    p_description text,
    p_yield_description text,
    p_instructions text,
    p_notes text,
    p_source_url text,
    p_ingredients jsonb
)
RETURNS uuid
LANGUAGE plpgsql
SET search_path TO ''
AS $function$
DECLARE
    v_recipe_id uuid;
    v_ingredient_id uuid;
    v_item jsonb;
    v_name text;
    v_quantity numeric;
    v_quantity_display text;
    v_is_optional boolean;
    v_unit_id uuid;
    v_position integer := 0;
BEGIN
    -- Only household members can create recipes.
    IF NOT public.is_household_member(p_household_id) THEN
        RAISE EXCEPTION 'Not authorized for this household';
    END IF;

    IF nullif(btrim(p_title), '') IS NULL THEN
        RAISE EXCEPTION 'Recipe title is required';
    END IF;

    IF p_ingredients IS NULL
       OR jsonb_typeof(p_ingredients) <> 'array' THEN
        RAISE EXCEPTION 'Ingredients must be an array';
    END IF;

    INSERT INTO public.recipes (
        household_id,
        title,
        description,
        yield_description,
        instructions,
        notes,
        source_url
    )
    VALUES (
        p_household_id,
        btrim(p_title),
        p_description,
        p_yield_description,
        coalesce(p_instructions, ''),
        p_notes,
        p_source_url
    )
    RETURNING id INTO v_recipe_id;

    FOR v_item IN
        SELECT value
        FROM jsonb_array_elements(p_ingredients)
    LOOP
        v_name := nullif(btrim(v_item->>'name'), '');

        IF v_name IS NULL THEN
            RAISE EXCEPTION 'Ingredient name is required';
        END IF;

        v_quantity := nullif(v_item->>'quantity', '')::numeric;
        v_quantity_display := nullif(v_item->>'quantity_display', '');
        v_is_optional := coalesce((v_item->>'is_optional')::boolean, false);
        v_unit_id := nullif(v_item->>'unit_id', '')::uuid;

        -- Reuse an ingredient if it already exists.
        INSERT INTO public.ingredients (
            household_id,
            name,
            normalized_name
        )
        VALUES (
            p_household_id,
            v_name,
            public.normalize_item_name(v_name)
        )
        ON CONFLICT (household_id, normalized_name)
        DO UPDATE SET name = public.ingredients.name
        RETURNING id INTO v_ingredient_id;

        INSERT INTO public.recipe_ingredients (
            household_id,
            recipe_id,
            ingredient_id,
            ingredient_text,
            quantity,
            quantity_display,
            is_optional,
            unit_id,
            preparation,
            sort_order
        )
        VALUES (
            p_household_id,
            v_recipe_id,
            v_ingredient_id,
            v_name,
            v_quantity,
            v_quantity_display,
            v_is_optional,
            v_unit_id,
            nullif(btrim(v_item->>'preparation'), ''),
            v_position
        );

        v_position := v_position + 1;
    END LOOP;

    RETURN v_recipe_id;
END;
$function$;


CREATE OR REPLACE FUNCTION public.update_recipe(
    p_recipe_id uuid,
    p_title text,
    p_description text,
    p_yield_description text,
    p_instructions text,
    p_notes text,
    p_source_url text,
    p_ingredients jsonb
)
RETURNS uuid
LANGUAGE plpgsql
SET search_path TO ''
AS $function$
DECLARE
    v_household_id uuid;
    v_ingredient_id uuid;
    v_item jsonb;
    v_name text;
    v_quantity numeric;
    v_quantity_display text;
    v_is_optional boolean;
    v_unit_id uuid;
    v_position integer := 0;
BEGIN
    -- Find the recipe and lock it during the update.
    SELECT household_id
    INTO v_household_id
    FROM public.recipes
    WHERE id = p_recipe_id
    FOR UPDATE;

    IF v_household_id IS NULL THEN
        RAISE EXCEPTION 'Recipe not found';
    END IF;

    IF NOT public.is_household_member(v_household_id) THEN
        RAISE EXCEPTION 'Not authorized for this household';
    END IF;

    IF nullif(btrim(p_title), '') IS NULL THEN
        RAISE EXCEPTION 'Recipe title is required';
    END IF;

    IF p_ingredients IS NULL
       OR jsonb_typeof(p_ingredients) <> 'array' THEN
        RAISE EXCEPTION 'Ingredients must be an array';
    END IF;

    -- Update the recipe details.
    UPDATE public.recipes
    SET
        title = btrim(p_title),
        description = p_description,
        yield_description = p_yield_description,
        instructions = coalesce(p_instructions, ''),
        notes = p_notes,
        source_url = p_source_url,
        updated_at = now()
    WHERE id = p_recipe_id;

    -- Replace the recipe's ingredient associations.
    DELETE FROM public.recipe_ingredients
    WHERE recipe_id = p_recipe_id;

    FOR v_item IN
        SELECT value
        FROM jsonb_array_elements(p_ingredients)
    LOOP
        v_name := nullif(btrim(v_item->>'name'), '');

        IF v_name IS NULL THEN
            RAISE EXCEPTION 'Ingredient name is required';
        END IF;

        v_quantity := nullif(v_item->>'quantity', '')::numeric;
        v_quantity_display := nullif(v_item->>'quantity_display', '');
        v_is_optional := coalesce((v_item->>'is_optional')::boolean, false);
        v_unit_id := nullif(v_item->>'unit_id', '')::uuid;

        -- Reuse an existing household ingredient when possible.
        INSERT INTO public.ingredients (
            household_id,
            name,
            normalized_name
        )
        VALUES (
            v_household_id,
            v_name,
            public.normalize_item_name(v_name)
        )
        ON CONFLICT (household_id, normalized_name)
        DO UPDATE SET name = public.ingredients.name
        RETURNING id INTO v_ingredient_id;

        INSERT INTO public.recipe_ingredients (
            household_id,
            recipe_id,
            ingredient_id,
            ingredient_text,
            quantity,
            quantity_display,
            is_optional,
            unit_id,
            preparation,
            sort_order
        )
        VALUES (
            v_household_id,
            p_recipe_id,
            v_ingredient_id,
            v_name,
            v_quantity,
            v_quantity_display,
            v_is_optional,
            v_unit_id,
            nullif(btrim(v_item->>'preparation'), ''),
            v_position
        );

        v_position := v_position + 1;
    END LOOP;

    RETURN p_recipe_id;
END;
$function$;
