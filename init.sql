CREATE DATABASE bank;

\c bank;

create table accounts
(
	id SERIAL
		primary key,
	login varchar(255) not null,
	balance bigint default 0 not null,
	created_at timestamp default now()
);

insert into accounts (login, balance) values ('petya', 1000);
insert into accounts (login, balance) values ('vasya', 2000);
insert into accounts (login, balance) values ('mark', 500);

----Read uncommitted
-- Read_uncommitted_1
---- см инструкцию по сайту
INSERT INTO accounts (login, balance, created_at) VALUES('ivan', 750, NOW());
DELETE FROM accounts WHERE login = 'vasya';
UPDATE accounts SET balance = 1500 WHERE login = 'petya';
--
--SELECT SUM(balance) FROM accounts;

-- Read_committed_1
--Repeatable_read_1
UPDATE accounts SET balance = 2000 WHERE login = 'petya';

drop table accounts;

--Serializable
UPDATE accounts SET balance = 1000 WHERE login = 'petya';