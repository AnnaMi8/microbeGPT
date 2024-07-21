--1 How many species possess histamine pathway?(BioCyc ID: PWY-6173)
SELECT COUNT(DISTINCT(a.species))
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.chocophlan AS c ON a.species = c.species
JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
WHERE p.pathway = 'PWY-6173';

--2 How abundant is K. aerogenes and K. oxytoca in healthy stool samples?
SELECT species, AVG(count) AS average_abundance
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND 
(species = 'Klebsiella aerogenes' OR species = 'Klebsiella oxytoca')
GROUP BY species;

--3 What's the average abundance of species that possess histamine pathway PWY-6173 in healthy stool samples? 
SELECT AVG(count)
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata AS m ON a.sample_id = m.sample_id
JOIN ds_mgpt_mgpt.chocophlan AS c ON a.species = c.species
JOIN ds_mgpt_mgpt.reactions_uniref90s AS r ON c.uniref90 = r.uniref90
JOIN ds_mgpt_mgpt.pathways_reactions AS p ON r.rxnid = p.rxnid
WHERE m.disease = 'healthy' AND m.body_site = 'stool' AND p.pathway = 'PWY-6173';

--4 Retrieve the sample IDs, counts, and species from the ‘abundance’ table where the species contains the term  ‘Klebsiella’ or contains the term ‘Lactobacillus’. Additionally, filter the results to include only samples where the count is greater than zero and the sample ID is associated with both ‘Klebsiella’ and a ‘Lactobacillus’ species.
SELECT sample_id, count, species
FROM ds_mgpt_mgpt.abundance
WHERE (species LIKE '%Klebsiella%' OR species LIKE '%Lactobacillus%')
AND count > 0
AND sample_id IN (
    SELECT sample_id
    FROM ds_mgpt_mgpt.abundance
    WHERE species LIKE '%Klebsiella%'
    INTERSECT
    SELECT sample_id
    FROM ds_mgpt_mgpt.abundance
    WHERE species LIKE '%Lactobacillus%'
);

