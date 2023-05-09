-- Active: 1652961517460@@127.0.0.1@3306
use sakila;
#1
SELECT title, rating, length as min_length
FROM film f1
WHERE length <= All (SELECT length
                    FROM film f2
                    WHERE f2.film_id <> f1.film_id);

#2
SELECT title
FROM film AS f1
WHERE length <= (SELECT MIN(length) 
                FROM film)
AND NOT EXISTS(SELECT * 
              FROM film AS f2 
              WHERE f2.film_id <> f1.film_id AND f2.length <= f1.length);

#3
SELECT first_name, last_name, MIN(p.amount) AS lowest_payment
FROM customer
INNER JOIN payment p ON customer.customer_id = p.customer_id
INNER JOIN address a ON customer.address_id = a.address_id
GROUP BY first_name, last_name;
#4
SELECT first_name, last_name, a.address, MIN(p.amount) AS lowest_payment, MAX(p.amount) AS highest_payment
FROM customer
INNER JOIN payment p ON customer.customer_id = p.customer_id
INNER JOIN address a ON customer.address_id = a.address_id
GROUP BY first_name, last_name, a.address;