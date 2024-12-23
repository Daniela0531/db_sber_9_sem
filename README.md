# ANALYZE
- Создать базу
- Заполнить её данными: одна или несколько таблиц
- Выполнить ANALYZE
- Придумать SQL запрос(ы) к базе
- Замерить их производительность
- Отключить автоматическое переанализироание
- Поменять содержимое базы, желательно не меняя её объем, но меняя распределение
- Повторно произвести замеры: должно стать медленнее

При этом подобрать запросы и данные так, что бы разница по скорости была ощутима. Желательно в десятки процентов или даже в 2 раза


```roomsql
CREATE DATABASE hw_database;
\c hw_database;

CREATE TABLE purchases (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    purchase_date TIMESTAMP NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
);

INSERT INTO purchases (user_id, product_id, purchase_date, amount)
SELECT
    (random() * 10000)::INT,                     -- 10,000 уникальных
    (random() * 100)::INT,                       -- 100 уникальных
    NOW() - (random() * INTERVAL '365 days'),    -- случайные даты за последний год
    (random() * 100)::DECIMAL(10, 2)             -- суммы от 0 до 100
FROM generate_series(1, 1000000);               -- 1,000,000 записей
```
включаем ANALYZE purchases, делаем запрос

```roomsql
ANALYZE purchases;

EXPLAIN ANALYZE SELECT product_id, COUNT(*) AS purchase_count
FROM purchases
GROUP BY product_id
ORDER BY purchase_count DESC
LIMIT 10;
```
вывод:

```roomsql
                                                                          QUERY PLAN                                                                           
---------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=14635.17..14635.19 rows=10 width=12) (actual time=84.297..86.200 rows=10 loops=1)
   ->  Sort  (cost=14635.17..14635.42 rows=101 width=12) (actual time=84.295..86.198 rows=10 loops=1)
         Sort Key: (count(*)) DESC
         Sort Method: top-N heapsort  Memory: 25kB
         ->  Finalize GroupAggregate  (cost=14607.40..14632.99 rows=101 width=12) (actual time=84.212..86.179 rows=101 loops=1)
               Group Key: product_id
               ->  Gather Merge  (cost=14607.40..14630.97 rows=202 width=12) (actual time=84.207..86.138 rows=303 loops=1)
                     Workers Planned: 2
                     Workers Launched: 2
                     ->  Sort  (cost=13607.37..13607.63 rows=101 width=12) (actual time=75.009..75.011 rows=101 loops=3)
                           Sort Key: product_id
                           Sort Method: quicksort  Memory: 29kB
                           Worker 0:  Sort Method: quicksort  Memory: 29kB
                           Worker 1:  Sort Method: quicksort  Memory: 29kB
                           ->  Partial HashAggregate  (cost=13603.00..13604.01 rows=101 width=12) (actual time=74.962..74.969 rows=101 loops=3)
                                 Group Key: product_id
                                 Batches: 1  Memory Usage: 32kB
                                 Worker 0:  Batches: 1  Memory Usage: 32kB
                                 Worker 1:  Batches: 1  Memory Usage: 32kB
                                 ->  Parallel Seq Scan on purchases  (cost=0.00..11519.67 rows=416667 width=4) (actual time=0.014..19.037 rows=333333 loops=3)
 Planning Time: 0.220 ms
 Execution Time: 86.276 ms
(22 rows)
```

отключаем autovacuum

```roomsql
ALTER SYSTEM SET autovacuum = 'off';
```
перезапустите сервис, чтобы очистить кэш

Изменить значения

```roomsql
UPDATE purchases
SET product_id = (CASE
    WHEN random() < 0.5 THEN 1
    ELSE product_id
END);
```
повторяем запрос
```roomsql
ANALYZE purchases;

EXPLAIN ANALYZE SELECT product_id, COUNT(*) AS purchase_count
FROM purchases
GROUP BY product_id
ORDER BY purchase_count DESC
LIMIT 10;
```
вывод:
```roomsql
                                                                           QUERY PLAN                                                                           
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=14635.17..14635.19 rows=10 width=12) (actual time=230.283..231.363 rows=10 loops=1)
   ->  Sort  (cost=14635.17..14635.42 rows=101 width=12) (actual time=230.281..231.360 rows=10 loops=1)
         Sort Key: (count(*)) DESC
         Sort Method: top-N heapsort  Memory: 25kB
         ->  Finalize GroupAggregate  (cost=14607.40..14632.99 rows=101 width=12) (actual time=230.144..231.321 rows=101 loops=1)
               Group Key: product_id
               ->  Gather Merge  (cost=14607.40..14630.97 rows=202 width=12) (actual time=230.137..231.284 rows=303 loops=1)
                     Workers Planned: 2
                     Workers Launched: 2
                     ->  Sort  (cost=13607.37..13607.63 rows=101 width=12) (actual time=222.518..222.522 rows=101 loops=3)
                           Sort Key: product_id
                           Sort Method: quicksort  Memory: 29kB
                           Worker 0:  Sort Method: quicksort  Memory: 29kB
                           Worker 1:  Sort Method: quicksort  Memory: 29kB
                           ->  Partial HashAggregate  (cost=13603.00..13604.01 rows=101 width=12) (actual time=222.466..222.475 rows=101 loops=3)
                                 Group Key: product_id
                                 Batches: 1  Memory Usage: 32kB
                                 Worker 0:  Batches: 1  Memory Usage: 32kB
                                 Worker 1:  Batches: 1  Memory Usage: 32kB
                                 ->  Parallel Seq Scan on purchases  (cost=0.00..11519.67 rows=416667 width=4) (actual time=0.226..160.679 rows=333333 loops=3)
 Planning Time: 3.753 ms
 Execution Time: 232.441 ms
(22 rows)
```
