function test = readtodb(file)
%
%
%
%
cmd = '';
sqlite('drop table t','test.sqlite3');
[raw,raw,raw] = xlsread(file);
[length,width] = size(raw);
sqlite('create table t(tblid integer primary key)','test.sqlite3');
for i = 1:width
    cmd = 'alter table t add ';
    cmd = [cmd,regexprep(char(raw(1,i)),'[^\w'']','')];
    [test,test] = sqlite(char(cmd),'test.sqlite3');
end