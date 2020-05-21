function heritabilityonlyACTEnoOUTLIERSwSATpValsallEdgestwinEdgesHCPiFOD = importHeritabilityResultACTEonly(filename, dataLines)
%IMPORTFILE Import data from a text file
%  HERITABILITYONLYACTENOOUTLIERSWSATPVALSALLEDGESTWINEDGESHCPIFOD =
%  IMPORTFILE(FILENAME) reads data from text file FILENAME for the
%  default selection.  Returns the data as a table.
%
%  HERITABILITYONLYACTENOOUTLIERSWSATPVALSALLEDGESTWINEDGESHCPIFOD =
%  IMPORTFILE(FILE, DATALINES) reads data for the specified row
%  interval(s) of text file FILENAME. Specify DATALINES as a positive
%  scalar integer or a N-by-2 array of positive scalar integers for
%  dis-contiguous row intervals.
%
%  Example:
%  heritabilityonlyACTEnoOUTLIERSwSATpValsallEdgestwinEdgesHCPiFOD = importfile("/Users/aurinaa/Google_drive/Genetics_connectome/HumanHubs_figures/data/heritability/heritability_onlyACTEnoOUTLIERS_wSATpVals_allEdges_twinEdges_HCP_iFOD2_FA_strength20.mat.txt", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 25-Feb-2020 09:42:17

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["heritabilityA", "heritabilityC", "heritabilityT", "heritabilityE", "heritabilitySp"];
opts.VariableTypes = ["double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
heritabilityonlyACTEnoOUTLIERSwSATpValsallEdgestwinEdgesHCPiFOD = readtable(filename, opts);

end