DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix(

show_id	VARCHAR(5),
type VARCHAR(15),
title VARCHAR(150),
director VARCHAR(208),
castS VARCHAR(1000),
country	VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description VARCHAR(250)

)

SELECT * FROM netflix;

-- Business Problems
-- 1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*) as total_content FROM netflix
GROUP BY type

-- 2. Find the most common rating for movies and TV shows

SELECT type, rating FROM (
SELECT type, rating, COUNT(*), RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking FROM netflix
GROUP BY 1, 2
) AS t1

WHERE ranking = 1

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT title, release_year, type FROM netflix
WHERE type = 'Movie'
	AND release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix

SELECT UNNEST(STRING_TO_ARRAY(country, ',')) as new_country, COUNT(*) as total_content FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. Identify the longest movie


SELECT * FROM netflix
WHERE type = 'Movie'
	AND 
	duration = (SELECT MAX(duration) FROM netflix)

-- 6. Find content added in the last 5 years

SELECT *, TO_DATE(date_added, 'Month DD, YYYY') as parsed_date FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- 7. Find all the movies/TV shows by director 'Christopher Nolan'!

SELECT * FROM netflix
WHERE director LIKE '%Christopher Nolan%'


-- 8. List all TV shows with more than 5 seasons

SELECT *, SPLIT_PART(duration, ' ', 1) as seasons FROM netflix
WHERE type = 'TV Show'
	AND 
	SPLIT_PART(duration, ' ', 1):: numeric > 5


-- 9. Count the number of content items in each genre

SELECT COUNT(show_id) as total_content, UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre FROM netflix
GROUP BY 2

-- 10.Find each year and the average numbers of content release in United States on netflix. 

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year, 
	COUNT(*) AS yearly_content, 
	ROUND(COUNT(*):: numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'United States'):: numeric * 100, 2) as avg_content_per_year
FROM netflix
WHERE country = 'United States'
GROUP BY 1


-- 11. List all movies that are documentaries

SELECT *FROM netflix
WHERE type = 'Movie'
	AND 
	listed_in ILIKE '%Documentaries%'

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS null

-- 13. Find how many movies actor 'Brad Pitt' appeared in last 10 years!

SELECT *, TO_DATE(date_added, 'Month DD, YYYY') as parsed_date FROM netflix
WHERE type = 'Movie'
	AND
	casts ILIKE '%Brad Pitt%'
	AND 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '10 years'

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in United States.

SELECT  UNNEST(STRING_TO_ARRAY(casts, ',')) as actors, COUNT(show_id) as num_movies FROM netflix
WHERE type = 'Movie'
	AND 
	country ILIKE '%United States'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

WITH new_table
AS
(
SELECT *,
	CASE
	WHEN description ILIKE '%Kill%'
	OR
	description ILIKE '%violence%' THEN 'Bad Content'
	ELSE 'Good Content'
	END category
FROM netflix
)

SELECT 
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1
