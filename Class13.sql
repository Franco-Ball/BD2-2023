-- Active: 1652961517460@@127.0.0.1@3306@sakila
#1
use sakila;
INSERT INTO customer (store_id,first_name,last_name,email,address_id,active)
SELECT 1,'ROMAN','RIQUELME','LABOMBONERA12@gmail.com', MAX(a.address_id),1
FROM address a
INNER JOIN city ci USING (city_id)
INNER JOIN country co USING(country_id)
WHERE ( co.country = "United States"
AND co.country_id = ci.country_id
AND ci.city_id = a.city_id
);

#2
INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT CURRENT_TIMESTAMP, (
SELECT MAX(i.inventory_id)
FROM inventory i
INNER JOIN film f USING(film_id)
WHERE f.title LIKE 'AMERICAN CIRCUS'), 1, NULL, (
SELECT manager_staff_id
FROM store
WHERE store_id = 2
ORDER BY RAND()
LIMIT 1
);

#3
UPDATE film 
SET release_year = 1998 
WHERE rating = 'PG';
UPDATE film 
SET release_year = 2000 
WHERE rating ='NC-17';
UPDATE film 
SET release_year = 2014 
WHERE rating ='PG-13';
UPDATE film 
SET release_year = 2018 
WHERE rating = 'R';
UPDATE film 
SET release_year = 2001 
WHERE rating ='G';

#4
SELECT f.film_id
FROM film f
INNER JOIN inventory i USING(film_id)
INNER JOIN rental r USING(inventory_id)
WHERE r.return_date IS NULL
ORDER BY r.rental_date DESC
LIMIT 1;

update rental
set return_date = CURRENT_TIMESTAMP
where rental_id = 998;

#5
DELETE 
FROM film 
WHERE film_id='56';
/*
ERROR: Cannot delete or update a parent row: a foreign key constraint fails (`sakila`.`film_actor`, CONSTRAINT `fk_film_actor_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE RESTRICT ON UPDATE CASCADE)
En este caso estamos intentando borrar una pelicula que tiene claves foraneas asignadas en otras tablas por lo que no se puede borrar 
ya que esto crearia un conflicto en las tablas

SOLUCION:
Para poder borrar la pelicula cuyo id es el 56 primero hay que borrar todos los registros de las otras tablas que esten relacionados con dicha pelicula
*/
DELETE 
FROM payment
WHERE rental_id IN (
SELECT rental_id
FROM rental
INNER JOIN inventory USING(inventory_id)
WHERE film_id = 56
);
DELETE FROM rental
WHERE inventory_id IN (
SELECT inventory_id
FROM inventory
WHERE film_id = 56
);
DELETE 
FROM inventory 
WHERE film_id = 56;
DELETE 
FROM film_actor 
WHERE film_id = 56;
DELETE 
FROM film_category 
WHERE film_id = 56;
#Una vez borrados todos los registros procedemos a borrar la pelicula
DELETE 
FROM film 
WHERE film_id = 56;

#6

SELECT inventory_id, film_id
FROM inventory
WHERE inventory_id NOT IN (
    SELECT inventory_id
    FROM inventory
    INNER JOIN rental USING (inventory_id)
    WHERE return_date IS NULL
);
#inv_id = 108 ; film_id = 22; 

INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
VALUES (CURRENT_DATE(), 108, (
    SELECT customer_id
    FROM customer
    ORDER BY customer_id DESC
    LIMIT 1), (
    SELECT staff_id
    FROM staff
    WHERE store_id = (
    SELECT store_id
    FROM inventory
    WHERE inventory_id = 108))
);

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES((
    SELECT customer_id
    FROM customer
    ORDER BY customer_id DESC
    LIMIT 1), (
    SELECT staff_id
    FROM staff
    LIMIT 1), (
    SELECT rental_id
    FROM rental
    ORDER BY rental_id DESC
    LIMIT 1
    ), (
    SELECT rental_rate
    FROM film
    WHERE film_id = 22),
    CURRENT_DATE()
);