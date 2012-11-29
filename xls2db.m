function error = xls2db(file)
% XLS2DB takes a XLS spreadsheet and inputs data into sqlite database
%
% Programmer: Dennis Magee
% Version: 0.1 (20 November 2012)
%
% ERROR = XLS2DB(FILE)
%
% INPUT:
%	FILE is a string with the path to the xls file
%
% OUTPUT:
%	ERROR is an integer value specifying a possible error
%		1 if there is an error, 0 if no error
%
error = 0;

% Open database file and drop current table
conn = 0;
sqliteopen('test.db');
try
    sqlitecmd('drop table t');
catch
    warning('No table t to drop')
end

% Read XLS file to a matrix RAW and get size
[raw,raw,raw] = xlsread(file);
[length,width] = size(raw);

% Create table and add columns
index = '';
for i = 1:width
    index = sprintf('%s,''%s''',index,char(raw(1,i)));
end
sqlitecmd('begin transaction');
cmd = sprintf('create table t(tblid integer primary key%s)',index);
[status,status] = sqlitecmd(cmd);
sqlitecmd('commit');
error = or(error,status);

% Read data from matrix into database
sqlitecmd('begin transaction');
for i = 2:length
    input = sprintf('%d',i-1);
    for j = 1:width

	    % Determine if data cell is empty, string, or number
        if (isnan(cell2mat(raw(i,j)))==1)
            data = '';
        elseif (iscellstr(raw(i,j))==1)
            data = sprintf('%s',char(raw(i,j)));
        else
            data = sprintf('%d',cell2mat(raw(i,j)));
        end
        
	    % Fix input of single quotes and add to input string
        data = strrep(data,'''','''''');
        input = sprintf('%s,''%s''',input,data);
    end
    cmd = sprintf('insert into t (tblid%s) values (%s)',index,input);
    [status,status] = sqlitecmd(cmd);
    error = or(error,status);
end
sqlitecmd('commit');

sqliteclose();
