--1 What is the distribution of the species Faecalibacterium prausnitzii in healthy reference?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata as m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
a.species = 'Faecalibacterium prausnitzii';

--2 What is the distribution(average level) of faecalibacterium prausnitzii in the database?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance 
WHERE species = 'Faecalibacterium prausnitzii';

--3 How many species have the histamine pathway (BioCyc ID: PWY-6173)?
SELECT COUNT(DISTINCT species)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.chocophlan AS c ON a.species = c.species
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

--6 How many species have a sample, on average? Calculate average abundance per each sample, excluding species where count is zero because it means they are not present in that sample.
SELECT AVG(num_species) AS avg_species_per_sample, AVG(abundance_sum/num_species) AS avg_abundance_per_sample
FROM (
    SELECT sample_id, COUNT(DISTINCT species) AS num_species, SUM(CASE WHEN count > 0 THEN count ELSE 0 END) AS abundance_sum
    FROM ds_mgpt_mgpt.abundance
    GROUP BY sample_id
) AS subquery;

--7 Calculate average abundance of Firmicutes in each healthy stool sample, then calculate an overall average of all these averages to get a mean value over samples.
SELECT AVG(avg_firmicutes) AS overall_avg_firmicutes
FROM (
  SELECT AVG(count) AS avg_firmicutes
  FROM ds_mgpt_mgpt.abundance AS a
  JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
  JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
  WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND t.phylum = 'Firmicutes'
  GROUP BY a.sample_id
) AS subquery;

--8 Looking for reference range for Helicobacter pylori in stool samples from Healthy patients. Is it 0-0? The range means the minimum and the maximum value.
SELECT MIN(count), MAX(count)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND a.species = 'Helicobacter pylori';

--9 What are the most abundant species in non-healthy samples?
SELECT species, SUM(count) AS total_abundance
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease != 'healthy'
GROUP BY species
ORDER BY total_abundance DESC
LIMIT 10;

--10 What is the distribution (average level) of the sum of the species that have histamine pathway (PWY-6173) in healthy stool samples? Look for species that possess pathway PWY- 6173, find those in abundance and calculate the average abundance of these species in each sample, then calculate an average of averages.
SELECT AVG(avg_abundance) 
FROM (
    SELECT AVG(count) AS avg_abundance
    FROM ds_mgpt_mgpt.abundance AS a
    JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
    JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
    JOIN ds_mgpt_mgpt.ip_ec AS ipe ON a.species = ipe.ip_id
    JOIN ds_mgpt_mgpt.ip_pathway AS ipp ON ipe.ip_id = ipp.ip_id
    WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND ipp.pathway = 'PWY-6173'
    GROUP BY a.sample_id, a.species
) AS subquery;

--11 What are the most three abundant species that belong to healthy samples and possess histamine pathway PWY-6173?
SELECT a.species, SUM(a.count) AS total_abundance
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.chocophlan AS c ON a.species = c.species
JOIN ds_mgpt_mgpt.ip_pathway AS ip ON c.uniref90 = ip.ip_id
WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND ip.pathway = 'PWY-6173'
GROUP BY a.species
ORDER BY total_abundance DESC
LIMIT 3;

--12 What's the average abundance of Bacteroides in the healthy samples from stool? Calculate average abundance of Bacteroides in each healthy stool sample, then calculate an overall average of all these averages to get a mean value over samples.
SELECT AVG(avg_bact) 
FROM (
    SELECT AVG(count) AS avg_bact 
    FROM ds_mgpt_mgpt.abundance AS a
    JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
    WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND a.species = 'Bacteroides'
    GROUP BY a.sample_id
) AS avg_bact_per_sample;

--13 How many species are associated with specific polyamine pathway (PWY-6305) in healthy stool samples? Count how many species possess this pathway.
SELECT COUNT(DISTINCT a.species)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.ip_pathway AS ip ON a.species = ip.ip_id
JOIN ds_mgpt_mgpt.pathways_reactions AS pr ON ip.pathway = pr.pathway
WHERE pr.pathway = 'PWY-6305' AND
a.sample_id IN (
    SELECT sample_id 
    FROM ds_mgpt_mgpt.metadata 
    WHERE disease = 'healthy' AND body_site = 'stool'
);

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
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND m.body_site = 'stool'
GROUP BY t.phylum
ORDER BY total_abundance DESC
LIMIT 1;

--16 What is the average value of Prevotellaceae in healthy stool samples  in western population? Calculate first an average value per sample and then the average of the averages.
SELECT AVG(avg_count) 
FROM (
    SELECT AVG(count) AS avg_count
    FROM ds_mgpt_mgpt.abundance AS a
    JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
    JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
    WHERE m.disease = 'healthy' AND
    m.body_site = 'stool' AND
    m.non_westernized = 'no' AND
    t.family = 'Prevotellaceae'
    GROUP BY a.sample_id
) AS subquery;

--17 How many non-healthy samples are there and how many different conditions do they belong to?
SELECT COUNT(DISTINCT m.sample_id) AS num_non_healthy_samples, COUNT(DISTINCT m.study_condition) AS num_conditions
FROM ds_mgpt_mgpt.metadata AS m
WHERE m.disease != 'healthy';

--18 GABA degradation pathway (4AMINOBUTMETAB-PWY): how many species possess it?
SELECT COUNT(DISTINCT species)
FROM ds_mgpt_mgpt.chocophlan AS c
JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
WHERE p.pathway = '4AMINOBUTMETAB-PWY';

--19 What is the average level of Lactobacilli in healthy stool samples? Calculate first an average value per sample and then the average of the averages.
SELECT AVG(avg_count) 
FROM (
    SELECT AVG(count) AS avg_count 
    FROM ds_mgpt_mgpt.abundance AS a
    JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
    WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND a.species = 'Lactobacillus'
    GROUP BY a.sample_id
) AS subquery;

--20 What is the most abundant family in healthy stool samples?
SELECT t.family, SUM(a.count) AS total_abundance
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.taxonomy AS t ON a.species = t.species
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND m.body_site = 'stool'
GROUP BY t.family
ORDER BY total_abundance DESC
LIMIT 1;