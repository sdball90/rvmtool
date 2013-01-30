function [rownum,column_names,error] = xls2db(file)
%------------------------------------------------------------------------------
% XLS2DB takes a XLS spreadsheet and inputs data into sqlite database
%
% HISTORY:
% 19 November 2012  Dennis Magee    Original code
% 29 November 2012  Dennis Magee    Revised to use mksqlite
% 18 December 2012  Dennis Magee    Fixed storing numbers in database
% 29 December 2012  Phillip Shaw    Added progress bar
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
error = false;

h = waitbar(0,'Please wait...'); % progress bar

% Open database file and drop current table
dbid = sqliteopen('test.db');
sqlitecmd(dbid,'drop table if exists t');

% Read XLS file to call array RAW and get size
[~,~,raw] = xlsread(file);
[rownum,colnum] = size(raw);

% Save the names of the columns in a cell array
column_names = cell([1,colnum+1]);
column_names(1,1) = cellstr('tblid');

% Create table with columns
index = '';
for i = 1:colnum
    index = sprintf('%s,''%s''',index,char(raw(1,i)));
    column_names(1,i+1) = cellstr(sprintf('%s',char(raw(1,i))));
end
sqlitecmd(dbid,'begin transaction');
cmd = sprintf('create table t(tblid integer primary key%s)',index);
[~,status] = sqlitecmd(dbid,cmd);
sqlitecmd(dbid,'commit');
error = or(error,status);

% Read data from cell array into database
sqlitecmd(dbid,'begin transaction');

for i = 2:rownum
    input = sprintf('%d',i-1);
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
    waitbar((i)/(rownum),h); % update progress bar
end
sqlitecmd(dbid,'commit');
sqliteclose(dbid);
rownum = rownum - 1;
delete(h); % close progress bar
