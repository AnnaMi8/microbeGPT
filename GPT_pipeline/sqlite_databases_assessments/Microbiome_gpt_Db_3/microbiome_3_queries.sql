--1 What is the distribution of the species faecalibacterium prausnitzii in healthy reference?
SELECT species, AVG(count) 
FROM abundance AS a 
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id 
JOIN taxonomy AS t ON a.species = t.species 
WHERE t.species = 'Faecalibacterium prausnitzii'
GROUP BY species;

--2 What is the distribution(average level) of faecalibacterium prausnitzii in the database?
SELECT AVG(count)
FROM abundance AS a
WHERE species = 'faecalibacterium prausnitzii';

--3 How many species have the histamine pathway (BioCyc ID: PWY-6173)?
SELECT COUNT(DISTINCT c.species)
FROM chocophlan AS c
JOIN reactions AS r ON c.uniref90 = r.uniref90
JOIN pathway AS p ON r.rxnid = p.rxnid
WHERE p.pathway = 'PWY-6173';

--4 How many samples belong to healthy patients?
SELECT COUNT(DISTINCT sample_id) 
FROM metadata 
WHERE metadata_column_name = 'disease'
AND metadata_variable_content = 'healthy';

--5 How many samples are from vagina and to how many different studies they belong?
SELECT COUNT(DISTINCT(sample_id)) AS sample_count, COUNT(DISTINCT(metadata_variable_content)) AS study_count
FROM metadata
WHERE metadata_column_name = 'body_site' AND metadata_variable_content = 'vagina';

--6 How many species have a patient/sample on average?
SELECT AVG(COUNT(DISTINCT species)) as avg_species_count
FROM abundance;

--7 What's the average abundance of Firmicutes in the healthy samples from stool?
SELECT AVG(count)
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
JOIN taxonomy AS t ON a.species = t.species
WHERE t.phylum = 'Firmicutes';

--8 Looking for reference range for Helicobacter pylori in stool samples from Healthy patients. Is it 0-0?
SELECT COUNT(*) 
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
WHERE a.species = 'Helicobacter pylori' AND a.count > 0;

--9 What are the most abundant species in non-healthy samples?
SELECT species, SUM(count) AS total_abundance
FROM abundance
JOIN metadata ON abundance.sample_id = metadata.sample_id
WHERE metadata.metadata_column_name = 'disease' AND metadata.metadata_variable_content <> 'healthy'
GROUP BY species
ORDER BY total_abundance DESC
LIMIT 1;

--10 What is the distribution (average level) of the sum of the species that have histamine pathway (PWY-6173) in healthy stool samples?
SELECT AVG(total_count) AS avg_count FROM (
SELECT SUM(count) AS total_count
FROM abundance AS a
JOIN chocophlan AS c ON a.species = c.species
JOIN reactions AS r ON c.uniref90 = r.uniref90
JOIN pathway AS p ON r.rxnid=p.rxnid
JOIN ip2mc AS i ON p.pathway=i.pathway
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
WHERE p.pathway = 'PWY-6173'
GROUP BY a.sample_id) AS sum_counts;

--11 What are the most three abundant species that belong to healthy samples and possess histamine pathway PWY-6173?
SELECT a.species, SUM(a.count) AS total_abundance
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON m.sample_id = a.sample_id
JOIN chocophlan AS c ON c.species = a.species
JOIN reactions AS r ON r.uniref90 = c.uniref90
JOIN pathway AS p ON p.rxnid = r.rxnid
WHERE m.metadata_variable_content = 'healthy'
AND m.metadata_column_name = 'disease'
AND m2.metadata_variable_content = 'stool'
AND m2.metadata_column_name = 'body_site'
AND p.pathway = 'PWY-6173'
GROUP BY a.species
ORDER BY total_abundance DESC
LIMIT 3;

--12 What's the average abundance of Bacteroides in the healthy samples from stool?
SELECT AVG(count)
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
JOIN taxonomy AS t ON a.species = t.species
WHERE t.genus = 'Bacteroides';

--13 How many species are associated with specific polyamine pathway (PWY-6305) in healthy stool samples?
SELECT COUNT(DISTINCT c.species)
FROM chocophlan AS c
JOIN reactions AS r ON c.uniref90 = r.uniref90
JOIN pathway AS p ON r.rxnid = p.rxnid
JOIN ip2mc AS i ON p.pathway = i.pathway
JOIN HealthyStoolSamples AS m ON m.sample_id = i.ip_id
WHERE p.pathway = 'PWY-6305';

--14 Are there any bacteria that belong to Lentisphaerae (Phylum section) in healthy stool samples? If so, how many?
SELECT COUNT(*) 
FROM abundance AS a 
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id 
JOIN taxonomy AS t ON a.species = t.species 
WHERE t.phylum = 'Lentisphaerae';

--15 What is the most abundant phylum in healthy stool samples?
SELECT t.phylum, SUM(a.count) AS total_abundance
FROM taxonomy AS t
JOIN abundance AS a ON t.species = a.species
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
GROUP BY t.phylum
ORDER BY total_abundance DESC
LIMIT 1;

--16 What is the average value of Prevotellaceae in healthy stool samples  in western population?
SELECT AVG(count) 
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
JOIN taxonomy AS t ON a.species = t.species
WHERE t.family = 'Prevotellaceae'
  AND m.metadata_variable_content = 'western';

--17 How many non-healthy samples are there and how many different conditions do they belong to?
SELECT COUNT(DISTINCT m.sample_id) AS num_non_healthy_samples, COUNT(DISTINCT m.metadata_variable_content) AS num_conditions 
FROM metadata AS m
WHERE m.metadata_column_name = 'disease'
AND m.metadata_variable_content != 'healthy';

--18 GABA degradation pathway (4AMINOBUTMETAB-PWY): how many species possess it?
SELECT COUNT(DISTINCT c.species)
FROM chocophlan AS c
JOIN reactions AS r ON c.uniref90 = r.uniref90
JOIN pathway AS p ON r.rxnid = p.rxnid
WHERE p.pathway = '4AMINOBUTMETAB-PWY';

--19 What is the average level of Lactobacilli in healthy stool samples?
SELECT AVG(count) 
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
WHERE a.species = 'Lactobacillus';

--20 What is the most abundant family in healthy stool samples?
SELECT family, SUM(count) AS abundance
FROM abundance AS a 
JOIN taxonomy AS t ON a.species = t.species 
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
GROUP BY family
ORDER BY abundance DESC
LIMIT 1;