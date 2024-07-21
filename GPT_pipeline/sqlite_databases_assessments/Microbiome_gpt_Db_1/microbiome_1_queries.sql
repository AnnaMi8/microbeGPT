--1 What is the distribution of the species faecalibacterium prausnitzii in healthy reference?
SELECT taxa_string, AVG(count) AS abundance_average, COUNT(*) AS sample_count
FROM abundance
JOIN chocophlan ON abundance.species = chocophlan.species AND abundance.taxa_string = chocophlan.taxa_string
JOIN HealthyStoolSamples ON abundance.sample_id = HealthyStoolSamples.sample_id
WHERE chocophlan.species = 's__Faecalibacterium prausnitzii'
GROUP BY taxa_string;

--2 What is the distribution(average level) of faecalibacterium prausnitzii in the database?
SELECT AVG(count) 
FROM abundance 
WHERE species = 'faecalibacterium prausnitzii';

--3 How many species have the histamine pathway (BioCyc ID: PWY-6173)?
SELECT COUNT(DISTINCT species) as num_species 
FROM chocophlan 
WHERE uniref90 IN (
    SELECT uniref90 
    FROM reactions 
    WHERE rxnid IN (
        SELECT rxnid 
        FROM pathway 
        WHERE pathway = 'PWY-6173'
    )
); 

--4 How many samples belong to healthy patients?
SELECT COUNT(DISTINCT sample_id) AS num_samples
FROM metadata
WHERE metadata_column_name = 'disease'
  AND metadata_variable_content = 'healthy';

--5 How many samples are from vagina and to how many different studies they belong?
SELECT COUNT(DISTINCT ab.sample_id) AS num_samples, COUNT(DISTINCT md.metadata_variable_content) AS num_studies
FROM abundance AS ab
JOIN chocophlan AS ch ON ab.taxa_string = ch.taxa_string AND ab.species = ch.species
JOIN metadata AS md ON ab.sample_id = md.sample_id
WHERE md.metadata_column_name = 'body_site' AND md.metadata_variable_content = 'vagina';

--6 How many species have a patient/sample on average?
SELECT AVG(species_count) 
FROM 
(SELECT COUNT(DISTINCT species) 
 AS species_count FROM abundance GROUP BY sample_id);

--7 What is the ratio Bacterioides/Firmicutes in healthy population in stool samples?
SELECT 
  b.taxa_string AS bacteria, 
  SUM(CASE WHEN b.genus = 'Bacteroides' THEN a.count ELSE 0 END) / 
  SUM(CASE WHEN b.phylum = 'Firmicutes' THEN a.count ELSE 0 END) AS ratio
FROM abundance a
JOIN chocophlan b ON a.taxa_string=b.taxa_string AND a.species=b.species
JOIN HealthyStoolSamples h ON a.sample_id=h.sample_id
GROUP BY bacteria
HAVING bacteria IN ('Bacteroides', 'Firmicutes')

--8 Looking for reference range for Helicobacter pylori in stool samples from Healthy patients. Is it 0-0?
SELECT abundance.count
FROM abundance
JOIN chocophlan
  ON abundance.taxa_string = chocophlan.taxa_string
  AND abundance.species = chocophlan.species
JOIN metadata
  ON abundance.sample_id = metadata.sample_id
WHERE metadata.metadata_column_name = 'disease'
  AND metadata.metadata_variable_content = 'healthy'
  AND metadata.sample_id IN (
      SELECT sample_id
      FROM metadata
      WHERE metadata_column_name = 'body_site'
        AND metadata_variable_content = 'stool'
  )
  AND chocophlan.genus = 'Helicobacter'
  AND chocophlan.species = 'pylori'; 

--9 What are the most abundant species in non-healthy samples?
SELECT species, sum(count) AS total_abundance
FROM abundance
JOIN chocophlan ON abundance.species = chocophlan.species AND abundance.taxa_string = chocophlan.taxa_string
JOIN metadata ON abundance.sample_id = metadata.sample_id
WHERE metadata.metadata_column_name = 'disease' AND metadata.metadata_variable_content != 'healthy'
GROUP BY species
ORDER BY total_abundance DESC
LIMIT 10;

