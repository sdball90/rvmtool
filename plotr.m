function plotr( column_names, sort, num_results, specific )
% PLOTR Creates figures to give a graphical representation of the
% relationships in the database
%
% HISTORY
% 28 February 2013  Dennis Magee    Original Code
%  3 April    2013  Dennis Magee    Don't plot single hits, plot specific searches
%
% INPUTS
%   COLUMN_NAMES - Array containing the names of the columns
%   SORT - 1 for accending results 0 for decending results
%   NUM_RESULTS - Integer value for max number of results to plot
%   SPECIFIC - 1 for specific search, 0 for general
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
if specific==0
    for i = 2:colnum
        title = char(column_names(i));
        % Grab data to plot for the column
        if ( sort == 0 )
            cmd = sprintf('select column_value,"%s" from "%s" order by "%s"',...
                title,title,title);
        else
            cmd = sprintf('select column_value,"%s" from "%s" order by "%s" desc',...
                title,title,title);
        end
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
            ticks = length(find(values~=1));
            if ticks==0
                continue;
            end
            % Remove single hits from graphs
            graph_values = zeros(1,ticks);
            graph_labels = cell(1,ticks);
            k=1;
            for j=1:length(values)
                if values(j)~=1
                    graph_values(k) = values(j);
                    graph_labels(k) = labels(j);
                    k = k+1;
                end
            end
            if num_results == -1
                num_results = ticks;
            end
            % Create the figure and plot the values
            if ticks > num_results
                if sort==0
                    bar_graph(graph_values(ticks-num_results+1:ticks),graph_labels(ticks-num_results+1:ticks),num_results,title);
                else
                    bar_graph(graph_values(1:num_results),graph_labels(1:num_results),num_results,title);
                end
            else
                bar_graph(graph_values,graph_labels,ticks,title);
            end
        end
    end
else
    cmd = sprintf('select counts,search_value from Specific_Search');
    result = sqlitecmd(dbid,cmd);
    if ~isempty(result)
        bar_graph(cell2mat(result(1)),result(2),1,column_names);
    end
end
sqliteclose(dbid);

function bar_graph(values,labels,ticks,plot_title)
figure;
barh(values);
set(gca,'YTick',1:ticks,'YTickLabel',labels,...
    'XLim',[min(values)-1 max(values)+1]);
title(plot_title);
xlabel('Number of hits');
ylabel('Items searched for');