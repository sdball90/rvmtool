function status = rfind(rownum,column_names, varargin)
%------------------------------------------------------------------------------
% RFIND looks for relationships between elements in a database
%
% HISTORY:
% 20 December 2012  Dennis Magee    Original Code
% 25 February 2013  Aaron Caldwell  Iterate on rows/columns/splits/columns
% 27 February 2013  Dennis Magee    Store relationships into database
%  3 April    2013  Aaron Caldwell  Adding Specific search parameters
%  3 April    2013  Dennis Magee    Error Prevention and add specific to database
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

% If we are not doing a specific search, do a general search
if(length(varargin) < 1)
    for i = 2:rownum

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

                % Split the string on delimiters
                string = char(row(j));
                if ~isempty(char(str_delimiter(j)))
                    string = regexp(char(row(j)),char(str_delimiter(j)),'split');
                end

                % Calculate the number of strings to search for
                if(iscell(string))
                    strnum = length(string);
                else
                    strnum = 1;
                end
                
                for k = 1:strnum

                    % Remove whitespace from beginning and end of the string
                    % and fix single quotes in the string
                    if iscell(string)
                        look = fixstr(string(k));
                    else
                        look = fixstr(string);
                    end
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
                    [rows,input] = findrel(dbid,column_names,char(look),j);
                    insert2db(dbid,char(column_names(j)),index,tblid(j),...
                        char(look),rows,input);
                    tblid(j) = tblid(j) + 1;
                end
            % If value in cell is not a string, it is a number
            else

                % Skip if value already in database
                cmd = sprintf('select count (tblid) from ''%s'' where (column_value = %d OR column_value like ''%%%d%%'')',...
                    char(column_names(j)),cell2mat(row(j)),cell2mat(row(j)));
                check_val = sqlitecmd(dbid,cmd);
                if (cell2mat(check_val) ~= 0)
                    continue;
                end
                [rows,input] = findrel(dbid,column_names,cell2mat(row(j)),j);
                % Insert counts into database and increment tblid
                insert2db(dbid,char(column_names(j)),index,tblid(j),...
                    cell2mat(row(j)),rows,input);
                tblid(j) = tblid(j) + 1;
            end
        end

        % increase value of progress bar
        wait_bar = wait_bar + (1/rownum);
        waitbar(wait_bar,h);

        % commit to database if over 1000 transactions pending and not last row
        if (i ~= rownum)
            if ( mod(sum(tblid),1000) < check_commit )
                sqlitecmd(dbid,'commit');
                sqlitecmd(dbid,'begin transaction');
            end
            check_commit = mod(sum(tblid),1000);
        end
    end
    
% Specific search
else
    % Remove floating ands at end and split search string on ands
    look_and = regexprep(char(varargin),'\s&&$|\s&$|\sAND$|\sand$', '');
    look_and = regexp(look_and,'\s&&\s|\s&\s|\sAND\s|\sand\s', 'split');
    find_rel = '';
    % Check if look_and string was split
    if iscell(look_and)
        and_length = length(look_and);
    else
        and_length = 1;
    end
    
    str_delimiter = get_delimiter(dbid,char(column_names));
    if char(str_delimiter) == '\|'
        str_delimiter = '|';
    end
    for i = 1:and_length
        % Remove floating ors at end and split string on ors
        if iscell(look_and)
            look = char(look_and(i));
        else
            look = look_and;
        end
        look_or = regexprep(char(look), '\s\|\|$|\s\|$|\sOR$|\sor$', '');
        look_or = regexp(look_or, '\s\|\|\s|\s\|\s|\sOR\s|\sor\s', 'split');
        or_rfind = '';
        % Check if look_or string was split
        if iscell(look_or)
            or_length = length(look_or);
        else
            or_length = 1;
        end
        
        for j = 1:or_length
            if iscell(look_or)
                look = fixstr(char(look_or(j)));
            else
                look = fixstr(look_or);
            end
            if isempty(look)
                continue;
            end
            is_num = str2num(char(look));
            if(~isempty(is_num))
                or_find_sub = sprintf('("%s" = %d OR "%s" LIKE ''%d%s%%'' OR "%s" LIKE ''%%%s%d'' OR "%s" LIKE ''%%%s%d%s%%'')', ...
                    column_names, is_num, column_names, is_num, char(str_delimiter), column_names, char(str_delimiter), is_num, column_names, char(str_delimiter), is_num, char(str_delimiter));
            else
                or_find_sub = sprintf('"%s" like ''%%%s%%''', column_names, char(look));
            end
            if j > 1
                or_rfind = sprintf('%s OR ',or_rfind);
            end
            or_rfind = sprintf('%s %s',or_rfind, or_find_sub);
        end
        if isempty(or_rfind)
            continue;
        end
        if i > 1
            find_rel = sprintf('%s AND ',find_rel);
        end
        find_rel = sprintf('%s (%s)', find_rel, or_rfind);
    end
    look = fixstr(find_rel);
    if isempty(look)
        status = 1;
        close(h);
        sqliteclose(dbid);
        return;
    end
    find = sprintf('select tblid from t where %s', find_rel);
    ids = sqlitecmd(dbid,find);
    rownum = mat2str(cell2mat(ids));
    counts = length(ids);
    cmd = sprintf('insert into Specific_Search (search_value,rownum,counts) values (''%s'',"%s",%d)',...
        char(varargin),rownum,counts);
    sqlitecmd(dbid,cmd);
end
% Commit last transactions and close the database and progress bar
if ( check_commit <= mod(sum(tblid),1000) )
    sqlitecmd(dbid,'commit');
end
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
%   CURRENT_COLUMN - Column value came from
% OUTPUTS
%   ROWS - String containing all rows value was found
%   INPUT - String of comma delimited values for counts
function [rows,input] = findrel(dbid,column_names,value,current_column)
input = '';
colnum = length(column_names);
row_result = [];
for i = 2:colnum
    % Find all rows containing the string and count the table ids
    if ischar(value)
        cmd = sprintf('select tblid from t where "%s" like ''%%%s%%''', ...
            char(column_names(i)), value);
    else
        cmd = sprintf('select tblid from t where ("%s" = %d OR "%s" like ''%%%d%%'')', ...
            char(column_names(i)), value, char(column_names(i)), value);
    end
    result = sqlitecmd(dbid,cmd);
    input = sprintf('%s,%d',input,length(result));
    if isempty(result)
        continue;
    end
    if i==current_column
        row_result=cell2mat(result);
    end
end
rows = mat2str(row_result);

% INSERT2DB
% Inserts the relationships into the database
%
% INPUTS
%   DBID - Database ID
%   TABLE - Database table to insert into
%   COLUMNS - String containing all the columns
%   TBLID - Table ID for the current insert
%   VALUE - Value to insert into database
%   ROWNUM - Row #s of value from main table
%   COUNTS - String containing the counts of relationships
function insert2db(dbid,table,columns,tblid,value,rownum,counts)
if ischar(value)
    cmd = sprintf('insert into "%s" (tblid,column_value,rownum%s) values (%d,''%s'',"%s"%s)',...
        table,columns,tblid,value,rownum,counts);
else
    cmd = sprintf('insert into "%s" (tblid,column_value,rownum%s) values (%d,%d,"%s"%s)',...
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