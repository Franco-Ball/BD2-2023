-- Active: 1652961517460@@127.0.0.1@3306
use sakila;
#1
SELECT co.country, count(ci.city) AS cant_city 
FROM country co 
JOIN city ci ON co.country_id = ci.country_id 
GROUP BY co.country 
ORDER BY co.country;

#2
SELECT co.country, count(ci.city) AS cant_city 
FROM country co
JOIN city ci ON co.country_id = ci.country_id 
GROUP BY co.country
HAVING count(ci.city) > 10
ORDER BY cant_city DESC;

#3
SELECT c.first_name, c.last_name, a.address,(SELECT COUNT(*) 
                                            FROM rental r 
                                            WHERE c.customer_id = r.customer_id) AS cant_films,(SELECT SUM(p.amount) 
                                                                                                FROM payment p 
                                                                                                WHERE c.customer_id = p.customer_id) AS money_spent 
FROM customer c
JOIN address a ON c.address_id = a.address_id
GROUP BY c.first_name, c.last_name, a.address, c.customer_id
ORDER BY money_spent DESC;

#4
SELECT c.name , AVG(f.length) AS film_duration_avg 
FROM film f JOIN film_category fc ON fc.film_id = f.film_id JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY film_duration_avg DESC;

#5
SELECT f.rating, COUNT(p.payment_id) AS sales
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id 
GROUP BY rating
ORDER BY sales DESC;