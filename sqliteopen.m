function status = sqliteopen(db_file)
%
%
%
status = 0;
mksqlite('open',db_file);
mksqlite('PRAGMA synchronous = OFF');