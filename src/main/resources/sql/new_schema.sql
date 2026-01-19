-- sql
-- src/main/resources/sql/new_schema.sql
BEGIN;

-- 1) Table d'historique des prix (normalisation)
CREATE TABLE IF NOT EXISTS dish_price (
                                          id serial PRIMARY KEY,
                                          id_dish int NOT NULL REFERENCES dish(id) ON DELETE CASCADE,
    selling_price numeric(10,2),
    effective_from timestamp without time zone DEFAULT now(),
    is_current boolean DEFAULT false
    );

CREATE INDEX IF NOT EXISTS idx_dish_price_dish ON dish_price (id_dish);

-- 2) Trigger/function pour s'assurer qu'il n'y a qu'un prix courant par plat
CREATE OR REPLACE FUNCTION ensure_one_current_price() RETURNS trigger AS $$
BEGIN
    IF NEW.is_current THEN
UPDATE dish_price
SET is_current = false
WHERE id_dish = NEW.id_dish
  AND id <> NEW.id;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ensure_one_current_price ON dish_price;
CREATE TRIGGER trg_ensure_one_current_price
    AFTER INSERT OR UPDATE ON dish_price
                        FOR EACH ROW
                        EXECUTE FUNCTION ensure_one_current_price();

-- 3) Ajouter la colonne selling_price sur dish si elle n'existe pas (optionnelle, peut être NULL)
ALTER TABLE dish ADD COLUMN IF NOT EXISTS selling_price numeric(10,2);

-- 4) Migration des valeurs existantes (si la colonne legacy 'price' existe et contient des valeurs)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'dish' AND column_name = 'price'
    ) THEN
        -- Insère les prix existants dans la table d'historique (évite les doublons)
        INSERT INTO dish_price (id_dish, selling_price, effective_from, is_current)
SELECT d.id, d.price, now(), true
FROM dish d
WHERE d.price IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM dish_price dp
    WHERE dp.id_dish = d.id
      AND dp.selling_price = d.price
);

-- Remplit la colonne selling_price du plat pour convenance (si vide)
UPDATE dish
SET selling_price = price
WHERE selling_price IS NULL
  AND price IS NOT NULL;
END IF;
END;
$$;

COMMIT;
