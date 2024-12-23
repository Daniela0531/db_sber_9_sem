# pgbench

Протестировать производительность (pgbench) базы данных
с различными значениями двух параметров:
размер страницы и размер кэша (shared_buffers).
В качестве нагрузки использовать вставку 2 млн записей
с уникальными (неповторяющимися) ключами.
Если у вас мощное оборудование, и вставка происходит слишком
быстро можно повысить объем до 16 млн ключей.

Кроме производительности проанализировать cache hit ratio.

(задача в разработке)

```roomsql
psql -U postgres -d db_for_hw -f init.sql
pgbench -U postgres -j 3 -c 3 -t 1000 -f insert.sql db_for_hw
```
```roomsql
SELECT sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read))::float as ratio
FROM pg_statio_user_tables;
```
