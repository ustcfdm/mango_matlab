function [img, img_stack, sgm_filtered] = MgFbpFanBeam(sgm, config)
% Perform pixel-driven CT reconstruction for fan beam flat detector.
% sgm: 2D sinogram (views x detectorElementCount)
% config: struct contains reconstruction parameters. Members are:
%
%       Views: number of views for reconstruction.
%       DetectorElementSize: [mm]
%       DetectorOffcenter: [mm]
%       SourceIsocenterDistance: [mm]
%       SourceDetectorDistance: [mm]
%
%       ImageDimension: (integer)
%       ImageSize or PixelSize: [mm]
%       ImageRotation: [degree]
%       ImageCenter: [x, y] (mm)
%
%       (Reconstruction kernels: select one)
%       "HammingFilter": t,   t + (1-t)*cos(pi*k/ 2*kn), 1 for ramp kernel, 
%                             0 for consine kernel, others are in-between
%       "GaussianApodizedRamp": delta


%===================================================================
% Prepare parameters
%===================================================================
views = config.Views;
N = size(sgm, 2);
M = config.ImageDimension;
if isfield(config, 'ImageSize')
    dx = config.ImageSize / M;
else
    dx = config.PixelSize;
end

SID = config.SourceIsocenterDistance;
SDD = config.SourceDetectorDistance;

% initize u: position (mm) of each detector element
du = config.DetectorElementSize;
u = ((1:N) - (N+1)/2)*du + config.DetectorOffcenter;


% initize beta: angle (radian) of X-ray source
beta = ((0:views-1) * (360/views) + config.ImageRotation) * pi/180;

% get reconstruction kernel
kernel = MgGetFbpKernelFanBeam(N, config.DetectorElementSize, config);

% image stack of reconstruction per view
img_stack = zeros(M, M, views);
% sginogram after filtration
sgm_filtered = zeros(size(sgm));

%===================================================================
% Filter sinogram
%===================================================================
% weight the sinogram
sgm = SDD^2 ./ sqrt(SDD^2 + u.^2) .* sgm;

% do the convolution
for col = 1:N
    sgm_filtered(:, col) = sum(sgm .* kernel(N-col+1:2*N-col),2) * du;
end

%===================================================================
% Do pixel-driven backprojection
%===================================================================
% reconstruct the image with filtered sinogram data
[x,y] = meshgrid((1-M)/2*dx:dx:(M-1)/2*dx, (M-1)/2*dx:-dx:(1-M)/2*dx);
x = x + config.ImageCenter(1);
y = y + config.ImageCenter(2);

for view = 1:views
    U = (SID-x*cos(beta(view))-y*sin(beta(view))) ;
    u0 = SDD*(x*sin(beta(view))-y*cos(beta(view))) ./ U;
    
    k = floor((u0-u(1))/du) + 1;
    tmp_idx = k<1 | k>=N;
    k(tmp_idx) = 1;
    w = u0 - u(k);
    w(tmp_idx) = 0;
    
    view_last = max(1, view-1);
    img_stack(:,:,view) = img_stack(:,:,view_last) + SID./U.^2.*( (1-w).*reshape(sgm_filtered(view,k),M,M) + w.*reshape(sgm_filtered(view,k+1),M,M) ) * pi / views ;
end

img = img_stack(:,:,end);

end

