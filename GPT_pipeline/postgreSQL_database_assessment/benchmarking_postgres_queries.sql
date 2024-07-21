--1 What is the distribution of the species faecalibacterium prausnitzii in healthy reference?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata as m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
a.species = 'Faecalibacterium prausnitzii';

-- 2 What is the distribution(average level) of faecalibacterium prausnitzii in the database?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance
WHERE species = 'Faecalibacterium prausnitzii';

--3 How many species have the histamine pathway (BioCyc ID: PWY-6173)?
SELECT COUNT(DISTINCT c.species) AS species_count
FROM ds_mgpt_mgpt.chocophlan AS c
JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
WHERE p.pathway = 'PWY-6173';

-- 4 How many samples belong to healthy patients?
SELECT COUNT(sample_id)
FROM  ds_mgpt_mgpt.metadata
WHERE disease = 'healthy';

-- 5 How many samples are from vagina and to how many different studies they belong?
SELECT COUNT(DISTINCT(study_name)), COUNT(DISTINCT(sample_id)) as num_samples,
FROM ds_mgpt_mgpt.metadata
WHERE body_site = 'vagina';

--6 How many species have a patient/sample on average?
SELECT AVG(species_count)
FROM (
    SELECT sample_id, COUNT(species) AS species_count
    FROM ds_mgpt_mgpt.abundance
    WHERE count <> 0
    GROUP BY sample_id
) AS subquery;

-- 7 What's the average abundance of Firmicutes in the healthy samples from stool?
SELECT AVG(total_firmicutes)
FROM(
    SELECT SUM(count) as total_firmicutes
    FROM ds_mgpt_mgpt.abundance AS a
    JOIN ds_mgpt_mgpt.metadata AS M ON a.sample_id = m.sample_id
    WHERE m.disease = 'healthy' AND m.body_site = 'stool'
    AND a.taxa_string LIKE '%__Firmicutes__%'
    GROUP BY a.sample_id
) AS subquery;

--8 Looking for healthy stool reference range for H pylori. Is it 0-0? 
SELECT MIN(count), MAX(count)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND m.body_site = 'stool'
    AND a.species = 'Helicobacter pylori';

--9 What are the most abundant species in non-healthy samples?
SELECT species, SUM(count) 
FROM ds_mgpt_mgpt.abundance 
WHERE sample_id IN 
    (SELECT sample_id FROM ds_mgpt_mgpt.metadata AS m 
        WHERE m.disease != 'healthy')
             GROUP BY species 
             ORDER BY SUM(count) DESC 
             LIMIT 1;

-- 10 What is the distribution (average level) of the sum of the species that have histamine pathway (PWY-6173) in healthy stool samples?
SELECT AVG(sum_counts)
FROM (
    SELECT species, AVG(count) AS sum_counts
    FROM ds_mgpt_mgpt.abundance 
    WHERE sample_id IN (
    SELECT sample_id FROM ds_mgpt_mgpt.metadata AS m
    WHERE m.disease = 'healthy' AND m.body_site = 'stool'
    )
    AND species IN (
        SELECT c.species
        FROM ds_mgpt_mgpt.chocophlan AS c
        JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
        JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
        WHERE p.pathway = 'PWY-6173'
    )
    GROUP BY species 
    ) AS subquery;

-- 11 What are the most three abundant species that belong to healthy samples and possess histamine pathway PWY-6173?       
SELECT a.species, SUM(a.count) AS total_counts
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' 
    AND a.species IN (
        SELECT c.species
        FROM ds_mgpt_mgpt.chocophlan AS c
        JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
        JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
        WHERE p.pathway = 'PWY-6173'
    )
GROUP BY a.species
ORDER BY total_counts DESC
LIMIT 3;

-- 12 What's the average abundance of Bacteroides in the healthy samples from stool?
SELECT AVG(total_bacteroides)
FROM(
    SELECT SUM(count) as total_bacteroides
    FROM ds_mgpt_mgpt.abundance AS a
    JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
    WHERE m.disease = 'healthy' AND m.body_site = 'stool'
    AND a.taxa_string LIKE '%__Bacteroides__%'
    GROUP BY a.sample_id
) AS subquery;

-- 13 How many species are associated with specific polyamine pathway (PWY-6305) in healthy stool samples?
SELECT COUNT(DISTINCT(species))
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND m.body_site = 'stool'
AND species IN (
    SELECT DISTINCT c.species 
    FROM ds_mgpt_mgpt.chocophlan AS c
    JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
    JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
    WHERE p.pathway = 'PWY-6305'
);

-- 14 Are there any bacteria that belong to Lentisphaerae (Phylum section) in healthy stool samples? If so, how many?
SELECT COUNT(DISTINCT(species)) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND m.body_site = 'stool'
AND taxa_string LIKE '%p__Lentisphaerae%'
ORDER BY SUM(count) DESC 
             LIMIT 3;

--15 What is the most abundant phylum in healthy stool samples?
SELECT t.phylum, SUM(a.count) AS total_count
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND
      m.body_site = 'stool'
GROUP BY t.phylum
ORDER BY total_count DESC
LIMIT 1;

-- 16 What is the average value of Prevotellaceae in healthy stool samples in western population?
SELECT AVG(average_prevot)
FROM (
    SELECT AVG(count) AS average_prevot
    FROM ds_mgpt_mgpt.abundance AS a
    JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
    WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND m.non_westernized = 'no'
    AND taxa_string LIKE '%Prevotellaceae%'
    GROUP BY a.sample_id
    ) AS subquery
;

-- 17 How many non-healthy samples are there and how many different conditions do they belong to?
SELECT
    COUNT(DISTINCT sample_id) AS total_non_healthy_samples,
    COUNT(DISTINCT disease) AS distinct_conditions
FROM ds_mgpt_mgpt.metadata AS m 
WHERE m.disease != 'healthy';

-- 18 GABA degradation pathway (4AMINOBUTMETAB-PWY): how many species possess it?
SELECT COUNT(DISTINCT c.species) AS species_count
FROM ds_mgpt_mgpt.chocophlan AS c
JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
WHERE p.pathway = '4AMINOBUTMETAB-PWY';

-- 19 What is the average level of Lactobacilli in healthy stool samples?
SELECT AVG(average_lacto)
FROM (
SELECT AVG(count) AS average_lacto
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND m.body_site = 'stool'
AND taxa_string LIKE '%g__Lactobacillus%'
GROUP BY a.sample_id) 
AS subquery
;

-- 20 What is the most abundant family in healthy stool samples? 
SELECT SUM(count) as total_count, t.family
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON t.species = a.species
WHERE m.disease = 'healthy' AND m.body_site = 'stool' 
GROUP BY t.family
ORDER BY total_count DESC
LIMIT 3;