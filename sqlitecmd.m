function [result,status] = sqlitecmd(connection,sql_string)
%
%
%
%
result = {};
status = 0;

%check that the driver is loaded
if ~exist('org.sqlite.JDBC','class')
  [path,file,ext] = fileparts(mfilename('fullpath'));
  javaaddpath([path,filesep,'sqlite-jdbc.jar'], '-end');
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
