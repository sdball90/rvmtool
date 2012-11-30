function status = sqliteclose(dbid)
%
%
%
status = 0;
mksqlite(dbid,'close');
