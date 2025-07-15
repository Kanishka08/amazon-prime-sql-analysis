create database amazon_prime_db;

use amazon_prime_db;

CREATE TABLE amazon (
    show_id VARCHAR(10),
    type VARCHAR(20),
    title VARCHAR(255),
    director VARCHAR(255),
    cast TEXT,
    country VARCHAR(100),
    date_added VARCHAR(100),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(50),
    listed_in VARCHAR(255),
    description TEXT
);
 

-- LOAD DATA LOCAL INFILE 'D:/projects/amazon/amazon_prime_titles.csv'
-- INTO TABLE amazon
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

select * from amazon;

SET SQL_SAFE_UPDATES = 0;

-- missing values handling
UPDATE amazon 
SET 
	director = NULLIF(director, ''),
    date_added = NULLIF(date_added, ''),
    cast = NULLIF(cast, ''),
    country = NULLIF(country, ''),
    rating = NULLIF(rating, '');
    
-- date column
ALTER TABLE amazon ADD COLUMN new_date_added DATE;
UPDATE amazon
SET new_date_added = STR_TO_DATE(date_added, '%M %d, %Y');    


-- 1.movies vs tv shows 
SELECT type, COUNT(*) AS total_titles
FROM amazon
GROUP BY type;

-- 2.common ratings for movies and tv shows
SELECT rating, COUNT(*) AS rating_count
FROM amazon
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY rating_count DESC;

-- 3.distribution of content rating by age group
WITH standardized_ratings AS (
    SELECT 
        CASE 
            WHEN rating IN ('TV-Y', 'TV-Y7', 'G', 'TV-G', 'ALL', 'ALL_AGES') THEN 'Kids (0-6)'
            WHEN rating IN ('7+', 'PG', 'TV-PG', 'TV-NR') THEN 'Young Teens (7-12)'
            WHEN rating IN ('13+', 'PG-13', 'TV-14', 'AGES_16_', '16') THEN 'Teens (13-17)'
            WHEN rating IN ('16+', '18+', 'TV-MA', 'NC-17', 'R', 'UNRATED', 'NOT_RATE', 'AGES_18_') THEN 'Adults (18+)'
            ELSE 'Unknown'
        END AS age_group,
        COUNT(*) AS total_titles
    FROM amazon
    WHERE rating IS NOT NULL
    GROUP BY age_group
)
SELECT age_group, total_titles,
       RANK() OVER (ORDER BY total_titles DESC) AS age_rank
FROM standardized_ratings
ORDER BY age_rank;

-- 4.common release month for content
SELECT DATE_FORMAT(new_date_added, '%M') AS release_month, COUNT(*) as total_content
FROM amazon
WHERE new_date_added IS NOT NULL
GROUP BY release_month
ORDER BY total_content DESC;

-- 5.prime content grown over years
WITH decade_wise_growth AS (
    SELECT 
        CASE 
            WHEN release_year BETWEEN 1920 AND 1929 THEN '1920s'
            WHEN release_year BETWEEN 1930 AND 1939 THEN '1930s'
            WHEN release_year BETWEEN 1940 AND 1949 THEN '1940s'
            WHEN release_year BETWEEN 1950 AND 1959 THEN '1950s'
            WHEN release_year BETWEEN 1960 AND 1969 THEN '1960s'
            WHEN release_year BETWEEN 1970 AND 1979 THEN '1970s'
            WHEN release_year BETWEEN 1980 AND 1989 THEN '1980s'
            WHEN release_year BETWEEN 1990 AND 1999 THEN '1990s'
            WHEN release_year BETWEEN 2000 AND 2009 THEN '2000s'
            WHEN release_year BETWEEN 2010 AND 2019 THEN '2010s'
            WHEN release_year BETWEEN 2020 AND 2029 THEN '2020s'
            ELSE 'Unknown'
        END AS decade,
        COUNT(*) AS total_titles
    FROM amazon
    WHERE release_year IS NOT NULL
    GROUP BY decade
)
SELECT * FROM decade_wise_growth ORDER BY decade;

