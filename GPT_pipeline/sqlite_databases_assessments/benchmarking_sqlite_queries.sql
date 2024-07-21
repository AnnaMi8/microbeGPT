-- 1 What is the distribution of the species faecalibacterium prausnitzii in healthy stool reference?
SELECT AVG(count) 
FROM abundance AS a
INNER JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
WHERE a.species LIKE '%s__Faecalibacterium_prausnitzii';

-- 2 What is the distribution(average level) of faecalibacterium prausnitzii in the database?
SELECT AVG(count) 
FROM abundance
WHERE species LIKE '%s__Faecalibacterium_prausnitzii';

-- 3 How many species have the histamine pathway (BioCyc ID: PWY-6173)?
SELECT COUNT(DISTINCT (c.species)) AS species_count
FROM chocophlan AS c
JOIN reactions AS r ON c.uniref90 = r.uniref90
JOIN pathway AS p ON r.rxnid = p.rxnid
WHERE p.pathway = 'PWY-6173';

-- 4 How many samples belong to healthy patients?
SELECT COUNT(DISTINCT(sample_id))
FROM metadata
WHERE metadata_column_name = 'disease' 
             AND metadata_variable_content = 'healthy';

-- 5 How many samples are from vagina and to how many different studies they belong?
SELECT COUNT(DISTINCT(metadata_variable_content))
FROM metadata
WHERE metadata_column_name = 'study_name' AND
sample_id IN (SELECT sample_id
FROM metadata as m
WHERE m.metadata_column_name = 'body_site' AND m.metadata_variable_content = "vagina");

-- 6 How many species have a patient/sample on average?
SELECT AVG(species_count)
FROM (
    SELECT sample_id, COUNT(species) AS species_count
    FROM abundance
    WHERE count <> 0
    GROUP BY sample_id
) AS subquery;

-- 7 What's the average abundance of Firmicutes in the healthy samples from stool?
SELECT AVG(total_firmicutes)
FROM(
    SELECT SUM(count) as total_firmicutes
    FROM abundance
    JOIN HealthyStoolSamples AS m ON abundance.sample_id = m.sample_id
    WHERE abundance.taxa_string LIKE '%__Firmicutes__%'
    GROUP BY abundance.sample_id
);

-- 8 Looking for healthy stool reference range for H pylori. Is it 0-0? 
SELECT MIN(count), MAX(count)
FROM abundance AS a
JOIN HealthyStoolSamples AS h ON a.sample_id = h.sample_id
JOIN metadata AS m ON a.sample_id = m.sample_id
WHERE a.species = 's__Helicobacter_pylori';

-- 9 What are the most abundant species in non-healthy samples?
SELECT species, SUM(count) 
FROM abundance 
WHERE sample_id IN 
    (SELECT sample_id FROM metadata 
        WHERE metadata_column_name = 'disease' 
             AND metadata_variable_content != 'healthy')
             GROUP BY species 
             ORDER BY SUM(count) DESC 
             LIMIT 10;

-- 10 What is the distribution (average level) of the sum of the species that have histamine pathway (PWY-6173) in healthy stool samples?
SELECT AVG(sum_counts)
FROM (
    SELECT species, AVG(count) AS sum_counts
    FROM abundance 
    WHERE sample_id IN (
        SELECT sample_id 
        FROM HealthyStoolSamples
    )
    AND species IN (
        SELECT c.species
        FROM chocophlan AS c
        JOIN reactions AS r ON c.uniref90 = r.uniref90
        JOIN pathway AS p ON r.rxnid = p.rxnid
        WHERE p.pathway = 'PWY-6173'
    )
    GROUP BY species 
    );

-- 11 What are the most three abundant species that belong to healthy stool samples and possess histamine pathway PWY-6173?
SELECT species, SUM(count) 
FROM abundance 
WHERE sample_id IN 
    (SELECT sample_id FROM HealthyStoolSamples)
