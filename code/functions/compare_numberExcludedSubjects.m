function [RvsF, FvsP] = compare_numberExcludedSubjects(plotWhat)

if nargin < 1
    plotWhat = 'BOTH';
end

parcellation = 'HCP';
weight = 'FA';
op = selectCONmetrics(parcellation, weight);
numThr = 4;

% load connectivity data
load('twinEdges_HCP_iFOD2_FA_strength20.mat')
V = readtable('subjectsRemoved_allEdges_twinEdges_HCP_iFOD2_FA_strength20.mat.txt');
H = readtable('heritabilityACTEnoOUTLIERSnew_wSATpVals_allEdges_twinEdges_HCP_iFOD2_FA_strength20.mat-1.txt'); 

nodeData = degrees_und(groupAdjlog);
numNodes = size(groupAdjlog,1);
% reshape heritability vector into the matrix for connected edges get indexes on diagonal
valMatrix = zeros(numNodes, numNodes);

% mask upper half to get indexes of existing links
C = maskuHalf(groupAdjlog);

switch plotWhat
    case 'DZ'
        valMatrix(C==1) = V.heritabilitySubRemDZ;
        selMeasure = V.heritabilitySubRemDZ;
    case 'MZ'
        valMatrix(C==1) = V.heritabilitySubRemMZ;
        selMeasure = V.heritabilitySubRemMZ; 
    case 'BOTH'
        valMatrix(C==1) = V.heritabilitySubRemMZ+V.heritabilitySubRemDZ;
        selMeasure = V.heritabilitySubRemMZ+V.heritabilitySubRemDZ;
    case 'VARrem'
        valMatrix(C==1) = V.edgeVarREM;
        selMeasure = V.edgeVarREM;
    case 'VARorig'
        valMatrix(C==1) = V.edgeVarORIG;
        selMeasure = V.edgeVarORIG;
end

valMatrix = valMatrix+valMatrix';

plotOptions.colIn = [1 1 1];
plotOptions.colorOut = [82 82 82]/255; %[0,69,41]/255; %[.35 .35 .35]; %[4 90 141]/255; %[.45 .45 .45]; %[5 113 176]/255;
plotOptions.whatDistribution = 'histogram';

RichClubHuman(groupAdjlog,valMatrix,nodeData,'left',...
    plotOptions.whatDistribution, plotOptions.colorOut, plotOptions.colIn);

ylabel('Mean number of excluded subjects')
set(gcf, 'Position', [500 500 750 550])
set(gca,'fontsize', 20);

if strcmp(plotWhat, 'VARrem')
    L = {'Mean edge variance', '(outliers excluded)'}; 
    ylabel(L)
    ylim([0.0001 0.002])
elseif strcmp(plotWhat, 'VARorig')
    L = {'Mean edge variance', '(outliers included)'}; 
    ylabel(L)
    ylim([0.0001 0.01])
else
    L = 'Mean number of excluded subjects'; 
    ylabel(L)
    ylim([0 25])
end

% plot scatter between heritability and a selected measure; 
[r,p] = corr(selMeasure, H.heritabilityA); 
figure('color','w')
scatter(selMeasure, H.heritabilityA, 30, ...
    'MarkerEdgeColor', [.25 .25 .25], 'MarkerFaceColor', [.28	.75	.57], 'LineWidth', 1.5); 
lsline
xlabel(L); ylabel('Heritability'); 
ylim([0 1])
title(sprintf('r=%.3f, p=%d', r,p))

heritMatrixHalf = zeros(numNodes, numNodes);
heritMatrixHalf(C==1) = H.heritabilityA; 
heritMatrixHalf = heritMatrixHalf+heritMatrixHalf';
heritMatrixHalf = maskuHalf(heritMatrixHalf);

[RvsF, FvsP, dataCell,~,f0] = plot_distanceViolin(heritMatrixHalf, valMatrix, groupAdjlog, nodeData, op.khub, numThr, 'Heritability');


end
