% ---------------------------------------------------------------------
% Find if genes that are outliers in non-cell specific list are
% ---------------------------------------------------------------------
function pORA = eQTL_ORA(eQTLgenes, M)
% test if disease-related genes are over-represented in the list of eQTL
% mapped genes
lists = {'scz', 'adhd', 'aut', 'bip', 'mdd', 'iq'};
% options specific for GWAS-based lists
brainParts = {'Cortex'}; %, 'Frontal_Cortex_BA9', 'Anterior_cingulate_cortex_BA24'};
numTissues = length(brainParts);

for l=1:length(lists)
    whatGeneSet = lists{l};
    results = selectGWASgenes_eQTL(whatGeneSet, brainParts, numTissues, 'oneList', 1);
        if sum(strcmp(fieldnames(results), whatGeneSet)) == 1
            selectedGenes = results.(whatGeneSet);
        end

    if ~isempty(results.(whatGeneSet))
        % X - number of genes that need to exceed
        % what is the actual number of genes from a list among outliers
        empOverlap = intersect(eQTLgenes, selectedGenes);
        X = 0:length(empOverlap);
        % M - total population size (all genes that were considered)
        % M = 15626;
        % K - number of items with a desired characteristic (number of genes in a
        % specific list)
        K = length(selectedGenes);
        % N - number of genes selected (number of genes in eQTL list)
        N = length(eQTLgenes);
        
        Y = hygepdf(X,M,K,N);
        pORA.(whatGeneSet).p = 1-sum(Y);
        pORA.(whatGeneSet).Noverlap = length(empOverlap); 
        pORA.(whatGeneSet).Ndisorder = length(selectedGenes); 
        pORA.(whatGeneSet).Genes = empOverlap; 
    end
    clearvars selectedGenes
end
end
