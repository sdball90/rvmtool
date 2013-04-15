function [rownum,column_names,error] = xls2db(file)
%------------------------------------------------------------------------------
% XLS2DB takes a XLS spreadsheet and inputs data into sqlite database
%
% HISTORY:
% 19 November 2012  Dennis Magee    Original code
% 29 November 2012  Dennis Magee    Revised to use mksqlite
% 18 December 2012  Dennis Magee    Fixed storing numbers in database
% 29 December 2012  Phillip Shaw    Added progress bar
% 24 February 2013  Dennis Magee    Added error check when opening excel file
%  3 April    2013  Dennis Magee    Add Specific_Search table
% 11 April    2013  Dennis Magee    Fix empty column issue
%
% [ROWNUM,COLUMN_NAMES,ERROR] = XLS2DB(FILE)
%
% INPUT:
%	FILE is a string with the path to the xls file
%
% OUTPUT:
%   ROWNUM is an integer value of the number of rows in the database
%
%   COLUMN_NAMES is a cell array containing the names of the columns
%
%	ERROR is an integer value specifying a possible error
%		1 if there is an error, 0 if no error
%
% METHOD:
%	Open database file and drop previous table
%   Read spreadsheet into raw cell array
%	Create database table with column names from first row of array
%	Insert rows of array into database
%	Close database file
%------------------------------------------------------------------------------
rownum = 0;
column_names = '';
error = false;

h = waitbar(0,'Please wait...'); % progress bar

% Open database file and drop current table
dbid = sqliteopen('test.db');
tables = sqlitecmd(dbid,'show tables');
if (~isempty(tables))
    for i = 1:length(tables)
        cmd = sprintf('drop table if exists ''%s''',char(tables(i)));
        sqlitecmd(dbid,cmd);
    end
end
clear tables;
% Read XLS file to call array RAW and get size
try
    waitbar(.1, h, 'Reading Excel File:');
    [~,~,raw] = xlsread(file);
catch MException
    % If there is a fault close the function
    disp(MException.message);
    error = true;
    waitbar(1,h,'Error');
    delete(h);
    sqliteclose(dbid);
    return
end

[rownum,colnum] = size(raw);

% Save the names of the columns in a cell array
column_names = cell([1,colnum+1]);
column_names(1,1) = cellstr('tblid');

% Create table with columns
index = '';
for i = 1:colnum
    % Check if column name is an empty string
    if isnan(cell2mat(raw(1,i)))
        error = true;
        delete(h);
        sqliteclose(dbid);
        return;
    elseif iscellstr(raw(1,i))
        if isempty(strtrim(char(raw(1,i))))
            error = true;
            delete(h);
            sqliteclose(dbid);
            return;
        end
    end
    % Check if column name is a number, convert to string
    if iscellstr(raw(1,i))
        column = strtrim(char(raw(1,i)));
    else
        column = sprintf('%d',cell2mat(raw(1,i)));
    end
    % Add column name to the list of column names
    index = sprintf('%s,''%s''',index,column);
    column_names(1,i+1) = cellstr(sprintf('%s',column));
end

% Create the primary table
cmd = sprintf('create table t(tblid integer primary key%s)',index);
[~,status] = sqlitecmd(dbid,cmd);
error = or(error,status);

% Read data from cell array into database
sqlitecmd(dbid,'begin transaction');

for i = 2:rownum
    input = sprintf('%d',i);
    for j = 1:colnum

	    % Determine if data cell is empty, string, or number
        if (isnan(cell2mat(raw(i,j)))==1)
            data = '';
        	input = sprintf('%s,''%s''',input,data);
        elseif (iscellstr(raw(i,j))==1)
            data = sprintf('%s',char(raw(i,j)));

	    	% Fix input of single quotes and add to input string
        	data = strrep(data,'''','''''');
        	input = sprintf('%s,''%s''',input,data);
        else
            data = sprintf('%d',cell2mat(raw(i,j)));
        	input = sprintf('%s,%s',input,data);
        end    
    end
    cmd = sprintf('insert into t (tblid%s) values (%s)',index,input);
    [~,status] = sqlitecmd(dbid,cmd);
    error = or(error,status);
    waitbar((i)/(rownum),h,'Creating Database:'); % update progress bar
    if ( mod(i,1000) == 0 )
        sqlitecmd(dbid,'commit');
        sqlitecmd(dbid,'begin transaction');
    end
end
sqlitecmd(dbid,'commit');

sqlitecmd(dbid,'begin transaction');
for i = 1:colnum
    cmd = sprintf('create table "%s"(tblid integer primary key,column_value,rownum%s)',...
        char(column_names(i+1)),index);
    [~,status] = sqlitecmd(dbid,cmd);
    error = or(error,status);
end
cmd = 'create table Specific_Search (search_value,rownum,counts)';
[~,status] = sqlitecmd(dbid,cmd);
error = or(error,status);
sqlitecmd(dbid,'commit');

sqliteclose(dbid);
delete(h); % close progress bar
clear raw;
