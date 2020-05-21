function HCPSNPsPOSRvsPbeta10percclumped = importeQTLinput(filename, startRow, endRow)
%IMPORTFILE1 Import numeric data from a text file as a matrix.
%   HCPSNPSPOSRVSPBETA10PERCCLUMPED = IMPORTFILE1(FILENAME) Reads data from
%   text file FILENAME for the default selection.
%
%   HCPSNPSPOSRVSPBETA10PERCCLUMPED = IMPORTFILE1(FILENAME, STARTROW,
%   ENDROW) Reads data from rows STARTROW through ENDROW of text file
%   FILENAME.
%
% Example:
%   HCPSNPsPOSRvsPbeta10percclumped = importfile1('HCP_SNPsPOS_RvsP_beta_10perc_clumped.txt', 2, 8208);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2019/12/11 11:11:34

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format for each line of text:
%   column1: text (%s)
%	column2: double (%f)
%   column3: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
HCPSNPsPOSRvsPbeta10percclumped = table(dataArray{1:end-1}, 'VariableNames', {'SNPs','tvals','pvals'});

