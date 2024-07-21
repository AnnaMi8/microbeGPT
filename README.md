# microbeGPT
This repository contains data and scripts used to develope microbeGPT project.
microbeGPT is an integrated pipeline that combines a SQL microbiome database with natural language processing capabilities. This project focuses on creating a microbiome reference database that consolidates data from sources like ChocoPhlan, MetaCyc, and CuratedMetagenomicsData. 
A natural language querying system is implemented using the GPT-4 API to generate SQL statements, enabling users to easily formulate and
execute complex queries without extensive technical expertise. microbeGPT is evaluated using benchmark questions about microbiome composition and function, testing various prompt engineering strategies and database optimizations to improve performance.

<ul>
    <li>Chocophlan database to create chocophlan SQL relation can be downloaded following the procedure indicated by: HUMAnN 3.0; The HuttenhowerLab. <a href="http://huttenhower.sph.harvard.edu/humann">http://huttenhower.sph.harvard.edu/humann</a>.</li>
    <li><code>metacyc_reactions_level4ec_only.uniref</code> and <code>CuratedAbundance.txt</code> input files can be found in Zenodo <a href="https://zenodo.org/records/12787794">https://zenodo.org/records/12787794</a>, due to file dimension.</li>
    <li>The remaining four input data files used in this work are all available in this repo <code>./create_SQL_databases/input_files/</code>.</li>
</ul>
<br>
Part of the data used in this work to build the reference microbiome databases is taken from databases that come with HUMAnN 3.0 pipeline, part of bioBakery 3 platform [1]. <br>
Tables containing InterPro domains and EC numbers 'ip2ec' and 'ip2mc' have been created from the correspondent input files reported while data was retrieved from Uniprot database[2].<br>
Metagenomic data was taken from CuratedMetagenomicData R package [3].<br>
<br>
References:<br>
[1]: http://dx.doi.org/10.7554/eLife.65088<br>
[2]: https://doi.org/10.1093/nar/gkac1052<br>
[3]:https://bioconductor.org/packages/release/data/experiment/vignettes/curatedMetagenomicData/inst/doc/curatedMetagenomicData.html </p>

