-- Active: 1652961517460@@127.0.0.1@3306@IMDB
CREATE DATABASE IMDB
    DEFAULT CHARACTER SET = 'utf8mb4';

USE IMDB;

create table film(
    film_id int not null AUTO_INCREMENT PRIMARY KEY,
    title varchar(50),
    description VARCHAR(255),
    release_year YEAR
);

create table actor(
    actor_id int not null AUTO_INCREMENT PRIMARY KEY,
    first_name varchar(30),
    last_name varchar(30)
);

CREATE Table film_actor(
    id int not null AUTO_INCREMENT PRIMARY KEY,
    actor_id int,
    film_id int
);

ALTER Table actor ADD last_update VARCHAR(30);
ALTER Table film ADD last_update VARCHAR(30);

alter Table film_actor add constraint fk_film_id Foreign Key (film_id) REFERENCES film(film_id);
alter Table film_actor add constraint fk_actor_id Foreign Key (actor_id) REFERENCES actor(actor_id);

INSERT INTO film(title, description, release_year, last_update) VALUES("VENOM", "While trying to take down Carlton, the CEO of Life Foundation, Eddie, a journalist, investigates experiments of human trials. Unwittingly, he gets merged with a symbiotic alien with lethal abilities.", 2018,"No recent updates");

INSERT INTO actor(first_name, last_name, last_update) VALUES("Tom", "Hardy", "No recent updates");

INSERT INTO actor(first_name, last_name, last_update) VALUES("Michelle", "Williams", "No recent updates");

INSERT INTO film(title, description, release_year, last_update) VALUES("INCEPTION", "Cobb steals information from his targets by entering their dreams. Saito offers to wipe clean Cobb's criminal history as payment for performing an inception on his sick competitor's son.", 2010,"No recent updates");

INSERT INTO actor(first_name, last_name, last_update) VALUES("Leonardo", "DiCaprio", "No recent updates");
