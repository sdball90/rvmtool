function dbid = sqliteopen(db_file)
%
%
%
dbid = mksqlite(0, 'open', db_file);
mksqlite('PRAGMA synchronous = OFF');