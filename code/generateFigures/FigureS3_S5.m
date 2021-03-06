%--------------------------------------------------%
% Figure S2-S5: Heritability
%--------------------------------------------------%
function FigureS3_S5()

parcellation = 'HCP';
weight = 'FA';
op = selectCONmetrics(parcellation, weight);

plotOptions.colIn = [1 1 1];
plotOptions.colorOut = [82 82 82]/255; %[0,69,41]/255; %[.35 .35 .35]; %[4 90 141]/255; %[.45 .45 .45]; %[5 113 176]/255;
plotOptions.whatDistribution = 'histogram';

% S3 a - make a plot for ACTE model for all edges
[~, ~, ~, ~, data_export_ACTE] = S3_compareHeritability('HCP',op.tract,'Afactor', weight,op.densThreshold,op.cvMeasure, plotOptions, true);
ylim([0.2 0.6])
ylabel({'Mean h^2'})

figureName = sprintf('makeFigures/Afactorcurves_ACTEonly_%s_%d.png', 'HCP', 0.2);
print(gcf,figureName,'-dpng','-r600');

% save data
writetable(data_export_ACTE,'data_export/source_data.xlsx','Sheet','Supplementary Figure3b','WriteVariableNames',true);


% S3 b,c - heritability for SC weight
whatFactors = {'Afactor', 'Efactor'};
weightSC = 'standard';

for k=1:length(whatFactors)
    
    [heritMatrixSC, nodeData, groupAdjlog, mask, data_export] = S3_compareHeritability('HCP',op.tract,whatFactors{k}, weightSC, op.densThreshold,op.cvMeasure, plotOptions, false);
    
    switch whatFactors{k}
        case 'Efactor'
            ylim([0.6 1])
            ylabel({'Mean e^2'})
            
        case 'Afactor'
            ylim([0 0.4])
            ylabel({'Mean h^2'})
    end
    
    figureName = sprintf('makeFigures/%s_curves_%s_%s_%d.png', whatFactors{k}, weightSC, parcellation, round(op.densThreshold*100));
    print(gcf,figureName,'-dpng','-r600');
    
    % save data export to excel
    switch whatFactors{k}
        case 'Efactor'
            writetable(data_export,'data_export/source_data.xlsx','Sheet','Supplementary Figure3d','WriteVariableNames',true);
        case 'Afactor'
            writetable(data_export,'data_export/source_data.xlsx','Sheet','Supplementary Figure3c','WriteVariableNames',true);
    end
    
    
end

degree = nodeData';
region = (1:360)';  
node_degree = table(region,degree); 
writetable(node_degree,'data_export/source_data.xlsx','Sheet','Supplementary Figure3a','WriteVariableNames',true);


% S5 - heritability in distance ranges
% get heritability for best-fitting models
[heritMatrix, nodeData, groupAdjlog, mask] = S3_compareHeritability(parcellation,op.tract,'Afactor',weight,op.densThreshold,op.cvMeasure, plotOptions, false);
ylim([0.3 0.7]); 
numThr = 4;
distMatr = giveConnDistance(parcellation, op.tract, groupAdjlog);


% bin data into distance bins
heritMatrixHalf = maskuHalf(heritMatrix);
heritMatrixHalf(groupAdjlog==0) = NaN;
distMatr = maskuHalf(distMatr);

% plot heritability for different distance bins as violin plots
[RvsF, FvsP, dataCell,~,f0] = plot_distanceViolin(heritMatrixHalf, distMatr, groupAdjlog, nodeData, op.khub, numThr, 'Heritability');
figureName = sprintf('makeFigures/heritability_distributions_distance_%s.png', parcellation);
print(f0,figureName,'-dpng','-r600');

% export distance values
% save data for each subplot separately
names_fields = {'rich', 'feeder', 'peripheral'}; 
cell_ranges = {'A:C', 'D:F', 'G:I'};
for rr=1:length(dataCell)
    
    S_exp = export_violins(dataCell{rr});
    S_export = array2table(S_exp,'VariableNames',names_fields);
    writetable(S_export,'data_export/source_data.xlsx','Sheet','Supplementary Figure5a-c','Range',cell_ranges{rr},'WriteVariableNames',true);
    
