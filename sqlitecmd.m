function [result,status] = sqlitecmd(dbid,sql_string)
% SQLITECMD runs a sql query for a database connection
%
% INPUT
%	DBID is an integer specifying the open database
%	SQL_STRING is a string containing a sql query
% OUTPUT
%	RESULT is the result of the sql query
%	STATUS is an integer value specifying a possible error
%	       1 if there is an error, 0 if no error
%
result = mksqlite(dbid,sql_string);
if (isnumeric(result))
    if result==1
        status = true;
    else
        status = false;
    end
else
    status = false;
end