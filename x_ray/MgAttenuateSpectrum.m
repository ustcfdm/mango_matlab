function N = MgAttenuateSpectrum(N0, energy, varargin)
% function N = MgAttenuateSpectrum(N, energy, ...)
% Given a spectrum N, attenuate it with certain material.
% N0: input spectrum (same size as energy).
% energy: array of energy (keV).
% varargin: e.g. "water", 2 [cm].

N = N0;

for k = 1:2:numel(varargin)
    mu = MgGetLinearAttenuation(varargin{k}, energy);
    N = N .* exp(-mu* varargin{k+1});
end