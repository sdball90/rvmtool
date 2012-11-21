function connection = sqliteopen(db_file)
%
%
%
connection = 0;

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
autocommit = 'off';
database_url = sprintf('jdbc:sqlite:%s', db_file);
connection = database(database_name,...
                      user_name,...
                      password,...
                      driver,...
                      database_url);
set(connection, 'AutoCommit', 'off');

%check connection
if isconnection(connection) % test for successful connection
  if isreadonly(connection) % check to see if it is read only
    warning('sqlite:readOnly','database connection is READ ONLY');
  end
else
  error('sqlite:cannotConnect','failed to connect to database: %s',connection.message);
end
