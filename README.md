# phasing-imputation
Phasing-Imputation process_(vcf-to-vcf)

# Description
Phasing: method for estimation of haplotypes from genotype data
Imputation: method for imputing missing genotypes from genotype data 

phase_impute_example.sh includes a process for applying haplotype phasing and genotype imputation methods to a VCF file containing genotype data from several samples from different chromosomes. The describes process does not apply to chromosomes X and Y. 

User input is a single VCF file containing genotype data from several samples from all the different chromosomes. The output is several VCF files, each one representing one sample and one specific chromosomic region.

Haplotype Reference Panel used: 1000Genomes_Project_Phase3

# Prerequisites
# Install VCFtools

wget -O "vcftools_0.1.13.tar.gz"  "https://downloads.sourceforge.net/project/vcftools/vcftools_0.1.13.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fvcftools%2Ffiles%2Fvcftools_0.1.13.tar.gz%2Fdownload&ts=1550155694"

tar zxvf vcftools_0.1.13.tar.gz

# Install ShapeIT

wget https://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.v2.r904.glibcv2.17.linux.tar.gz

tar zxvf shapeit.v2.r904.glibcv2.17.linux.tar.gz

# Install Impute2

wget https://mathgen.stats.ox.ac.uk/impute/impute_v2.3.2_x86_64_static.tgz

tar zxvf impute_v2.3.2_x86_64_static.tgz

# Install Haplotype Refernce Panel 

wget https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.tgz 

tar zxvf 1000GP_Phase3.tgz
