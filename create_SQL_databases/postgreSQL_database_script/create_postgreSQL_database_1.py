import glob
import psycopg2
from Bio import SeqIO
import gzip
import os


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


# functions to create relations in the database
# pathways connected to reactions
def insert_pathways(pathways_input, conn):
    cur = conn.cursor()
    cur.execute("""CREATE TABLE IF NOT EXISTS ds_mgpt_mgpt.pathways_reactions (
              id SERIAL PRIMARY KEY,
              pathway TEXT,
              rxnid TEXT)
             """)

    path_ids = []
    for index, line in enumerate(open(pathways_input, 'r')):
        if testing and index > 2:
            continue
        lines = line.split()
        for rxn in lines[1:]:
            path_ids.append((lines[0], rxn))

    pathway_insert = "INSERT INTO ds_mgpt_mgpt.pathways_reactions (pathway, rxnid) VALUES (%s, %s)"
    cur.executemany(pathway_insert, path_ids)
    conn.commit()
    cur.close()


# list of unique pathways  
def insert_unique_pathways(pathways_input,ip2mc_input, conn):
    cur = conn.cursor()
    cur.execute("""CREATE TABLE IF NOT EXISTS ds_mgpt_mgpt.unique_pathways (
              pathway_id TEXT PRIMARY KEY)
             """)
    
    pathways_ids = set()
    for index, line in enumerate(open(ip2mc_input, 'r')):
        if testing and index > 3:
            continue
        lines = line.split()
        for rxn in lines[1:]:
            pathways_ids.add(rxn)
    for index, line in enumerate(open(pathways_input, 'r')):
        lines = line.split()
        pathways_ids.add(lines[0])

    pathway_insert = "INSERT INTO ds_mgpt_mgpt.unique_pathways (pathway_id) VALUES (%s)"
    cur.executemany(pathway_insert, [(pathway_id,) for pathway_id in pathways_ids])
    conn.commit()
    cur.close()

#list of unique reactions
def insert_unique_reactions(rxn_input, pathways_input, conn):
    cur = conn.cursor()
    cur.execute("""CREATE TABLE IF NOT EXISTS ds_mgpt_mgpt.unique_reactions (
              reaction_id TEXT PRIMARY KEY)
             """)

    rxns = set()
    for index, line in enumerate(open(pathways_input, 'r')):
        if testing and index > 3:
            continue
        lines = line.split()
        for rxn in lines[1:]:
            rxns.add(rxn)
    for index, line in enumerate(open(rxn_input, 'r')):
        lines = line.split()
        rxns.add(lines[0])

    rxn_insert = "INSERT INTO ds_mgpt_mgpt.unique_reactions (reaction_id) VALUES (%s)"
    cur.executemany(rxn_insert, [(reaction_id,) for reaction_id in rxns])
    conn.commit()
    cur.close()
    
# list of unique IP numbers
def insert_unique_ips(ip2mc_input,ip2ec_input, conn):
    cur = conn.cursor()
    cur.execute("""CREATE TABLE IF NOT EXISTS ds_mgpt_mgpt.unique_ip_numbers (
              ip_id TEXT PRIMARY KEY)
             """)
    
    ips = set()
    for index, line in enumerate(open(ip2ec_input, 'r')):
        lines = line.split()
        ips.add(lines[0])
    for index, line in enumerate(open(ip2mc_input, 'r')):
        lines = line.split()
        ips.add(lines[0])

    ip_insert = "INSERT INTO ds_mgpt_mgpt.unique_ip_numbers (ip_id) VALUES (%s)"
    cur.executemany(ip_insert, [(ip_id,) for ip_id in ips])
    conn.commit()
    cur.close()
    
# insert ip2ec table
def insert_ip2ec(table_path, conn):
    cur = conn.cursor()
    
    cur.execute("""CREATE TABLE IF NOT EXISTS ds_mgpt_mgpt.ip_ec (
    id SERIAL PRIMARY KEY,
    ip_id TEXT,
    ec TEXT
    )
    """)

    ip2ec_tuples = [(x.split()[0], x.split()[1]) for x in open(table_path, 'r')]
    ip2ec_insert = "INSERT INTO ds_mgpt_mgpt.ip_ec (ip_id, ec) VALUES (%s, %s)"
    cur.executemany(ip2ec_insert, ip2ec_tuples)
    conn.commit()
    cur.close()

