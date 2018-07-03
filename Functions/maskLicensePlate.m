function [ maskedImage, mask ] = maskLicensePlate( image )
%maskLicensePlate
%   Maskes out the license plate image of a picture. Returns -1 if no plate
%   can be found.
%   Requires dipImage to be running.

%% Constants
closeParam = 17;
erodeParam = 9;
minObjectSize = 300;
ratioLB = 0.02;
ratioUB = 0.04;

%% Mask out (possible) license plate
BW = createMaskHSV(image);

%% Convert to dipImage object, erode and close
dipObject = dip_image(BW, 'sfloat');
dipObject = threshold(dipObject, 'fixed', 1); 
dipObject = closing(dipObject, closeParam, 'rectangular'); % closes any holes in plates
dipObject = erosion(dipObject, erodeParam, 'rectangular'); % Erodes any small objects

%% Label image
labelledImage = label(dipObject, inf, minObjectSize, 0);

%% Measure
msr = measure(labelledImage,[],{'Size','Perimeter'},[],Inf,0,0);

if isempty(msr) % If no object detected
    maskedImage = -1;
    mask = -1;
else
    
areas = msr.size;
perimeters = msr.perimeter;
ratios = areas ./ (perimeters.^2);
noRatios = size(ratios, 2);
mask = cell(1, 1);
plateCount = 0;

%% Check if dimensions matches license plate description
for i = 1:noRatios
    if ratios(i) >= ratioLB && ratios(i) <= ratioUB
        plateCount = plateCount + 1;
        mask{plateCount, 1} = labelledImage == i;
    end
end

maskedImage = cell(plateCount, 1);

for i = 1:plateCount
    mask{i} = ~mask{i};
    image(mask{i}) = 0;
    maskedImage{i} = image;
end
end
end

