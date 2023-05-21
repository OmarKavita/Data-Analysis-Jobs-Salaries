Create database Data_science;
use Data_science;
drop table salaries;
create table salaries(
 Id int not null,
 Work_year varchar(20),
 Experience_level varchar(20),
 Employment_type varchar(20),
 Job_title varchar(45),
 Salary int,
 Salary_currency varchar(20),
 Salary_in_usd int,
 Employee_residence varchar(20),
 Remote_ratio int,
 Company_location varchar(20),
 Company_size varchar(10),
 primary key (Id));
 
 alter table salaries
 change Company_locaion company_location varchar(20);

create table companies(
 Id int not null,
 Company_name varchar(20),
 primary key (Id)
 );
 
 /* DATA CLEANING */

Select * from salaries;
# there is error in the data of work_year column as there is exta 'e' after year in somr of the rows.

update salaries
set work_year = replace( work_year, "e", "")
where work_year like "%e";

#Check if there are any duplicate values in salaries
select Id, count(*) from salaries
group by Id
having count(*) >1;                     #no duplicate found

#Checking the datatype of columns
Describe salaries;                     
#work year has varchar dataype, we need to change this

alter table salaries 
change column work_year work_year year;

-- Q1. What is the average salary for all the jobs in the dataset?
select avg(salary) from salaries;
# Average salary is approx 5L

-- Q2. How many cities are involved into this data?
select count(distinct company_location) from salaries;
# This data is collected from 41 dfferent countries

-- Q3. what is the average salary for each job category?
select job_title, avg(salary) as average_salary from salaries 
group by job_title 
order by average_salary desc;
# Data science manager has highest average salary, BI data analyst has second highest salary.

-- Q4. which 5 country has highest avearage salary ?
select company_location, avg(salary) as avg_salary from salaries 
group by company_location
order by avg_salary desc
limit 5;
# CL country code has highest average salary of data analysts i.e. approx 3 cr.


-- Q5. which 5 country has lowest avearage salary of employees?
select company_location, avg(salary) as avg_salary from salaries 
group by company_location
order by avg_salary
limit 5;
# country with country code IR has the minimum average salary of data scientist i.e. 4000 only.

-- Q6. which country is at top 10 for having maximum number of employees?
select company_location, count(Id) as num_DataSc from salaries 
group by company_location;
# US is hving most number of data analysts

-- Q7. Any correlation between number of employees and their salaries?
select company_location, avg(salary) as avg_salary, count(Id) as num_DataSc 
from salaries 
group by company_location
order by avg_salary desc;
# no correlation

-- Q8. Top 10 job title having maximum number of employees?
select job_title, count(Id) as num_emp from salaries 
group by job_title
order by num_emp desc;
# data scientist, data engineer, machine learning engineer and data analyst has maximum number of employees.

-- Q9. What is the average salary of job title having maximum number of employees?
select job_title, avg(salary) from salaries 
group by job_title
order by count(*) desc
limit 4;
# data scientist and data analyst have more average salary than overall average salary

-- Q10 What is the average salary for each job title in each location, and what is the percentage of jobs for each job title in each location?
select job_title, company_location, avg(salary) as avg_salary,
(count(*) * 100 / (select count(*) from salaries where company_location = s.company_location)) 
as percent_jobs from salaries s
group by company_location, job_title;

-- Q11. Wht is the average salary of employers in US?
select avg(salary) from salaries 
where company_location = 'US';
# average salary of employees in US is less than half of the overall average salary.
 
-- Q12. what percent of emlpoyees have salary above the average salary?
select (select count(*) from salaries where salary> 
		(select avg(salary) from salaries)) * 100 / count(*) 
from salaries;
# Only 8.57% employees have salary greatr than average salary. 
# That means, there is huge salary gap between position with high salary and low salary.

-- Q13. What is the total number of jobs available for each year of experience, and what is the average salary for each year of experience?
select experience_level, count(*), avg(salary) as avg_salary from salaries
group by experience_level
order by avg_salary desc;
# MI experience level has highest number of employees and highest salary.
/* EN - Entry level
 MI - mid-level 
 SE - Senior-level 
 EX - Expert */
 
-- Q14. What is the average salary different job levels according to the size of their company?
select experience_level, company_size, avg(salary) as avg_salary from salaries
group by experience_level, company_size
order by experience_level, avg_salary desc;
# medium-sized companies have least average salary for all experience level except Mid-level position.

-- 15.Can you identify any correlation between the company's size and the average salarys?
select company_size, avg(salary) as avg_salary from salaries
group by company_size
order by avg_salary desc;
# large sized companies have highest average salary, followed by small level and medium-sized companies have least salary.

-- Q16.  What is the name of the company that offers the highest salary for each job title?
with CTE AS(
select s.* from salaries s
where (s.job_title, s.salary) in 
(select job_title, max(salary) from salaries group by job_title)
)
select ct.job_title, ct.salary, c.company_name from cte ct
left join companies c
on ct.Id = c.Id
order by ct.salary desc
Limit 10;

#ALTERNTE METHOD

with cte as(
select * from (
select *, rank() over(partition by job_title order by salary desc)as rnk from salaries ) as x
where x.rnk = 1)
select ct.Id, ct.job_title, c.company_name, ct.salary
from cte as ct
inner join companies c on ct.Id = c.Id
order by salary desc;
# Company ghi is offering the highest salary for the role of data scientist.

-- Q18. what is the role that has maximum salary in each company?
select company_name, job_title, salary from (
select c.company_name, s.*, rank() over(partition by c.company_name order by salary desc) as rn
from salaries s left join companies c 
on s.id = c.id) as new_tbl
where rn =1
order by salary desc;
# in most companies, Daa scientist and data science manager have highest salary.

-- Q19. Rank the companies according to their average salary
with top_companies as (
select row_number() over() as rnk, c.company_name, avg(s.salary) as avg_salary from salaries s 
left join companies c 
on s.id = c.id
group by c.company_name
order by avg_salary desc
limit 10)
select row_number() over() as rnk, t.* from top_companies t;
# ghi company has rank 1 among the companies with highest average salary.

-- Q20. What is the average salary for each job title in each company, and what is the rank of each job title within each company based on the average salary?
SELECT job_title, company_name, AVG(salary) AS average_salary, 
RANK() OVER (PARTITION BY company_name ORDER BY AVG(salary) DESC) AS salary_rank 
FROM salaries s
INNER JOIN companies c ON s.id = c.id 
GROUP BY job_title, company_name;

-- Q21. Find out the demand of every job title based on company location and rank them according to the demand.
SELECT job_title, company_location, COUNT(*) AS num_jobs, 
RANK() OVER (PARTITION BY company_location ORDER BY COUNT(*) DESC) AS job_rank 
FROM salaries
GROUP BY company_location, job_title
order by job_rank;
    
-- Q22. Find out location-wise average salary for each job role, also name the company that offers highest avg salay in each location.
SELECT job_title, company_location, AVG(salary) AS average_salary, company_name 
FROM salaries s
INNER JOIN companies c ON s.id = c.id 
WHERE salary = (SELECT MAX(salary) FROM salaries WHERE job_title = s.job_title AND company_location = s.company_location) 
GROUP BY job_title, company_location, company_name;
