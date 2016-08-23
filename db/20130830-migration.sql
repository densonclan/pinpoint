UPDATE periods SET completed='f';
UPDATE periods SET current='f';
UPDATE periods SET current='t' WHERE id IN (47,13,57);

UPDATE options SET name='F', client_id=1 WHERE id=9;
UPDATE options SET name='H3', client_id=1 WHERE id=19;
INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'LA', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 1 FROM options WHERE name='A' AND client_id=1;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'XA', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 1 FROM options WHERE name='A' AND client_id=1;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'XB', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 1 FROM options WHERE name='B' AND client_id=1;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'LB', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 1 FROM options WHERE name='B' AND client_id=1;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'F', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 2 FROM options WHERE name='F' AND client_id=1;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'KG', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 2 FROM options WHERE name='G' AND client_id=2;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'KC', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 2 FROM options WHERE name='C' AND client_id=2;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'MG', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 2 FROM options WHERE name='G' AND client_id=2;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'MF', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 2 FROM options WHERE name='F' AND client_id=2;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'KF', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 2 FROM options WHERE name='F' AND client_id=2;

UPDATE options SET client_id=1 WHERE id=17;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT 'X', box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 1 FROM options WHERE name='X' AND client_id=2;

INSERT INTO options (name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, updated_at, created_at, client_id)
SELECT name, box_quantity, price_zone, multibuy, licenced, total_ambient, total_licenced, total_temp, total_quantity, now(), now(), 2 FROM options WHERE name='H (Sc)' AND client_id=1;
