function plotr( column_names )
% PLOTR Creates figures to give a graphical representation of the
% relationships in the database
%
% HISTORY
% 28 February 2013  Dennis Magee    Original Code
%
% INPUTS
%   COLUMN_NAMES - Array containing the names of the columns
%
% METHOD
%   Open Database
%   Get results from database
%   Cut labels to 40 characters
%   Plot the results
%   Close Databese
%
colnum = length(column_names);
dbid = sqliteopen('test.db');
for i = 2:colnum
    title = char(column_names(i));
    % Grab data to plot for the column
    cmd = sprintf('select column_value,"%s" from "%s" order by "%s" desc',...
        title,title,title);
    result = sqlitecmd(dbid,cmd);
    % Nothing to plot if result is empty
    if ~isempty(result)
        % Set the labels and cut the text to 40 characters each
        labels = result(:,1);
        for j = 1:length(labels)
            if iscellstr(labels(j))
                str = char(labels(j));
                if length(str) > 40
                    labels(j) = cellstr(str(1:40));
                end
            else
                labels(j) = cellstr(mat2str(cell2mat(labels(j))));
            end
        end
        % Set the values and change to number array
        values = cell2mat(result(:,2));
        ticks = length(values);
        % Create the figure and plot the values
        if length(values) > 20
            bar_graph(values(1:20),labels(1:20),20,title);
        else
            bar_graph(values,labels,ticks,title);
        end
    end
end
sqliteclose(dbid);

function bar_graph(values,labels,ticks,plot_title)
figure;
barh(values);
set(gca,'YTick',1:ticks,'YTickLabel',labels,...
    'XLim',[min(values)-1 max(values)+1]);
title(plot_title);