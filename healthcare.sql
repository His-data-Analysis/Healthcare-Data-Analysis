-- Creating a database:
create database healthcare_db;
use healthcare_db;

-- creating two tables called diabetic_data and demographic out of the same data:
show tables;
select *from diabetic_data;
select count(*) from diabetic_data;
describe diabetic_data;

-- updating age column in demographic table 
update demographic
set age=replace(age, '[', '(');
 
-- Just wanted to findout the max number and min number of patient number:
select max(patient_nbr) from demographic;
select min(patient_nbr) from demographic;

-- finding duplicates using row number windows function
select *
	from (
		  select *,
          row_number() over(partition by patient_nbr order by patient_nbr) as RowNum
          from demographic
		 )d
	where d.RowNum>1;
 
-- Another way of finding duplicates in the dataset:
select count(*)
 from(
select *
	from (
		  select *,
          row_number() over(partition by patient_nbr order by patient_nbr) as RowNum
          from demographic
		 )d
	where d.RowNum>1
    )as dup;

-- Finding duplicates in the table diabetic_data:
select *
	from (
		  select *,
          row_number() over(partition by patient_nbr order by patient_nbr) as RowNum
          from diabetic_data
          )d
	where d.RowNum >1;

-- Finding duration of stay in hospital
select time_in_hospital, count(*) as counts
from diabetic_data
group by time_in_hospital
order by time_in_hospital;
 
-- SQL command creating Histogram
select 
	round(time_in_hospital, 1) as bins,
    count(*) as counts,
    rpad('', count(*)/100, '*') as bar
    from diabetic_data
    group by bins
    order by bins;

 -- Just to find out how many medical specialties in the hospital    
select distinct(medical_specialty),
	dense_rank() over (order by medical_specialty) as serial_no
    from diabetic_data
    order by medical_specialty;
 
-- Finding the average number of procedures done in each speciality:
select medical_specialty,
		round(avg(num_procedures),1)avg_procedures
        from diabetic_data
        group by medical_specialty
        order by avg_procedures desc;
 
select medical_specialty,
		round(avg(num_procedures),1)avg_procedures,
        count(*) total_number_procedures_done
        from diabetic_data
        group by medical_specialty
        having count(*) > 50
        and avg_procedures >2.5
        order by avg_procedures desc;

select * from diabetic_data
join demographic on diabetic_data.patient_nbr = demographic.patient_nbr;

select race, round(avg(num_lab_procedures),1) num_avg_lab_procedures
from diabetic_data
join demographic on diabetic_data.patient_nbr = demographic.patient_nbr
group by race
order by num_avg_lab_procedures desc;
 
-- Finding average stay in the hospital and the number of procedures done.
select round(avg(time_in_hospital),1) avg_stay_hospital,
case
	when num_lab_procedures >= 0 and num_lab_procedures < 25 then "few"
     when num_lab_procedures >= 25 and num_lab_procedures < 55 then "average"
     else "many"
     end as procedure_frequency
from diabetic_data
group by procedure_frequency
Order by avg_stay_hospital desc;

Select  count(*) as total_count
From
(
select patient_nbr from demographic where race = "Asian" 
union
select patient_nbr from diabetic_data where metformin = "up"
) as combined_total;
 
select concat('Patient',' ', diabetic_data.patient_nbr,' ', 'was',' ', race,' ', 'and', 
	(case
		when readmitted like '%<30%' Then "was readmitted <30 days after discharge"
		-- when readmitted = 'no' Then "was not"
        -- when readmitted = 'No' Then "was not"
        else ' was not readmitted.'
        end),' ',   
        'and had',' ', num_medications,' ', 'medications and ', num_lab_procedures,' ', 'lab procedures.') summary
        from diabetic_data
        join demographic on diabetic_data.patient_nbr = demographic.patient_nbr
        order by diabetic_data.patient_nbr desc;
 
-- Using Common Table Expression 
with cte as
		(
        select concat('Patient',' ', diabetic_data.patient_nbr,' ', 'was',' ', race,' ', 'and',' ', 
	(case
		when readmitted like '%<30%' Then "was readmitted <30 days after discharge"
        when readmitted like '%>30%' Then "was readmitted >30 days after discharge"
		when not readmitted like "%NO%" then "was readmitted"
        when readmitted like "%NO%" then "was not readmitted"
		end),' ',  
        'and had',' ', num_medications,' ', 'medications and ', num_lab_procedures,' ', 'lab procedures.') summary
        from diabetic_data
        join demographic on diabetic_data.patient_nbr = demographic.patient_nbr
        )
	select *from cte where summary like "%<30%";
 
    
   

      





