-- Active: 1652961517460@@127.0.0.1@3306@sakila
use sakila;

#1

DROP FUNCTION IF EXISTS get_film_copy_count;

DELIMITER //

CREATE FUNCTION get_film_copy_count(FILM_IDENTIFIER VARCHAR(255), STORE_ID INT) RETURNS INT READS SQL DATA
BEGIN 
	DECLARE film_count INT;
	SELECT COUNT(*) INTO film_count
	FROM inventory i
	JOIN film f ON i.film_id = f.film_id
	WHERE (f.film_id = film_identifier OR f.title = film_identifier)
    AND i.store_id = store_id;
	RETURN film_count;
	END
//
DELIMITER ;

SELECT get_film_copy_count(9, 1);
SELECT get_film_copy_count('ACADEMY DINOSAUR', 2);

#2 

DROP PROCEDURE IF EXISTS get_customers_in_country;

DELIMITER //

CREATE PROCEDURE get_customers_in_country(IN country_name VARCHAR(50), OUT customer_list VARCHAR(255))
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE first_name_c VARCHAR(50);
    DECLARE last_name_c VARCHAR(50);
    DECLARE country VARCHAR(250);

   
    DECLARE cur CURSOR FOR
        SELECT first_name, last_name, co.country
        FROM customer cu
        JOIN `address` ad ON cu.address_id = ad.address_id
        JOIN city ci ON ad.city_id = ci.city_id
        JOIN country co ON ci.country_id = co.country_id
        WHERE co.country = country_name;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    
    SET customer_list = '';
    OPEN cur;
    
    loop_label: LOOP
        FETCH cur INTO first_name_c, last_name_c;
        
        IF done THEN
            LEAVE loop_label;
        END IF;
        
        IF country = country_name THEN
			SET customer_list = CONCAT(f_name,' ', l_name, ' ; ', customer_list);
		END IF;
        
    END LOOP;
    
    CLOSE cur;
END;
//
DELIMITER ;

SET @list = '';
CALL get_customers_in_country('Argentina', @list);
SELECT @list;

#3 

/*
 Cuando llamamos a la funcion "inventory_in_stock" esta devuelve verdadero o falso dependiendo de si el articulo  del inventario que le pasamos por parametro está en stock o no teniendo en cuenta los alquileres relacionados.
 Esta funcion busca el id que le pasamos por parametro entre los ids de la tabla rental, si lo encuentra devuelve falso y si no devuelve verdadero
 Cuando usamos el procedimiento "film_in_stock" este nos permite saber si una pelicula está en stock en una determinada tienda gracias a los paramentros que ingresamos
 para usar este procedimiento hay que pasarle "film_id" y "store_id", luego busca en la tabla del inventario con esos datos y llama a la funcion "inventory_in_stock".
 Si encuentra el id de la pelicula y de la store que mandamos y "inventory_in_stock" resulta verdadero este procedimiento nos devuelve la cantidad de copias disponibles
*/