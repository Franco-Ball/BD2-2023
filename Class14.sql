-- Active: 1652961517460@@127.0.0.1@3306@sakila
#1
SELECT CONCAT(c.first_name, ' ', c.last_name) AS 'Nombre del cliente', ad.address, ci.city
FROM customer c
INNER JOIN address ad USING(address_id)
INNER JOIN city ci USING(city_id)
INNER JOIN country co USING(country_id)
WHERE co.country = 'Argentina';

#2
SELECT f.title, l.name, f.rating,
CASE
WHEN f.rating LIKE 'G' THEN 'All ages admitted'
WHEN f.rating LIKE 'PG' THEN 'Some material may not be suitable for children'
WHEN f.rating LIKE 'PG-13' THEN 'Some material may be inappropriate for children under 13'
WHEN f.rating LIKE 'R' THEN 'Under 17 requires accompanying parent or adult guardian'
WHEN f.rating LIKE 'NC-17' THEN 'No one 17 and under admitted'
END 'Content Rating'
FROM film f
INNER JOIN language l USING(language_id);

#3
SELECT CONCAT( ac.first_name, ' ', ac.last_name) AS 'actor', f.title AS 'film', f.release_year AS 'release_year'
FROM film f
INNER JOIN film_actor USING(film_id)
INNER JOIN actor ac USING(actor_id)
WHERE CONCAT(first_name, ' ', last_name) LIKE TRIM(UPPER('Penelope Guiness'));

#4
SELECT f.title, r.rental_date, c.first_name,
CASE
WHEN r.return_date IS NOT NULL THEN 'Yes'
ELSE 'No'
END 'Returned'
FROM rental r
INNER JOIN inventory i USING(inventory_id)
INNER JOIN film f USING(film_id)
INNER JOIN customer c USING(customer_id)
WHERE
MONTH(r.rental_date) = '05'
OR MONTH(r.rental_date) = '06'
ORDER BY r.rental_date;

#5
/*
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
SELECT actor_id, first_name, COALESCE(last_name, 'No last name') AS last_name
FROM actor;
