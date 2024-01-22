CREATE DATABASE med_order_manager IF NOT EXISTS;

-- склад
CREATE TABLE stock (
    name VARCHAR(50) PRIMARY KEY,
    count INTEGER NOT NULL CHECK (count >= 0),
    recipe_required INTEGER NOT NULL CHECK (recipe_required = 0 OR recipe_required = 1)
) IF NOT EXISTS;

-- заказы
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    fio VARCHAR(100) NOT NULL,
    date_until DATE NOT NULL
) IF NOT EXISTS;

-- составы заказов
CREATE TABLE lists (
    id UUID PRIMARY KEY,
    med VARCHAR(50) REFERENCES stock(name),
    count INTEGER NOT NULL CHECK (count >= 1),
    order_id UUID REFERENCES orders
) IF NOT EXISTS;



-- USER (mom = med orders manager, случайно получилось)
CREATE ROLE mom_admin LOGIN ENCRYPTED PASSWORD 'admin';
GRANT SELECT, INSERT, UPDATE, DELETE ON stock, orders, lists TO mom_admin;



-- ЗАПРОСЫ

-- получить состав склада (getStock)
SELECT * FROM stock ORDER BY name;

-- получить список заказов (getOrders)
SELECT * FROM orders ORDER BY date_until;

-- получить списки ото всех заказов (getLists)
SELECT * FROM lists ORDER BY order_id, med;

-- (ФРОНДЭНДОМ НЕ ИСПОЛЬЗУЕТСЯ) получить список лекарств у конкретного заказа (getOrderList)
SELECT * FROM lists WHERE order_id = '<order_id>' ORDER BY med;



-- ИЗМЕНЕНИЯ ДАННЫХ

-- (ФРОНТЭНДОМ НЕ ИСПОЛЬЗУЕТСЯ) занесение лекарства на склад (addStock)
INSERT INTO stock (name, count, recipe_required) VALUES ('<name>', <count>, <0|1>);

-- (ФРОНТЭНДОМ НЕ ИСПОЛЬЗУЕТСЯ) удаление лекарства из склада (deleteStock)
-- ВНИМАНИЕ! ИСПОЛЬЗОВАТЬ ОСТОРОЖНО! НА ЭТИХ ДАННЫХ ПОДВЯЗАНЫ ЗАПИСИ В ТАБЛИЦЕ lists
DELETE FROM stock WHERE name = '<name>';

-- изменение количества лекарств на складе (поставка, заказ) (updateStockCount)
UPDATE stock SET count = count + <delta> WHERE name = '<med_name>';

-- занесение заказа (addOrder)
INSERT INTO orders (id, fio, date_until) VALUES ('<order_id>', '<fio>', <date_until>);

-- обновление данных заказа (не списка внутри него) (updateOrder)
UPDATE orders SET fio = '<fio>', date_until = <date_until> WHERE id = '<order_id>';

-- занесение строки списка в список лекарств заказа (при создании или изменении заказа) (addList)
INSERT INTO lists (id, med, count, order_id) VALUES ('<id>', '<med_name>', <count>, '<order_id>');

-- обновление данных списка лекарств (updateList)
UPDATE lists SET med = '<med_name>', count = <count> WHERE id = '<id>';

-- удаление строки в списке лекарств заказа (при его изменении) (deleteList)
DELETE FROM lists WHERE id = '<id>';

-- удаление заказа (по истечению даты) (deleteOrder)
DELETE FROM lists WHERE order_id = '<order_id>';
DELETE FROM orders WHERE id = '<order_id>';




