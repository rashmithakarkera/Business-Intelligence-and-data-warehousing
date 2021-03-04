DROP TABLE service;
drop table clinic;
drop table doctor;

-- create clinic table
create table clinic
(hospital_id number(6) not null,
hospital_name VARCHAR2(30),
hospital_address VARCHAR2(70),
suburb VARCHAR2(40),
postcode VARCHAR2(4),
primary Key( hospital_id));


--create table doctor
create table doctor
(staff_id number(6) not null ,
staff_name VARCHAR2(30),
staff_ph VARCHAR2(10) ,
primary key(staff_id));

-- create table patient
create table patient
(patient_id number(6) not null,
patient_name VARCHAR2(30) not null,
patient_age number(3) not null,
patient_ph_no VARCHAR2(10),
patient_address VARCHAR2(70),
patient_nationality VARCHAR2(30) ,
patient_emergency_contact VARCHAR2(10),
primary key( patient_id));

-- create service table
create table service
( service_id number(6) not null,
staff_id number(6) not null,
hospital_id number(6) not null,
service_name VARCHAR2(30),
service_cost  numeric( 10,2),
primary key( service_id),
foreign key(staff_id) references doctor(staff_id),
foreign key(hospital_id) references clinic(hospital_id));



--create table assignment
create table asssignment
( assignment_id number(6) not null,
patient_id number(6) not null,
patient_service_start_date date,
patient_service_end_date date,
service_id number(6) not null,
primary key(assignment_id),
foreign key(service_id) references service(service_id));



insert into clinic values(01, 'Alfred','13 York Street',' Glen Iris', 3100);
insert into clinic values(02, 'Monash','31 Southern Cross',' Caulfield', 3300);
insert into clinic values(03, 'Caroline','11 Park Street',' Yarra', 3200);
insert into clinic values(04, 'RMIT','22 Isle Street',' Kilda', 3204);
insert into clinic values(05, 'Melbourne','6 Park Village',' Clayton', 3000);

insert into doctor values(11, 'Shalika', 0422356775);
insert into doctor values(12, 'Rashmita',434567891);
insert into doctor values(13, 'Rahul',  0456789111);
insert into doctor values(14, 'Disha',  456789123);
insert into doctor values(15, 'Shruti', 567891234);

insert into patient values(111, 'Ramey Patel', 12, 1234567890,' 12 pike ' ,'Indian', 0423456888);
insert into patient values(112, 'Kay Piel', 22, 0434567890,' 6 Long Isle ' ,'Chinese',04234557789);
insert into patient values(113, 'Athennee Jake', 34, 4434567890,' 7 kate Ln ' ,'German',0423456786);
insert into patient values(114, 'Park Tae', 52, 4234567890,' 11 Market Road ' ,'Korean',04234544330);
insert into patient values(115, 'James Bryan', 44, 6264567890,' SouthBank Avey ' ,'Australian', 0423467345);


insert into service values(51,11,03,'men’s health ', 40.00);
insert into service values(52,11,02,'mental health', 44.00);
insert into service values(53,12,03,'skin diseases', 30.00);
insert into service values(54,15,01,'paediatric health', 20.00);
insert into service values(55,13,04,'specialists n pathology', 30.00);
insert into service values(56,13,04,'general medical consultations', 30.00);


insert into asssignment values(201,111, TO_DATE('22-feb-2020','DD-MON-YYYY'),TO_DATE('24-feb-2020','DD-MON-YYYY'),51);
insert into asssignment values(202,112, TO_DATE('11-mar-2020','DD-MON-YYYY'),TO_DATE('12-mar-2020','DD-MON-YYYY'),52);
insert into asssignment values(203,112, TO_DATE('02-apr-2020','DD-MON-YYYY'),TO_DATE('7-apr-2020','DD-MON-YYYY'),53);
insert into asssignment values(204,113, TO_DATE('20-mar-2020','DD-MON-YYYY'),TO_DATE('28-mar-2020','DD-MON-YYYY'),53);
insert into asssignment values(205,114, TO_DATE('06-jan-2020','DD-MON-YYYY'),TO_DATE('10-jan-2020','DD-MON-YYYY'),55);
insert into asssignment values(206,115, TO_DATE('06-jun-2019','DD-MON-YYYY'),TO_DATE('10-jun-2019','DD-MON-YYYY'),51);
insert into asssignment values(207,115, TO_DATE('16-jun-2019','DD-MON-YYYY'),TO_DATE('20-jun-2019','DD-MON-YYYY'),53);
insert into asssignment values(208,115, TO_DATE('26-jun-2019','DD-MON-YYYY'),TO_DATE('30-jun-2019','DD-MON-YYYY'),52);
insert into asssignment values(209,115, TO_DATE('24-jun-2019','DD-MON-YYYY'),TO_DATE('29-jun-2019','DD-MON-YYYY'),56);
insert into asssignment values(210,115, TO_DATE('20-jun-2019','DD-MON-YYYY'),TO_DATE('29-jun-2019','DD-MON-YYYY'),56);
insert into asssignment values(212,115, TO_DATE('02-jun-2019','DD-MON-YYYY'),TO_DATE('29-jun-2019','DD-MON-YYYY'),56);

