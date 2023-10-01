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


# +------------------------------- CLASS 15 ---------------------------------------------+

/*
1)
Create a view named list_of_customers, it should contain the following columns:
customer id
customer full name,
address
zip code
phone
city
country
status (when active column is 1 show it as 'active', otherwise is 'inactive')
store id
*/

#Hacer una view es lo mismo que hacer una query con lo que dice la consigna nada mas se agrega la primera linea de codigo
#Con esto podes almacenar esta info en una "tabla virtual" que es mas rapida, aparte de customizable
CREATE VIEW `list_of_customers` AS 
SELECT customer_id, CONCAT(`first_name`,' ', `last_name`) AS fullname, 
ad.address, ad.postal_code, ct.city, co.country, 
CASE 
WHEN active = 1 THEN 'active'  
ELSE 'inactive'
END as status, store_id
FROM customer
JOIN address ad USING(address_id)
JOIN city ct USING(city_id)
JOIN country co USING(country_id)


/*
2)
Create a view named film_details, it should contain the following columns: 
film id, title, description, category, price, length, rating, 
actors - as a string of all the actors separated by comma. 
Hint use GROUP_CONCAT
*/

#IMPORTANTE CUANDO USAS GROUP_CONCAT PONER UN GROUP BY SINO ANDA MAL
#[or replace] despues del create hace que si ya esta creada la reemplace, bueno para ir probando
create or replace view film_details AS
SELECT film_id, title , description, cat.name as category, rental_rate, length, rating, GROUP_CONCAT(ac.first_name, ' ', ac.last_name, ';') as actors_list
from film
join film_category USING(film_id)
join category cat USING(category_id)
join film_actor USING(film_id)
join actor ac USING(actor_id)
GROUP BY film_id;

#Llamar a la view para ver que estoy haciendo :P (y corregir)
SELECT * FROM film_details

/*
3)
Create view sales_by_film_category, 
it should return 'category' and 'total_rental' columns.
*/

#El total de las rentas es la cantidad de plata recaudada // practicar hacer la cantidad de veces que se rento una pelicula x categoria
CREATE or REPLACE view sales_by_film_category AS
SELECT cat.name, SUM(p.amount) as total_rental
FROM film
JOIN film_category USING(film_id)
JOIN category cat USING(category_id)
JOIN inventory USING(film_id)
JOIN rental USING(inventory_id)
JOIN payment p USING(rental_id)
GROUP BY cat.name;

SELECT * FROM sales_by_film_category;

/*
4)
Create a view called actor_information where it should return:
actor id, first name, last name and the amount of films he/she acted on.
*/

#IMPORTANTE tratar de no usar subqueries en el count(no me salen :c), los joins andan bien
CREATE or REPLACE VIEW actor_information AS
SELECT ac.actor_id, ac.first_name, ac.last_name, 
COUNT(fa.film_id) as featured_in
FROM actor ac
JOIN film_actor fa USING(actor_id)
GROUP BY ac.actor_id;

SELECT * FROM actor_information

/*
5)
Analyze view actor_info, explain the entire query and specially how the sub query works.
Be very specific, take some time and decompose each part and give an explanation for each.
*/

SELECT * FROM actor_info
/*
 La query dentro de la view "actor_info" devuelve como resultado:
 a) El ID de cada actor
 b) El nombre de cada actor
 c) El apellido de cada actor
 d) Una lista con todas las películas en las que este actua donde las mismas estan ordenadas alfabeticamente por categoria, las cuales tambien estan ordenadas de la misma manera
 Ordenando alfabeticamente las categorías y dentro de cada una, organizando alfabeticamente las películas
 */

/*
6)
Materialized views, write a description, why they are used, alternatives, DBMS were they exist, etc.
*/
#COPIADO DE LA GUIA // TEORICO DE MATERIALIZED VIEWS
/*
 Las vistas materializadas son tablas que se crean mediante una consulta con los datos de otras tablas.  Esto proporciona un acceso mucho más eficiente, a costa de un incremento en el tamaño de la base de datos y a una posible falta de sincronía, se emplean cuando se va a trabajar con uno grupo reducido de datos de manera reiterada y se requiere su almacenamiento para agilizar las consultas y facilitar el trabajo a la hora de consultar los datos almacenados.
 Por ello, las views son utilizadas frecuentemente en todas las bases de datos que poseen grandes cantidades de datos o, en su defecto, emplean un grupo de datos de manera reiterada en sus consultas y demás.
Una de sus alternativas es una simple vista, la cual no se almacena en la memoria y siempre se actualiza cuando modificamos los datos de una tabla.
Las vistas materializadas son existen en los siguientes DBMS: PostgreSQL, MySQL, Microsoft SQL Server, Oravle, Snowflake, Redshift, MongoDB, entre otros
 */