AND species IN (
    SELECT c.species
    FROM chocophlan AS c
    JOIN reactions AS r ON c.uniref90 = r.uniref90
    JOIN pathway AS p ON r.rxnid = p.rxnid
    WHERE p.pathway = 'PWY-6173'
)
             GROUP BY species 
             ORDER BY SUM(count) DESC 
             LIMIT 3;

-- 12 What's the average abundance of Bacteroides in the healthy samples from stool?
SELECT AVG(total_bacteroides)
FROM(SELECT SUM(count) as total_bacteroides
FROM abundance
JOIN HealthyStoolSamples AS m ON abundance.sample_id = m.sample_id
WHERE abundance.taxa_string LIKE '%__Bacteroides__%'
GROUP BY abundance.sample_id
);

-- 13 How many species are associated with specific polyamine pathway (PWY-6305) in healthy stool samples?
SELECT COUNT(DISTINCT(species))
FROM abundance 
WHERE sample_id IN (SELECT sample_id FROM HealthyStoolSamples)
AND species IN (
    SELECT DISTINCT c.species 
    FROM chocophlan AS c
    JOIN reactions AS r ON c.uniref90 = r.uniref90
    JOIN pathway AS p ON r.rxnid = p.rxnid
    WHERE p.pathway = 'PWY-6305'
);

-- 14 Are there any bacteria that belong to Lentisphaerae (Phylum section) in healthy stool samples? If so, how many?
SELECT COUNT(DISTINCT(species)) 
FROM abundance 
WHERE sample_id IN 
    (SELECT sample_id FROM HealthyStoolSamples)
AND taxa_string LIKE '%p__Lentisphaerae%'
ORDER BY SUM(count) DESC 
             LIMIT 3;

-- 15 What is the most abundant phylum in healthy stool samples? 
SELECT SUM(count) as total_count, t.phylum
FROM abundance AS a
JOIN taxonomy AS t ON t.species = t.species
JOIN HealthyStoolSamples as m on m.sample_id = a.sample_id
GROUP BY t.phylum
ORDER BY total_count DESC
LIMIT 3;

-- 16 What is the average value of Prevotellaceae in healthy stool samples in western population?
SELECT AVG(average_prevot)
FROM (
SELECT AVG(count) AS average_prevot
FROM abundance 
WHERE sample_id IN 
    (SELECT sample_id FROM HealthyStoolSamples)
    AND sample_id IN 
    (SELECT sample_id 
     FROM metadata
     WHERE metadata_column_name = 'non_westernized'
     AND metadata_variable_content = 'no')
AND taxa_string LIKE '%f__Prevotellaceae%'
GROUP BY sample_id)
;

-- 17 How many non-healthy samples are there and how many different conditions do they belong to?           
SELECT
    COUNT(DISTINCT sample_id) AS total_non_healthy_samples,
    COUNT(DISTINCT metadata_variable_content) AS distinct_conditions
FROM metadata
WHERE metadata_column_name = 'disease'
    AND metadata_variable_content != 'healthy';

-- 18 GABA degradation pathway (4AMINOBUTMETAB-PWY): how many species possess it?   
SELECT COUNT(DISTINCT c.species) AS species_count
FROM chocophlan AS c
JOIN reactions AS r ON c.uniref90 = r.uniref90
JOIN pathway AS p ON r.rxnid = p.rxnid
WHERE p.pathway = '4AMINOBUTMETAB-PWY';

-- 19 What is the average level of Lactobacilli in healthy stool samples?
SELECT AVG(average_lacto)
FROM (
SELECT AVG(count) AS average_lacto
FROM abundance 
WHERE sample_id IN 
    (SELECT sample_id FROM HealthyStoolSamples)
AND taxa_string LIKE '%g__Lactobacillus%'
GROUP BY sample_id)
;

-- 20 What is the most abundant family? 
SELECT SUM(count) as total_count, t.family
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
JOIN taxonomy AS t ON t.species = a.species
GROUP BY t.family
ORDER BY total_count DESC
LIMIT 3;