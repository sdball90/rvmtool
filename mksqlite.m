% Mksqlite A MATLAB interface to SQLite
%  SQLite is an embedded SQL engine that can be managed without SQL 
%  Server databases within files. Mksqlite provides the interface 
%  to the SQL database.
%
% General call:
%  dbid = mksqlite ([dbid,] SQL Command [,argument])
%
%  The dbid parameter is optional and is required only if you want to work
%  with multiple databases. If dbid is omitted, then the #1 database is
%  used automatically.
%
% Function calls:
%  mksqlite ('open', 'database file')
%   or
%  dbid = mksqlite (0, 'open', 'database file')
%
%  Opens the database file with the file name "database file". If the file
%  does not exist it will be created. If a dbid is specified and dbid
%  refers to a database that is already open, it will be closed before
%  executing the command. If you specify the dbid 0, the next free dbid is 
%  returned.
%
%  mksqlite ('close')
%   or
%  mksqlite (dbid, 'close')
%   or
%  mksqlite (0, 'close')
%
%  Closes a database file. When specifying a dbid, this database is closed.
%  If you specify the dbid 0, all open databases are closed.
%
%  mksqlite ('SQL command')
%   or
%  mksqlite (dbid, 'SQL command')
%
%  Executes SQL command.
%
% Example:
%  mksqlite ('open', 'testdb.db3');
%  result = mksqlite('select * from test table');
%  mksqlite ('close');
%
%  Reads all fields of the table "test table" in the database "testdb.db3"
%  into the variable "result".
%
% Example:
%  mksqlite ('open', 'testdb.db3')
%  mksqlite ('show tables')
%  mksqlite ('close')
%
%  Shows all tables in the database "testdb.db3".
%
% (c) 2008 by Martin Kortmann <mail@kortmann.de>
%