commit;


--create location dimesion table

create table locationdim as
select distinct suburb, postcode from clinic ;
--DROP TABLE locationdim CASCADE CONSTRAINTS PURGE;

-- create timeperiod table
create table timeperioddim 
(
timeperiod_no number not null,
timeperiod_name varchar2(30)
);
--DROP TABLE timeperioddim CASCADE CONSTRAINTS PURGE;
insert into timeperioddim values(91, 'Summer');
insert into timeperioddim values(92, 'Winter');
insert into timeperioddim values(93, 'Spring');
insert into timeperioddim values(94, 'Autumn');


--create table servicedim 
create table servicedim  as select distinct s.service_id , s.service_name, 
a.patient_service_start_date  service_time
from service s , asssignment a where s.service_id = a.service_id;

--DROP TABLE servicedim CASCADE CONSTRAINTS PURGE;


-- create table  agedim
create table agedim
(
age_id number not null,
age_group varchar(20));

insert into agedim values(911, 'age infant <1');
insert into agedim values(912, ' children <18');
insert into agedim values(913, ' adult 18+');
insert into agedim values(914, ' senior 65+');

--DROP TABLE agedim CASCADE CONSTRAINTS PURGE;




-- creating temp fact
--drop table tempfact_hospital;
create table tempfact_hospital as
select  s.service_id, s.service_name, s.hospital_id, c.suburb, a.patient_service_start_date , a.patient_id, p.patient_name,p.patient_age ,  s.service_cost
from service s , clinic c, asssignment a , patient p
where s.hospital_id = c.hospital_id and s.service_id =a.service_id and p.patient_id = a.patient_id; 

ALTER TABLE tempfact_hospital
ADD (age_id NUMBER);

UPDATE tempfact_hospital SET age_id = 911 WHERE age_id < 1;
UPDATE tempfact_hospital SET age_id = 912 WHERE patient_age >= 1 and patient_age < 18;
UPDATE tempfact_hospital SET age_id = 913 WHERE patient_age >= 18 and patient_age < 65;
UPDATE tempfact_hospital SET age_id = 914 WHERE patient_age >= 65; 

ALTER TABLE tempfact_hospital
ADD (timeperiod_no NUMBER);


UPDATE tempfact_hospital SET timeperiod_no = 91 WHERE EXTRACT(month FROM patient_service_start_date) in (12,1,2);
UPDATE tempfact_hospital SET timeperiod_no = 92 WHERE EXTRACT(month FROM patient_service_start_date) in (6,7,8);
UPDATE tempfact_hospital SET timeperiod_no = 93 WHERE EXTRACT(month FROM patient_service_start_date) in (9,10,11);
UPDATE tempfact_hospital SET timeperiod_no = 94 WHERE EXTRACT(month FROM patient_service_start_date) in (3,4,5);



-- Now, create the fact table,

--DROP TABLE fact_hospital CASCADE CONSTRAINTS PURGE;
CREATE TABLE fact_hospital AS
SELECT T.suburb, T.age_id, T.timeperiod_no,
 T.service_id, COUNT(t.patient_id) AS total_no_patients, sum(t.service_cost) as total_service_cost
FROM tempfact_hospital T
GROUP BY T.service_id, T.suburb, T.timeperiod_no, T.age_id;


-- Show the total number of patients making appointments during Winter.
select
t.timeperiod_name , sum(f.total_no_patients) as total_no_of_patients
from fact_hospital f, timeperioddim t
where f.timeperiod_no =t.timeperiod_no
group by timeperiod_name
 having upper(timeperiod_name) = upper('winter');

-- Show the total service charged for each service cost type.
select s.service_id , sum(f.total_service_cost) as total_cost_charged_per_service
from fact_hospital f, (select distinct service_id from servicedim) s    --s will have temporary results with distinct service id's
where f.service_id =s.service_id
group by s.service_id;

 

-- Show the total number of patients by each age group (infant <1, children <18, adult 18+,senior 65+) in April 2020.
select  s.service_time,a.age_group, sum(total_no_patients) total_no_of_patients from 

fact_hospital h, agedim a,servicedim s where
h.service_id = s.service_id and h.age_id = a.age_id and 
extract(month from s.service_time) = 4 and extract(year from s.service_time) = 2020
group by s.service_time,a.age_group; 


-- Show the total service charged for general medical consultations in each suburb.
select  f.suburb, s.service_id ,sum(f.total_service_cost)
from fact_hospital f, (select distinct service_id, service_name from servicedim where upper(service_name) =upper('General Medical Consultations')) s    --s will have temporary results with distinct service id's
where f.service_id =s.service_id
group by s.service_id , f.suburb;

select * from servicedim;

 
