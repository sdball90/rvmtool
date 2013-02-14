function [rownum, column_names, table_names, error] = xls2db_v2(file)
%--------------------------------------------------------------------------
% XLS2DB Version 2 takes a XLS spreadsheet and inputs data into sqlite
% database
%
% HISTORY:
% 4 Febuary 2013  Aaron Caldwell    Original code
%
% [ROWNUM,COLUMN_NAMES,ERROR] = XLS2DB_V2(FILE)
%
% INPUT:
%   FILE is a string with the path to the xls file
%
% OUTPUT:
%   ROWNUM is an integer value of the number of rows in the database
%
%   COLUMN_NAMES is a cell array containing the names of the columns
%
%   ERROR is an integer value specifying a possible error 1 if there is an
%         error, 0 if no error
%--------------------------------------------------------------------------
error = false;
rownum = 0;
column_names = cell(0);

h = waitbar(0,'Please wait...'); % Progress bar

% Open database file
try
    dbid = sqliteopen('test.db');
    waitbar(1, h, 'Opening Database');
catch MException
    % If there is a fault close the function
    disp(MException);
    error = true;
    waitbar(100,h);
    delete(h);
    return
end

% Read XLS file to call array RAW and get size
[~,~,raw] = xlsread(file);
[rownum, colnum] = size(raw);

% Save the names of the columns to make each table
column_names = cell([1,colnum+1]);
column_names(1,1) = cellstr('tblid');

primary_key = '';
for i=1:colnum
    primary_key = sprintf('%s,''%s''',primary_key,char(raw(1,i)));
    column_names(1,i+1) = cellstr(sprintf('%s',char(raw(1,i))));
    waitbar(i/colnum*1000,h,'Reading in Excel Column Names.');
end

% Find columns with repeated names to create tables for normalization
table_names = {};
k = 1;
for i=1:length(column_names)
    column_pairs = {};
    pattern = strcat('.*',upper(column_names(i)),'.*');
    x = regexp(upper(column_names),pattern,'match');
    indices = find(~cellfun(@isempty,x));
    if length(indices) > 1
        for j = 1:length(indices)
            column_pairs(j) = {column_names(indices(j))};
        end
        table_names(k) = {column_pairs};
        k = k + 1;
    end
end

for i=1:length(table_names)
    table_pairs = table_names(i);
    
end


sqliteclose(dbid);

delete(h);