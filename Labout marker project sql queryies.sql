select * from education_categories;
select * from education;
SELECT * FROM training_and_experience_categories;
select * from job_zone_reference;
select * from job_zones;
select * from knowledge;
SELECT * FROM work_activities;
SELECT * FROM work_styles;
SELECT * FROM related_occupations;
SELECT * FROM occupation_data;
SELECT * from content_model_reference;
select * from essential_skills;
select * from software_skills;
SELECT * FROM training_and_experience;
SELECT * FROM employment_projections;
SELECT * FROM related_occupations;



with education_table as (
		select e.onetsoc_code,e.element_id,ec.scale_id,ec.category,ec.category_description,e.data_value,od.title
		from education_categories ec 
		Inner JOIN education e on ec.category = e.category
		Inner JOIN occupation_data od on od.onetsoc_code = e.onetsoc_code
)
select * from education_table;


with Knowledge_table as (
select od.onetsoc_code,kn.element_id,cmr.element_name,od.title, 
		CASE
        WHEN scale_id = 'IM' THEN 'Importance'
        WHEN scale_id = 'LV' THEN 'Level'
        ELSE 'Unknown'
    END AS scale_name,kn.data_value from knowledge kn 
Inner JOIN content_model_reference cmr on cmr.element_id = kn.element_id
Inner JOIN occupation_data od on od.onetsoc_code = kn.onetsoc_code)
select * from Knowledge_table;


with essential_skills_table as (
select cmr.element_name,od.title,es.onetsoc_code,
	CASE
        WHEN scale_id = 'IM' THEN 'Importance'
        WHEN scale_id = 'LV' THEN 'Level'
        ELSE 'Unknown'
    END AS scale_name,
    es.data_value from essential_skills es
Inner JOIN content_model_reference cmr on cmr.element_id = es.element_id
Inner JOIN  occupation_data od on od.onetsoc_code = es.onetsoc_code)
select * from essential_skills_table;

with work_activities_table as (
SELECT wa.element_id,
CASE
        WHEN scale_id = 'IM' THEN 'Importance'
        WHEN scale_id = 'LV' THEN 'Level'
        ELSE 'Unknown'
    END AS scale_name,
    wa.data_value,cmr.element_name,od.title FROM work_activities wa
Inner JOIN content_model_reference cmr on cmr.element_id = wa.element_id
Inner JOIN  occupation_data od on od.onetsoc_code = wa.onetsoc_code)
select * from work_activities_table;

with work_styles_table as (
SELECT ws.element_id,
CASE
        WHEN scale_id = 'WI' THEN 'Work Importance'
        WHEN scale_id = 'DR' THEN 'Domain Rating'
        ELSE 'Unknown'
    END AS scale_description,
    ws.data_value,cmr.element_name,od.title FROM work_styles ws
Inner JOIN content_model_reference cmr on cmr.element_id = ws.element_id
Inner JOIN  occupation_data od on od.onetsoc_code = ws.onetsoc_code)
select * from work_styles_table;

with training_and_experience_table as (
SELECT te.onetsoc_code,te.element_id,
CASE
    WHEN te.scale_id = 'RW' THEN 'Related Work Experience'
    WHEN te.scale_id = 'PT' THEN 'On-the-job Training'
    WHEN te.scale_id = 'OJ' THEN 'On-the-job Training Category'
    ELSE 'Unknown'
END AS scale_description,
od.title,tec.category_description,te.category,te.data_value FROM training_and_experience te
Inner JOIN training_and_experience_categories tec on tec.category = te.category
Inner Join occupation_data od on od.onetsoc_code = te.onetsoc_code)
select * from training_and_experience_table;

with job_zones_table as (
select jz.onetsoc_code,
CASE
        WHEN job_zone = 1 THEN 'Entry-Level (Little or No Preparation)'
        WHEN job_zone = 2 THEN 'Basic Preparation Required'
        WHEN job_zone = 3 THEN 'Moderate Preparation Required'
        WHEN job_zone = 4 THEN 'High Preparation Required'
        WHEN job_zone = 5 THEN 'Extensive Preparation and Advanced Expertise Required'
        ELSE 'Unknown'
    END AS job_zone_category,od.title from job_zones jz
Inner Join occupation_data od on od.onetsoc_code = jz.onetsoc_code)
select * from job_zones_table;


with software_skills_table as ( 
select ss.onetsoc_code,ss.workplace_example as software_skills,
    CASE
        WHEN emerging_technology = 'Y' THEN 'Yes'
        WHEN emerging_technology = 'N' THEN 'No'
        ELSE 'Unknown'
    END AS emerging_technology_status,
    CASE
        WHEN in_demand = 'Y' THEN 'Yes'
        WHEN in_demand = 'N' THEN 'No'
        ELSE 'Unknown'
    END AS in_demand_status,
    ss.element_id,od.title,cmr.element_name from software_skills ss
Inner Join occupation_data od on od.onetsoc_code = ss.onetsoc_code
Inner JOIN content_model_reference cmr on cmr.element_id = ss.element_id)
select * from software_skills_table;

with related_occupation_table as (
SELECT
o1.title AS occupation,
CASE
    WHEN relatedness_tier = 'Primary-Short'
        THEN 'Strong Relationship (Short Transition)'
    WHEN relatedness_tier = 'Primary-Long'
        THEN 'Strong Relationship (Long Transition)'
    WHEN relatedness_tier = 'Supplemental'
        THEN 'Weak Relationship'
    ELSE 'Unknown'
END AS relationship_strength,
o2.title AS related_occupation
FROM related_occupations ro
JOIN occupation_data o1
ON ro.onetsoc_code = o1.onetsoc_code
JOIN occupation_data o2
ON ro.related_onetsoc_code = o2.onetsoc_code)
select * from related_occupation_table;


select * from employment_projections;

SET SQL_SAFE_UPDATES = 0;
UPDATE employment_projections
SET work_experience_in_a_related_occupation = 'None'
WHERE work_experience_in_a_related_occupation IS NULL;
SET SQL_SAFE_UPDATES = 1;

with master_occupation_table as (
SELECT ep.occupation_code,od.title,ep.employment_2024,ep.employment_2034,employment_change_2024_2034,
ep.employment_percent_change_2024_2034 as emp_per_2024_2034,
ep.occupational_openings_2024_2034_annual_average as openings_2024_2034_avg,
ep.median_annual_wage_2024 as annual_wage_2024,ep.typical_entry_level_education as education_level,ep.education_code,
ep.work_experience_in_a_related_occupation as wrk_exp_related_occupation FROM occupation_data od
Inner Join employment_projections ep on ep.occupation_code = left(od.onetsoc_code,7))
select * from master_occupation_table;
