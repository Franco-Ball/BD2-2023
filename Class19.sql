-- Active: 1652961517460@@127.0.0.1@3306@sakila
use sakila;
#1
CREATE USER data_analyst@localhost
IDENTIFIED BY "pepe1234";

#2
GRANT SELECT, UPDATE, DELETE ON sakila.* TO 'data_analyst'@'localhost';

#3
create table test (id int primary key, nombre varchar(30));

/*
 ERROR 1142 (42000): CREATE command denied to user 'data_analyst'@'localhost' for table 'test'
 Este error ocurre porque estamos intentando crear una tabla cuando el usuario data_analyst no tiene los permisos necesarios para hacerlo, 
 ya que posteriormente solo le asignamos los permisos SELECT, UPDATE y CREATE
 */

#4

UPDATE film SET title = "LA PALERMONETA" WHERE film_id = 500;

/*Anda correctamente porque tiene los permisos*/

#5

REVOKE UPDATE ON sakila.* FROM data_analyst;

#6

UPDATE film SET title = "EL GALLINERO" WHERE film_id = 500;

/*
 ERROR 1142 (42000): UPDATE command denied to user 'data_analyst'@'localhost' for table 'film'
 Este error ocurre porque le acabamos de sacar los permisos para editar tablas en la actividad numero 5
 */