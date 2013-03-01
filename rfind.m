function status = rfind(rownum,column_names)
%------------------------------------------------------------------------------
% RFIND looks for relationships between elements in a database
%
% HISTORY:
% 20 December 2012  Dennis Magee    Original Code
% 25 February 2013  Aaron Caldwell  Itterate on rows/columns/splits/columns
% 27 February 2013  Dennis Magee    Store relationships into database
%
% STATUS = RFIND(ROWNUM,COLUMN_NAME)
%
% INPUT:
%	ROWNUM is an integer value of the number of rows in the database
%
%	COLUMN_NAMES is a cell array containing the names of the columns
%
% OUTPUT:
%	STATUS is an integer value specifying a possible error
%		1 if there is an error, 0 if no error
%
% METHOD:
%------------------------------------------------------------------------------
status = 0;
wait_bar = 0;
h = waitbar(wait_bar,'Finding Relationships:'); % progress bar

% Open the database test.db
dbid = sqliteopen('test.db');

% Calculate the number of columns from the array of column names
colnum = length(column_names);

% Put column names in a list and find delimiter for each column
index = '';
str_delimiter = cell(1,colnum);
for i = 2:colnum
    index = sprintf('%s,''%s''',index,char(column_names(i)));
    str_delimiter(i) = get_delimiter(dbid,char(column_names(i)));
end

% table ids for each table and
tblid = ones(1,colnum);
check_commit = 0;

% Start finding relationships
sqlitecmd(dbid,'begin transaction');
for i = 1:rownum
    
    % Get rows based on tblid = i
    cmd = sprintf('select * from t where tblid = %d', i);
    row = sqlitecmd(dbid,cmd);
    for j = 2:colnum
        % Check if row value is a string
        if iscellstr(row(j))
            
            % Skip row if string is empty
            if isempty(char(row(j)))
                continue;
            end
            
            % split the string on delimiters
            string = char(row(j));
            if ~isempty(char(str_delimiter(j)))
                string = regexp(char(row(j)),char(str_delimiter(j)),'split');
            end

            % calculate the string of strings
            if(iscell(string))
                strnum = length(string);
                for k = 1:strnum
                    
                    % Remove whitespace from beginning and end of the string
                    % and fix single quotes in the string
                    look = fixstr(string(k));
                    % Skip checking relationships if look is empty or value
                    % already in database
                    if (isempty(char(look)))
                        continue;
                    end
                    cmd = sprintf('select count (tblid) from ''%s'' where column_value = ''%s''',...
                        char(column_names(j)),char(look));
                    check_val = sqlitecmd(dbid,cmd);
                    if (cell2mat(check_val) ~= 0)
                        continue;
                    end
                    % Find relationships and place counts into database
                    input = findrel(dbid,column_names,char(look));
                    insert2db(dbid,char(column_names(j)),index,tblid(j),...
                        char(look),i,input);
                    tblid(j) = tblid(j) + 1;
                end
                
            % If the string did not split
            else
                % Remove whitespace from beginning and end of the string
                % and fix single quotes in the string
                look = fixstr(string);
                
                % Skip is value is empty or already in database
                if (isempty(char(look)))
                    continue;
                end
                cmd = sprintf('select count (tblid) from "%s" where column_value = ''%s''',...
                    char(column_names(j)),char(look));
                check_val = sqlitecmd(dbid,cmd);
                if (cell2mat(check_val) ~= 0)
                    continue;
                end
                
                % Find relationships and place counts in database
                input = findrel(dbid,column_names,char(look));
                insert2db(dbid,char(column_names(j)),index,tblid(j),...
                    char(look),i,input);
                tblid(j) = tblid(j) + 1;
            end

		% If value in cell is not a string, it is a number
        else
            
            % Skip if value already in database
            cmd = sprintf('select count (tblid) from ''%s'' where column_value = %d',...
                char(column_names(j)),cell2mat(row(j)));
            check_val = sqlitecmd(dbid,cmd);
            if (cell2mat(check_val) ~= 0)
                continue;
            end
            input = findrel(dbid,column_names,cell2mat(row(j)));
            % Insert counts into database and increment tblid
            insert2db(dbid,char(column_names(j)),index,tblid(j),...
                cell2mat(row(j)),i,input);
            tblid(j) = tblid(j) + 1;
        end
    end
    
    % increase value of progress bar
    wait_bar = wait_bar + (1/rownum);
    waitbar(wait_bar,h);
    
    % commit to database if over 1000 transactions and not last row
    if (i ~= rownum)
        if ( mod(sum(tblid),1000) < check_commit )
            sqlitecmd(dbid,'commit');
            sqlitecmd(dbid,'begin transaction');
        end
        check_commit = mod(sum(tblid),1000);
    end
end
% Commit last transactions and close the database and progress bar
sqlitecmd(dbid,'commit');
close(h);
sqliteclose(dbid);

% GET_DELIMITER
% Finds the primary delimiter for the database column
%
% INPUTS
%   DBID - Database ID
%   COLUMN - Comumn to find delimiter
% OUTPUTS
%   OUT - Delimiter to be used for the column
function out = get_delimiter(dbid,column)
out = cellstr('');
delimiters = cellstr(['~';'|';';';',']);
for i = 1:length(delimiters);
    cmd = sprintf('select count(tblid) from t where "%s" like ''%%%s%%''',...
        column,char(delimiters(i)));
    result = sqlitecmd(dbid,cmd);
    if (cell2mat(result) ~= 0)
        if char(delimiters(i)) == '|'
            out = cellstr('\|');
        else
            out = delimiters(i);
        end
        return;
    end
end

% FINDREL
% Finds the relationships of a specific value
%
% INPUTS
%   DBID - Database ID
%   COLUMN_NAMES - Array of all the column names
%   VALUE - Specific value to find relationships for
% OUTPUTS
%   INPUT - string of comma delimited values for counts
function input = findrel(dbid,column_names,value)
input = '';
colnum = length(column_names);
for i = 2:colnum
    % Find all rows containing the string and count the table ids
    if ischar(value)
        cmd = sprintf('select count(tblid) from t where "%s" like ''%%%s%%''', ...
            char(column_names(i)), value);
    else
        cmd = sprintf('select count(tblid) from t where "%s" = %d', ...
            char(column_names(i)), value);
    end
    result = sqlitecmd(dbid,cmd);
    input = sprintf('%s,%d',input,cell2mat(result));
end

% INSERT2DB
% Inserts the relationships into the database
%
% INPUTS
%   DBID - Database ID
%   TABLE - Database table to insert into
%   COLUMNS - String containing all the columns
%   TBLID - Table ID for the current insert
%   VALUE - Value to insert into database
%   ROWNUM - Row # of value from main table
%   COUNTS - String containing the counts of relationships
function insert2db(dbid,table,columns,tblid,value,rownum,counts)
if ischar(value)
    cmd = sprintf('insert into "%s" (tblid,column_value,rownum%s) values (%d,''%s'',%d%s)',...
        table,columns,tblid,value,rownum,counts);
else
    cmd = sprintf('insert into "%s" (tblid,column_value,rownum%s) values (%d,%d,%d%s)',...
        table,columns,tblid,value,rownum,counts);
end
sqlitecmd(dbid,cmd);

% FIXSTR
% Fixes the string to be used in sprintf
%
% INPUTS
%   STR - String to be fixed
% OUTPUTS
%   OUT - Fixed string
function out = fixstr(str)
out = strtrim(str);
out = strrep(out,'''','''''');