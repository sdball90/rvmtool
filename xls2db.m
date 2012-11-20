function test = xls2db(file)
%
%
%
%
cmd = '';
conn = sqliteopen('test.db');
sqlitecmd(conn,'drop table t');
[raw,raw,raw] = xlsread(file);
[length,width] = size(raw);
sqlitecmd(conn,'create table t(tblid integer primary key)');
for i = 1:width
    cmd = 'alter table t add ';
    cmd = [cmd,regexprep(char(raw(1,i)),'[^\w'']','')];
    [test,test] = sqlitecmd(conn,cmd);
end
sqlitecmd(conn,'commit');
sqliteclose(conn);