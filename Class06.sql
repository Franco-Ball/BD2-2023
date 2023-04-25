-- Active: 1652961517460@@127.0.0.1@3306
use sakila;
#1
SELECT a1.first_name, a1.last_name 
FROM actor a1
WHERE EXISTS (SELECT * 
              FROM actor a2 
              WHERE a1.last_name = a2.last_name AND a1.actor_id != a2.actor_id)
ORDER BY a1.last_name;

#2
SELECT a1.first_name, a1.last_name 
FROM actor a1 
WHERE not EXISTS (SELECT fa.actor_id 
                  FROM film_actor fa 
                  WHERE a1.actor_id = fa.actor_id);

#3
SELECT c1.first_name, c1.last_name 
FROM customer c1
WHERE ( SELECT count(*) 
        FROM rental r 
        WHERE c1.customer_id = r.customer_id) = 1;

#4
SELECT c1.first_name, c1.last_name 
FROM customer c1
WHERE ( SELECT count(*) 
        FROM rental r 
        WHERE c1.customer_id = r.customer_id) > 1;

#5
SELECT a1.first_name, a1.last_name 
FROM actor a1
WHERE EXISTS (SELECT * 
              FROM film f 
              join film_actor fa on f.film_id = fa.film_id
              WHERE f.film_id = fa.film_id AND a1.actor_id = fa.actor_id 
              AND (f.title = 'BETRAYED REAR' or f.title = 'CATCH AMISTAD'))
order BY last_name;

#6
SELECT a1.first_name, a1.last_name 
FROM actor a1
WHERE EXISTS (SELECT * 
              FROM film f 
              join film_actor fa on f.film_id = fa.film_id
              WHERE f.film_id = fa.film_id AND a1.actor_id = fa.actor_id 
              AND f.title = 'BETRAYED REAR') 
              AND not EXISTS (SELECT * 
                              FROM film f
                              join film_actor fa on f.film_id = fa.film_id
                              WHERE f.film_id = fa.film_id AND a1.actor_id = fa.actor_id 
                              AND f.title = 'CATCH AMISTAD')
ORDER BY last_name;

#7
SELECT a1.first_name, a1.last_name 
FROM actor a1
WHERE EXISTS (SELECT * 
              FROM film f 
              join film_actor fa on f.film_id = fa.film_id
              WHERE f.film_id = fa.film_id AND a1.actor_id = fa.actor_id 
              AND f.title = 'BETRAYED REAR') 
              AND EXISTS (SELECT * 
                              FROM film f
                              join film_actor fa on f.film_id = fa.film_id
                              WHERE f.film_id = fa.film_id AND a1.actor_id = fa.actor_id 
                              AND f.title = 'CATCH AMISTAD')
ORDER BY last_name;

#8
SELECT a1.first_name, a1.last_name 
FROM actor a1
WHERE not EXISTS (SELECT * 
              FROM film f 
              join film_actor fa on f.film_id = fa.film_id
              WHERE f.film_id = fa.film_id AND a1.actor_id = fa.actor_id 
              AND (f.title = 'BETRAYED REAR' or f.title = 'CATCH AMISTAD'))
order BY last_name;