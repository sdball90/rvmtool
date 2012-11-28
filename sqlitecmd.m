function [result,status] = sqlitecmd(connection,sql_string)
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
result = {};
status = 0;

% Check that the driver is loaded
if ~exist('org.sqlite.JDBC','class')
  [path,file,ext] = fileparts(mfilename('fullpath'));
  javaaddpath([path,filesep,'sqlite-jdbc.jar'], '-end');
end

% Run sql command and check for error
% Do not check errors on begin and commit statements
curs = exec(connection,sql_string);
if (~isempty(curs.Message) && ...
	isempty(regexpi(sql_string,'\s*(commit)|(begin)|(drop)','start')))
  status = 1;
  warning(char(curs.Message))
end

% If select statement, return result of query
if regexpi(sql_string,'\s*select\s+','start')
   curs = fetch(curs);
   result = curs.Data;
end
