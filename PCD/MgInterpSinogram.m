function sgmInterp = MgInterpSinogram(sgm, fitDegree, interpHalfLength, fitHalfLength)
% function sgmInterp = MgInterpSinogram(sgm, interpHalfLength, fitHalfLength)
% This function interpolate gaps between PCD panels.
% sgmInterp: sinogram after interpolation correciton.
% sgm: input sinogram data (rows x cols x slices).
% fitDegree: polynomial fitting power.
% interpHalfLength: half length of interpolation range between panels (default = 10).
% fitHalfLength: half length of fitting range between panels (default = 20).

%=======================================================================================
% The detector has 20 panels. Each panel width is 256 pixels. The detector total width 
% is 5120 pixels. The positions of gaps to be interpolated are (1:19)*256.
%=======================================================================================

if nargin < 3
    fitHalfLength = 20;
end
if nargin < 2
    interpHalfLength = 10;
end

idxGap = (1:19)*256;

[rows, cols, pages] = size(sgm);

sgmInterp = sgm;

% start interpolation
for page = 1:pages
    for row = 1:rows
        for idx = idxGap
            idxInterp = (idx-interpHalfLength):(idx+interpHalfLength);
            idxFit = (idx-fitHalfLength):(idx+fitHalfLength);
            sgmInterp(row, idxInterp, page) = MgInterp1D(sgm(row,idxFit,page), fitDegree, idxInterp-idxFit(1)+1); 
        end
    end
end

end