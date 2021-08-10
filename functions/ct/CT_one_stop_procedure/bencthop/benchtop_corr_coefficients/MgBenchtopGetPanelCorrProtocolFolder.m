function folder = MgBenchtopGetPanelCorrProtocolFolder(protocol)
% Return the folder that contains panel correction coefficients for the given protocol.
% protocol: string of protocol name (e.g. '125kV_0.25Cu_th_20_85keV_old_collimator')


folder = sprintf('%s/%s', fileparts(which('MgBenchtopGetPanelCorrProtocolFolder')), protocol);

end

