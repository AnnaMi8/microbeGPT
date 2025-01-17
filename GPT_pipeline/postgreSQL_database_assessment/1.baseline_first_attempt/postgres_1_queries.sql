--1 What is the distribution of the species faecalibacterium prausnitzii in healthy reference?
SELECT AVG(count)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
a.species = 'faecalibacterium prausnitzii';

--2 What is the distribution(average level) of faecalibacterium prausnitzii in the database?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance 
WHERE species = 'Faecalibacterium prausnitzii';

--3 How many species have the histamine pathway (BioCyc ID: PWY-6173)?
SELECT COUNT(DISTINCT species)
FROM ds_mgpt_mgpt.chocophlan AS c
JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
WHERE p.pathway = 'PWY-6173';

--4 How many samples belong to healthy patients?
SELECT COUNT(DISTINCT sample_id) 
FROM ds_mgpt_mgpt.metadata
WHERE disease = 'healthy';

--5 How many samples are from vagina and to how many different studies they belong?
SELECT 
    COUNT(DISTINCT(sample_id)) as num_samples, 
    COUNT(DISTINCT(study_name)) as num_studies 
FROM 
    ds_mgpt_mgpt.metadata 
WHERE 
    body_site = 'vagina';

--6 How many species have a patient/sample on average?
SELECT AVG(species_count)
FROM (
  SELECT COUNT(DISTINCT species) AS species_count
  FROM ds_mgpt_mgpt.abundance
  GROUP BY sample_id
) AS species_counts;

--7 What's the average abundance of Firmicutes in the healthy samples from stool?
SELECT AVG(count)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE m.disease = 'healthy' 
AND m.body_site = 'stool' 
AND t.phylum = 'Firmicutes';

--8 Looking for reference range for Helicobacter pylori in stool samples from Healthy patients. Is it 0-0?
SELECT COUNT(*) 
FROM ds_mgpt_mgpt.abundance AS a 
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE m.disease = 'healthy' 
AND m.body_site = 'stool' 
AND t.genus = 'Helicobacter' 
AND t.species = 'Helicobacter pylori';

--9 What are the most abundant species in non-healthy samples?
SELECT a.species, SUM(a.count) AS total_abundance
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease != 'healthy'
GROUP BY a.species
ORDER BY total_abundance DESC
LIMIT 10;

--10 What is the distribution (average level) of the sum of the species that have histamine pathway (PWY-6173) in healthy stool samples?
SELECT AVG(SUM(a.count)) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.ip_ec as ipe ON a.species=ipe.ip_id
JOIN ds_mgpt_mgpt.ip_pathway as ipp ON ipp.ip_id=ipe.ip_id
JOIN ds_mgpt_mgpt.metadata as m ON m.sample_id=a.sample_id
WHERE m.disease = 'healthy' 
  AND m.body_site = 'stool' 
  AND ipp.pathway = 'PWY-6173'
GROUP BY a.sample_id;

--11 What are the most three abundant species that belong to healthy samples and possess histamine pathway PWY-6173?
SELECT a.species, SUM(a.count) AS total_abundance
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
JOIN ds_mgpt_mgpt.chocophlan AS c ON t.genus = c.species
JOIN ds_mgpt_mgpt.ip_pathway AS ip ON c.uniref90 = ip.ip_id
JOIN ds_mgpt_mgpt.pathways_reactions AS pr ON ip.pathway = pr.pathway
WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND pr.pathway = 'PWY-6173'
GROUP BY a.species
ORDER BY total_abundance DESC
LIMIT 3;

--12 What's the average abundance of Bacteroides in the healthy samples from stool?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata as m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
a.species = 'Bacteroides';

--13 How many species are associated with specific polyamine pathway (PWY-6305) in healthy stool samples?
SELECT COUNT(DISTINCT a.species)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.ip_ec AS ie ON ie.id = a.pid
JOIN ds_mgpt_mgpt.ip_pathway AS ip ON ip.ip_id = ie.ip_id
JOIN ds_mgpt_mgpt.pathways_reactions AS pr ON pr.pathway = ip.pathway
WHERE pr.pathway = 'PWY-6305' AND
a.sample_id IN (
    SELECT sample_id 
    FROM ds_mgpt_mgpt.metadata AS m 
    WHERE m.disease = 'healthy' AND m.body_site = 'stool'
);

--14 Are there any bacteria that belong to Lentisphaerae (Phylum section) in healthy stool samples? If so, how many?
SELECT COUNT(distinct(a.species))
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
t.phylum = 'Lentisphaerae';

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

--16 What is the average value of Prevotellaceae in healthy stool samples  in western population?
SELECT AVG(count)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE m.disease = 'healthy'
AND m.body_site = 'stool'
AND m.non_westernized = 'no'
AND t.family = 'Prevotellaceae';

--17 How many non-healthy samples are there and how many different conditions do they belong to?
SELECT COUNT(DISTINCT m.sample_id) AS non_healthy_samples, COUNT(DISTINCT m.study_condition) AS different_conditions
FROM ds_mgpt_mgpt.metadata AS m
WHERE m.disease <> 'healthy';

--18 GABA degradation pathway (4AMINOBUTMETAB-PWY): how many species possess it?
SELECT COUNT(DISTINCT t.species) AS num_species
FROM ds_mgpt_mgpt.taxonomy AS t
JOIN ds_mgpt_mgpt.chocophlan AS c ON t.species = c.species
JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
WHERE p.pathway = '4AMINOBUTMETAB-PWY';

--19 What is the average level of Lactobacilli in healthy stool samples?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata as m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
a.species = 'Lactobacillus';

--20 What is the most abundant family in healthy stool samples?
SELECT t.family, sum(a.count) as total_count 
FROM ds_mgpt_mgpt.abundance as a 
JOIN ds_mgpt_mgpt.taxonomy as t ON a.species = t.species 
JOIN ds_mgpt_mgpt.metadata as m ON a.sample_id = m.sample_id 
WHERE m.disease = 'healthy' AND m.body_site = 'stool' 
GROUP BY t.family 
ORDER BY total_count DESC 
LIMIT 1;

