%% SQLITEOPEN 
% Runs a sql query for a database connection
%
%% DBID = SQLITEOPEN(DB_FILE)
% * INPUT
%
% *DB_FILE* a database file
%
% * OUTPUT
%
% *DBID* is an integer specifying the open database
%
function dbid = sqliteopen(db_file)
dbid = mksqlite(0, 'open', db_file);