# insert metadata
def insert_metadata(metadata_input, conn):
    # Create the metadata table
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS ds_mgpt_mgpt.metadata(
        study_name TEXT,
        sample_id TEXT PRIMARY KEY,
        subject_id TEXT,
        body_site TEXT,
        antibiotics_current_use TEXT,
        study_condition TEXT,
        disease TEXT,
        age TEXT,
        age_category TEXT,
        gender TEXT,
        country TEXT,
        non_westernized TEXT)
    """)
    meta_ids = []
    try:
        meta_ids = []
        sample_ids = set()
        with open(metadata_input, 'r') as file:
                    header_line = file.readline()
                    header_line = header_line.split()
                    for index, line in enumerate(file):
                        lines = line.split('\t')
                        if lines[1] not in sample_ids:
                            sample_ids.add(lines[1])
                            meta_ids.append((lines[0].strip('"'), sample_id.strip('"'), lines[2].strip('"'),
                                     lines[3].strip('"'), lines[4].strip('"'), lines[5].strip('"'),
                                     lines[6].strip('"'), lines[7].strip('"'), lines[9].strip('"'),
                                     lines[10].strip('"'), lines[11].strip('"'), lines[12].strip('"')))
                        else:
                            pass                
                
    except Exception as e:
        print(f"An error occurred: {e}")
        
    # Insert data into the metadata table
    insert_query = "INSERT INTO ds_mgpt_mgpt.metadata (study_name,sample_id,subject_id,body_site,antibiotics_current_use,study_condition,disease,age,age_category,gender,country,non_westernized) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);"
    cur.executemany(insert_query, meta_ids)
    conn.commit()
    cur.close()
    
# insert ip2mc table
def insert_ip2mc(table_path, conn):
    cur = conn.cursor()
    cur.execute("""CREATE TABLE IF NOT EXISTS ds_mgpt_mgpt.ip_pathway (
    id SERIAL PRIMARY KEY,
    ip_id TEXT,
    pathway TEXT
    )
    """)

    ip2_mc_tuples = [(x.split()[0], x.split()[1]) for x in open(table_path, 'r')]
    ip2mc_insert = "INSERT INTO ds_mgpt_mgpt.ip_pathway (ip_id, pathway) VALUES (%s, %s)"
    cur.executemany(ip2mc_insert, ip2_mc_tuples)
    conn.commit()
    cur.close()

# chocophlan table 
def insert_chocophlan(path, conn):
    cur = conn.cursor()
    cur.execute("""CREATE TABLE IF NOT EXISTS ds_mgpt_mgpt.chocophlan (
              pid SERIAL PRIMARY KEY,
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
            choco_ids.append((r[0], taxa_string, r[2], os.path.basename(filename), taxa_strings[6].split('__')[1].replace('_', ' ')))
    choco_insert = """INSERT INTO ds_mgpt_mgpt.chocophlan 
    (id, taxa_string, uniref90, genome, species) 
    VALUES (%s, %s, %s, %s, %s)"""
    cur.executemany(choco_insert, choco_ids)
    conn.commit()
    cur.close()
    

#taxonomy table
def insert_taxonomy(path,abundance_input, conn):
    cur = conn.cursor()

    # Create the taxonomy table
    cur.execute("""
        CREATE TABLE IF NOT EXISTS ds_mgpt_mgpt.taxonomy (
            species TEXT PRIMARY KEY,
            genus TEXT,
            family TEXT,
            phylum TEXT,
            kingdom TEXT
        )
    """)
    
    species_list = set()
    taxa_ids = []
    for index, filename in enumerate(glob.glob(path + '/*ffn.gz')):
        if filename.find("alaS") > 0:
            continue
        # Add other conditions if needed
        first_record = next(SeqIO.parse(gzip.open(filename, "rt"), "fasta"))
        r = first_record.id.split("|")
        taxa_string = r[1]
        taxa_strings = taxa_string.split(".")
        taxa_ids.append((taxa_strings[6].split('__')[1].replace('_', ' '),
                         taxa_strings[5].split('__')[1].replace('_', ' '),
                         taxa_strings[4].split('__')[1].replace('_', ' '),
                         taxa_strings[1].split('__')[1].replace('_', ' '),
                         taxa_strings[0].split('__')[1].replace('_', ' ')))
        species_list.add(taxa_strings[6].split('__')[1].replace('_', ' '))
        
    with open(abundance_input, 'r') as file:
        header = file.readline()
        for line in file:
            taxa_string, sample_id, count, species = line.strip().split('\t')
            species = species.split('__')[1].replace('_', ' ')
            taxa_string = taxa_string.split('|')
            if species not in species_list:
                species_list.add(species)
                taxa_ids.append((
                taxa_string[6].split('__')[1].replace('_', ' '),
                taxa_string[5].split('__')[1].replace('_', ' '),
                taxa_string[4].split('__')[1].replace('_', ' '),
                taxa_string[1].split('__')[1].replace('_', ' '),
                taxa_string[0].split('__')[1].replace('_', ' ')
            ))      

    # Insert data into the taxonomy table
    taxa_insert = """
        INSERT INTO ds_mgpt_mgpt.taxonomy
        (species, genus, family, phylum, kingdom)
        VALUES (%s, %s, %s, %s, %s)
    """
    cur.executemany(taxa_insert, taxa_ids)
    conn.commit()
    cur.close()
    

    
#reactions and their uniref90 proteins associated
def insert_reactions(rxn_input, conn):
    cur = conn.cursor()
    cur.execute("""CREATE TABLE IF NOT EXISTS ds_mgpt_mgpt.reactions_uniref90s (
              id SERIAL PRIMARY KEY,
              rxnid TEXT,
              uniref90 TEXT
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

    rxn_insert = "INSERT INTO ds_mgpt_mgpt.reactions_uniref90s (rxnid, uniref90) VALUES (%s, %s)"
    cur.executemany(rxn_insert, rxn_ids)
    conn.commit()
    cur.close()
    
def insert_abundance(abundance_input, conn):
    # first create empty table
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS abundance (
            pid SERIAL PRIMARY KEY,
            taxa_string TEXT,
            sample_id TEXT,
            count REAL,
            species TEXT)""")
    # fill in table
    with open(abundance_input, 'r') as file:
        header = file.readline()
        for line in file:
            taxa_string, sample_id, count, species = line.strip().split('\t')
            species = species.split('__')[1].replace('_',' ')
            cur.execute("INSERT INTO abundance (taxa_string, sample_id, count, species) VALUES (%s, %s, %s, %s)", (taxa_string, sample_id, count, species))
    conn.commit()
    cur.close()
    
# insert table with unique uniref90 values
def insert_unique_uniref90(conn):
    cur = conn.cursor()
    
    cur.execute("""CREATE TABLE ds_mgpt_mgpt.unique_uniref90s AS
        SELECT DISTINCT uniref90
        FROM ds_mgpt_mgpt.chocophlan
        UNION
        SELECT DISTINCT uniref90
        FROM ds_mgpt_mgpt.reactions_uniref90s;
        """)
    
    cur.execute("""ALTER TABLE ds_mgpt_mgpt.unique_uniref90s
    ADD CONSTRAINT unique_column_constraint UNIQUE (uniref90);""")
    conn.commit()
    cur.close()    


# CONNECTION TO THE DATABASE and execute function that inserts the table of interest

hostname = '' # replace with hostname
database = 'datalake' # replace with database name
username = '' # replace with username
port_id = 5434
conn = None
cur = None
try: 
    conn = psycopg2.connect(host = hostname,
                           dbname = database,
                           user = username,
                           port = port_id)

    insert_ip2ec(ip2ec_input, conn)    
    insert_unique_ips(ip2mc_input,ip2ec_input, conn)
    insert_ip2mc(ip2mc_input, conn)
    insert_unique_pathways(pathways_input,ip2mc_input, conn)
    insert_pathways(pathways_input, conn)
    insert_unique_reactions(rxn_input, pathways_input, conn)
    insert_reactions(rxn_input, conn)
    insert_chocophlan(chocophlan_input, conn)
    insert_taxonomy(chocophlan_input,abundnace_input, conn)
    insert_abundance(abundance_input, conn)
    insert_metadata(metadata_input, conn)
    insert_unique_uniref90(conn)
    
    # finally set indexes in all columns that will be most used for search
    cur = conn.cursor()
    cur.execute("""CREATE INDEX pathwayidx ON ds_mgpt_mgpt.unique_pathways (pathway_id);
        CREATE INDEX ipidx ON ds_mgpt_mgpt.unique_ip_numbers (ip_id);
        CREATE INDEX rxnid ON ds_mgpt_mgpt.unique_reactions (reaction_id);
        CREATE INDEX unirefidx ON ds_mgpt_mgpt.unique_uniref90s (uniref90);
        CREATE INDEX taxonomy_index ON ds_mgpt_mgpt.taxonomy (species);
        CREATE INDEX taxa_levels_idx ON ds_mgpt_mgpt.taxonomy(phylum, family,genus); 
        CREATE INDEX metadata_idx ON ds_mgpt_mgpt.metadata (sample_id);
        CREATE INDEX abundance_idx ON ds_mgpt_mgpt.abundance (sample_id, species);
        CREATE INDEX abu_count_ids ON ds_mgpt_mgpt.abundance (count);
        CREATE INDEX chocophlan_taxa_idx ON ds_mgpt_mgpt.chocophlan (species);
        CREATE INDEX chocophlan_uniref90_idx ON ds_mgpt_mgpt.chocophlan (uniref90);
        CREATE INDEX reactions_rxnid_idx ON ds_mgpt_mgpt.reactions_uniref90s (rxnid, uniref90);""")
    
# exception class captures the errors that can happen so I can know why the connection is failing
except Exception as error:
    print(error)
finally:
    if cur is not None:
        cur.close()
    if conn is not None:
        conn.close()

print('done')