end

[RvsF_subj, FvsP_subj, dataCell] = compare_numberExcludedSubjects('BOTH'); 
figureName = sprintf('makeFigures/Heritability_NRexcluded_subjects_%s.png', parcellation);
print(gcf,figureName,'-dpng','-r300');

% export to excell
for rr=1:length(dataCell)
    
    S_exp = export_violins(dataCell{rr});
    S_export = array2table(S_exp,'VariableNames',names_fields);
    
    writetable(S_export,'data_export/source_data.xlsx','Sheet','Supplementary Figure5d-f','Range',cell_ranges{rr},'WriteVariableNames',true);
    
end
    

[RvsF_variance, FvsP_variance, dataCell] = compare_numberExcludedSubjects('VARrem'); 
figureName = sprintf('makeFigures/Heritability_Variance_%s.png', parcellation);
print(gcf,figureName,'-dpng','-r300');

% export to excell
for rr=1:length(dataCell)
    
    S_exp = export_violins(dataCell{rr});
    S_export = array2table(S_exp,'VariableNames',names_fields);
    writetable(S_export,'data_export/source_data.xlsx','Sheet','Supplementary Figure5g-i','Range',cell_ranges{rr},'WriteVariableNames',true);
    
end

% plot R/F/P curves without excluding outlies for heritability calculation
[~, nodeData_out, data_export] = S3_compareHeritability_withOutliers('HCP',op.tract,'Afactor', weight,op.densThreshold,op.cvMeasure, plotOptions);
ylim([0 0.7])
ylabel({'Mean h^2'})
figureName = sprintf('makeFigures/Heritability_WITHoutliers_%s.png', parcellation);
print(gcf,figureName,'-dpng','-r300');

% export to excell
writetable(data_export,'data_export/source_data.xlsx','Sheet','Supplementary Figure5k','WriteVariableNames',true);
degree = nodeData_out';
region = (1:360)';  
node_degree = table(region,degree); 
writetable(node_degree,'data_export/source_data.xlsx','Sheet','Supplementary Figure5j','WriteVariableNames',true);


% S4 - heritability for different parcellations and densities;
parcs = {'HCP','random500'};
tractography = 'iFOD2';
conWeight = 'FA';
densThresholds = [0.15, 0.2, 0.25; % for HCP parcellation
    0.05 0.1, 0.15]; % for random 500 parcellation
khubs = [90, 105, 120; % for HCP parcellation
    35, 70, 100]; % for random 500 parcellation
yVals = [[0.3, 0.7]; [0.3 0.7]];
cvMeasure = 'strength';
label_name = {'a', 'b', 'c', 'd', 'e', 'f'}; 
qq=1; 
for pa=1:length(parcs)
    parc = parcs{pa};
    yVal = yVals(pa,:);
    
    for de=1:size(densThresholds,2)
        densThreshold = densThresholds(pa,de);
        khub = khubs(pa,de);
        
        [heritMatrix, nodeData, groupAdjlog, mask, data_exp_parc] = S3_compareHeritability(parc,tractography,'Afactor', conWeight,densThreshold,cvMeasure, plotOptions);
        
        figureName = sprintf('makeFigures/Afactor_curves_%s_%d.png', parc, densThreshold);
        ylim(yVal)
        ylabel({'Mean h^2'})
        
        % save to excell
        sheet_name = sprintf('Supplementary Figure4%s', label_name{qq}); 
        writetable(data_exp_parc,'data_export/source_data.xlsx','Sheet',sheet_name,'WriteVariableNames',true);
        
        degree = nodeData';
        region = (1:length(nodeData))';
        node_degree = table(region,degree);
        writetable(node_degree,'data_export/source_data.xlsx','Sheet',sheet_name,'Range','G:H','WriteVariableNames',true);


        print(gcf,figureName,'-dpng','-r600');
        qq=qq+1; 

    end



end
end






