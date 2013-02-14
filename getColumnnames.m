function [rownum,column_names,error] = getColumnnames(file)

error = false;

% Open database file and drop current table
dbid = sqliteopen('test.db');
sqlitecmd(dbid,'drop table if exists t');

% Read XLS file to call array RAW and get size
[~,~,raw] = xlsread(file);
[rownum,colnum] = size(raw);

% Save the names of the columns in a cell array
column_names = cell([1,colnum+1]);
column_names(1,1) = cellstr('tblid');

for i = 1:colnum
    column_names(1,i+1) = cellstr(sprintf('%s',char(raw(1,i))));
end
sqliteclose(dbid);