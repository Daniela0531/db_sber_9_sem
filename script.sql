-- -- удаляю таблицы
--
-- drop table book;
-- drop table author;

 -- создаю таблицы

 CREATE TABLE author (
   id SERIAL PRIMARY KEY,
   name VARCHAR(100) NOT NULL
 );

 CREATE TABLE book (
   id SERIAL PRIMARY KEY,
   title VARCHAR(255) NOT NULL,
   author_id INT NOT NULL,
   public_year SMALLINT NULL,
   CONSTRAINT fk_author FOREIGN KEY(author_id) REFERENCES author(id));

 -- заполняю таблицы

 INSERT INTO author(name) VALUES('Virginia Woolf');
 INSERT INTO author(name) VALUES('Harper Lee');
 INSERT INTO author(name) VALUES('F. Scott Fitzgerald');
 INSERT INTO author(name) VALUES('J.R.R. Tolkien');
 INSERT INTO author(name) VALUES('George Orwell');
 INSERT INTO book(title, author_id, public_year) VALUES
 ('Mrs. Dalloway',1,1925),
 ('To the Lighthouse',1,1927),
 ('To Kill a Mockingbird',2,1960),
 ('The Great Gatsby',3,1925),
 ('The Lord of the Rings',4,1955);
 INSERT INTO book(title, author_id, public_year) VALUES
 ('1984',(SELECT id FROM author WHERE name = 'George Orwell'),1949),
 ('Animal Farm',(SELECT id FROM author WHERE name = 'George Orwell'),1945);

 -- создаю btree индексы и меряю их размер

 -- одна колонка
 CREATE INDEX i_btree ON author (name);
 -- смотрю размер
 SELECT pg_size_pretty(pg_relation_size('i_btree'));
 DROP INDEX i_btree;

 -- две колонки
 CREATE INDEX i_btree ON book (title, public_year);
 -- смотрю размер
 SELECT pg_size_pretty(pg_relation_size('i_btree'));
 DROP INDEX i_btree;

 -- выражение
 CREATE INDEX i_btree ON author ((lower(name)));
 -- смотрю размер
 SELECT pg_size_pretty(pg_relation_size('i_btree'));
 DROP INDEX i_btree;

 -- создаю hash индексы и меряю их размер

 -- одна колонка
 CREATE INDEX i_hash ON author USING hash (name);
 -- смотрю размер
 SELECT pg_size_pretty(pg_relation_size('i_hash'));
 DROP INDEX i_hash;

-- -- две колонки - говорит для этого индекса это не возможно
-- CREATE INDEX i_hash ON book USING hash (title, public_year);
-- -- смотрю размер
-- SELECT pg_size_pretty(pg_relation_size('i_hash'));
-- DROP INDEX i_hash;

 -- выражение
 CREATE INDEX i_hash ON book USING hash (lower(title));
 -- смотрю размер
 SELECT pg_size_pretty(pg_relation_size('i_hash'));
 DROP INDEX i_hash;

 -- создаю spgist индексы и меряю их размер

 -- одна колонка
 CREATE INDEX i_spgist ON author USING spgist (name);
 -- смотрю размер
 SELECT pg_size_pretty(pg_relation_size('i_spgist'));
 DROP INDEX i_spgist;

-- -- две колонки - говорит для этого индекса это не возможно
-- CREATE INDEX i_spgist ON book USING spgist (title, public_year);
-- -- смотрю размер
-- SELECT pg_size_pretty(pg_relation_size('i_spgist'));
-- DROP INDEX i_spgist;

 -- выражение
 CREATE INDEX i_spgist ON book USING spgist (lower(title));
 -- смотрю размер
 SELECT pg_size_pretty(pg_relation_size('i_spgist'));
 DROP INDEX i_spgist;

 -- создаю bloom индексы и меряю их размер

 create extension bloom;

 -- одна колонка
 CREATE INDEX i_bloom ON author USING bloom (name);
 -- смотрю размер
 SELECT pg_size_pretty(pg_relation_size('i_bloom'));
 DROP INDEX i_bloom;

 -- две колонки
 CREATE INDEX i_bloom ON book USING bloom (title, author_id);
 -- смотрю размер
 SELECT pg_size_pretty(pg_relation_size('i_bloom'));
 DROP INDEX i_bloom;

 -- выражение
 CREATE INDEX i_bloom ON book USING bloom (lower(title));
 -- смотрю размер
 SELECT pg_size_pretty(pg_relation_size('i_bloom'));
 DROP INDEX i_bloom;
