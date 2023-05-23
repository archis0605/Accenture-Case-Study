create database accenture_db;
use accenture_db;

/*1. In the school one teacher might be teaching more than one class. 
Write a query to identify how many classes each teacher is taking.*/
select t.teacher_name, count(*) as num_of_class
from teacher t
inner join teacher_allocation ta using(teacher_id)
group by t.teacher_name;

/*2. It is interesting for teachers to come across students with ntimes similar to theirs.
John is one of the teachers who finds this fascinating and 
wants to find out how many students in each class have names similar to his. Write a query to help him find this data.*/
with cte1 as 
	(
    with cte as 
		(
        select s.class_id, s.student_name, ta.teacher_id
		from student s
		inner join teacher_allocation ta using(class_id)
        )
	select c.class_id, c.student_name, c.teacher_id, t.teacher_name
	from cte c
	inner join teacher t using(teacher_id)
    )
select class_id, count(*) as same_name
from cte1
where student_name = teacher_name
group by class_id;

/*3. Every class teacher assigns unique roll number to their class students based on the alphabetical order of their names.
Can you help by writing a query that will assign roll number to each student in a class.*/
with cte as (select class_id, student_name,
		row_number() over (partition by class_id order by student_name asc) as roll_num
from student)
select c.class_standard, c.class_section, t.student_name, t.roll_num
from class c
inner join cte t using(class_id);

/*4. The principal of the school wants to understand the diversity of students in his school. One of the important aspects is
gender diversity. Provide a query that computes the male to female gender ratio in each class.*/
with male as (
		select class_id, gender, count(*) as male_cnt
		from student
		where gender = "M"
		group by class_id, gender
		order by class_id
        ),
female as (
		select class_id, gender, count(*) as female_cnt
		from student
		where gender = "F"
		group by class_id, gender
		order by class_id
        )

select m.class_id, (m.male_cnt/f.female_cnt) as male_female_ratio
from male m
inner join female f using(class_id);

/*5. Every school has teachers with different years of experience working in that school. The principal wants to know the average 
experience of teachers at his school.*/
select teacher_id, teacher_name, teacher_subject,
		date_of_joining,
        timestampdiff(year, date_of_joining, current_date()) as experience
from teacher;

/*6. At the end of every year class teachers must provide students with their marks sheet for the whole year.
The marks sheet of a student consist of exam (Quarterly, Half-Yearly, etc.) wise marks obtained out of the total marks. 
Help them by writing a query that gives the student wise marks sheet.*/
select e.class_standard, ep.student_id, e.exam_name, e.exam_subject, ep.marks, e.total_marks
from exam_paper ep
inner join exam e using(exam_id)
order by class_standard;

/*7. Every teacher has certain group of favourite students and keep track of their performance in exams. 
A teacher approached you to find out the percentages attained by students with ids 1,4,9,16,25 in the "Quarterly" exam. 
Write a query to obtain this data for each student.*/
with quarterly as (
	select ep.student_id, e.exam_name, sum(ep.marks) as marks_obtain, sum(e.total_marks) as total
	from exam_paper ep
	inner join exam e using(exam_id)
	where e.exam_name = "Quarterly"	and student_id in (1,4,9,16,25)
	group by ep.student_id)
select student_id, round(((marks_obtain/total)*100),2) as percentage
from quarterly;

/*8. Class teachers assign ranks to their students based on their marks obtained in each exam. Write a query 
to assign ranks (continuous) to students in each class for "Half-Yearly" exams.*/
with rank_num as (select ep.student_id, sum(ep.marks) as marks_obtain
from exam_paper ep
inner join exam e using(exam_id)
where e.exam_name = "Half Yearly"
group by ep.student_id)

select student_id, marks_obtain, dense_rank() over(order by marks_obtain desc) as rnk
from rank_num;
