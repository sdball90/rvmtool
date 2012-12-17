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
   for j = 1:(rownum-1)
	   string = regexp(char(data(j)),',','split');
	   [~,length] = size(string);
	   for k = 1:length
		   look = strtrim(string(k));
		   look = strrep(look,'"','""');
           cmd = sprintf('select tblid from t where "%s" like "%%%s%%"', char(column_name(1,i)), char(look));
		   result = sqlitecmd(dbid,cmd);
       end
   end
end

sqliteclose(dbid);
