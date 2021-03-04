select * from ACCIDENT.accident_record;
select * from ACCIDENT.police_officer;
select * from ACCIDENT.accident;

--create table timedim

--drop table timedim cascade constraints purge;
create table timedim(
time_id number not null,
time_desc VARCHAR2(50));
insert into timedim values(1,'daytime: 6AM - 5:59PM');
insert into timedim values(2,'nighttime 6PM - 5:59AM');
select * from timedim;
--create table locationdim1
--drop table locationdim1 cascade constraints purge;
create table locationdim1
as select distinct accident_suburb from accident.accident ;

--create branchdim tble
--drop table branchdim cascade constraints purge;

create table branchdim as
select distinct officer_branch as branch_name
from ACCIDENT.police_officer;

--create modeldim tble
--drop table modeldim cascade constraints purge;
create table modeldim as
select distinct vehicle_model 
from ACCIDENT.vehicle;

-- create tempfact_accident table for accident
create table tempfact_accident as
select a.accident_suburb, a.accident_date_time, v.vehicle_model,v.vehicle_no, ar.accident_no,p.officer_branch from 
ACCIDENT.vehicle v, ACCIDENT.accident_record ar , ACCIDENT.accident a, ACCIDENT.police_officer p
where v.vehicle_no = ar.vehicle_no and ar.accident_no=a.accident_no and a.officer_id = p.officer_id;

alter table tempfact_accident
ADD (time_id NUMBER);
 
 --update tempfact_accident set time_id =1
--WHERE to_char(accident_date_time, 'HH24:MI') >= '06:00'
--AND to_char(accident_date_time, 'HH24:MI') < '18:00';
-- NOT WROKING AS EXPECTED
update tempfact_accident set time_id = 1
WHERE to_char(accident_date_time, 'HH24') = '06'
OR to_char(accident_date_time, 'HH24') = '07'
OR to_char(accident_date_time, 'HH24') = '08'
OR to_char(accident_date_time, 'HH24') = '09'
OR to_char(accident_date_time, 'HH24') = '10'
OR to_char(accident_date_time, 'HH24') = '11'
OR to_char(accident_date_time, 'HH24') = '12'
OR to_char(accident_date_time, 'HH24') = '13'
OR to_char(accident_date_time, 'HH24') = '14'
OR to_char(accident_date_time, 'HH24') = '15'
OR to_char(accident_date_time, 'HH24') = '16'
OR to_char(accident_date_time, 'HH24') = '17'
OR to_char(accident_date_time, 'HH24') < '18';

update tempfact_accident set time_id = 2
WHERE to_char(accident_date_time, 'HH24') = '18'
OR to_char(accident_date_time, 'HH24') = '19'
OR to_char(accident_date_time, 'HH24') = '20'
OR to_char(accident_date_time, 'HH24') = '21'
OR to_char(accident_date_time, 'HH24') = '22'
OR to_char(accident_date_time, 'HH24') = '23'
OR to_char(accident_date_time, 'HH24') = '00'
OR to_char(accident_date_time, 'HH24') = '01'
OR to_char(accident_date_time, 'HH24') = '02'
OR to_char(accident_date_time, 'HH24') = '03'
OR to_char(accident_date_time, 'HH24') = '04'
OR to_char(accident_date_time, 'HH24') = '05'
OR to_char(accident_date_time, 'HH24') < '06';

--create fact_accident
CREATE TABLE fact_accident AS
SELECT  T.time_id, t.officer_branch, t.accident_suburb,t.vehicle_model,
  count(t.accident_no) AS total_no_of_accident
FROM tempfact_accident T
GROUP BY t.accident_suburb,t.vehicle_model,T.time_id, t.officer_branch ;

--Show the total number of accidents happening by different locations and by differentlighting periods (daytime: 6AM - 5:59PM and nighttime 6PM - 5:59AM).
select f.accident_suburb,t.time_desc, count(f.total_no_of_accident) as total_accident
from fact_accident f, timedim t where f.time_id = t.time_id
group  by f.accident_suburb,t.time_desc ;



-- Show the total number of accidents by each vehicle model.
select f.vehicle_model, count(*) as total_accident from fact_accident f , modeldim m
where f.vehicle_model =m.vehicle_model
group by f.vehicle_model;

--select * from ACCIDENT.vehicle where vehicle_model ='Volusia';
--select * from ACCIDENT.accident_record where vehicle_no = 'VM009';

-- Show the number of vehicles involved in every accident event on different locations.
select accident_no, count(*) vehicles from ACCIDENT.accident_record
group by accident_no;
-- Show the number of accidents taken care of by different police officer branches.
select f.officer_branch, count(f.officer_branch) as total_accident from fact_accident f,
branchdim b where f.officer_branch = b.branch_name
group by f.officer_branch;
