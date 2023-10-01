-- Active: 1696090225772@@127.0.0.1@3306@sakila
use sakila;
# +------------------------------- CLASS 13 ---------------------------------------------+
/*
Write the statements with all the needed subqueries, do not use hard-coded ids unless is specified. Check which fields are mandatory and which ones can be ommited (use default value).

1)
Add a new customer:
    To store 1
    For address use an existing address. The one that has the biggest address_id in 'United States'
*/
describe customer; #Ver la estructura de customer para saber que valores insertar

#Usar una subquey adentro de un insert para obtener el id mas grande de la direccion en estados unidos // dos en uno
INSERT into customer(store_id, first_name, last_name, address_id) 
SELECT 1, 'JOSE', 'ÑOQUI', MAX(a.address_id)
FROM address a
JOIN city USING(city_id)
JOIN country USING(country_id)
WHERE country LIKE 'United States'
;

/*
2)
Add a rental:
    Make easy to select any film title. I.e. I should be able to put 'film tile' in the where, and not the id.
    Do not check if the film is already rented, just use any from the inventory, e.g. the one with highest id.
    Select any staff_id from Store 2.
*/

DESCRIBE rental;

#Ahora ademas de la subquery en el insert tenemos sub-subqueries, el resultado de cada sub-subquery tiene que ser solo una row asi se inserta sin ningun problema 
INSERT into rental (rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT CURRENT_TIMESTAMP, (
    SELECT MAX(inv.inventory_id) 
    FROM inventory inv
    JOIN film f USING(film_id)
    WHERE f.title LIKE 'AMERICAN CIRCUS'), 1, NULL, (
        SELECT manager_staff_id 
        FROM store
        WHERE store_id = 2
        ORDER BY RAND()
        LIMIT 1);

/*
3)
Update film year based on the rating
For example if rating is 'G' release date will be '2001'
You can choose the mapping between rating and year.
Write as many statements are needed.
*/

UPDATE film
SET release_year = 2001
WHERE rating LIKE 'G';
UPDATE film
SET release_year = 2011
WHERE rating LIKE 'PG';
UPDATE film
SET release_year = 2021
WHERE rating LIKE 'NC-17';
UPDATE film
SET release_year = 2031
WHERE rating LIKE 'PG-13';
UPDATE film
SET release_year = 2041
WHERE rating LIKE 'R';

/*
4)
Return a film:
Write the necessary statements and queries for the following steps.
Find a film that was not yet returned. And use that rental id. Pick the latest that was rented for example.
Use the id to return the film.
*/

#Buscar el id de la pelicula que fue rentada mas recientemente y todavia no fue devuelta
SELECT rental_id, rental_date
        FROM rental 
        WHERE return_date is null 
        AND (SELECT MAX(rental_date) FROM rental WHERE return_date is null) = rental_date;

#Meter ese ID en el update y poner la decha de devolucion igual a la de ahora
UPDATE rental
set return_date = CURRENT_TIMESTAMP 
WHERE rental_id = 16050

/*
5)
Try to delete a film
    Check what happens, describe what to do.
    Write all the necessary delete statements to entirely remove the film from the DB.
*/

DELETE FROM film
WHERE film_id = 1;
#No se puede borrar la pelicula porque esta tiene FKs asignadas, osea otros objetos en otras tablas usan informacion de este
#Para poder borrar la pelicula hay que borrar todas los registros de las otras tablas que la afectan
Delete from film_actor
WHERE film_id = 1;
Delete from film_category
where film_id = 1;
DELETE FROM payment
WHERE rental_id IN (
SELECT rental_id
FROM rental
INNER JOIN inventory USING(inventory_id)
WHERE film_id = 1
);

DELETE FROM rental
WHERE inventory_id in (SELECT inventory_id 
                        FROM inventory
                        INNER JOIN film USING(film_id)
                        WHERE film_id=1 );

DELETE FROM inventory
WHERE film_id = 1;

#Es importante recordar que hay que borrar los registros de afuera hacia adentro
#Osea primero borrar el registro que no tenga FKs y asi en adelante

/*
6)
Rent a film
Find an inventory id that is available for rent (available in store) pick any movie. Save this id somewhere.
Add a rental entry
Add a payment entry
Use sub-queries for everything, except for the inventory id that can be used directly in the queries.
*/

#Traigo todas las peliculas que estan disponibles para rentar y elijo un id
SELECT * FROM inventory
WHERE inventory_id in (SELECT inventory_id 
                            FROM rental 
                            WHERE return_date is not NULL);
#inventory_id=10 

#Meto todos los datos a rental como en el Ej 2
INSERT INTO rental(rental_date, inventory_id, customer_id, staff_id)
SELECT CURRENT_TIMESTAMP, 10, 
(SELECT customer_id FROM customer ORDER BY RAND() limit 1),
(SELECT staff_id FROM staff where store_id = (
    SELECT store_id
    FROM inventory
    WHERE inventory_id = 10) ORDER BY RAND() limit 1);

#Meto los datos correctos a payment
INSERT INTO payment (payment_date, customer_id, staff_id, rental_id, amount)
SELECT CURRENT_TIMESTAMP,
(SELECT customer_id FROM rental ORDER BY rental_id DESC LIMIT 1), 
(SELECT staff_id FROM rental ORDER BY rental_id desc LIMIT 1), 
(SELECT rental_id FROM rental ORDER BY rental_id DESC LIMIT 1), 
(SELECT rental_rate FROM film WHERE film_id = (SELECT film_id FROM inventory WHERE inventory_id=10))
;

