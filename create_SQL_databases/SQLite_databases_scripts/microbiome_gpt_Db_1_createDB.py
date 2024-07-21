# import libraries
import sqlite3
import glob
from Bio import SeqIO
import gzip
import os
import pandas as pd

#define input files
global testing
testing = 0
#file pathways
pathways_input = './create_SQL_databases/input_files/metacyc_pathways'
rxn_input = './create_SQL_databases/input_files/metacyc_reactions_level4ec_only.uniref'
chocophlan_input = '.../chocophlan_v201901_v31/chocophlan/'  # replace with correct pathway after downloading the database
ip2mc_input = './create_SQL_databases/input_files/interpro2metacyc.txt'
ip2ec_input = './create_SQL_databases/input_files/interpro2ec.txt'
metadata_input = './create_SQL_databases/input_files/Curatedmetadata.txt'
abundance_input = './create_SQL_databases/input_files/CuratedAbundance.txt'



indexes = """
CREATE INDEX pathwayidx on pathway(pathway, rxnid);
CREATE INDEX reactionsidx on reactions(rxnid, uniref90);
CREATE INDEX chocophlanidx on chocophlan(id, taxa_string, uniref90, genome);
CREATE INDEX chocophlan_taxa_idx on chocophlan(species);
CREATE INDEX chocophlan_uniref90_idx on chocophlan(uniref90);
CREATE INDEX pathway_pathway_idx ON pathway(pathway);
CREATE INDEX reactions_rxnid_idx ON reactions(rxnid);
CREATE INDEX abundance_idx ON abundance(sample_id, species);
CREATE INDEX metadata_idx ON metadata(sample_id)
"""

# Define functions
def insert_chocophlan(path, conn):
    conn.execute("""CREATE TABLE IF NOT EXISTS chocophlan (
              pid INTEGER PRIMARY KEY AUTOINCREMENT,
              id TEXT, 
              taxa_string TEXT,
              uniref90 TEXT,
              genome TEXT,
    species TEXT)
             """)

    choco_ids = []
    for index, filename in enumerate(glob.glob(chocophlan_input + '/*ffn.gz')):
        if filename.find("alaS") > 0:
            continue
        if testing and index > 2:
            continue
        for record in  SeqIO.parse(gzip.open(filename, "rt"), "fasta"):
            r = record.id.split("|")
            taxa_string = r[1]
            taxa_strings = taxa_string.split(".")
            choco_ids.append((r[0], taxa_string, r[2], os.path.basename(filename), taxa_strings[6]))
    choco_insert = """INSERT INTO chocophlan 
    (id, taxa_string, uniref90, genome, species) 
    VALUES (?, ?, ?, ?, ?)"""
    conn.executemany(choco_insert, choco_ids)
    conn.commit()

def insert_pathways(pathways_input, conn):
    conn.execute("""CREATE TABLE IF NOT EXISTS pathway (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              pathway TEXT,
              rxnid TEXT,
              FOREIGN KEY (rxnid)
                  REFERENCES reactions (rxnid))
             """)

    path_ids = []
    for index, line in enumerate(open(pathways_input, 'r')):
        if testing and index > 2:
            continue
        lines = line.split()
        for rxn in lines[1:]:
            path_ids.append((lines[0], rxn))

    pathway_insert = "INSERT INTO pathway (pathway, rxnid) VALUES (?, ?)"
    conn.executemany(pathway_insert, path_ids)
    conn.commit()

    conn.executescript("""
    ALTER TABLE pathway ADD COLUMN pathway_count INTEGER;

    UPDATE pathway
    SET pathway_count = (
    SELECT COUNT(DISTINCT r.uniref90)
    FROM reactions r
    JOIN pathway p ON p.rxnid = r.rxnid
    WHERE p.pathway = pathway.pathway
    )
    WHERE EXISTS (
    SELECT 1
    FROM reactions r
    JOIN pathway p ON p.rxnid = r.rxnid
    WHERE p.pathway = pathway.pathway
    );
    """)
    
