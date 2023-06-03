CREATE DATABASE project_hr;

USE project_hr;

SELECT * FROM hrd;

ALTER TABLE hrd
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hrd;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

UPDATE hrd
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END; 

ALTER TABLE hrd
MODIFY COLUMN birthdate DATE;

UPDATE hrd
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hrd
MODIFY COLUMN hire_date DATE;

ALTER TABLE hrd
MODIFY COLUMN termdate DATE;

ALTER TABLE hrd 
ADD COLUMN age INT;

SET sql_mode = 'ALLOW_INVALID_DATES';

UPDATE hrd
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != ' ';


UPDATE hrd
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hrd;

SELECT count(*) FROM hrd WHERE age < 18;

SELECT COUNT(*) FROM hrd WHERE termdate > CURDATE();

SELECT COUNT(*)
FROM hrd
WHERE termdate = '0000-00-00' ;

SELECT location FROM hr;

select * from hr;

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT GENDER, count(*) AS COUNT
    FROM HRD
    WHERE AGE >= 18 AND TERMDATE = "0000-00-00"
    GROUP BY GENDER;
-- 2. What is the race/ethnicity breakdown of employees in the company?
Select race, count(*) as count
	from hrd
	where age >= 18 and termdate = '0000-00-00'
	group by race
	order by count(*) desc;
-- 3. What is the age distribution of employees in the company?
	SELECT 
    MIN(AGE) AS YOUNGEST,
    MAX(AGE) AS OLDEST
    FROM HRD
    WHERE AGE >=18 AND TERMDATE ='0000-00-00'
    
	SELECT
		CASE
        WHEN AGE >= 18 AND AGE <= 24 THEN '18-24'
        WHEN AGE >= 25 AND AGE <= 34 THEN '25-34'
		WHEN AGE >= 35 AND AGE <= 44 THEN '35-44'
        WHEN AGE >= 45 AND AGE <= 54 THEN '45-54'
        WHEN AGE >= 55 AND AGE <= 64 THEN '18-24'
        ELSE '65+' 
        END AS AGE_GROUP,GENDER,
        COUNT(*) AS COUNT 
        FROM HRD
        WHERE AGE >= 18 AND TERMDATE = '0000-00-00'
        GROUP BY AGE_GROUP,GENDER
        ORDER BY AGE_GROUP,GENDER;


-- 4. How many employees work at headquarters versus remote locations?
SELECT LOCATION, count(*) AS COUNT
FROM HRD
 WHERE AGE >= 18 AND TERMDATE = '0000-00-00'
 group by LOCATION;


-- 5. What is the average length of employment for employees who have been terminated?
SELECT
	ROUND(AVG(datediff(TERMDATE,HIRE_DATE))/365,0) AS AVG_LENGTH_EMPLOYMENT
    FROM HRD
    WHERE TERMDATE <= curdate() AND TERMDATE <> '0000-00-00' AND AGE >= 18;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT DEPARTMENT, GENDER, count(*) AS COUNT
FROM HRD
WHERE AGE >= 18 AND TERMDATE = '0000-00-00'
GROUP BY DEPARTMENT, GENDER
ORDER BY DEPARTMENT;


-- 7. What is the distribution of job titles across the company?
SELECT JOBTITLE, count(*) AS COUNT
FROM HRD
WHERE AGE >= 18 AND TERMDATE = '0000-00-00'
GROUP BY JOBTITLE
ORDER BY JOBTITLE DESC;

-- 8. Which department has the highest turnover rate?

SELECT DEPARTMENT, TOTAL_COUNT, TERMINATED_COUNT,  TERMINATED_COUNT/TOTAL_COUNT AS TERMINATION_RATE
FROM (
SELECT DEPARTMENT, count(*) AS TOTAL_COUNT, 
SUM(CASE WHEN TERMDATE <> '0000-00-00' AND TERMDATE <= curdate()THEN 1 ELSE 0 END) AS TERMINATED_COUNT
FROM HRD
WHERE AGE >= 18
GROUP BY DEPARTMENT
) AS SUBQUERY
ORDER BY TERMINATION_RATE DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT LOCATION_STATE, count(*) AS COUNT
FROM HRD
WHERE AGE >= 18 AND TERMDATE = '0000-00-00'
GROUP BY LOCATION_STATE
ORDER BY COUNT DESC;


-- 10. How has the company's employee count changed over time based on hire and term dates?
 SELECT
 YEAR, HIRES, TERMINATIONS, HIRES-TERMINATIONS AS NET_CHANGE,
 ROUND((HIRES-TERMINATIONS)/HIRES * 100, 2) AS NET_CHANGE_PERCENT
 FROM (
	SELECT YEAR(HIRE_DATE) AS YEAR,
    count(*) AS HIRES,
    SUM(CASE WHEN TERMDATE <> '0000-00-00' AND TERMDATE <= curdate() THEN 1 ELSE 0 END) AS TERMINATIONS
    FROM HRD
    WHERE AGE >= 18
    GROUP BY year(HIRE_DATE) )AS SUBQUERY
    ORDER BY YEAR ASC;
-- 11. What is the tenure distribution for each department?
SELECT DEPARTMENT, ROUND(AVG(datediff(TERMDATE, HIRE_DATE)/365),0) AS AVG_TENURE
FROM HRD
WHERE TERMDATE <= CURDATE() AND TERMDATE<> '0000-00-00' AND AGE >= 18
GROUP BY DEPARTMENT;