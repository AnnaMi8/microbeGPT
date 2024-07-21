CREATE TABLE chocophlan (
    pid INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique ID for each species existent in chocophlan
    id TEXT, 
    taxa_string TEXT,  -- taxonomic classfication 
    uniref90 TEXT,
    genome TEXT,
    species TEXT,
    genus TEXT,
    family TEXT,
    phylum TEXT,
    kingdom TEXT
);

CREATE TABLE reactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique reaction ID
    rxnid INTEGER, -- Reaction ID
    uniref90 TEXT, -- Uniref90 protein identifier that belongs to the reaction
    FOREIGN KEY (uniref90)
        REFERENCES chocophlan (uniref90)
);
              
CREATE TABLE pathway (
    id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique pathway ID
    pathway TEXT, -- Pathway ID in metacyc database
    rxnid TEXT, pathway_count INTEGER, -- Reaction ID belonging to that pathway
    FOREIGN KEY (rxnid)
      REFERENCES reactions (rxnid)
);

CREATE TABLE IF NOT EXISTS "Ip2ec" (
    id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique IP to EC number identifier
    ip_id TEXT, -- IP ID
    ec TEXT, -- EC number corresponding to IP number
    FOREIGN KEY (ip_id)
              REFERENCES "Ip2mc" (ip_id)
);
    
CREATE TABLE IF NOT EXISTS "Ip2mc" (
    id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique IP to metacyc pathway identifier
    ip_id TEXT, -- IP number ID
    pathway TEXT, -- Corresponding metacyc pathway
    FOREIGN KEY (pathway)
              REFERENCES pathway (pathway)
);

CREATE TABLE abundance (
    pid INTEGER PRIMARY KEY AUTOINCREMENT, --Unique abundance identifier
    taxa_string TEXT, 
    sample_id TEXT, -- sample ID
    count REAL, -- abundance value of the species in the sample
    species TEXT
);

CREATE TABLE metadata (
    pid INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique metadata identifier
    sample_id TEXT, -- Sample ID
    metadata_column_name TEXT, -- metadata variable names
    metadata_variable_content TEXT, -- value/content that the variable has
    FOREIGN KEY (sample_id)
          REFERENCES abundance (sample_id)
);
        
CREATE INDEX pathwayidx on pathway(pathway, rxnid);
CREATE INDEX reactionsidx on reactions(rxnid, uniref90);
CREATE INDEX chocophlanidx on chocophlan(id, taxa_string, uniref90, genome);
CREATE INDEX chocophlan_taxa_idx on chocophlan(taxa_string);
CREATE INDEX chocophlan_uniref90_idx on chocophlan(uniref90);
CREATE INDEX pathway_pathway_idx ON pathway(pathway);
CREATE INDEX reactions_rxnid_idx ON reactions(rxnid);
CREATE INDEX abundance_idx ON abundance(sample_id, species);
CREATE INDEX metadata_idx ON metadata(sample_id)
;


CREATE VIEW HealthyStoolSamples AS
SELECT *
FROM metadata
WHERE metadata_column_name = 'disease'
  AND metadata_variable_content = 'healthy'
  AND sample_id IN (
      SELECT sample_id
      FROM metadata
      WHERE metadata_column_name = 'body_site'
        AND metadata_variable_content = 'stool'
  ) /* HealthyStoolSamples(pid,sample_id,metadata_column_name,metadata_variable_content) */;
-- when asked to calculate healthy stool reference/ samples use HealthyStoolSamples table

-- chocophlan.taxa_string can be joined with abundance.taxa_string
-- chocophlan.species can be joined with abundance.species
-- metadata.metadata_column_name possible values are: study_name, subject_id, body_site, antibiotics_current_use, study_condition, disease, age, infant_age, age_category, gender, country, non_westernized, sequencing_platform, DNA_extraction_kit, PMID, number_reads, number_bases, minimum_read_length, median_read_length, NCBI_accession, pregnant, lactating, curator, BMI, family, treatment, days_from_first_collection, family_role, born_method, feeding_practice, location, diet, travel_destination, visit_number, premature, birth_weight, gestational_age, antibiotics_family, disease_subtype, days_after_onset, creatine, albumine, hscrp, ESR, ast, alt, globulin, urea_nitrogen, BASDAI, BASFI, alcohol, flg_genotype, population, menopausal_status, lifestyle, body_subsite, uncurated_metadata, tnm, triglycerides, hdl, ldl, hba1c, change_in_tumor_size, RECIST, ORR, smoker, ever_smoker, dental_sample_type, history_of_periodontitis, PPD_M, PPD_B, PPD_D, PPD_L, fobt, disease_stage, disease_location, calprotectin, HBI, SCCAI, mumps, cholesterol, c_peptide, glucose, creatinine, bilubirin, prothrombin_time, wbc, rbc, hemoglobinometry, FMT_role, subcohort, fmt_id, remission, dyastolic_p, systolic_p, insulin_cat, adiponectin, glp_1, cd163, il_1, leptin, fgf_19, glutamate_decarboxylase_2_antibody, HLA, autoantibody_positive, age_seroconversion, age_T1D_diagnosis, hitchip_probe_class, previous_therapy, performance_status, toxicity_above_zero, PFS12, fasting_insulin, fasting_glucose, protein_intake, stec_count, shigatoxin_2_elisa, stool_texture, anti_PD_1, ajcc, smoke, bristol_score, hsCRP, LDL, mgs_richness, ferm_milk_prod_consumer, inr, birth_control_pil, c_section_type, hla_drb12, hla_dqa12, hla_dqa11, hla_drb11, zigosity, brinkman_index, alcohol_numeric, breastfeeding_duration, formula_first_day, ALT, eGFR

--average richness is a term that refers to the average number of different species a sample has