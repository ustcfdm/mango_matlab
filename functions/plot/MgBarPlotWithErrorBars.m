function MgBarPlotWithErrorBars(data_series, data_error)
% Plot multiple bars with error bars.

b = bar(data_series);

hold on;

% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(data_series);

% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = b(i).XEndPoints;
end

% Plot the errorbars
errorbar(x',data_series,data_error,'k','linestyle','none');

hold off



end

