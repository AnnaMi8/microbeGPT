---Relations 
CREATE TABLE ds_mgpt_mgpt.abundance (
    pid integer NOT NULL,
    taxa_string text,
    sample_id text,
    count real, -- OTU count (relative abundance) for that species in that sample
    species text
);


CREATE TABLE ds_mgpt_mgpt.chocophlan (
    pid integer NOT NULL,
    id text,
    taxa_string text,
    uniref90 text,
    genome text,
    species text
);

CREATE TABLE ds_mgpt_mgpt.ip_ec (
    id integer NOT NULL,
    ip_id text,
    ec text
);

CREATE TABLE ds_mgpt_mgpt.ip_pathway (
    id integer NOT NULL,
    ip_id text,
    pathway text
);

CREATE TABLE ds_mgpt_mgpt.metadata (
    study_name text, -- study name the sample comes from, usually a name and a year, indicating first author and pubblication year
    sample_id text NOT NULL,
    subject_id text, -- patient identifier
    body_site text, -- specifies body site the sample was taken from
    antibiotics_current_use text, -- says if patient was taking antibiotics when the sample was taken
    study_condition text,
    disease text, -- 142 possible diseases the patient could have, including beign healthy
    age text, -- numerical value of the age
    age_category text, -- says the age category of the patient the sample was taken from: senior /adult/NA/schoolage/newborn/child
    gender text,
    country text, -- (41 possible countries the samples belong to, each country is defined by its 3-letters name i.e. Denmark = 'DNK' )
    non_westernized text -- says if the country is (mainly) geographycally from west or east (yes/no)
);


CREATE TABLE ds_mgpt_mgpt.pathways_reactions (
    id integer NOT NULL,
    pathway text,
    rxnid text
);

CREATE TABLE ds_mgpt_mgpt.reactions_uniref90s (
    id integer NOT NULL,
    rxnid text,
    uniref90 text
);

CREATE TABLE ds_mgpt_mgpt.taxonomy (
    species text NOT NULL,
    genus text,
    family text,
    phylum text,
    kingdom text
);

CREATE TABLE ds_mgpt_mgpt.unique_ip_numbers (
    ip_id text NOT NULL
);

CREATE TABLE ds_mgpt_mgpt.unique_pathways (
    pathway_id text NOT NULL
);

CREATE TABLE ds_mgpt_mgpt.unique_reactions (
    reaction_id text NOT NULL
);

CREATE TABLE ds_mgpt_mgpt.unique_uniref90s (
    uniref90 text
);


--- primary keys
ALTER TABLE ONLY ds_mgpt_mgpt.abundance
    ADD CONSTRAINT abundance_pkey PRIMARY KEY (pid);

ALTER TABLE ONLY ds_mgpt_mgpt.chocophlan
    ADD CONSTRAINT chocophlan_pkey PRIMARY KEY (pid);

ALTER TABLE ONLY ds_mgpt_mgpt.ip_ec
    ADD CONSTRAINT ip_ec_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ds_mgpt_mgpt.ip_pathway
    ADD CONSTRAINT ip_pathway_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ds_mgpt_mgpt.metadata
    ADD CONSTRAINT metadata_pkey PRIMARY KEY (sample_id);

ALTER TABLE ONLY ds_mgpt_mgpt.pathways_reactions
    ADD CONSTRAINT pathways_reactions_pkey PRIMARY KEY (id);
    
ALTER TABLE ONLY ds_mgpt_mgpt.reactions_uniref90s
    ADD CONSTRAINT reactions_uniref90s_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ds_mgpt_mgpt.taxonomy
    ADD CONSTRAINT taxonomy_pkey PRIMARY KEY (species);

ALTER TABLE ONLY ds_mgpt_mgpt.unique_uniref90s
    ADD CONSTRAINT unique_column_constraint UNIQUE (uniref90);

ALTER TABLE ONLY ds_mgpt_mgpt.unique_ip_numbers
    ADD CONSTRAINT unique_ip_numbers_pkey PRIMARY KEY (ip_id);

ALTER TABLE ONLY ds_mgpt_mgpt.unique_pathways
    ADD CONSTRAINT unique_pathways_pkey PRIMARY KEY (pathway_id);

ALTER TABLE ONLY ds_mgpt_mgpt.unique_reactions
    ADD CONSTRAINT unique_reactions_pkey PRIMARY KEY (reaction_id);
    
    
-- abundance.species can be joined with taxonomy.species 
-- abundance.sample_id can be joined with metadata.sample_id 
-- chocophlan.species can be joined with taxonomy.species
-- chocophlan.uniref90  can be joined with unique_uniref90s.uniref90
-- reactions_uniref90s.rxnid can be joined with unique_reactions.reaction_id
-- reactions_uniref90s.uniref90 can be joined with unique_uniref90s.uniref90
-- pathways_reactions.pathway can be joined with unique_pathways.pathway_id 
-- pathways_reactions.rxnid can be joined with unique_reactions.reaction_id 
-- ip_ec.ip_id can be joined with unique_ip_numbers.ip_id.
-- ip_pathway.ip_id can also be joined with unique_ip_numbers.ip_id.
    
--- when asked about healthy stool samples means: SELECT sample_id FROM ds_mgpt_mgpt.metadata AS m WHERE m.disease = 'healthy' AND m.body_site = 'stool';

-- Example: What is the distribution of E. coli in healthy samples from stool?
SELECT AVG(count) 
FROM ds_mgpt_mgpt.abundance AS a
JOIN ds_mgpt_mgpt.metadata as m ON a.sample_id = m.sample_id
WHERE m.disease = 'healthy' AND
m.body_site = 'stool' AND
a.species = 'Escherichia coli';