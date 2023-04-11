-- Active: 1652961517460@@127.0.0.1@3306
use sakila;
#1
SELECT title, special_features
FROM film
WHERE rating = "PG-13";

#2
SELECT DISTINCT length FROM film ORDER BY LENGTH ASC;

#3
SELECT f1.title, f1.rental_rate, f1.replacement_cost
FROM film f1
WHERE f1.replacement_cost BETWEEN 20.00 and 24.00
ORDER BY replacement_cost ASC;

#4
SELECT f1.title, c.name as category, f1.rating 
FROM film f1
join film_category on f1.film_id = film_category.film_id
join category c on film_category.category_id = c.category_id
WHERE f1.special_features like "%Behind the Scenes%";

#5
SELECT a.first_name, a.last_name
FROM actor a
join film_actor on a.actor_id = film_actor.actor_id
join film on film_actor.film_id = film.film_id
WHERE film.title LIKE 'ZOOLANDER FICTION';

#6
SELECT address, city.city, country.country 
FROM store
JOIN address ON store.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE store.store_id = 1;
#7
SELECT f1.title, f2.title, f1.`rating` 
  FROM film f1, film f2
WHERE f1.`rating` = f2.`rating` AND f1.film_id <> f2.film_id;

#8
SELECT film.title, staff.first_name, staff.last_name 
FROM inventory
JOIN film ON inventory.film_id = film.film_id
JOIN store ON inventory.store_id = store.store_id
JOIN staff ON store.manager_staff_id = staff.staff_id
WHERE inventory.store_id = 2;