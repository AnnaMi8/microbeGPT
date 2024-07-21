--1 What is the distribution of the species faecalibacterium prausnitzii in healthy reference?
SELECT AVG(count) 
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
WHERE a.species LIKE '%s__Faecalibacterium_prausnitzii'; 

--2 What is the distribution(average level) of faecalibacterium prausnitzii in the database?
SELECT AVG(count) 
FROM abundance AS a
JOIN taxonomy AS t ON a.species = t.species
WHERE t.genus = 'Faecalibacterium' AND t.species = 'Faecalibacterium_prausnitzii'; 

--3 How many species have the histamine pathway (BioCyc ID: PWY-6173)?
SELECT COUNT(DISTINCT species)
FROM chocophlan AS c
JOIN reactions AS r ON c.uniref90 = r.uniref90
JOIN pathway AS p ON r.rxnid = p.rxnid
WHERE p.pathway = 'PWY-6173'; 

--4 How many samples belong to healthy patients?
SELECT COUNT(DISTINCT sample_id)
FROM metadata
WHERE metadata_column_name = 'disease' AND metadata_variable_content = 'healthy'; 

--5 How many samples are from vagina and to how many different studies they belong?
SELECT COUNT(DISTINCT m.sample_id) AS num_samples, COUNT(DISTINCT metadata_variable_content) AS num_studies
FROM metadata AS m
JOIN abundance AS a ON m.sample_id = a.sample_id
WHERE m.metadata_column_name = 'body_site'
AND m.metadata_variable_content = 'vagina';

--6 How many species have a patient/sample on average?
SELECT AVG(COUNT(DISTINCT species)) FROM abundance; 

--7 What's the average abundance of Firmicutes in the healthy samples from stool?
SELECT AVG(count)
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
JOIN taxonomy AS t ON a.species = t.species
WHERE t.phylum = 'Firmicutes'; 

--8 Looking for reference range for Helicobacter pylori in stool samples from Healthy patients. Is it 0-0?
SELECT AVG(count) 
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
WHERE a.species LIKE '%s__Helicobacter_pylori'; 

--9 What are the most abundant species in non-healthy samples?
SELECT a.species, SUM(a.count) AS total_abundance
FROM abundance AS a
JOIN metadata AS m ON a.sample_id = m.sample_id
WHERE m.metadata_column_name = 'disease'
  AND m.metadata_variable_content != 'healthy'
GROUP BY a.species
ORDER BY total_abundance DESC
LIMIT 10;

--10 What is the distribution (average level) of the sum of the species that have histamine pathway (PWY-6173) in healthy stool samples?
SELECT AVG(abundance.count)
FROM abundance
JOIN taxonomy ON abundance.species = taxonomy.species
JOIN chocophlan ON abundance.species = chocophlan.species
JOIN reactions ON chocophlan.uniref90 = reactions.uniref90
JOIN pathway ON reactions.rxnid = pathway.rxnid
JOIN ip2mc ON pathway.pathway = ip2mc.pathway
WHERE ip2mc.pathway = 'PWY-6173'
  AND abundance.sample_id IN (
      SELECT sample_id
      FROM metadata
      WHERE metadata_column_name = 'disease'
        AND metadata_variable_content = 'healthy'
        AND sample_id IN (
            SELECT sample_id
            FROM metadata
            WHERE metadata_column_name = 'body_site'
              AND metadata_variable_content = 'stool'
        )
  );

--11 What are the most three abundant species that belong to healthy samples and possess histamine pathway PWY-6173?
SELECT species, SUM(abundance.count) as total_abundance
FROM abundance
JOIN ip2mc ON abundance.species=ip2mc.ip_id
JOIN pathway ON pathway.pathway_id=ip2mc.pathway 
JOIN HealthyStoolSamples ON HealthyStoolSamples.sample_id=abundance.sample_id
WHERE pathway.pathway = 'PWY-6173'
GROUP BY species
ORDER BY total_abundance DESC
LIMIT 3;

--12 What's the average abundance of Bacteroides in the healthy samples from stool?
SELECT AVG(count)
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
WHERE a.species LIKE '%g__Bacteroides%';

--13 How many species are associated with specific polyamine pathway (PWY-6305) in healthy stool samples?
SELECT COUNT(DISTINCT a.species)
FROM abundance AS a
JOIN taxonomy AS t ON a.species = t.species
JOIN chocophlan AS c ON t.species = c.species
JOIN reactions AS r ON c.uniref90 = r.uniref90
JOIN pathway AS p ON r.rxnid = p.rxnid
JOIN ip2mc AS i ON p.pathway = i.pathway
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
WHERE i.pathway = 'PWY-6305';

--14 Are there any bacteria that belong to Lentisphaerae (Phylum section) in healthy stool samples? If so, how many?
SELECT COUNT(*) 
FROM (
  SELECT DISTINCT sample_id 
  FROM abundance 
  JOIN taxonomy ON abundance.species = taxonomy.species 
  JOIN HealthyStoolSamples ON abundance.sample_id = HealthyStoolSamples.sample_id 
  WHERE taxonomy.phylum = 'Lentisphaerae'
) AS LentisphaeraeSamples;

--15 What is the most abundant phylum in healthy stool samples?
SELECT t.phylum, SUM(a.count) as total_count
FROM taxonomy as t
JOIN abundance as a ON t.species = a.species
JOIN HealthyStoolSamples as m on m.sample_id = a.sample_id
GROUP BY t.phylum
ORDER BY total_count DESC
LIMIT 1;

--16 What is the average value of Prevotellaceae in healthy stool samples  in western population?
SELECT AVG(count)
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id 
JOIN taxonomy AS t ON a.species = t.species
WHERE t.family = 'Prevotellaceae' AND m.metadata_variable_content like 'western%'; 

--17 How many non-healthy samples are there and how many different conditions do they belong to?
SELECT COUNT(DISTINCT metadata_variable_content) AS num_conditions, COUNT(*) AS num_non_healthy_samples
FROM metadata
WHERE metadata_column_name = 'disease'
  AND metadata_variable_content != 'healthy';

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
WHERE a.species LIKE '%s__Lactobacillus%';

--20 What is the most abundant family in healthy stool samples?
SELECT family, SUM(count) AS total_abundance
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
JOIN taxonomy AS t ON a.species = t.species
GROUP BY family
ORDER BY total_abundance DESC
LIMIT 1;

