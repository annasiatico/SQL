USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(UCASE(first_name), " ",UCASE(last_name)) as "Actor Name" from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What 
-- is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`
SELECT first_name, last_name from actor
where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, 
-- in that order
SELECT first_name, last_name from actor
where last_name like "%LI%"
order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, 
-- and China
SELECT country_id, country from country
where country in ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the 
-- type `BLOB`, as the difference between it and `VARCHAR` are significant)
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) as 'count_of_last_name' from actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names 
-- that are shared by at least two actors
SELECT last_name, count(last_name) as 'count_of_last_name' from actor
GROUP BY last_name
HAVING count(last_name) >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a 
-- query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name 
-- after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` 
-- and `address`
SELECT s.first_name, s.last_name, a.address as address from staff s
JOIN address a ON s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` 
-- and `payment`.
SELECT s.first_name, s.last_name, SUM(p.amount) as total_amount from staff s
JOIN payment p ON s.staff_id = p.staff_id
WHERE p.payment_date BETWEEN '2005-08-01 12:00:00 AM' AND '2005-09-01 12:00:00 AM'
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. 
-- Use inner join.
SELECT title, count(fa.actor_id) as number_of_actors from film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(i.film_id) as current_inventory from film f
INNER JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) as 'Total Amount Paid' from customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY p.customer_id
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles 
-- of movies starting with the letters `K` and `Q` whose language is English.
SELECT title from film 
WHERE (title LIKE "K%" OR title LIKE "Q%") 
AND language_id IN (SELECT language_id FROM language WHERE name = "English");

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT a.first_name, a.last_name from actor a
WHERE actor_id IN
(SELECT actor_id FROM film_actor WHERE film_id IN
	(SELECT film_id FROM film WHERE title = 'ALONE TRIP'));
    
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
-- of all Canadian customers. Use joins to retrieve this information.
SELECT cu.first_name, cu.last_name, cu.email, co.country from customer cu
JOIN address a ON cu.address_id = a.address_id
JOIN city c ON c.city_id = a.city_id
JOIN country co ON co.country_id = c.country_id
WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
SELECT f.title, c.name as category from film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, count(i.film_id) AS "Number of Rentals" FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY count(i.film_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
	   s.store_id,
	   CONCAT(c.city, ", ", co.country) AS store_location,
	   CONCAT(st.first_name, " ", st.last_name) AS manager,
       CONCAT("$", FORMAT(SUM(p.amount), 2)) AS total_sales
FROM
	   payment p
       JOIN rental r ON p.rental_id = r.rental_id
       JOIN inventory i ON r.inventory_id = i.inventory_id
       JOIN store s ON i.store_id = s.store_id
       JOIN address a ON s.address_id = a.address_id
       JOIN city c ON a.city_id = c.city_id
       JOIN country co ON c.country_id = co.country_id
       JOIN staff st ON s.manager_staff_id = st.staff_id
GROUP BY s.store_id;
    
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, co.country FROM city c
JOIN address a ON a.city_id = c.city_id
JOIN store s ON s.address_id = a.address_id
JOIN country co ON c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following 
-- tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS gross_revenue FROM category c 
JOIN film_category f ON c.category_id = f.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross 
-- revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute 
-- another query to create a view.
create view top_five_genres as 
SELECT c.name as genre, SUM(p.amount) AS gross_revenue FROM category c 
JOIN film_category f ON c.category_id = f.category_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view if exists top_five_genres;






