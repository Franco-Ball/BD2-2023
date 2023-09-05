-- Active: 1652961517460@@127.0.0.1@3306@sakila
use sakila;
#1
CREATE USER data_analyst@localhost
IDENTIFIED BY "pepe1234";

#2
GRANT SELECT, UPDATE, DELETE ON sakila.* TO 'data_analyst'@'localhost';

#3
create table test (id int, nombre varchar(30));

#4