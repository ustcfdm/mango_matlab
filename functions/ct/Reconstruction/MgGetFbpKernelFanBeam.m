function kernel = MgGetFbpKernelFanBeam(N, dx, config)
% MgGetFbpKernelFanBeam, get the reconstruction kernel for FBP CT reconstruction.
% N: number of detector elements.
% dx: detector element size [mm].
% config: a struct contains the name and parameter of kernel. Refer to mgfbp for more infomation.
% kernel: array of output kernel (length: 2*N - 1)
%
% TODO: only support 'HammingFilter' and 'GaussianApodizedRamp' kernel for now (2021-01-22).

if isfield(config, 'HammingFilter')    
    % combine ramp and consine
    kernel = config.HammingFilter * MgGetRampKernel(N, dx) +  (1 - config.HammingFilter) * MgGetCosKernel(N, dx);    
elseif isfield(config, 'GaussianApodizedRamp')
    kernel_ramp = MgGetRampKernel(2*N-1, dx);
    % gaussian part
    sigma = config.GaussianApodizedRamp;
    gauss_func = MgGetGaussianCurve(N, dx, sigma);
    
    kernel = conv(gauss_func, kernel_ramp, 'same') * dx;
end


end

%===============================================================
% Internel functions
%===============================================================

%----------------------------------------
% get ramp kernel
%----------------------------------------
function kernel = MgGetRampKernel(N, dx)
kernel = zeros(1, 2*N-1);
% ramp part
for k = 1:2:N-1
    kernel(N-k) = -1/ (k*pi*dx)^2;
    kernel(N+k) = -1/ (k*pi*dx)^2;
end
kernel(N) = 1/ (2*dx)^2;
end

%----------------------------------------
% get cosine kernel
%----------------------------------------
function kernel = MgGetCosKernel(N, dx)
kernel = zeros(1, 2*N-1);
% consine part
for k = 0:N-1
    kernel(N-k) = (-1)^k * (1/(1+2*k)+1/(1-2*k))/(2*pi*dx^2) - (1/(1+2*k)^2 + 1/(1-2*k)^2) / (pi*dx)^2;
    kernel(N+k) = (-1)^k * (1/(1+2*k)+1/(1-2*k))/(2*pi*dx^2) - (1/(1+2*k)^2 + 1/(1-2*k)^2) / (pi*dx)^2;
end
end

%----------------------------------------
% get Gaussian curve
%----------------------------------------
function gauss = MgGetGaussianCurve(N, dx, sigma)
idx = (-N+1):(N-1);

gauss = exp(-idx.^2/sigma^2/2);
gauss = gauss / sum(gauss)/dx;

end