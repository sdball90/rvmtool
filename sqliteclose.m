function status = sqliteclose(connection)
%
%
%
status = 0;

    %check that the driver is loaded
    if ~exist('org.sqlite.JDBC','class')
      [path,file,ext] = fileparts(mfilename('fullpath'));
      javaaddpath([path,filesep,'sqlite-jdbc.jar'], '-end');
    end
    close(connection);
