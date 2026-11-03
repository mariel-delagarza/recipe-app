
-- Replace the initial generic departments with Safeway categories.
-- Safe while household_items has no records.

delete from public.departments;

insert into public.departments (name, default_sort_order)
values
    ('Baby Care', 10),
    ('Beverages', 20),
    ('Bread & Bakery', 30),
    ('Breakfast & Cereal', 40),
    ('Canned Goods & Soups', 50),
    ('Condiments, Spice & Bake', 60),
    ('Cookies, Snacks & Candy', 70),
    ('Dairy, Eggs & Cheese', 80),
    ('Deli', 90),
    ('Flowers, Cards, Occasion', 100),
    ('Frozen Foods', 110),
    ('Fruits & Vegetables', 120),
    ('Grains, Pasta & Sides', 130),
    ('International Cuisine', 140),
    ('Meat & Seafood', 150),
    ('Nutrition & Wellness', 160),
    ('Paper, Cleaning & Home', 170),
    ('Personal Care & Health', 180),
    ('Pet Care', 190),
    ('Wine, Beer & Spirits', 200),
    ('Other', 999);
