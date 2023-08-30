-- Active: 1652961517460@@127.0.0.1@3306@sakila
use sakila;
#1 
SELECT a.address, a.postal_code, ci.city, co.country
FROM address AS a
JOIN city AS ci ON a.city_id = ci.city_id
JOIN country AS co ON ci.country_id = co.country_id
WHERE a.postal_code IN ('40195', '93323', '91400');
#16ms

SELECT a.address, a.postal_code, ci.city, co.country
FROM address AS a
JOIN city AS ci ON a.city_id = ci.city_id
JOIN country AS co ON ci.country_id = co.country_id
WHERE a.postal_code NOT IN ('40195', '93323', '91400');
#38ms
CREATE INDEX PostalCode ON address(postal_code);
#Primera query despues del index =11ms, la segunda = 15ms
#El index crea una lista que le ahorra a la base de datos el tener que recorrer todo otra vez para hacer la query


#2
SELECT first_name
FROM actor
ORDER BY first_name;
#16ms

SELECT last_name
FROM actor
ORDER BY last_name;
#9ms
#la query donde se ordena por nombre es mas lenta porque no existe un index en sakila
#mientras que para el apellido si, por lo que esta es mas rapida

#3

SELECT description
FROM film
WHERE description LIKE "%Character%"
ORDER BY description;
# 105ms

#para usar match y against, hay que crear el index "Fulltext_idx"
CREATE FULLTEXT INDEX FullText_idx ON film(description);

SELECT description
FROM film
WHERE MATCH(description) AGAINST("Character")
ORDER BY description;
# 26ms
#la segunda query es mucho mas rapida que la primera pq no recorre toda la tabla film sino que directamente usa el indice y se ahorra toda la comparacion
