use netflix;
-- ### *Basic Queries (Easy)*

-- 1. Retrieve all records from the table.
select * from netflix_user;

-- 2. Select all users from the USA.
select user_id,name ,country from netflix_user 
where country = "USA";

-- 3. Find distinct subscription types available.
select distinct subscription_type from netflix_user;

-- 4. Count the total number of users.
select count(*) from netflix_user;

-- 5. Retrieve all users who logged in during the last 7 days.
select * from netflix_user
where datediff((select max(last_login) from netflix_user) , last_login ) <= 7;

-- 6. Get the average watch time of all users.
select avg(watch_time_hours) from netflix_user;

-- 7. List all users whose names start with ‘A’.
select user_id,name from netflix_user
where name like "A%";

-- 8. Find users younger than 25 years old.
select user_id,name , age from netflix_user
where age < 25;

-- 9. Count how many users belong to each country.
select count(user_id) , country from netflix_user
group by country order by count(user_id) desc;

-- 10. Retrieve the maximum and minimum watch time.
select max(watch_time_hours) as maximum_watchtime , min(watch_time_hours) as minimum_watchtime from netflix_user;
-- ---

-- ### *Sorting & Filtering*
-- 11. Retrieve the top 5 users with the highest watch time.
select user_id , name ,watch_time_hours from netflix_user
order by watch_time_hours desc limit 5;

-- 12. Find all users who watch more than 10 hours.
select user_id , name from netflix_user
where watch_time_hours > 10;

-- 13. Get all users sorted by age in descending order.
select user_id , name , age from netflix_user
order by age desc;

-- 14. Find users who do not have a favorite genre.
select * from netflix_user
where favorite_genre is null;

-- 15. Retrieve all users who have either a ‘Premium’ or ‘Basic’ subscription.
select user_id , name, subscription_type from netflix_user
where subscription_type = "basic" or subscription_type = "premium";

-- 16. Get users who have logged in during the last month.
select * from netflix_user
where datediff((select max(last_login) from netflix_user), last_login) <= 30;

-- 17. Identify users who have never logged in.
select user_id , name , watch_time_hours from netflix_user
where watch_time_hours is null;

-- 18. Retrieve users whose favorite genre is either ‘Comedy’ or ‘Action’.
select user_id , name , favorite_genre from netflix_user
where favorite_genre = 'comedy' or favorite_genre = 'action';

-- 19. Count how many users are older than 30 and have watched more than 20 hours.
select user_id , name , age , watch_time_hours from netflix_user
where age > 30 and watch_time_hours > 20;

-- 20. List all users with missing or NULL values in any column.
SELECT * 
FROM netflix_user
WHERE 
    User_ID IS NULL OR
    Name IS NULL OR
    Age IS NULL OR
    Country IS NULL OR
    Subscription_Type IS NULL OR
    Watch_Time_Hours IS NULL OR
    Favorite_Genre IS NULL OR
    Last_Login IS NULL;

-- ---

-- ### *Aggregations & Grouping*
-- 21. Count the number of users per country.
select country,count(user_id) from netflix_user group by country;

-- 22. Calculate the average age of users per subscription type.
select subscription_type , avg(age) from netflix_user
group by subscription_type;

-- 23. Find the total watch time per subscription type.
select subscription_type , sum(watch_time_hours) from netflix_user group by subscription_type;

-- 24. Get the most popular favorite genre.
select max(favorite_genre) from netflix_user;

-- 25. Find the country with the highest number of users.
select country , count(user_id) from netflix_user group by country order by count(user_id) desc;

-- 26. Retrieve the subscription type with the lowest average watch time.
select subscription_type , avg(watch_time_hours) as lowest_watchtime from netflix_user 
group by subscription_type order by lowest_watchtime asc limit 1 ;

-- 27. Find the top 3 most common favorite genres.
select favorite_genre ,count(favorite_genre) as common from netflix_user 
group by favorite_genre order by common desc limit 3;

-- 28. Count how many users belong to each subscription type.
select subscription_type , count(user_id) from netflix_user 
group by subscription_type;

