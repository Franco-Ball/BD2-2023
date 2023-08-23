-- Active: 1652961415872@@127.0.0.1@3306
use sakila;
#1
CREATE TABLE `employees` (
  `employeeNumber` int(11) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `firstName` varchar(50) NOT NULL,
  `extension` varchar(10) NOT NULL,
  `email` varchar(100) NOT NULL,
  `officeCode` varchar(10) NOT NULL,
  `reportsTo` int(11) DEFAULT NULL,
  `jobTitle` varchar(50) NOT NULL,
  PRIMARY KEY (`employeeNumber`)
);
INSERT INTO employees (employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle) 
VALUES 
  (1002, 'Murphy', 'Diane', 'x5800', 'dmurphy@classicmodelcars.com', '1', NULL, 'President'),
  (1056, 'Patterson', 'Mary', 'x4611', 'mpatterso@classicmodelcars.com', '1', 1002, 'VP Sales'),
  (1076, 'Firrelli', 'Jeff', 'x9273', 'jfirrelli@classicmodelcars.com', '1', 1002, 'VP Marketing');

INSERT INTO employees (employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
VALUES (2011, 'Benavidez', 'Momo', '12', NULL, '3', 2010, 'Baneador profesional');
#No se puede insertar el valor "NULL" al campo email porque cuando creamos la tabla especificamos que esto no sea posible

#2
UPDATE employees SET employeeNumber = employeeNumber - 20
#La query le resta 20 unidades a employeeNumber en todos las rows

UPDATE employees SET employeeNumber = employeeNumber + 20
#La query no se puede completar porque al sumarle 20 al valor de la pimary key de uno de los empleados este resulta igual que el valor de otra primary key de la tabla

#3
ALTER TABLE employees ADD age int check(age >= 16 and age <= 70);

#4
#La tabla film_actor es una tabla intermedia entre film y actor, esta contiene las FK de las tablas film y actor.
#Esta tabla es necesaria porque existe una relacion de muchos a muchos donde un actor actua en muchas 
#peliculas, mientras que una pelicula tiene varios actores. La tabla conecta los id de las peliculas y los actores.

#5
ALTER TABLE employees 
ADD COLUMN lastUpdate datetime;
ADD COLUMN lastUpdateUser varchar(50);

DELIMITER //
CREATE TRIGGER employee_insert_trigger
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER employee_update_trigger
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = CURRENT_TIMESTAMP;
END;
//
DELIMITER ;

#6
show TRIGGERS;

# Ins_film
BEGIN
INSERT INTO film_text (film_id, title, description)
VALUES (new.film_id, new.title, new.description);   
END
#copia los valores de film_id, title, y description de una fila recién insertada en otra tabla llamada film_text. 

#upd_film
BEGIN
IF (old.title != new.title) OR (old.description != new.description) OR (old.film_id != new.film_id)
THEN
UPDATE film_text SET title=new.title, description=new.description, film_id=new.film_id 
WHERE film_id=old.film_id;
END IF;   
END
#updatea automáticamente los valores en la tabla film_text cuando se modifica una fila en otra tabla. 

#del_film
BEGIN     
DELETE FROM film_text 
WHERE film_id = old.film_id;   
END
#borra automáticamente filas en la tabla film_text cuando se elimina una fila correspondiente en otra tabla. 
