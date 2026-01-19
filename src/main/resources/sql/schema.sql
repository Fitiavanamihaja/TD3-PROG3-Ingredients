-- sql
-- src/main/resources/sql/schema.sql (modifié : ajout selling_price)
create type dish_type as enum ('STARTER', 'MAIN', 'DESSERT');

create table if not exists dish
(
    id            serial primary key,
    name          varchar(255),
    dish_type     dish_type,
    price         numeric(10,2),
    selling_price numeric(10,2)  -- colonne optionnelle (peut être NULL)
);

create type ingredient_category as enum ('VEGETABLE', 'ANIMAL', 'MARINE', 'DAIRY', 'OTHER');

create table if not exists ingredient
(
    id       serial primary key,
    name     varchar(255),
    price    numeric(10, 2),
    category ingredient_category
);

create type unit_type as enum ('PCS', 'KG', 'L');

create table if not exists dish_ingredient
(
    id                serial primary key,
    id_dish           int not null references dish(id) on delete cascade,
    id_ingredient     int not null references ingredient(id) on delete restrict,
    required_quantity numeric(10,2),
    unit              unit_type
);

create index if not exists idx_dish_ingredient_dish on dish_ingredient (id_dish);
create index if not exists idx_dish_ingredient_ingredient on dish_ingredient (id_ingredient);
