Create database if not exists healthcare;

use healthcare;

Create table flu_demo_data(
Age int not null,
Id varchar(36) primary key,
First_name varchar(30) not null,
Last_name varchar(30) not null,
County varchar(30) not null,
Race varchar(10) not null,
Ethinicity varchar(20) not null,
Gender varchar(1) not null,
Earliest_flu_shot_2022 datetime,
Zip char(4),
Flu_shot_2022 int not null
);

Create table flu_shot(
Birth_date Date not null,
Race varchar(10) not null,
County varchar(30) not null,
Id varchar(36),
First_name varchar(30) not null,
Last_name varchar(30) not null,
Gender char(1) not null,
Age int not null,
EARLIEST_FLU_2019 date,
Patient varchar(36),
Get_Flu_shot_2019 int not null
);


Create table Hospital_ER(
Date datetime not null,
Patient_id varchar(11) primary key,
Patient_gender varchar(2) not null,
Patient_age int not null,
Patient_sat_score int,
Patient_first_inital char(1) not null,
Patient_last_name varchar(40) not null,
Patient_race varchar(70) not null,
Patient_admin_flag varchar(5) not null,
Patient_waittime int not null,
department_referral varchar(20)
);

Create table Health_care_demo(
Encounter_id varchar(50) not null,
Start_date datetime not null,
Stop_time date not null,
Encounterclass varchar(30) not null,
Enc_type varchar(60) not null,
Base_encounter_cost decimal(5,2) not null,
Total_claim_cost decimal(10,2) not null,
Organisation varchar(40) not null,
Enc_reason varchar(100) not null,
Payer varchar(30) not null,
Payer_category varchar(20) not null,
Patient_id varchar(36),
First_name varchar(30) not null,
Last_name varchar(30) not null,
birthdate date not null,
Ethnicity varchar(20) not null,
Race varchar(10) not null,
Zip int not null,
Flu_2022 int not null,
Covid int not null,
Org_name varchar(80) not null,
Zip_org int not null,
Org_city varchar(20) not null,
Org_state varchar(2) not null
);

show global variables like 'local infile';
set global local_infile=1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL_Server 8.0/Uploads/Flu Demo Data.csv'
INTO TABLE flu_demo_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Select * from Health_care_demo;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL_Server 8.0/Uploads/Flu shot-2019.csv'
INTO TABLE flu_shot
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL_Server 8.0/Uploads/Hospital ER.csv'
INTO TABLE Hospital_ER
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL_Server 8.0/Uploads/Healthcare Demo Data.csv'
INTO TABLE Health_care_demo
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- How many encounters did we have before the year 2022?

SELECT COUNT(Encounter_id)
FROM Health_care_demo
WHERE Start_date < '2022-01-01';

-- How many distinct patients did we treat before the year 2020?

Select count(distinct Patient)
from flu_shot
where EARLIEST_FLU_2019 < '2020-01-01';

-- How many distinct encounter classes are documented in the HEALTHCARE DEMO DATA table?

select count(Distinct Encounterclass) as Distinct_Encounter_Classes
from Health_care_demo;

-- What is our patient mix by gender, race and ethnicity? 

select Gender, Race, Ethinicity, count(*) as total_count
from flu_demo_data
group by Gender, Race, Ethinicity
order by Gender, Race, Ethinicity;

--  Maximum and Minimum age of patient in Hospital ER Table?

Select Min(Patient_age) as min_age, Max(Patient_age) as max_age
from Hospital_ER;

-- Which county had the highest number of patients from FLU DEMO DATA?

Select County, count(County) as count
from flu_demo_data
group by County
order by count;

-- How many patient got FLU SHOT in 2019 based on County?

Select County, Count(GET_FLU_SHOT_2019) as Total_Flu_Shot
from flu_shot
where GET_FLU_SHOT_2019 = 1
group by County
order by County;

-- Find the average age of patient by county?