def insert_reactions(rxn_input, conn):
    conn.execute("""CREATE TABLE IF NOT EXISTS reactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              rxnid INTEGER,
              uniref90 TEXT,
              FOREIGN KEY (uniref90)
                  REFERENCES chocophlan (uniref90)
              )
             """)

    rxn_ids = []
    for index, line in enumerate(open(rxn_input, 'r')):
        if testing and index > 3:
            continue
        lines = line.split()
        for unif in lines[1:]:
            if unif.find("UniRef90") > -1:
                rxn_ids.append((lines[0], unif))

    rxn_insert = "INSERT INTO reactions (rxnid, uniref90) VALUES (?, ?)"
    conn.executemany(rxn_insert, rxn_ids)
    conn.commit()

def insert_ip2mc(table_path, conn):
      conn.execute("""CREATE TABLE IF NOT EXISTS ip2mc (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ip_id TEXT,
      pathway TEXT,
      FOREIGN KEY (pathway)
                  REFERENCES pathway (pathway)
      )
      """)
      
      ip2_mc_tuples = [(x.split()[0], x.split()[1]) for x in open(table_path, 'r')]
      ip2mc_insert = "INSERT INTO ip2mc (ip_id, pathway) VALUES (?, ?)"
      conn.executemany(ip2mc_insert, ip2_mc_tuples)
      conn.commit()

def insert_ip2ec(table_path, conn):
      conn.execute("""CREATE TABLE IF NOT EXISTS ip2ec (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ip_id TEXT,
      ec TEXT,
      FOREIGN KEY (ip_id)
                  REFERENCES ip2mc (ip_id)
      )
      """)
      
      ip2ec_tuples = [(x.split()[0], x.split()[1]) for x in open(table_path, 'r')]
      ip2ec_insert = "INSERT INTO ip2ec (ip_id, ec) VALUES (?, ?)"
      conn.executemany(ip2ec_insert, ip2ec_tuples)
      conn.commit()
    
def insert_metadata(metadata_input, conn):
    # Create the metadata table
    conn.execute("""
        CREATE TABLE IF NOT EXISTS metadata (
            pid INTEGER PRIMARY KEY AUTOINCREMENT,
            sample_id TEXT,
            metadata_column_name TEXT,
            metadata_variable_content TEXT,
            FOREIGN KEY (sample_id)
                  REFERENCES abundance (sample_id)
        )
    """)
    meta_ids = []
    try:
        with open(metadata_input, 'r') as file:
            header_line = file.readline().strip()
            header = [col.strip('"') for col in header_line.split('\t')]
            header.remove("sample_id")
            for index, line in enumerate(file):
                lines = line.strip().split('\t')
                lines = [col.strip('"') for col in lines]
                sample_id = lines[1]
                lines.remove(lines[1])
                if len(lines) != len(header):
                    raise ValueError(f"Header column mismatch at line {index + 2}. Check your data.")

                for idx, el in enumerate(lines):
                    meta_ids.append((sample_id, header[idx], el))
    except FileNotFoundError:
        print(f"File '{file_path}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")
        
    # Insert data into the metadata table
    insert_query = "INSERT INTO metadata (sample_id, variable_name, value) VALUES (?, ?, ?)"
    conn.executemany(insert_query, meta_ids)
    conn.commit()   

def insert_abundance(abundance_input, conn):
    # first create empty table
    conn.execute("""
        CREATE TABLE IF NOT EXISTS abundance (
            pid INTEGER PRIMARY KEY AUTOINCREMENT,
            taxa_string TEXT,
            sample_id TEXT,
            count REAL,
            species TEXT)""")
    # fill in table
    with open(abundance_input, 'r') as file:
        header = file.readline()
        for line in file:
            taxa_string, sample_id, count, species = line.strip().split('\t')
            conn.execute("INSERT INTO abundance (taxa_string, sample_id, count, species) VALUES (?, ?, ?, ?)", (taxa_string, sample_id, count, species))
    conn.commit()
    

# tables are created in specific order from parent to child tables for foreign keys settings
conn = sqlite3.connect('microbiome_gpt_Db_1.db')
insert_abundance(abundance_input, conn)
insert_metadata(metadata_input, conn)
insert_chocophlan(chocophlan_input, conn)
insert_reactions(rxn_input, conn)
insert_pathways(pathways_input, conn)
insert_ip2ec(ip2ec_input, conn)
insert_ip2mc(ip2mc_input, conn)
res = conn.executescript(indexes)
conn.commit()
conn.close()
print("done")
    
