--1 What is the distribution of the species faecalibacterium prausnitzii in healthy reference?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata as m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy as t ON a.species = t.species
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
t.species = 'Faecalibacterium prausnitzii';

--2 What is the distribution(average level) of faecalibacterium prausnitzii in the database?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE t.species = 'Faecalibacterium prausnitzii';

--3 How many species have the histamine pathway (BioCyc ID: PWY-6173)?
SELECT COUNT(DISTINCT t.species)
FROM ds_mgpt_mgpt.taxonomy AS t
JOIN ds_mgpt_mgpt.chocophlan AS c ON t.species = c.species
JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
WHERE p.pathway = 'PWY-6173';

--4 How many samples belong to healthy patients?
SELECT COUNT(DISTINCT sample_id) 
FROM ds_mgpt_mgpt.metadata 
WHERE disease = 'healthy';

--5 How many samples are from vagina and to how many different studies they belong?
SELECT COUNT(DISTINCT m.sample_id) AS num_samples, COUNT(DISTINCT m.study_name) AS num_studies
FROM ds_mgpt_mgpt.metadata AS m
WHERE m.body_site = 'vagina';

--6 How many species have a patient/sample on average?
SELECT AVG(num_species)
FROM (
    SELECT COUNT(DISTINCT species) AS num_species
    FROM ds_mgpt_mgpt.abundance
    GROUP BY sample_id
) AS species_counts;

--7 What's the average abundance of Firmicutes in the healthy samples from stool?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata as m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
t.phylum = 'Firmicutes';

--8 Looking for reference range for Helicobacter pylori in stool samples from Healthy patients. Is it 0-0?
SELECT MIN(count), MAX(count)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND t.genus = 'Helicobacter' AND t.species = 'pylori';

--9 What are the most abundant species in non-healthy samples?
SELECT a.species, SUM(a.count) AS total_count
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease != 'healthy'
GROUP BY a.species
ORDER BY total_count DESC
LIMIT 10;

--10 What is the distribution (average level) of the sum of the species that have histamine pathway (PWY-6173) in healthy stool samples?
SELECT AVG(sum_count)
FROM (
  SELECT SUM(a.count) AS sum_count
  FROM ds_mgpt_mgpt.abundance AS a
  JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
  JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
  JOIN ds_mgpt_mgpt.chocophlan AS c ON t.species = c.species
  JOIN ds_mgpt_mgpt.ip_pathway AS ip ON c.uniref90 = ip.ip_id
  JOIN ds_mgpt_mgpt.unique_pathways AS up ON ip.pathway = up.pathway_id
  WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND up.pathway_id = 'PWY-6173'
  GROUP BY a.sample_id
) AS sum_counts;

--11 What are the most three abundant species that belong to healthy samples and possess histamine pathway PWY-6173?
SELECT a.species, SUM(a.count) AS total_abundance
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
JOIN ds_mgpt_mgpt.chocophlan AS c ON t.species = c.species
JOIN ds_mgpt_mgpt.reactions_uniref90s AS ru ON c.uniref90 = ru.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS pr ON ru.rxnid = pr.rxnid
JOIN ds_mgpt_mgpt.ip_pathway AS ip ON pr.pathway = ip.pathway
WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND ip.ip_id = 'PWY-6173'
GROUP BY a.species
ORDER BY total_abundance DESC
LIMIT 3;

--12 What's the average abundance of Bacteroides in the healthy samples from stool?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata as m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
t.genus = 'Bacteroides';

--13 How many species are associated with specific polyamine pathway (PWY-6305) in healthy stool samples?
SELECT COUNT(DISTINCT a.species)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.chocophlan AS c ON a.species = c.species
JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS pr ON r.rxnid = pr.rxnid
JOIN ds_mgpt_mgpt.ip_pathway AS ip ON pr.pathway = ip.pathway
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
ip.pathway_id = 'PWY-6305';

--14 Are there any bacteria that belong to Lentisphaerae (Phylum section) in healthy stool samples? If so, how many?
SELECT COUNT(DISTINCT a.species)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
t.phylum = 'Lentisphaerae';

--15 What is the most abundant phylum in healthy stool samples?
SELECT t.phylum, SUM(a.count) AS total_abundance
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.taxa_string = t.species
WHERE m.disease = 'healthy' AND m.body_site = 'stool'
GROUP BY t.phylum
ORDER BY total_abundance DESC
LIMIT 1;

--16 What is the average value of Prevotellaceae in healthy stool samples  in western population?
SELECT AVG(count)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
m.non_westernized = 'no' AND
t.family = 'Prevotellaceae';

--17 How many non-healthy samples are there and how many different conditions do they belong to?
SELECT COUNT(DISTINCT m.sample_id) AS num_non_healthy_samples, COUNT(DISTINCT m.study_condition) AS num_conditions
FROM ds_mgpt_mgpt.metadata AS m
WHERE m.disease != 'healthy';

--18 GABA degradation pathway (4AMINOBUTMETAB-PWY): how many species possess it?
SELECT COUNT(DISTINCT t.species)
FROM ds_mgpt_mgpt.taxonomy AS t
JOIN ds_mgpt_mgpt.chocophlan AS c ON t.species = c.species
JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
WHERE p.pathway = '4AMINOBUTMETAB-PWY';

--19 What is the average level of Lactobacilli in healthy stool samples?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata as m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
t.genus = 'Lactobacillus';

--20 What is the most abundant family in healthy stool samples?
SELECT t.family, SUM(a.count) AS total_abundance
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND m.body_site = 'stool'
GROUP BY t.family
ORDER BY total_abundance DESC
LIMIT 1;

