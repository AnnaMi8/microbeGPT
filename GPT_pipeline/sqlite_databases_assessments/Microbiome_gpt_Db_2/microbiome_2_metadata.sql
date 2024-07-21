CREATE TABLE taxonomy (
    species TEXT PRIMARY KEY,-- unique species ID
    genus TEXT,
    family TEXT,
    phylum TEXT,
    kingdom TEXT );
CREATE TABLE abundance (
            pid INTEGER PRIMARY KEY AUTOINCREMENT,
            taxa_string TEXT,
            sample_id TEXT,
            count REAL, -- OTU count (relative abundance) for that species in that sample
            species TEXT, 
            FOREIGN KEY (species) 
                REFERENCES taxonomy(species));
CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE metadata (
            pid INTEGER PRIMARY KEY AUTOINCREMENT,
            sample_id TEXT, -- samples IDs
            metadata_column_name TEXT, -- metadata possible variables : ex. condition of the patient, country and age of the patient, body site the sample comes from etc..
            metadata_variable_content TEXT,
            FOREIGN KEY (sample_id)
                  REFERENCES abundance (sample_id)
        );
CREATE TABLE chocophlan (
              pid INTEGER PRIMARY KEY AUTOINCREMENT,
              id TEXT, 
              taxa_string TEXT,
              uniref90 TEXT, -- uniref90 ID protein that that species possess
              genome TEXT,
    species TEXT,
    FOREIGN KEY (species)
        REFERENCES taxonomy(species));
CREATE TABLE reactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              rxnid INTEGER, -- Reaction ID
              uniref90 TEXT, -- Uniref90 protein that belongs to the reaction
              FOREIGN KEY (uniref90)
                  REFERENCES chocophlan (uniref90)
              );
CREATE TABLE pathway (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              pathway TEXT, -- Pathway ID in metacyc database
              rxnid TEXT, pathway_count INTEGER,
              FOREIGN KEY (rxnid)
                  REFERENCES reactions (rxnid));
CREATE TABLE ip2ec (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ip_id TEXT,
      ec TEXT,
      FOREIGN KEY (ip_id)
                  REFERENCES ip2mc (ip_id)
      );
CREATE TABLE ip2mc (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ip_id TEXT,
      pathway TEXT,
      FOREIGN KEY (pathway)
                  REFERENCES pathway (pathway)
      );

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
  
CREATE INDEX pathwayidx on pathway(pathway, rxnid);
CREATE INDEX reactionsidx on reactions(rxnid, uniref90);
CREATE INDEX chocophlanidx on chocophlan(id, taxa_string, uniref90, genome);
CREATE INDEX chocophlan_taxa_idx on chocophlan(species);
CREATE INDEX chocophlan_uniref90_idx on chocophlan(uniref90);
CREATE INDEX pathway_pathway_idx ON pathway(pathway);
CREATE INDEX reactions_rxnid_idx ON reactions(rxnid);
CREATE INDEX abundance_idx ON abundance(sample_id, species);
CREATE INDEX metadata_idx ON metadata(sample_id);
CREATE INDEX taxonomy_index ON taxonomy(species, genus, family, phylum, kingdom);
  
-- when asked to calculate healthy stool reference/ samples use HealthyStoolSamples table
--average richness is a term that refers to the average number of different species a sample has
-- When searching for any taxa level they are written as in the following example: k__Bacteria|p__Proteobacteria|c__Gammaproteobacteria|o__Enterobacterales|f__Enterobacteriaceae|g__Escherichia|s__Escherichia_coli

-- Example: What is the distribution of E. coli in healthy samples from stool?
SELECT AVG(count) 
FROM abundance AS a
JOIN HealthyStoolSamples AS m ON a.sample_id = m.sample_id
WHERE a.species = '%s__Escherichia_coli';