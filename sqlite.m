function [result,status] = sqlite(sql_string,db_file)
%SQLITE executes a query on a given database
%   SQL_STRING should be a string of the sqlite commands to be executed
%   DB_FILE should inlclude both the path and filename of the database file
%   to be used. If path is not included the current folder is used. If file
%   does not exist it will be created.
%   STATUS should return 0 on a successful query
%   RESULT is a cell array of the data returned
%
%
%   Examples:
%
%      result = sqlite('SELECT * FROM some_table','d:\a_folder\test.db');
%      [result,status] = sqlite('CREATE TABLE new_table (id integer)','test.db');
%
%   copyright 2010-2012 garrett foster
%   source: https://bitbucket.org/garrettfoster/sqlite-matlab
%   version: 2012.02.05

  %prefill outputs
  result = {};
  status = 0;

  if nargin == 2
    %fix filename if needed
    [path,file,ext] = fileparts(db_file);
    if isequal(path,'') %if path is empty assume they want the current path
      path = cd;
      db_file = [path,filesep,file,ext];
    end

    %check that the driver is loaded
    if ~exist('org.sqlite.JDBC','class')
      [path,file,ext] = fileparts(mfilename('fullpath'));
      javaaddpath([path,filesep,'sqlite-jdbc.jar'], '-end');
    end

    %create connection
    database_name = ''; %not needed
    user_name = ''; %not needed
    password = ''; %not needed
    driver = 'org.sqlite.JDBC';
    database_url = sprintf('jdbc:sqlite:%s', db_file);
    connection = database(database_name,...
                          user_name,...
                          password,...
                          driver,...
                          database_url);

    %check connection
    if isconnection(connection) % test for successful connection
      if isreadonly(connection) %check to see if it is read only
        warning('sqlite:readOnly','database connection is READ ONLY');
      end
    else
      error('sqlite:cannotConnect','failed to connect to database: %s',connection.message);
    end

    %check query to see if read or write
    if regexpi(sql_string,'\s*select\s+','start')

      %check to see if there is a limit
      nrows = floor(str2double(...
        regexprep(...
          regexpi(sql_string,'limit\s+\d+','match'),...
        'limit\s+','','once','ignorecase')...
      ));

      %if limit isn't defined figure out the maximum number of rows
      if isempty(nrows)
        table_name = regexprep(regexpi(sql_string,'from\s+\w+','match'),'from\s+','','once','ignorecase');
        setdbprefs('DataReturnFormat','numeric');
        temp_string = sprintf('%s%s%s','SELECT COUNT(*) FROM ',table_name{1},' ;');
        nrows = fetch(connection,temp_string,1);
      end

       setdbprefs('DataReturnFormat','cellarray');
      result = fetch(connection,sql_string,nrows);

    else
      curs = exec(connection,sql_string);
      if ~isempty(curs.Message);
        status = 1; %FIXME the message should probably be shown
      end
    end

    %display any errors and close connection
    close(connection);

  else
    error('sqlite:notEnoughArguments','Function sqlite expects 2 arguments');
  end

end