-- 29. Find the total watch time of all users from India.
select sum(watch_time_hours) from netflix_user 
where country = 'india';

-- 30. Identify which country has the highest watch time per user.
select country , avg(watch_time_hours) from netflix_user group by country order by avg(watch_time_hours) limit 1 ;
-- ---

-- ### *Joins (Simulating) & Subqueries*
-- 31. Find users who have a higher watch time than the average watch time.
select user_id, name, watch_time_hours from netflix_user
where watch_time_hours > (select avg(watch_time_hours) from netflix_user);

-- 32. Retrieve users whose watch time is in the *top 10%*.
with ranked as (
select user_id , name , watch_time_hours,
rank() over(order by watch_time_hours desc) as rank_position,
count(*) over() as total_count from netflix_user)
select user_id,name,watch_time_hours,rank_position from ranked 
where rank_position <= total_count*0.10
order by watch_time_hours desc;

-- 33. Get the list of users whose last login was more than 30 days ago.
SELECT user_id, name, last_login 
FROM netflix_user 
WHERE DATEDIFF(NOW(), last_login) > 30;


-- 34. Identify users who have a different favorite genre than their country's most popular genre.
WITH MostPopularGenre AS (
    SELECT country, favorite_genre, 
           COUNT(*) AS genre_count,
           RANK() OVER (PARTITION BY country ORDER BY COUNT(*) DESC) AS rank_position
    FROM netflix_user
    GROUP BY country, favorite_genre
)
SELECT u.user_id, u.name, u.country, u.favorite_genre, mpg.favorite_genre AS most_popular_genre
FROM netflix_user u
JOIN MostPopularGenre mpg 
    ON u.country = mpg.country 
WHERE mpg.rank_position = 1 
AND u.favorite_genre <> mpg.favorite_genre;

-- 35. List users who have spent more time watching than the average watch time in their country.
with countryaverage as
(select user_id,name,country,watch_time_hours,
avg(watch_time_hours) over(partition by country) as average from netflix_user)
select user_id,name,country,watch_time_hours,average 
from countryaverage
where watch_time_hours > average ;

-- 36. Find users who have the same favorite genre as the most popular genre globally.
select user_id,name, favorite_genre from netflix_user
where favorite_genre = (select max(favorite_genre) from netflix_user);
-- 37. Identify users who have logged in on the most recent login date.
select user_id,name,last_login from netflix_user
where last_login = (select max(last_login) from netflix_user);

-- 38. Retrieve all users who have more than the median watch time.
WITH OrderedUsers AS (
SELECT user_id, name, watch_time_hours,
ROW_NUMBER() OVER (ORDER BY watch_time_hours) AS row_num,
COUNT(*) OVER () AS total_count
FROM netflix_user
)
SELECT user_id, name, watch_time_hours
FROM OrderedUsers
WHERE row_num > total_count / 2;

-- 39. Find users who have logged in more than once in the last 7 days.
-- not possible with these columns 

-- 40. Identify users whose watch time is above the 75th percentile.
with percentile as (
select user_id,name,watch_time_hours,percent_rank() over(order by watch_time_hours) as pr
from netflix_user)
select user_id,name,watch_time_hours from percentile
where pr > 0.75;
-- ---

-- ### *Window Functions & Ranking*
-- 41. Rank users by watch time within each subscription type.
select user_id,name ,watch_time_hours,rank() over(partition by country order by watch_time_hours desc) as rankk
from netflix_user;

-- 42. Calculate the cumulative watch time of all user over time.
select user_id ,name,watch_time_hours,sum(watch_time_hours) over(order by watch_time_hours desc) as cumutative from netflix_user;

-- 43. Find the user with the highest watch time in each country.
with highest_watchtime as (
select user_id , name ,country,watch_time_hours,
rank() over(partition by country order by watch_time_hours desc) as rank_position from netflix_user)
select user_id , name ,country ,watch_time_hours, rank_position 
from highest_watchtime
where rank_position = 1;

-- 44. Retrieve the difference in watch time between each user and the user ranked directly above them.
select user_id,name,watch_time_hours,
lag(watch_time_hours) over(order by watch_time_hours desc) as previous_watchtime,
watch_time_hours - lag(watch_time_hours) over (order by watch_time_hours desc) as difference
from netflix_user order by watch_time_hours desc;