Select County, avg(age) as Average_age
from flu_demo_data
group by County
order by County;

-- Calculate the total number of encounters by organization city?

Select Org_city, Encounterclass, Count(*) as Total_Encounterclass
from Health_care_demo
group by Org_city
order by Org_city;

-- Count the number of patients admitted by race?

Select Patient_race, count(*) as Number_Of_Patients
from Hospital_ER
group by Patient_race
order by Number_Of_Patients;

-- Find the patient with the maximum waiting time?

Select patient_first_inital, patient_last_name, patient_waittime
from Hospital_ER
order by patient_waittime
desc limit 1;

-- Identify the average SAT score for each gender?

Select patient_gender, avg(patient_sat_score) as Average_SAT_Score
from Hospital_ER
group by patient_gender;

-- Find the average waiting time for patients grouped by department referral?

Select department_referral, avg(patient_waittime) as Avg_waiting_time
from Hospital_ER
group by department_referral;

-- Find the total number of patients who have 'Medicare' as a payer?

Select Payer, Count(*) as Total_Count
from Health_care_demo
where Payer = 'Medicare';

-- Find the number of patients who received a flu shot in 2019 by race and county?

Select Race, County, Count(GET_FLU_SHOT_2019) as TotalCount
from Flu_Shot
where GET_FLU_SHOT_2019 = 1
group by Race, County;

-- Is there any patient who have received both a flu shot in 2019 and an encounter in 2022?

Select Flu_shot.First_name, Flu_shot.Last_name, Flu_shot.GET_FLU_SHOT_2019, Health_care_demo.flu_2022
from Flu_shot
join Health_care_demo on Flu_shot.id = Health_care_demo.patient_id
where Flu_shot.GET_FLU_SHOT_2019 = 1 
And Health_care_demo.flu_2022 = 1;

-- Find the total encounter costs per patient (Top 5) who has been admitted in the 'Hospital Encounter with Problem' category?

Select First_name, Last_name,enc_type, sum(total_claim_cost) as Total_Cost
from Health_care_demo
where enc_type = 'Hospital Encounter with Problem'
group by First_name, Last_name
order by Total_Cost
desc limit 5;

-- Are there any patients who were treated in multiple counties?

SELECT Id, First_name, Last_name, COUNT(DISTINCT COUNTY) AS County_Count
FROM flu_shot
GROUP BY Id, First_name, Last_name
HAVING County_Count > 1;
 
 -- Find the average waiting time for patients grouped by both gender and race?
 
Select Patient_race, Patient_gender, Avg(Patient_waittime) as Average_waiting_time
from Hospital_ER
group by Patient_race, Patient_gender
order by Average_waiting_time desc;

-- Identify the top 3 counties with the highest average patient age in the flu dataset?

Select County, avg(age) as Average_Age
from Flu_shot
group by County
order by Average_Age desc limit 3;

-- Calculate the percentage of patients who received a flu shot in 2019 per race category?

Select Race, count(CASE WHEN GET_FLU_SHOT_2019 = 1 THEN 1 END) as Total_Patients_with_Flu_shot, Count(*), ROUND((COUNT(CASE WHEN GET_FLU_SHOT_2019 = 1 THEN 1 END)/Count(*))*100,2) as Percentage
from Flu_shot
group by Race
order by Percentage;

-- Find the average waiting time for male and female patients across different departments in the Hospital_ER table?

Select Patient_gender, Department_referral, avg(patient_waittime) as Average_watiting_time
from Hospital_ER
group by Patient_gender, Department_referral
order by Average_watiting_time;

-- Determine which organization city has the highest total encounter cost, and what percentage it contributes to the overall encounter cost?

Select Org_city, Sum(total_claim_cost) as Total, ROUND((Sum(Total_claim_cost)/(SELECT Sum(Total_claim_cost) FROM Health_care_demo)*100),2) as Percentage
from Health_care_demo
group by Org_city
order by Percentage
desc limit 1;