-- 6.are newer movies getting better ratings than older ones
SELECT 
    CASE 
        WHEN release_year BETWEEN 1920 AND 1929 THEN '1920s'
        WHEN release_year BETWEEN 1930 AND 1939 THEN '1930s'
        WHEN release_year BETWEEN 1940 AND 1949 THEN '1940s'
        WHEN release_year BETWEEN 1950 AND 1959 THEN '1950s'
        WHEN release_year BETWEEN 1960 AND 1969 THEN '1960s'
        WHEN release_year BETWEEN 1970 AND 1979 THEN '1970s'
        WHEN release_year BETWEEN 1980 AND 1989 THEN '1980s'
        WHEN release_year BETWEEN 1990 AND 1999 THEN '1990s'
        WHEN release_year BETWEEN 2000 AND 2009 THEN '2000s'
        WHEN release_year BETWEEN 2010 AND 2019 THEN '2010s'
        WHEN release_year BETWEEN 2020 AND 2021 THEN '2020s'
        ELSE 'Other' 
    END AS decade,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(*) AS total_content
FROM amazon
WHERE rating IS NOT NULL
GROUP BY decade
ORDER BY decade DESC;

-- 7.top 5 popular genres
SELECT category, total_titles, 
       RANK() OVER (ORDER BY total_titles DESC) AS genre_rank
FROM (
    SELECT 'Action' AS category, 
           SUM(CASE WHEN listed_in LIKE '%Action%' THEN 1 ELSE 0 END) AS total_titles
    FROM amazon
    UNION ALL
    SELECT 'Drama', 
           SUM(CASE WHEN listed_in LIKE '%Drama%' THEN 1 ELSE 0 END) 
    FROM amazon
    UNION ALL
    SELECT 'Comedy', 
           SUM(CASE WHEN listed_in LIKE '%Comedy%' THEN 1 ELSE 0 END) 
    FROM amazon
    UNION ALL
    SELECT 'Documentary', 
           SUM(CASE WHEN listed_in LIKE '%Documentary%' THEN 1 ELSE 0 END) 
    FROM amazon
    UNION ALL
    SELECT 'Romance', 
           SUM(CASE WHEN listed_in LIKE '%Romance%' THEN 1 ELSE 0 END) 
    FROM amazon
    UNION ALL
    SELECT 'Horror', 
           SUM(CASE WHEN listed_in LIKE '%Horror%' THEN 1 ELSE 0 END) 
    FROM amazon
    UNION ALL
    SELECT 'Sci-Fi', 
           SUM(CASE WHEN listed_in LIKE '%Sci-Fi%' THEN 1 ELSE 0 END) 
    FROM amazon
    UNION ALL
    SELECT 'Fantasy', 
           SUM(CASE WHEN listed_in LIKE '%Fantasy%' THEN 1 ELSE 0 END) 
    FROM amazon
    UNION ALL
    SELECT 'Adventure', 
           SUM(CASE WHEN listed_in LIKE '%Adventure%' THEN 1 ELSE 0 END) 
    FROM amazon
) AS genre_counts
LIMIT 5;

-- 8, countries with highest number of prime titles
SELECT 
    country, 
    total_titles,
    RANK() OVER (ORDER BY total_titles DESC) AS country_rank
FROM (
    SELECT 'United States' AS country, 
           SUM(CASE WHEN country LIKE '%United States%' THEN 1 ELSE 0 END) AS total_titles
    FROM amazon WHERE country IS NOT NULL

    UNION ALL

    SELECT 'India', 
           SUM(CASE WHEN country LIKE '%India%' THEN 1 ELSE 0 END)
    FROM amazon WHERE country IS NOT NULL

    UNION ALL

    SELECT 'United Kingdom', 
           SUM(CASE WHEN country LIKE '%United Kingdom%' THEN 1 ELSE 0 END)
    FROM amazon WHERE country IS NOT NULL

    UNION ALL

    SELECT 'Canada', 
           SUM(CASE WHEN country LIKE '%Canada%' THEN 1 ELSE 0 END)
    FROM amazon WHERE country IS NOT NULL

    UNION ALL

    SELECT 'France', 
           SUM(CASE WHEN country LIKE '%France%' THEN 1 ELSE 0 END)
    FROM amazon WHERE country IS NOT NULL

    UNION ALL

    SELECT 'Germany', 
           SUM(CASE WHEN country LIKE '%Germany%' THEN 1 ELSE 0 END)
    FROM amazon WHERE country IS NOT NULL

    UNION ALL

    SELECT 'Italy', 
           SUM(CASE WHEN country LIKE '%Italy%' THEN 1 ELSE 0 END)
    FROM amazon WHERE country IS NOT NULL

    UNION ALL

    SELECT 'Spain', 
           SUM(CASE WHEN country LIKE '%Spain%' THEN 1 ELSE 0 END)
    FROM amazon WHERE country IS NOT NULL
) AS country_counts
ORDER BY total_titles DESC
LIMIT 5;






