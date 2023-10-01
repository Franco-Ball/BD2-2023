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


# +------------------------------- CLASS 14 ---------------------------------------------+

/*
1)
Write a query that gets all the customers that live in Argentina. Show the first and last name in one column, the address and the city.
*/

#Usar group_concat para poner dos columnas o mas en una sola
#SOLUCION JOIN
SELECT GROUP_CONCAT(first_name, ' ', last_name) as nombre_completo, a.address as direccion, ct.city as ciudad 
FROM customer
JOIN address a USING(address_id)
JOIN city ct USING(city_id)
JOIN country c USING(country_id)
WHERE c.country LIKE 'Argentina'
GROUP by direccion, ciudad;

/*
2)
Write a query that shows the film title, language and rating. 
Rating shall be shown as the full text described here:
https://en.wikipedia.org/wiki/Motion_picture_content_rating_system#United_States. 
Hint: use case.
*/
#Case es como un switch!! Muy importante poner end al final del case
SELECT f.title, 
CASE 
WHEN f.rating LIKE 'G' THEN 'All ages admitted'
WHEN f.rating LIKE 'PG' THEN 'Some material may not be suitable for children'
WHEN f.rating LIKE 'PG-13' THEN 'Some material may be inappropriate for children under 13'
WHEN f.rating LIKE 'R' THEN 'Under 17 requires accompanying parent or adult guardian'
WHEN f.rating LIKE 'NC-17' THEN 'No one 17 and under admitted'
END,
l.name
FROM film f
JOIN language l USING(language_id)

/*
3)
Write a search query that shows all the films (title and release year) an actor was part of.
Assume the actor comes from a text box introduced by hand from a web page. 
Make sure to "adjust" the input text to try to find the films as effectively as you think is possible.
*/

#Usando subqueries
SELECT f.title, f.release_year
FROM film f
WHERE film_id in (SELECT film_id FROM film_actor WHERE actor_id = (SELECT actor_id FROM actor WHERE first_name LIKE UPPER('%boB%') and last_name LIKE UPPER('%FaWceTt%')));

#Usando JOIN // MAS FACIL
SELECT f.title, f.release_year FROM film f
JOIN film_actor USING(film_id)
JOIN actor ac USING(actor_id)
where ac.first_name LIKE UPPER('%boB%') and ac.last_name LIKE UPPER('%FaWceTt%');

/*
4)
Find all the rentals done in the months of May and June. 
Show the film title, customer name and if it was returned or not. 
There should be returned column with two possible values 'Yes' and 'No'.
*/

SELECT f.title, CONCAT(c.first_name, ' ', c.last_name) as customer, 
CASE
WHEN return_date is NULL THEN 'NO'  
ELSE 'YES'
END as returned
FROM rental 
JOIN customer c USING(customer_id)
JOIN inventory USING(inventory_id)
JOIN film f USING(film_id)
WHERE MONTH(date(rental_date)) = 6 or MONTH(date(rental_date)) = 5
ORDER BY rental_id; 

/*
#5
Investigate CAST and CONVERT functions. Explain the differences if any, write examples based on sakila DB.
CAST FUNCTION
The CAST() function converts a value (of any type) into the specified datatype.
The syntax is as follows :
CAST(<value> AS <datatype>)
*/
;
SELECT film_id, title, CAST(rental_rate AS UNSIGNED) AS rental_rate_int
FROM film;
/*

CONVERT FUNCTION
The CONVERT() function converts a value into the specified datatype or character set.
The syntax of this function is:
CONVERT (<value>, <source charset>,<target charset>);
*/
SELECT film_id, title, CONVERT(rental_duration, CHAR) AS rental_duration_str
FROM film;
/*
Differences
CAST is ANSI SQL standard, while CONVERT is specific to MySQL.
CONVERT has an optional second parameter that allows specifying a specific character set for string conversions.
*/
#6
/*
NVL Function (Not Available in MySQL):
The NVL function is used in Oracle databases to replace a null value with an alternative value. It has the following syntax:
NVL(expression, replace_with)


ISNULL Function (Available in SQL Server, Sybase, etc., but not MySQL):
The ISNULL function is used in some database systems like SQL Server to replace a null value with an alternative value. It has the following syntax:
ISNULL(expression, replace_with)

IFNULL Function (MySQL-Specific):
The IFNULL function is specific to MySQL and is used to replace a null value with an alternative value. It has the following syntax:
IFNULL(expression, replace_with)
*/;
SELECT actor_id, first_name, IFNULL(last_name, 'No last name') AS last_name
FROM actor;
/*
COALESCE Function:
The COALESCE function is a standard SQL function that works in many database systems, including MySQL. It returns the first non-null expression from a list of expressions. Its syntax is:
COALESCE(expression1, expression2, ..., expressionN)
*/
SELECT actor_id, first_name, COALESCE(last_name) AS last_name
FROM actor;
