function status = rfind(rownum,column_name)
%
%
%
%
%
status = 0;
dbid = sqliteopen('test.db');
[~,colnum] = size(column_name);

for i = 2:colnum
   cmd = sprintf('select "%s" from t',char(column_name(1,i)));
   data = sqlitecmd(dbid,cmd);
   for j = 1:rownum 
       
   end
end

sqliteclose(dbid);