--10 What is the distribution (average level) of the sum of the species that have histamine pathway (PWY-6173) in healthy stool samples?
WITH histamine_species AS (
  SELECT DISTINCT ch.species
  FROM chocophlan ch
  INNER JOIN reactions re
  ON ch.uniref90 = re.uniref90
  INNER JOIN pathway pa
  ON re.rxnid = pa.rxnid
  INNER JOIN Ip2mc ip
  ON pa.pathway = ip.pathway
  WHERE ip.ip_id = 'PWY-6173'
), healthy_stool_abundance AS (
  SELECT ab.species, ab.count
  FROM abundance ab
  INNER JOIN metadata md
  ON ab.sample_id = md.sample_id
  WHERE md.metadata_column_name = 'disease'
    AND md.metadata_variable_content = 'healthy'
    AND md.sample_id IN (
      SELECT sample_id
      FROM metadata
      WHERE metadata_column_name = 'body_site'
        AND metadata_variable_content = 'stool'
    )
)
SELECT AVG(total_count) AS average_count
FROM (
  SELECT SUM(ab.count) AS total_count
  FROM healthy_stool_abundance ab
  WHERE ab.species IN histamine_species
  GROUP BY ab.sample_id
) grouped_counts;

--11 What are the most three abundant species that belong to healthy samples and possess histamine pathway PWY-6173?
WITH histamine_species AS (
  SELECT ab.species, SUM(ab.count) AS total_abundance
  FROM abundance ab
  JOIN chocophlan cp ON cp.uniref90 = ab.species
  JOIN Ip2mc i2m ON i2m.ip_id = cp.id
  JOIN pathway p ON p.pathway = i2m.pathway
  WHERE p.pathway = 'PWY-6173'
  GROUP BY ab.species
), 
healthy_stool_samples AS (
  SELECT ab.sample_id, ab.species, SUM(ab.count) AS total_abundance
  FROM abundance ab
  JOIN metadata m ON m.sample_id = ab.sample_id
  WHERE m.metadata_column_name = 'disease' AND m.metadata_variable_content = 'healthy'
  AND m.sample_id IN (
    SELECT sample_id FROM metadata
    WHERE metadata_column_name = 'body_site' AND metadata_variable_content = 'stool'
  )
  GROUP BY ab.species
)
SELECT hs.species, hs.total_abundance
FROM histamine_species h
JOIN healthy_stool_samples hs ON h.species = hs.species
ORDER BY hs.total_abundance DESC
LIMIT 3;

--12 What's the average abundance of Bacteroides in the healthy samples from stool?
SELECT AVG(ab.count) as avg_abundance
FROM abundance ab
JOIN HealthyStoolSamples hss ON hss.sample_id = ab.sample_id
JOIN chocophlan cp ON ab.taxa_string = cp.taxa_string AND ab.species = cp.species
WHERE cp.genus = 'Bacteroides'

--13 How many species are associated with specific polyamine pathway (PWY-6305) in healthy stool samples?
SELECT COUNT(DISTINCT chocophlan.species) as species_count
FROM chocophlan 
JOIN reactions ON chocophlan.uniref90 = reactions.uniref90 
JOIN pathway ON reactions.rxnid = pathway.rxnid 
JOIN Ip2mc ON Ip2mc.pathway = pathway.pathway 
JOIN Ip2ec ON Ip2mc.ip_id = Ip2ec.ip_id 
JOIN abundance ON chocophlan.species = abundance.species AND chocophlan.taxa_string = abundance.taxa_string 
JOIN HealthyStoolSamples ON abundance.sample_id = HealthyStoolSamples.sample_id
WHERE pathway.pathway = 'PWY-6305'; 

