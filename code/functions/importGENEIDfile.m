function HCPlistGenesentrezID = importGENEIDfile(filename, dataLines)
%IMPORTFILE Import data from a text file
%  HCPLISTGENESENTREZID = IMPORTFILE(FILENAME) reads data from text file
%  FILENAME for the default selection.  Returns the data as a table.
%
%  HCPLISTGENESENTREZID = IMPORTFILE(FILE, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  HCPlistGenesentrezID = importfile("/Users/aurinaa/Google_drive/Genetics_connectome/HumanHubs_figures/data/reeqtls/HCP_listGenes_entrezID.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 18-May-2020 12:19:15

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
opts.VariableNames = ["initial_alias", "converted_alias", "name", "description", "namespace"];
opts.VariableTypes = ["double", "double", "string", "string", "categorical"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["name", "description"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["name", "description", "namespace"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "initial_alias", "TrimNonNumeric", true);
opts = setvaropts(opts, "initial_alias", "ThousandsSeparator", ",");

% Import the data
HCPlistGenesentrezID = readtable(filename, opts);

end