-- 45. Assign a dense rank to users based on their watch time.
select user_id , name , watch_time_hours,dense_rank() over (order by watch_time_hours desc) as dense from netflix_user;

-- 46. Find the running total of watch time per country.
select user_id ,name,country ,watch_time_hours,sum(watch_time_hours) over(partition by country order by watch_time_hours desc) as cumutative from netflix_user;

-- 47. Retrieve the previous and next user's watch time for each user.
select user_id,name,watch_time_hours,
lag(watch_time_hours) over(order by watch_Time_hours desc) as previous_watch_time,
lead(watch_time_hours) over(order by watch_time_hours desc) as next_watch_time 
from netflix_user order by watch_time_hours desc;

-- 48. Identify the first user who logged in for each country.
with first_login_per_country as (
select user_id,name ,country,last_login, row_number() over (partition by country order by last_login asc) as rownum from netflix_user)
select user_id,name,country,last_login ,rownum from first_login_per_country
where rownum = 1;

-- 49. Calculate the average watch time over the last 7 days for each user.
-- not possible with these columns

-- 50. Rank users based on their age in ascending order.
select user_id,name,age,rank() over(order by age asc) as rank_age from netflix_user;
-- ---

-- ### *Advanced Queries & Performance Optimization*

-- 51. Optimize a query to find the users with the highest watch time.
select user_id,name,watch_time_hours 
from netflix_user
where watch_time_hours = (select max(watch_time_hours) from netflix_user);

-- 52. Identify duplicate records and remove them
SELECT 
    name, age, country, subscription_type, watch_time_hours, favorite_genre, last_login,
    COUNT(*) AS duplicate_count
FROM 
    netflix_user
GROUP BY 
    name, age, country, subscription_type, watch_time_hours, favorite_genre, last_login
HAVING 
    COUNT(*) > 1;
    
WITH ranked_duplicates AS (
SELECT user_id,
ROW_NUMBER() OVER (PARTITION BY name, age, country, subscription_type, watch_time_hours, favorite_genre, last_login ORDER BY user_id) AS rn
FROM netflix_user
)
DELETE FROM netflix_user
WHERE user_id IN (SELECT user_id
FROM ranked_duplicates
WHERE rn > 1
);

-- 53. Write an index creation query for faster searches on the Country column.
create index country_idx on netflix_user(country(20));
-- --for partition by country we have to change text to varchar
ALTER TABLE netflix_user MODIFY country VARCHAR(100);

-- 54. Partition the table by Country to optimize query performance.
CREATE TABLE netflix_user_partitioned (
    user_id INT,
    name VARCHAR(100),
    age INT,
    country VARCHAR(100),
    subscription_type VARCHAR(50),
    watch_time_hours INT,
    favorite_genre VARCHAR(100),
    last_login DATE
)
PARTITION BY LIST COLUMNS(country) (
    PARTITION p_USA VALUES IN ('USA'),
    PARTITION p_UK VALUES IN ('UK'),
    PARTITION p_India VALUES IN ('India'),
    PARTITION p_Others VALUES IN ('Canada', 'Australia', 'Germany', 'France')
);

-- 55. Explain how an execution plan helps in optimizing queries.
EXPLAIN SELECT * FROM netflix_user WHERE country = 'USA';
EXPLAIN ANALYZE SELECT * FROM netflix_user WHERE country = 'USA';

-- 56. Retrieve the users whose watch time follows a monthly increasing trend.
-- not possible with these columns

-- 57. Identify users who have changed their subscription type at least once.
-- not possible

-- 58. Retrieve the subscription type that contributes the highest total watch time.
select subscription_type,sum(watch_time_hours) as total_watchtime from netflix_user
group by subscription_type order by total_watchtime desc limit 1;

-- 59. Create a view to show only active users who have logged in within the last 30 days
CREATE VIEW active_users_last_30_days AS
SELECT * FROM netflix_user
WHERE Last_Login >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
SELECT * FROM active_users_last_30_days;
