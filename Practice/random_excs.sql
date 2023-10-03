-- Active: 1696090225772@@127.0.0.1@3306@sakila
use sakila;

#clase 13 ej 3

UPDATE film SET release_year = 2001 WHERE rating = 'G'

/* clase 13 ej6
Rent a film

Find an inventory id that is available for rent (available in store) pick any movie. Save this id somewhere.
Add a rental entry
Add a payment entry
Use sub-queries for everything, except for the inventory id that can be used directly in the queries.

*/

#1865
SELECT distinct inventory_id FROM inventory join rental r USING(inventory_id) WHERE film_id = 407 AND r.rental_date is not null;

INSERT INTO rental(rental_date, inventory_id, customer_id, staff_id)
SELECT CURRENT_TIMESTAMP, 
(1865),
(SELECT customer_id FROM customer ORDER BY customer_id DESC LIMIT 1),
(SELECT staff_id FROM staff  JOIN store s USING(store_id) JOIN inventory i USING(store_id) WHERE i.inventory_id = 1865 AND s.store_id = i.store_id);

INSERT INTO payment(payment_date, customer_id, staff_id, rental_id, amount)
SELECT CURRENT_TIMESTAMP,
(SELECT customer_id FROM customer ORDER BY customer_id DESC LIMIT 1),
(SELECT staff_id FROM staff  JOIN store s USING(store_id) JOIN inventory i USING(store_id) WHERE i.inventory_id = 1865 AND s.store_id = i.store_id),
(SELECT LAST_INSERT_ID()), #Tambien se puede buscar como (select max(rental_id) from rental)
200;

/* clase 14 ej 6
Find all the rentals done in the months of May and June. Show the film title, customer name and if it was returned or not. 
There should be returned column with two possible values 'Yes' and 'No'.
*/

SELECT f.title, CONCAT(c.first_name, ' ', c.last_name) as Cliente,
CASE 
    WHEN r.return_date is null THEN 'NO'
    ELSE 'YES'
END as returned
FROM rental r
JOIN customer c USING(customer_id)
JOIN inventory USING(inventory_id)
JOIN film f USING(film_id)
WHERE MONTH(r.rental_date) = 5 or MONTH(r.rental_date) = 6
;

/* clase 15 ej 4
Create a view called actor_information where it should return: 
actor id, first name, last name and the amount of films he/she acted on.
*/

CREATE or REPLACE view actor_information AS
SELECT actor_id, a.first_name, a.last_name, COUNT(film_id) FROM film_actor
JOIN actor a USING(actor_id)
GROUP BY actor_id;

/* clase 15 ej 3
Create view sales_by_film_category, it should return 'category' and 'total_rental' columns.
*/

CREATE or REPLACE view sales_by_film_category AS
SELECT c.name, COUNT(rental_id) as rentas, SUM(p.amount) as dinero FROM rental
JOIN payment p USING(rental_id)
JOIN inventory i USING(inventory_id)
JOIN film USING(film_id)
join film_category USING(film_id)
JOIN category c USING(category_id)
GROUP BY c.name;

SELECT * FROM sales_by_film_category

/*  CLASE 18 FUNCTIONS & PROCEDURES*/

#-------------- RENTAR UNA PELICULA EJ COMBINADO ---------------
DELIMITER $$
create function get_staff_id_by_inventory_id(inv_id int) RETURNS INT
DETERMINISTIC
BEGIN

    DECLARE id_staff int;
    SELECT st.staff_id into id_staff
    FROM store s
    JOIN staff st USING(store_id)
    JOIN inventory i USING(store_id)
    WHERE i.inventory_id = inv_id AND s.store_id = st.store_id;

    RETURN(id_staff);

END $$
DELIMITER ;

SELECT get_staff_id_by_inventory_id();

DELIMITER $$
CREATE Procedure rent_film(IN cust_id int, in inv_id int)
BEGIN

DECLARE id_staff INT;
SELECT get_staff_id_by_inventory_id(inv_id) into id_staff;

INSERT INTO rental(rental_date, inventory_id, customer_id, staff_id)
SELECT CURRENT_TIMESTAMP, 
(inv_id),
(cust_id),
(id_staff);

INSERT INTO payment(payment_date, customer_id, staff_id, rental_id, amount)
SELECT CURRENT_TIMESTAMP,
(cust_id),
(id_staff),
(SELECT LAST_INSERT_ID()),
200;

END $$
DELIMITER ;

CALL rent_film(500, 1);

#-------------- RENTAR UNA PELICULA EJ COMBINADO ---------------
