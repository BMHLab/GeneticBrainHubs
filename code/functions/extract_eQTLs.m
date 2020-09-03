function [pORA_eQTL, genes_ENTREZ] = extract_eQTLs(whatDATA, whatSET)

if nargin <1
    whatDATA = 'HCP'; 
end
if nargin <2
    whatSET = 'POS'; 
end

% 1. SNP-gene mapping based on the annotation file
fileClumped = sprintf('%s_list_clumpedSNPs_p1_01_p2_05_withRS_FINAL.txt', whatDATA); 
SNPIDs = readtable(fileClumped, 'ReadVariableNames',false); 

% load relevant SNP file
targetSNP = readtable(sprintf('%s_SNPs%s_RvsP_beta_10perc_clumped.txt', whatDATA, whatSET)); 
% get their rs IDs
[~, IND] = intersect(SNPIDs.Var2, targetSNP.SNPs);
targetSNPrs = SNPIDs.Var1(IND); 

% find genes based on annotation from PSYCHencode
genes = importpec_genes('pec_genes.annot_FINAL.txt'); 
genesONLY = importpec_genesONLY('pec_genes.annot_FINAL.txt'); 

GIND = cell(size(targetSNPrs,1),1); 
for i=1:size(targetSNPrs)
    
    % add spaces around rsID
    c = strcat({' '},targetSNPrs{i}, {' '}); 
    GIND{i} = find(contains(genes, c{:})); 
    
end

% get all genes together
G = unique(vertcat(GIND{:}));
genesSEL = genesONLY(G); 

% take the overlap with DER-08a_hg19_eQTL.significant.txt
Gsig = readtable('DER-08a_hg19_eQTL.significant.txt'); 
Gsig_names = unique(extractBefore(Gsig.gene_id,'.')); 
genesSIG = intersect(genesSEL, Gsig_names); 

% find their entrezIDs: read in BIOMART
BIOMART = readtable('BIOMART_geneIDs.txt'); 
[~, IND_BIO] = intersect(BIOMART.ensembl_gene_id, genesSIG); 
genes_ENTREZ = BIOMART.entrezgene_id(IND_BIO); 
genes_ENTREZ(contains(genes_ENTREZ, 'NA')) = [];
genes_ENTREZ = str2double(genes_ENTREZ); 

% test ORA
whatAnnotation = 'PSYCHENCODE'; 
N = 25699; % total number of genes considered in eQTL mapping.
pORA_eQTL = eQTL_ORA(genes_ENTREZ, N, whatAnnotation); 

end


% maybe finding some brain-related genes that are comming up at random. 



% 2. extract only genes with valid entrezIDs using BIOMART data and save
% the output
% 3. 

