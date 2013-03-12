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
%   Cut labels to 30 characters
%   Plot the results
%   Close Databese
%
colnum = length(column_names);
dbid = sqliteopen('test.db');
for i = 2:colnum
    % Grab data to plot for the column
    cmd = sprintf('select column_value,"%s" from "%s" order by column_value',...
        char(column_names(i)),char(column_names(i)));
    result = sqlitecmd(dbid,cmd);
    % Nothing to plot if result is empty
    if ~isempty(result)
        % Set the labels and cut the text to 30 characters each
        labels = result(:,1);
        for j = 1:length(labels)
            if iscellstr(labels(j))
                str = char(labels(j));
                if length(str) > 30
                    labels(j) = cellstr(str(1:30));
                end
            else
                labels(j) = cellstr(mat2str(cell2mat(labels(j))));
            end
        end
        % Set the values and change to number array
        values = cell2mat(result(:,2));
        ticks = length(values);
        % Create the figure and plot the values
        %if length(values) > 20
        %    for j = 1:20:ticks
        %        if j+19 < ticks
        %            bar_graph(values(j:j+19),labels(j:j+19),...
        %                ticks,char(column_names(i)));
        %        else
        %            bar_graph(values(j:ticks),labels(j:ticks),...
        %                ticks,char(column_names(i)));
        %        end
        %    end
        %else
            bar_graph(values,labels,ticks,char(column_names(i)));
            pie_chart(values,labels,char(column_names(i)));
        %end
    end
end
sqliteclose(dbid);

function bar_graph(values,labels,ticks,plot_title)
figure;
barh(values);
set(gca,'YTick',1:ticks,'YTickLabel',labels,...
    'XLim',[min(values)-1 max(values)+1]);
title(plot_title);

function pie_chart(values,~,plot_title)
figure;
pie(values);
%set(gca,'YTick',1:ticks,'YTickLabel',labels,...
%    'XLim',[min(values)-1 max(values)+1]);
title(plot_title);