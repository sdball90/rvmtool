function [result,status] = sqlitecmd(sql_string)
% SQLITECMD runs a sql query for a database connection
%
% INPUT
%	CONNECTION is a database connection object
%	SQL_STRING is a string containing a sql query
% OUTPUT
%	RESULT is the result of the sql query
%	STATUS is an integer value specifying a possible error
%	    1 if there is an error, 0 if no error
%
status = 0;
result = mksqlite(sql_string);