-- sql
-- src/main/resources/sql/data.sql (modifié : mises à jour sur selling_price)
insert into dish (id, name, dish_type) values
                                           (1, 'Salaide fraîche', 'STARTER'),
                                           (2, 'Poulet grillé', 'MAIN'),
                                           (3, 'Riz aux légumes', 'MAIN'),
                                           (4, 'Gâteau au chocolat ', 'DESSERT'),
                                           (5, 'Salade de fruits', 'DESSERT');

insert into ingredient (id, name, price, category) values
                                                       (1, 'Laitue', 800.0, 'VEGETABLE'),
                                                       (2, 'Tomate', 600.0, 'VEGETABLE'),
                                                       (3, 'Poulet', 4500.0, 'ANIMAL'),
                                                       (4, 'Chocolat ', 3000.0, 'OTHER'),
                                                       (5, 'Beurre', 2500.0, 'DAIRY');

-- sql
-- Ajout ou mise à jour des lignes demandées dans `dish_ingredient`
INSERT INTO dish_ingredient (id, id_dish, id_ingredient, required_quantity, unit) VALUES
                                                                                      (1, 1, 1, 0.20, 'KG'),
                                                                                      (2, 1, 2, 0.15, 'KG'),
                                                                                      (3, 2, 3, 1.00, 'KG'),
                                                                                      (4, 4, 4, 0.30, 'KG'),
                                                                                      (5, 4, 5, 0.20, 'KG')
ON CONFLICT (id) DO UPDATE
    SET id_dish = EXCLUDED.id_dish,
        id_ingredient = EXCLUDED.id_ingredient,
        required_quantity = EXCLUDED.required_quantity,
        unit = EXCLUDED.unit;

-- valeurs de prix des plats (optionnel) : écrire dans selling_price
update dish set selling_price = 2000.0 where id = 1;
update dish set selling_price = 6000.0 where id = 2;