--14 Are there any bacteria that belong to Lentisphaerae (Phylum section) in healthy stool samples? If so, how many?
SELECT COUNT(DISTINCT abundance.pid) AS num_bacteria_lentisphaerae
FROM chocophlan
JOIN abundance ON chocophlan.taxa_string = abundance.taxa_string AND chocophlan.species = abundance.species
JOIN metadata ON abundance.sample_id = metadata.sample_id
WHERE chocophlan.phylum = 'Lentisphaerae'
AND metadata.metadata_column_name = 'disease'
AND metadata.metadata_variable_content = 'healthy'
AND metadata.sample_id IN (
    SELECT sample_id
    FROM metadata
    WHERE metadata_column_name = 'body_site'
    AND metadata_variable_content = 'stool'
); 

--15 What is the most abundant phylum in healthy stool samples?
SELECT c.phylum, SUM(a.count) AS total_abundance
FROM chocophlan c
INNER JOIN abundance a ON c.taxa_string = a.taxa_string AND c.species = a.species
INNER JOIN HealthyStoolSamples h ON a.sample_id = h.sample_id
GROUP BY c.phylum
ORDER BY total_abundance DESC
LIMIT 1;

--16 What is the average value of Prevotellaceae in healthy stool samples  in western population?
SELECT AVG(abundance.count) AS avg_prevotellaceae
FROM abundance
JOIN chocophlan ON abundance.taxa_string = chocophlan.taxa_string AND abundance.species = chocophlan.species
JOIN metadata ON abundance.sample_id = metadata.sample_id
WHERE metadata.metadata_column_name = 'disease' 
  AND metadata.metadata_variable_content = 'healthy'
  AND metadata.sample_id IN (
      SELECT sample_id
      FROM metadata
      WHERE metadata_column_name = 'body_site'
        AND metadata_variable_content = 'stool'
    )
  AND metadata.sample_id IN (
      SELECT sample_id 
      FROM metadata 
      WHERE metadata_column_name = 'country' 
      AND metadata_variable_content IN ('USA', 'Canada', 'Western Europe')
   )
  AND chocophlan.family = 'Prevotellaceae';

--17 How many non-healthy samples are there and how many different conditions do they belong to?
SELECT COUNT(DISTINCT m.sample_id) AS num_non_healthy_samples, COUNT(DISTINCT m.metadata_variable_content) AS num_conditions
FROM metadata m
JOIN abundance a ON m.sample_id = a.sample_id
JOIN chocophlan c ON a.taxa_string = c.taxa_string AND a.species = c.species
WHERE m.metadata_column_name = 'disease' AND m.metadata_variable_content != 'healthy' 

--18 GABA degradation pathway (4AMINOBUTMETAB-PWY): how many species possess it?
SELECT COUNT(DISTINCT chocophlan.pid)
FROM chocophlan
JOIN reactions ON chocophlan.uniref90 = reactions.uniref90
JOIN pathway ON reactions.rxnid = pathway.rxnid
JOIN Ip2mc ON pathway.pathway = Ip2mc.pathway
WHERE Ip2mc.pathway = '4AMINOBUTMETAB-PWY';

--19 What is the average level of Lactobacilli in healthy stool samples?
SELECT AVG(abundance.count) as avg_lactobacilli
FROM abundance 
JOIN chocophlan ON abundance.taxa_string = chocophlan.taxa_string AND abundance.species = chocophlan.species
JOIN HealthyStoolSamples ON abundance.sample_id = HealthyStoolSamples.sample_id
WHERE chocophlan.genus LIKE '%Lactobacillus%'

--20 What is the most abundant family in healthy stool samples?
SELECT c.family, SUM(a.count) AS total_abundance
FROM chocophlan AS c
JOIN abundance AS a ON c.species = a.species AND c.taxa_string = a.taxa_string
JOIN HealthyStoolSamples AS s ON a.sample_id = s.sample_id
GROUP BY c.family
ORDER BY total_abundance DESC
LIMIT 1;

