-- Active: 1652961517460@@127.0.0.1@3306@sakila
use sakila;

DESCRIBE staff;

show tables;

#Show title and special_features of films that are PG-13

SELECT title, special_features, rating
FROM film
WHERE rating = "PG-13";

#Get a list of all the different films duration.

SELECT DISTINCT title, LENGTH
FROM film;

#Show title, rental_rate and replacement_cost of films that have replacement_cost from 20.00 up to 24.00

SELECT title, rental_rate, replacement_cost
FROM film
WHERE replacement_cost BETWEEN 20.00 and 24.00
order by replacement_cost;

#Show title, category and rating of films that have 'Behind the Scenes' as special_features

SELECT title, c.name, rating, special_features
FROM film
JOIN film_category fc ON film.film_id = fc.film_id
join category c on fc.category_id = c.category_id
WHERE special_features = 'Behind the Scenes';

#Show first name and last name of actors that acted in 'ZOOLANDER FICTION'

SELECT first_name, last_name
FROM actor
join film_actor fa on fa.actor_id = actor.actor_id
JOIN film f on f.film_id = fa.film_id
WHERE title = 'ZOOLANDER FICTION';

#Show the address, city and country of the store with id 1

SELECT address, ct.city, co.country
FROM address
JOIN store on store.address_id = address.address_id
JOIN city ct ON ct.city_id = address.city_id
JOIN country co on co.country_id = ct.country_id
where store_id = 1;

#Show pair of film titles and rating of films that have the same rating.

SELECT f1.title, f1.rating, f2.title
FROM film f1, film f2
WHERE f1.film_id != f2.film_id and f1.rating = f2.rating;

#Get all the films that are available in store id 2 and the manager first/last name of this store (the manager will appear in all the rows).

SELECT title, staff.first_name, staff.last_name
FROM film
join inventory i on i.film_id = film.film_id
join store s on s.store_id = i.store_id
JOIN staff on staff.staff_id = s.manager_staff_id
WHERE s.store_id = 2;
---------------------------------------------------------------------------
#CLASE 6

#List all the actors that share the last name. Show them in order

SELECT a1.first_name, a1.last_name
FROM actor a1
WHERE EXISTS (SELECT * 
                FROM actor a2
                WHERE a2.actor_id <> a1.actor_id and a2.last_name = a1.last_name)
order by a1.last_name asc;

#Find actors that dont work in any film

SELECT a1.last_name 
FROM actor a1
where not exists (SELECT * 
                FROM film_actor fa
                where fa.actor_id = a1.actor_id);

#Find customers that rented only one film

SELECT c.last_name 
FROM customer c
where (SELECT count(*) 
        FROM rental r
        where c.customer_id = r.customer_id) = 1;

#Find customers that rented more than one film

SELECT c.last_name 
FROM customer c
where (SELECT count(*) 
        FROM rental r
        where c.customer_id = r.customer_id) > 1;

#List the actors that acted in 'BETRAYED REAR' or in 'CATCH AMISTAD'

SELECT a1.last_name 
FROM actor a1
where exists (SELECT * 
        FROM film f
        join film_actor fa on f.film_id = fa.film_id
        where a1.actor_id = fa.actor_id and fa.film_id = f.film_id 
        and (f.title = "BETRAYED REAR" or f.title = "CATCH AMISTAD"));

#List the actors that acted in 'BETRAYED REAR' but not in 'CATCH AMISTAD'

SELECT a1.last_name 
FROM actor a1
where exists (SELECT * 
        FROM film f
        join film_actor fa on f.film_id = fa.film_id
        where a1.actor_id = fa.actor_id and fa.film_id = f.film_id 
        and f.title = "BETRAYED REAR")
and not EXISTS (SELECT * 
        FROM film f
        join film_actor fa on f.film_id = fa.film_id
        where a1.actor_id = fa.actor_id and fa.film_id = f.film_id 
        and f.title = "CATCH AMISTAD");

#List the actors that acted in both 'BETRAYED REAR' and 'CATCH AMISTAD'

SELECT a1.last_name 
FROM actor a1
where exists (SELECT * 
        FROM film f
        join film_actor fa on f.film_id = fa.film_id
        where a1.actor_id = fa.actor_id and fa.film_id = f.film_id 
        and f.title = "BETRAYED REAR")
