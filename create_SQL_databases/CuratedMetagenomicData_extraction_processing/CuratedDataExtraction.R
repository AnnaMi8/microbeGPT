library(dplyr)
library(DT)
library(curatedMetagenomicData)
library(tidyr)
library(table1)

## extract metadata and abundance from CuratedMetagenomicData 

# extract metadata
metadata <- curatedMetagenomicData::sampleMetadata
write.table(abundance, file = "CuratedMetadata.txt", sep = "\t", row.names = FALSE)


# get abundance table 
relativeAbundance_tse <- sampleMetadata |>
  returnSamples("relative_abundance", rownames = "long")

# assay is the table from which the TreeSummarizedExperiment (tse) object is built and this is abundance table we are looking for
abundance <- assay(relativeAbundance_tse)
# write to txt file tab separated
write.table(abundance, file = "abundance.txt", sep = "\t", row.names = FALSE)


## CuratedMetadata is already usable for being used as input file in SQL databases creation.
## Abundance data will be preprocessed in 'abundanceData_preprocessing' script, to get the dataset ready for being inserted as a table in SQL database.
## This is done because file was very big and was making table creation process very slow at database creation step.


# PRODUCE TABLE1 for metadata: display statistics
metadata_part <- metadata[1:20]

#There are some missing values in study condition, but those are set as 'healthy' in disease column, so the N.A. sections are replaced with 'healthy'
missing_rows <- is.na(metadata_part$study_condition)
rows_with_missing <- metadata_part[missing_rows, ]

# replace N.A study condition rows with 'healthy', accoriding to 'disease' column
metadata_part$study_condition[is.na(metadata_part$study_condition)] <- "control"
# to get a smaller table, stratification is done distinguishing between control and a general label called disease.
metadata_part$study_condition[which(metadata_part$study_condition !="control")] <- "disease"

label(metadata_part$age_category)       <- "Age category"
label(metadata_part$gender)       <- "Gender"
label(metadata_part$non_westernized)     <- "Non westernized"
label(metadata_part$body_site) <- "Body site"
label(metadata_part$sequencing_platform) <- "Sequencing platform"

table1(~ age_category + gender + non_westernized + body_site + sequencing_platform | study_condition, data=metadata_part)