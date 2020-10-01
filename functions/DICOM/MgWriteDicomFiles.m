function MgWriteDicomFiles(img, outputFolder, patientName, seriesDescription, kVp, imgDimension, imageSize, sliceThickness, spacingBetweenSlices, windowLevel, sourceToDetectorDistance, sourceToIsocenterDistance, dicomHeader)
% MgWriteDicomFiles(img, outputFolder, imgDimension, seriesDescription, imageSize, kVp, sliceThickness, spacingBetweenSlices, windowLevel, sourceToDetectorDistance, sourceToIsocenterDistance)
% Write the image (volume) to DICOM files in folder 'outputFolder'
% imgDimension: e.g. 512 or 1024
% seriesDescription: 'e.g. 'Cadaver Head'
% kVp: kVp
% imageSize: [mm]
% sliceThickness: [mm]
% spacingBetweenSlices: [mm]
% windowLevel: e.g. [-100, 100] (HU)
% sourceToDetectorDistance: [mm]
% sourceToIsocenterDistance: [mm]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare meta header info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 13
    meta = dicomHeader;
else
    meta = dicominfo('dicom_sample.dicm');
end

uid3 = dicomuid();

meta.PatientName.FamilyName = patientName;
meta.SeriesDescription = seriesDescription;
meta.KVP = kVp;

meta.Width = imgDimension;
meta.Height = imgDimension;
meta.PixelSpacing = [imageSize/imgDimension, imageSize/imgDimension];
meta.SliceThickness = sliceThickness;
meta.DistanceSourceToDetector = sourceToDetectorDistance;
meta.DistanceSourceToPatient = sourceToIsocenterDistance;

meta.WindowCenter = mean(windowLevel);
meta.WindowWidth = windowLevel(2) - windowLevel(1);
meta.RescaleIntercept = -1024;
meta.RescaleSlope = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write image(s) to DICOM file(s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MgMkdir(outputFolder, false);
for k = 1:size(img, 3)
    % calculate z position
    z = k*spacingBetweenSlices;
    meta.ImagePositionPatient = [0; 0; z];
    
    % some ID numbers
    meta.MediaStorageSOPInstanceUID = sprintf("%s.%d", uid3, k);
    meta.AcquisitionNumber = k;
    
    % write to file
    dicomwrite(int16(img(:,:,k)) - meta.RescaleIntercept, sprintf('%s/img_%d.dcm', outputFolder, k), meta);
end




end

