-- Active: 1652961517460@@127.0.0.1@3306@sakila
use sakila;

describe rental;

#Class11
#Find all the film titles that are not in the inventory.

SELECT f.title , f.film_id
FROM film f
where not exists (SELECT * 
                    FROM inventory i
                    WHERE i.film_id = f.film_id);


#Find all the films that are in the inventory but were never rented.
#Show title and inventory_id.
#This exercise is complicated.
#hint: use sub-queries in FROM and in WHERE or use left join and ask if one of the fields is null


SELECT f.title , f.film_id
FROM film f
where exists (SELECT * 
                    FROM inventory i
                    WHERE i.film_id = f.film_id and not exists (SELECT * 
                                                    from rental r
                                                    WHERE i.inventory_id = r.inventory_id))
;


select f.title, i2.inventory_id
from film as f
         inner join inventory i2 on f.film_id = i2.film_id
where exists(select i.film_id
             from inventory as i
             where i.film_id = f.film_id
               and not exists(select r.inventory_id from rental as r where r.inventory_id = i.inventory_id));




#Generate a report with:
#customer (first, last) name, store id, film title,
#when the film was rented and returned for each of these customers
#order by store_id, customer last_name
#Show sales per store (money of rented films)



#show stores city, country, manager info and total sales (money)
#(optional) Use concat to show city and country and manager first and last name

SELECT s.store_id, ct.city, co.country, stf.last_name, (SELECT sum(p.amount) FROM payment p where p.staff_id = stf.staff_id) as money_raised
FROM store s
inner join address a on s.address_id = a.address_id
inner join city ct on a.city_id = ct.city_id
inner join country co on ct.country_id = co.country_id
inner join staff stf on s.manager_staff_id = stf.staff_id
;
#Which actor has appeared in the most films?

SELECT CONCAT(a.first_name, ' ', a.last_name) as name, count(fa.actor_id) as Peliculas
FROM actor a
inner join film_actor fa on a.actor_id = fa.actor_id
group by a.actor_id
HAVING Peliculas >= all (SELECT count(fa.actor_id) 
                        FROM actor a
                        inner join film_actor fa on a.actor_id = fa.actor_id
                        GROUP BY a.actor_id)
;