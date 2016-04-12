-- create table
drop table if exists users;
create table users (
   lastname varchar(40) not null,
   id integer not null
);

-- insert table
insert into users
select ('user' || (t.id::text)) as nick, (random() * 100000)::integer
from (select * from generate_series(1, 100000) as id) as t;
