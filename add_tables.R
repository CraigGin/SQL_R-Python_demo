# Get CRC data set from curatedMetagenomicData, create data frames
# with species abundances, meta data, and taxonomy, and add them 
# as tables to the database gutMB.

# Set username and password for MySQL server:
username <- 'crgin'
password <- 'insecure'

# Install necessary packages
if(!require(curatedMetagenomicData, quietly = TRUE)){
  if(!require(BiocManager, quietly = TRUE)){
    install.packages("BiocManager")
  }
  library('BiocManager')
  BiocManager::install("curatedMetagenomicData")
}

if(!require(dplyr, quietly = TRUE)){
  install.packages('dplyr')
}

if(!require(RMySQL, quietly = TRUE)){
  install.packages('RMySQL')
}

if(!require(tibble, quietly = TRUE)){
  install.packages('tibble')
}

# Load packages
library("dplyr")
library("RMySQL")
library("curatedMetagenomicData")
library("tibble")

# Download data from FengQ_2015 from the curatedMetagenomicData package
ra.list <- curatedMetagenomicData('FengQ_2015.relative_abundance',
                                  dryrun=FALSE)
TSE <- ra.list[[1]]    
meta.data <- as.data.frame(colData(TSE))  
taxa.abun <- as.data.frame(t(assay(TSE)))

# Convert abundances to proportions and transpose data
taxa.abun <- as.data.frame(t(apply(taxa.abun, MARGIN=1, function(x) x/sum(x))))

# Create taxonomy table from column names of taxa.abun
sep_tax <- strsplit(colnames(taxa.abun), split="\\|")
tax.table <- do.call(rbind.data.frame, sep_tax)
colnames(tax.table) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
tax.table[] <- lapply(tax.table, substring, first=4)

# Format data frames
colnames(taxa.abun) <- tax.table$Species
meta.data <- rownames_to_column(meta.data, var="sample_id")
taxa.abun <- rownames_to_column(taxa.abun, var="sample_id")

# Connect to MySQL database
gutMB <- dbConnect(MySQL(), 
                   dbname='gutMB',
                   username=username,
                   password=password)

# Write tables to database
dbWriteTable(gutMB, "abundance_table", taxa.abun, overwrite=TRUE, row.names=FALSE)
dbWriteTable(gutMB, "meta_data", meta.data, overwrite=TRUE, row.names=FALSE)
dbWriteTable(gutMB, "tax_table", tax.table, overwrite=TRUE, row.names=FALSE)

dbGetQuery(gutMB, "ALTER TABLE abundance_table
                   MODIFY COLUMN sample_id VARCHAR(10)")
dbGetQuery(gutMB, "ALTER TABLE abundance_table
                   ADD PRIMARY KEY (sample_id)")

dbGetQuery(gutMB, "ALTER TABLE meta_data
                   MODIFY COLUMN sample_id VARCHAR(10)")
dbGetQuery(gutMB, "ALTER TABLE meta_data
                   ADD PRIMARY KEY (sample_id)")

# Disconnect
dbDisconnect(gutMB)

