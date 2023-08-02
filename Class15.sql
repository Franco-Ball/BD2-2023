-- Active: 1652961415872@@127.0.0.1@3306
use sakila;
#1
CREATE VIEW list_of_customer AS
SELECT c.customer_id, CONCAT(c.first_name,' ', c.last_name) AS customer_full_name, a.`address`, a.postal_code AS zip_code,
a.phone, ci.city, co.country, if(c.active, 'active', '') AS `status`, c.store_id
FROM customer c
JOIN `address` a USING(address_id)
JOIN city c1 USING(city_id)
JOIN country co USING(country_id);
SELECT * FROM list_of_customer;

#2
CREATE VIEW film_details AS
SELECT f.film_id, f.title,f.description,ca.name AS category,f.rental_rate AS price,f.length,f.rating,
group_concat(concat(ac.first_name,' ',ac.last_name)ORDER BYac.first_name SEPARATOR ', ') as actors
FROM film f
JOIN film_category USING(film_id)
JOIN category ca USING(category_id)
JOIN film_actor USING(film_id)
JOIN actor ac USING(actor_id)
GROUP BY f.film_id, ca.name;
SELECT * FROM film_details;

#3
CREATE VIEW sales_by_film_category AS
SELECT ca.name AS category, sum(p.amount) AS total_rental
from payment p
JOIN rental USING(rental_id)
JOIN inventory USING(inventory_id)
JOIN film USING(film_id)
JOIN film_category USING(film_id)
JOIN category ca USING(category_id)
GROUP BY ca.`name`
ORDER BY total_sales;
SELECT * FROM sales_by_film_category;

#4
CREATE VIEW actor_information AS
SELECT a.actor_id as actor_id, a.first_name as first_name, a.last_name as last_name, COUNT(film_id) as films
FROM actor a
JOIN film_actor USING(actor_id)
GROUP BY ac.actor_id, ac.first_name, ac.last_name;
SELECT * FROM actor_information;

#5
/*
 La query dentro de la view "actor_info" devuelve como resultado:
 a) El ID de cada actor
 b) El nombre de cada actor
 c) El apellido de cada actor
 d) Una lista con todas las películas en las que este actua donde las mismas estan ordenadas alfabeticamente por categoria, las cuales tambien estan ordenadas de la misma manera
 Ordenando alfabeticamente las categorías y dentro de cada una, organizando alfabeticamente las películas
 */

#6
/*
 Las vistas materializadas son tablas que se crean mediante una consulta con los datos de otras tablas.  Esto proporciona un acceso mucho más eficiente, a costa de un incremento en el tamaño de la base de datos y a una posible falta de sincronía, se emplean cuando se va a trabajar con uno grupo reducido de datos de manera reiterada y se requiere su almacenamiento para agilizar las consultas y facilitar el trabajo a la hora de consultar los datos almacenados.
 Por ello, las views son utilizadas frecuentemente en todas las bases de datos que poseen grandes cantidades de datos o, en su defecto, emplean un grupo de datos de manera reiterada en sus consultas y demás.
Una de sus alternativas es una simple vista, la cual no se almacena en la memoria y siempre se actualiza cuando modificamos los datos de una tabla.
Las vistas materializadas son existen en los siguientes DBMS: PostgreSQL, MySQL, Microsoft SQL Server, Oravle, Snowflake, Redshift, MongoDB, entre otros
 */