and EXISTS (SELECT * 
        FROM film f
        join film_actor fa on f.film_id = fa.film_id
        where a1.actor_id = fa.actor_id and fa.film_id = f.film_id 
        and f.title = "CATCH AMISTAD");

#List all the actors that didnt work in 'BETRAYED REAR' or 'CATCH AMISTAD'

SELECT a1.last_name 
FROM actor a1
where NOT exists (SELECT * 
        FROM film f
        join film_actor fa on f.film_id = fa.film_id
        where a1.actor_id = fa.actor_id and fa.film_id = f.film_id 
        and f.title = "BETRAYED REAR")
and NOT EXISTS (SELECT * 
        FROM film f
        join film_actor fa on f.film_id = fa.film_id
        where a1.actor_id = fa.actor_id and fa.film_id = f.film_id 
        and f.title = "CATCH AMISTAD");

----------------------------------------------------------------------
#Class07
#Find the films with less duration, show the title and rating.

SELECT title 
FROM film
WHERE length <= ALL (SELECT LENGTH FROM film);

#Write a query that returns the title of the film which duration is the lowest. If there are more than one film with the lowest durtation, the query returns an empty resultset.

SELECT f.title 
FROM film f
WHERE f.length = (SELECT MIN(LENGTH) FROM film)
and not EXISTS (SELECT * 
                FROM film f2
                where f2.film_id <> f.film_id and f.LENGTH = f2.LENGTH)
;

#Generate a report with list of customers showing the lowest payments done by each of them. Show customer information, the address and the lowest amount, provide both solution using ALL and/or ANY and MIN.

SELECT c.last_name, (SELECT MIN(p.amount) from payment p WHERE p.customer_id = c.customer_id), a.address
FROM customer c
join address a on c.address_id = a.address_id
order by c.last_name asc
;

SELECT DISTINCT c.last_name, p.amount
FROM customer c
join payment p on c.customer_id = p.customer_id
WHERE p.amount <= ALL (SELECT p.amount from payment p WHERE p.customer_id = c.customer_id)
;
#Generate a report that shows the customers information with the highest payment and the lowest payment in the same row.

SELECT c.last_name, (SELECT MIN(p.amount) from payment p WHERE p.customer_id = c.customer_id), (SELECT MAX(p.amount) from payment p where p.customer_id = c.customer_id),a.address
FROM customer c
join address a on c.address_id = a.address_id
order by c.last_name asc
;

describe country;

---------------------------------------------------------------------------
#Class09

#Get the amount of cities per country in the database. Sort them by country, country_id.

SELECT c.country_id, c.country ,(SELECT count(*) from city ct WHERE c.country_id = ct.country_id) as City_cant
FROM country c
order by c.country_id, c.country;

#Get the amount of cities per country in the database. Show only the countries with more than 10 cities, order from the highest amount of cities to the lowest

SELECT c.country , count(ct.city) as City_cant
FROM country c
join city ct on c.country_id = ct.country_id
GROUP BY c.country
HAVING City_cant > 10
ORDER BY City_cant desc;

#Generate a report with customer (first, last) name, address, total films rented and the total money spent renting films.
#Show the ones who spent more money first .

SELECT c.first_name, c.last_name, a.address, Count(r.customer_id) as cant_rented, SUM(p.amount) as cant_spent
FROM customer c
join rental r on c.customer_id = r.customer_id
join payment p on r.rental_id = p.rental_id
join address a on c.address_id = a.address_id
group by c.first_name, c.last_name, a.address
ORDER BY cant_spent desc
;

#Which film categories have the larger film duration (comparing average)?
#Order by average in descending order

SELECT cat.name, AVG(f.length) as avg_length
FROM category cat
join film_category fc on cat.category_id = fc.category_id
join film f on fc.film_id = f.film_id
group by cat.name
ORDER BY avg_length desc
;

SELECT cat.name, (SELECT AVG(f.length) from film f join film_category fc on f.film_id = fc.film_id where fc.category_id = cat.category_id) as avg_length
FROM category cat
order by avg_length desc
;

#Show sales per film rating

SELECT f.rating, count(r.rental_id) as sales
FROM film f
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
group by f.rating
order by sales desc
;

#Show money raised with each rating
SELECT f.rating, SUM(p.amount) as money_raised
FROM film f
join inventory i on f.film_id = i.film_id
join rental r on i.inventory_id = r.inventory_id
join payment p on r.rental_id = p.rental_id
group by f.rating
order by money_raised desc
;

describe rental;
-----------------------------------------------------------
