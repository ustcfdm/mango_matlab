function arrayInterp = MgInterp1D(array, fitDegree, interpIdx, fitIdx)
% function MgInterp1D(array, fitDegree, interpIdx, fitIdx)
% This function interpolate elements in array with polynomial fitting data.
% arrayNew: interpolated array data (only interpolated data is in array).
% array: 1D data.
% fitDegree: polynomial fitting degree.
% interpIdx: element index in array to be interpolated (index starts from 1).
% fitIdx: element index (starts from 1) for polynomial fitting. (default: all elements in array excluding interpIdx)

N = numel(array);

if nargin < 4
    fitIdx = 1:N;
    fitIdx(interpIdx) = [];
end

p = polyfit(fitIdx, array(fitIdx), fitDegree);
arrayInterp = polyval(p, interpIdx);

end

