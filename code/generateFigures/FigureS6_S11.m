%--------------------------------------------------%
% Figure S6-S11: CGE and MPC
%--------------------------------------------------%
function FigureS6_S11()

whatDWI = 'HCP';
weight = 'standard'; %for GenCog'standard';
parc = 'HCP';
op = selectCONmetrics(parc, weight);
numThr = 4;

plotOptions.colIn = [1 1 1];
plotOptions.colorOut = [82 82 82]/255; %[0,69,41]/255; %[.35 .35 .35]; %[4 90 141]/255; %[.45 .45 .45]; %[5 113 176]/255;
plotOptions.whatDistribution = 'histogram';

[coexpData, A, matrices, coordinates, avWeight] = giveConnExp_HCP(parc,op.tract,op.probe,weight,op.brainPart,op.nRem);
[~, ~, M, ~, avWeightFA] = giveConnExp_HCP(parc,op.tract,op.probe,'FA',op.brainPart, 0);

numLC = size(coexpData.averageCoexpression,1);

GrSC = giveMeRichClub(matrices, coordinates, op.groupConn ,op.densThreshold, false, op.cvMeasure, op.consThr);
GrFA = avWeightFA.*logical(GrSC);
groupAdjlog = logical(GrSC);
nodeData = degrees_und(groupAdjlog);

% Define distance based on the distance between regions on the surface - it's more relevant for CGE then connection distance based on the tract length.
distMatr = coexpData.averageDistance;
% select left hemisphere data for connectivity matrix, degree distribution
groupAdjlog = groupAdjlog(1:numLC, 1:numLC);
nodeData = nodeData(1:numLC);

