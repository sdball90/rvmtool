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
sqlitecmd(conn,'commit');
for i = 1:width
    cmd = sprintf('alter table t add ''%s'';',char(raw(1,i)));
    [test,test] = sqlitecmd(conn,cmd);
end
sqlitecmd(conn,'commit');

for i = 2:length
    cmd = sprintf('insert into t (tblid) values (%i)',i-1);
    [test,test] = sqlitecmd(conn,cmd);
    sqlitecmd(conn,'commit');
    for j = 1:width
        if (isnan(cell2mat(raw(i,j)))==1)
            data = '';
        elseif (iscellstr(raw(i,j))==1)
            data = sprintf('%s',char(raw(i,j)));
        else
            data = sprintf('%d',cell2mat(raw(i,j)));
        end
        index = sprintf('%s',char(raw(1,j)));
        data = strrep(data,'''','');
        cmd = sprintf('update t set ''%s''=''%s'' where tblid=%i',index,data,i-1);
        [test,test] = sqlitecmd(conn,cmd);
    end
end

sqlitecmd(conn,'commit');
sqliteclose(conn);