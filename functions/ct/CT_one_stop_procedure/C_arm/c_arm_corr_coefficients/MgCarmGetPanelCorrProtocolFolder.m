function folder = MgCarmGetPanelCorrProtocolFolder(protocol)
% Return the folder that contains panel correction coefficients for the given protocol.
% protocol: string of protocol name (e.g. '7s-dyna-1mmCu-th_20_70keV')


folder = sprintf('%s/%s', fileparts(which('MgCarmGetPanelCorrProtocolFolder')), protocol);

end