% use exponential fit to correct for distance effect
% Figure S6 and 8 A-C
CGEmatrix_uncorrected = corr(coexpData.parcelExpression(:,2:end)');
[CGEmatrix, FitCurve, c, data_exp] = measure_correctDistance(CGEmatrix_uncorrected, coexpData.averageDistance, 'Correlated gene expression');
CGEmatrix(groupAdjlog==0) = NaN;

writetable(data_exp,'data_export/source_data.xlsx','Sheet','Supplementary Figure6ab','WriteVariableNames',true);

% plot CGE for different distance bins as violin plots
[RvsF, FvsP, dataCell, xThresholds] = plot_distanceViolin(CGEmatrix , distMatr, groupAdjlog, nodeData, op.khub, numThr, 'CGE');
figureName = sprintf('makeFigures/CGEdist_%s_%d.png', parc, round(op.densThreshold*100));
print(gcf,figureName,'-dpng','-r600');

% export to excell
names_fields = {'rich', 'feeder', 'peripheral'}; 
cell_ranges = {'A:C', 'D:F', 'G:I'};

for rr=1:length(dataCell)
    
    S_exp = export_violins(dataCell{rr});
    S_export = array2table(S_exp,'VariableNames',names_fields);
    writetable(S_export,'data_export/source_data.xlsx','Sheet','Supplementary Figure8a-c','Range',cell_ranges{rr},'WriteVariableNames',true);
    
end

% get p-values comparing rich to peripheral links
for k=1:length(dataCell)
    [~, pRP(k),~,statsRP(k)] = ttest2(dataCell{1,k}{1,1},dataCell{1,k}{3,1}, 'Vartype','unequal', 'Tail', 'right');
    tRP(k) = statsRP.tstat;
end

% Figure S11
% for each of cell-specific gene groups, make R/F/P curves.
[cellGenesUNIQUE,cellGroups] = getCellSpecificGenes('all_gene_data.csv');
nG = length(cellGroups); 

% for each cell-specific list of genes find ones in the expression data
listGenes = getCellExpression(cellGenesUNIQUE,cellGroups,coexpData); 

label_name_cell = {'a', 'b', 'c', 'd', 'e', 'f', 'g'};

for g=1:length(cellGroups)
    % extract expression measures for each gene group
    groupExp = listGenes{g,3};
    groupCGE = corr(groupExp');
    % correct CGE for distance effects using the "fitCurve" based on all genes
    groupCGE_DC = groupCGE-FitCurve;
    
    % plot curves
    [~,data_export_cell] = RichClubHuman(groupAdjlog,groupCGE_DC, nodeData, 'right', plotOptions.whatDistribution, plotOptions.colorOut, plotOptions.colIn);
    ylabel({'Mean spatially-corrected', 'correlated gene expression'})
    set(gcf, 'Position', [500 500 750 550])
    set(gca,'fontsize', 18);
    ylim([-0.05 0.18])
    
    % save to excell
    sheet_name = sprintf('Supplementary Figure11%s', label_name_cell{g});
    writetable(data_export_cell,'data_export/source_data.xlsx','Sheet',sheet_name,'WriteVariableNames',true);
    
    degree = nodeData';
    region = (1:length(nodeData))';
    node_degree = table(region,degree);
    writetable(node_degree,'data_export/source_data.xlsx','Sheet',sheet_name,'Range','G:H','WriteVariableNames',true);
    
    % remove "-" from group name for saving the figure;
    groupName = listGenes{g,1};
    isD = contains(groupName,'-');
    
    if isD
        groupName = erase(groupName,'-');
    end
    
    figureName = sprintf('makeFigures/CGEcurves_%sgenes_%s_%d.png', listGenes{g,1}, parc, round(op.densThreshold*100));
    print(gcf,figureName,'-dpng','-r600');
end


% Figure S7 and S8D-F
parcs = {'HCP','random500'};
tract = 'iFOD2';

densThresholds = [0.15, 0.2, 0.25; ... % for HCP parcellation
    0.05 0.1, 0.15]; % for custom 500 parcellation

khubs = [90, 105, 120; ...% for HCP parcellation
    35, 70, 100]; % for custom 500 parcellation

label_name = {'a', 'b', 'c', 'd', 'e', 'f'};
qq=1;
for pa=1:length(parcs)
    parc = parcs{pa};
    
    [coexpData, ~, matrices, coordinates] = giveConnExp_HCP(parc,op.tract,op.probe,weight,op.brainPart,op.nRem);
    
    
    for de=1:size(densThresholds,2)
        densThreshold = densThresholds(pa,de);
        khub = khubs(pa,de);
        numLC = size(coexpData.averageCoexpression,1);
        
        GrSC = giveMeRichClub(matrices, coordinates, op.groupConn ,densThreshold, false, op.cvMeasure, op.consThr);
        groupAdjlog = logical(GrSC);
        nodeData = degrees_und(groupAdjlog);
        
        
        % load data containing connection distance
        distMatr = giveConnDistance(parc, tract, groupAdjlog);
        distMatr = maskuHalf(distMatr);
        % select left hemisphere data for connectivity matrix, degree distribution and distance matrix
        distMatr = distMatr(1:numLC, 1:numLC);
        groupAdjlog = groupAdjlog(1:numLC, 1:numLC);
        nodeData = nodeData(1:numLC);
        
        % use exponential fit to correct for distance effect
        CGEmatrix_uncorrected = corr(coexpData.parcelExpression(:,2:end)');
        [CGEmatrix, FitCurve] = measure_correctDistance(CGEmatrix_uncorrected, coexpData.averageDistance, 'CGE', 'exp', false);
        CGEmatrix(groupAdjlog==0) = NaN;
        
        % plot R/F/P lines for CGE
        whatTail = 'right';
        [~, data_exp_parc] = RichClubHuman(groupAdjlog,CGEmatrix, nodeData, whatTail, plotOptions.whatDistribution, plotOptions.colorOut, plotOptions.colIn);
        ylabel({'Mean spatially-corrected', 'correlated gene expression'})
        set(gcf, 'Position', [500 500 750 550])
        set(gca,'fontsize', 18);
        ylim([-0.05 0.18])
        
        sheet_name = sprintf('Supplementary Figure7%s', label_name{qq});
        writetable(data_exp_parc,'data_export/source_data.xlsx','Sheet',sheet_name,'WriteVariableNames',true);
        
        degree = nodeData';
        region = (1:length(nodeData))';
        node_degree = table(region,degree);
        writetable(node_degree,'data_export/source_data.xlsx','Sheet',sheet_name,'Range','G:H','WriteVariableNames',true);
        
        qq=qq+1;
        
        figureName = sprintf('makeFigures/CGEcurves_%s_%d.png', parc, densThreshold);
        print(gcf,figureName,'-dpng','-r600');
        
        if strcmp(parc, 'random500') || densThreshold==0.1
            % plot for different distance bins as violin plots
            [RvsF, FvsP, dataCell,~,f0] = plot_distanceViolin(CGEmatrix, coexpData.averageDistance, groupAdjlog, nodeData, khubs(pa,de), numThr, 'CGE');
            figureName = sprintf('makeFigures/CGE_distributions_distance_%s_%d.png', parc, densThreshold);
            print(f0,figureName,'-dpng','-r600');
            
            for rr=1:length(dataCell)
                
                S_exp = export_violins(dataCell{rr});
                S_export = array2table(S_exp,'VariableNames',names_fields);
                writetable(S_export,'data_export/source_data.xlsx','Sheet','Supplementary Figure8d-f','Range',cell_ranges{rr},'WriteVariableNames',true);
                
            end
            
        end
        
    end
end


% Figure S9A
% make RFP plot using Monash dataset connectome
[coexpData, A, matrices, coordinates, avWeight, sub_monash] = giveConnExp_GenCog('HCP',op.tract,op.probe,op.conW,op.brainPart,op.nRem);
GrSC_GC = giveMeRichClub(matrices, coordinates, op.groupConn, op.densThreshold, false, op.cvMeasure, op.consThr);

CGEmatrix_uncorrected = corr(coexpData.parcelExpression(:,2:end)');
numLC = size(coexpData.averageCoexpression,1);

groupAdjlogGC = logical(GrSC_GC);
nodeDataGC = degrees_und(groupAdjlogGC);

groupAdjlogGC = groupAdjlogGC(1:numLC, 1:numLC);
nodeDataGC = nodeDataGC(1:numLC);

[CGEmatrixGC, FitCurve] = measure_correctDistance(CGEmatrix_uncorrected, coexpData.averageDistance, 'CGE', 'exp', false);
CGEmatrixGC(groupAdjlogGC==0) = NaN;

whatTail = 'right';
[~, data_export_monash] = RichClubHuman(groupAdjlogGC,CGEmatrixGC, nodeDataGC, whatTail, plotOptions.whatDistribution, plotOptions.colorOut, plotOptions.colIn);
ylabel({'Mean spatially-corrected', 'correlated gene expression'})
set(gcf, 'Position', [500 500 750 550])
set(gca,'fontsize', 18);
ylim([-0.05 0.1])

figureName = sprintf('makeFigures/CGEcurves_%s_%d_%s.png', parc, densThreshold, whatDWI);
print(gcf,figureName,'-dpng','-r600');
% export to excell

writetable(data_export_monash,'data_export/source_data.xlsx','Sheet','Supplementary Figure9a','WriteVariableNames',true);

degree = nodeDataGC';
region = (1:length(nodeDataGC))';
node_degree = table(region,degree);
writetable(node_degree,'data_export/source_data.xlsx','Sheet','Supplementary Figure9a','Range','G:H','WriteVariableNames',true);

% Figure S9B - MPC as a function of degree random500 parcellation
FigureS9(); 

% Figure S10
% make CGE plots for Celegans and mouse
load('data/wormANDmouse/CElegansConnectivityData.mat')
load('data/wormANDmouse/CelegansGeneDataWS256CertainEmptyEnrichedPartial.mat')
plotOptions.whatDistribution = 'barCount'; %'histogram'; 

Adj_worm = C.Adj_B{1,3}; 
CGE_worm = G.Corr.Pearson_noLR; 
[~,~,nodeData_worm] = degrees_dir(Adj_worm); 

[~, export_worm] = RichClubCelegans(Adj_worm,CGE_worm, nodeData_worm, 'right', plotOptions.whatDistribution, plotOptions.colorOut, plotOptions.colIn); 
ylim([0 0.5])

writetable(export_worm,'data_export/source_data.xlsx','Sheet','Supplementary Figure10a','WriteVariableNames',true);

degree = nodeData_worm';
region = (1:length(nodeData_worm))';
node_degree = table(region,degree);
writetable(node_degree,'data_export/source_data.xlsx','Sheet','Supplementary Figure10a','Range','G:H','WriteVariableNames',true);


figureName = sprintf('makeFigures/CGEcurves_Celegans.png');
print(gcf,figureName,'-dpng','-r600');

% plot for mouse
load('data/wormANDmouse/mouseData.mat')
Adj_mouse = allAdj; 
CGE_mouse = allLinkData; 

[~,~,nodeData_mouse] = degrees_dir(Adj_mouse); 
[~, export_mouse] = RichClubMouse(Adj_mouse,CGE_mouse, nodeData_mouse, 'right', plotOptions.whatDistribution, plotOptions.colorOut, plotOptions.colIn); 
ylim([0 0.25])

figureName = sprintf('makeFigures/CGEcurves_mouse.png');
print(gcf,figureName,'-dpng','-r600');

% export to excell

writetable(export_mouse,'data_export/source_data.xlsx','Sheet','Supplementary Figure10b','WriteVariableNames',true);

degree = nodeData_mouse';
region = (1:length(nodeData_mouse))';
node_degree = table(region,degree);
writetable(node_degree,'data_export/source_data.xlsx','Sheet','Supplementary Figure10b','Range','G:H','WriteVariableNames',true);


end
