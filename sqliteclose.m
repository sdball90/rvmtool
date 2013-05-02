%% SQLITECLOSE 
% Closes an open database
%
%% STATUS = SQLITEOPEN(DBID)
% * INPUT
%
% *DBID* is an integer specifying the open database
%
% * OUTPUT
%
% *STATUS* is an integer value specifying a possible error
% 1 if there is an error, 0 if no error
function status = sqliteclose(dbid)
status = 0;
mksqlite(dbid,'close');
