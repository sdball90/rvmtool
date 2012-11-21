function status = xls2db(file)
% XLS2DB takes a XLS spreadsheet and inputs data into sqlite database
%
% Programmer: Dennis Magee
% Version: 0.1 (20 November 2012)
%
% STATUS = XLS2DB(FILE)
%
% INPUT:
%	FILE is a string with the path to the xls file
%
% OUTPUT:
%	STATUS is an integer value specifying a possible error
%		1 if there is an error, 0 if no error
%

% Open database file and drop current table
conn = sqliteopen('test.db');
sqlitecmd(conn,'drop table t');

% Read XLS file to a matrix RAW and get size
[raw,raw,raw] = xlsread(file);
[length,width] = size(raw);

% Create table and add columns
sqlitecmd(conn,'create table t(tblid integer primary key)');
sqlitecmd(conn,'commit');
for i = 1:width
    cmd = sprintf('alter table t add ''%s'';',char(raw(1,i)));
    [status,status] = sqlitecmd(conn,cmd);
end
sqlitecmd(conn,'commit');

% Read data from matrix into database
for i = 2:length
    cmd = sprintf('insert into t (tblid) values (%i)',i-1);
    [status,status] = sqlitecmd(conn,cmd);
    sqlitecmd(conn,'commit');
    for j = 1:width

	% Determine if data cell is empty, string, or number
        if (isnan(cell2mat(raw(i,j)))==1)
            data = '';
        elseif (iscellstr(raw(i,j))==1)
            data = sprintf('%s',char(raw(i,j)));
        else
            data = sprintf('%d',cell2mat(raw(i,j)));
        end
        index = sprintf('%s',char(raw(1,j)));

	% Strip data cell of single quotes and add to database
        data = strrep(data,'''','');
        cmd = sprintf('update t set ''%s''=''%s'' where tblid=%i',index,data,i-1);
        [status,status] = sqlitecmd(conn,cmd);
    end
end

sqlitecmd(conn,'commit');
sqliteclose(conn);
