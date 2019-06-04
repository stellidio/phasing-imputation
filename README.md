# phasing-imputation
Phasing-Imputation process_(vcf-to-vcf)

# Description
phase_impute_example.sh describes a process that applies phasing and imputation to a vcf file. 
Input: a vcf file containing genomic data of multiple samples from different chromosomes.
Output: vcf files. One for each sample for each chomosome position. 
Haplotype Refeence Panel used: 1000GP_Phase3

# Prerequisites

# Install vcftools
wget -O "vcftools_0.1.13.tar.gz"  "https://downloads.sourceforge.net/project/vcftools/vcftools_0.1.13.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fvcftools%2Ffiles%2Fvcftools_0.1.13.tar.gz%2Fdownload&ts=1550155694"
tar zxvf vcftools_0.1.13.tar.gz

# Install ShapeIT
wget https://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.v2.r904.glibcv2.17.linux.tar.gz
tar zxvf shapeit.v2.r904.glibcv2.17.linux.tar.gz

# Install Impute2
wget https://mathgen.stats.ox.ac.uk/impute/impute_v2.3.2_x86_64_static.tgz
tar zxvf impute_v2.3.2_x86_64_static.tgz

# Download Reference Data
wget https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.tgz 
tar zxvf 1000GP_Phase3.tgz
