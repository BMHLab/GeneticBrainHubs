%--------------------------------------------------%
% Figure S1
%--------------------------------------------------%
function FigureS1()

whatDWI = 'HCP';
weight = 'standard';
parcellation = 'HCP';

op = selectCONmetrics(parcellation, weight);

if strcmp(whatDWI, 'HCP')
    
    [coexpData, A, matrices, coordinates, avWeight] = giveConnExp_HCP(parcellation,op.tract,op.probe,weight,op.brainPart,op.nRem);
    [~, ~, M, ~, avWeightFA] = giveConnExp_HCP(parcellation,op.tract,op.probe,'FA',op.brainPart, 0);
    
elseif strcmp(whatDWI, 'GenCog')
    
    [coexpData, A, matrices, coordinates, avWeight] = giveConnExp_GenCog(parcellation,op.tract,op.probe,weight,op.brainPart,op.nRem);
    [~, ~, M, ~, avWeightFA] = giveConnExp_GenCog(parcellation,op.tract,op.probe,'FA',op.brainPart, 0);
    
end

yVals = [0.95 1.35];
yValsFA = [0.95 1.15];
numRepeats = 1000;
numShuffle = 50;
whatDistribution = 'histogram';

% choose colors
colorOut = [82 82 82]/255; % outside of the circles
colorIn = [1 1 1]; % inside of the circles

[GrSC, mDIST] = giveMeRichClub(matrices, coordinates, op.groupConn, op.densThreshold, false, op.cvMeasure, op.consThr, 50, 100 , 'bu', 'randmio_und', yVals);
GrFA = avWeightFA.*logical(GrSC);
GrSClog = log(GrSC);
GrSClog(isinf(GrSClog)) = 0;
nodeDeg = degrees_und(GrSC);

kRange = 1:max(nodeDeg);

% a) topological RC
[~, dMiddle_top, PhiNormMean_top] = PlotRichClub(GrSC,mDIST,'bu','randmio_und', numShuffle, numRepeats, yVals, whatDistribution, colorOut, colorIn);
figureName = sprintf('makeFigures/RCbin_%s_%d.png', parcellation, round(op.densThreshold*100));
print(gcf,figureName,'-dpng','-r300');

% save to excel
RC_bin = table(kRange', PhiNormMean_top', 'VariableNames', {'node_degree', 'RC_bin'}); 
writetable(RC_bin,'data_export/source_data.xlsx','Sheet','Supplementary Figure1a','WriteVariableNames',true);

% b) weighted RC - log(SC) weight, topology fixed, weights randomised
[~, dMiddle_wsc, PhiNormMean_wsc] = PlotRichClub(GrSClog,mDIST,'wu','shuffleWeights', numShuffle, numRepeats, yVals, whatDistribution, colorOut, colorIn);
figureName = sprintf('makeFigures/RCwei_logSC_%s_%d.png', parcellation, round(op.densThreshold*100));
print(gcf,figureName,'-dpng','-r300');

% save to excel
RC_weilog = table(kRange', PhiNormMean_wsc', 'VariableNames', {'node_degree', 'RC_weilog'}); 
writetable(RC_weilog,'data_export/source_data.xlsx','Sheet','Supplementary Figure1b','WriteVariableNames',true);


% c) weighted RC - FA weight, topology fixed, weights randomised
[~, dMiddle_wfa, PhiNormMean_wfa] = PlotRichClub(GrFA,mDIST,'wu','shuffleWeights', numShuffle, numRepeats, yValsFA, whatDistribution, colorOut, colorIn);
figureName = sprintf('makeFigures/RCwei_FA_%s_%d.png', parcellation, round(op.densThreshold*100));
print(gcf,figureName,'-dpng','-r300');

% save to excel
RC_weifa = table(kRange', PhiNormMean_wfa', 'VariableNames', {'node_degree', 'RC_weifa'}); 
writetable(RC_weifa,'data_export/source_data.xlsx','Sheet','Supplementary Figure1c','WriteVariableNames',true);


% d) connection length as a function of degree
[dist_vals, ~, kr_plot] = RichClubHuman_TOPO(GrFA,mDIST,nodeDeg, true, whatDistribution, colorOut, colorIn);
axisName = {'Mean connection', 'distance (mm)'};
ylabel(axisName, 'FontSize', 18)
xlabel('Node degree, k','FontSize', 18);
ylim([50 65])
figureName = sprintf('makeFigures/DIST_%s_%d.png', parcellation, round(op.densThreshold*100));
print(gcf,figureName,'-dpng','-r300');

% save to excel
mean_dist = table(kr_plot', dist_vals, 'VariableNames', {'node_degree', 'distance'}); 
writetable(mean_dist,'data_export/source_data.xlsx','Sheet','Supplementary Figure1d','WriteVariableNames',true);


% e) binary normalised edge communicability as a function of degree
% - null, is randomising topology
ComNormBIN = normCommunicability(GrFA, 'bin', numShuffle, numRepeats, 'randmio_und');
[com_bin, ~, kr_plot] = RichClubHuman_TOPO(GrFA,ComNormBIN,nodeDeg, true, whatDistribution, colorOut, colorIn);
axisName = {'Mean edge','communicability (binary)'};
ylabel(axisName, 'FontSize', 18)
xlabel('Node degree, k','FontSize', 18);
figureName = sprintf('makeFigures/COMMbin_%s_%d.png', parcellation, round(op.densThreshold*100));
print(gcf,figureName,'-dpng','-r300');

% save to excel
com_bin_exp = table(kr_plot', com_bin, 'VariableNames', {'node_degree', 'com_bin'}); 
writetable(com_bin_exp,'data_export/source_data.xlsx','Sheet','Supplementary Figure1e','WriteVariableNames',true);

% f) weighted normalised edge communicability as a function of degree
% - null, is randomising weights while keeping the topology
ComNormWEI = normCommunicability(GrFA, 'wei', numShuffle, numRepeats, 'shuffleWeights');
[com_wei, ~, kr_plot] = RichClubHuman_TOPO(GrFA,ComNormWEI, nodeDeg, true, whatDistribution, colorOut, colorIn);
axisName = {'Mean edge', 'communicability (weighted)'};
ylabel(axisName, 'FontSize', 18)
xlabel('Node degree, k','FontSize', 18);
figureName = sprintf('makeFigures/COMMwei_%s_%d.png', parcellation, round(op.densThreshold*100));
print(gcf,figureName,'-dpng','-r300');

% save to excel
com_wei_exp = table(kr_plot', com_wei, 'VariableNames', {'node_degree', 'com_wei'}); 
writetable(com_wei_exp,'data_export/source_data.xlsx','Sheet','Supplementary Figure1f','WriteVariableNames',true);

end



