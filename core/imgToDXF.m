function imgToDXF(imgPath, outputDXFPath, tolerance, originX, originY, desiredSize, invertImg, useEdges)
% imgToDXF Converts an image to a DXF file by extracting boundaries and writing polylines.
%
% USAGE:
%   imgToDXF(imgPath, outputDXFPath, tolerance, originX, originY, desiredSize, invertImg, useEdges)
%
% DESCRIPTION:
%   This function processes an input image and extracts its boundaries to generate a DXF file.
%   It applies binarization or edge detection, scales the coordinates, simplifies boundaries, and
%   writes them as polylines into a DXF file.
%
% INPUTS:
%   imgPath         - Path to the input image file (string)
%   outputDXFPath   - Path to save the generated DXF file (string)
%   tolerance       - Boundary simplification tolerance (scalar, higher = more simplification)
%   originX, originY - DXF coordinate offsets for positioning the output (scalars)
%   desiredSize     - Maximum dimension for scaling the DXF output (scalar, e.g., 2.8 inches)
%   invertImg       - Boolean flag; if true, inverts the image before processing
%   useEdges        - Boolean flag; if true, applies Canny edge detection instead of binarization
%
% OUTPUTS:
%   A DXF file is generated and saved at the specified output path.
%
% AUTHOR:
%   Serge Alhalbi - OSU
%

% Read image
img = imread(imgPath);

% Convert to grayscale if necessary
if size(img,3) == 3
    grayImg = rgb2gray(img);
else
    grayImg = img;
end

% Apply inversion if required
if invertImg
    grayImg = imcomplement(grayImg);
end

% Convert to binary or use edge detection
if useEdges
    bwImg = edge(grayImg, 'Canny'); % Use Canny edge detection
else
    bwImg = imbinarize(grayImg); % Convert to black and white
end

% Find image dimensions
[H, W] = size(bwImg);
cx = W / 2;
cy = H / 2;

% Calculate scale factor
max_dimension = max(W, H);
scale_factor = desiredSize / max_dimension;

% Find boundaries
[B, L] = bwboundaries(bwImg, 'noholes');

% Simplify boundaries (Even if tolerance is 0; still recuces size)
for k = 1:length(B)
    B{k} = reducepoly(B{k}, tolerance);
end

% Open DXF file for writing
fid = fopen(outputDXFPath, 'w');
fprintf(fid, '0\nSECTION\n2\nHEADER\n0\nENDSEC\n0\nSECTION\n2\nTABLES\n0\nENDSEC\n');
fprintf(fid, '0\nSECTION\n2\nBLOCKS\n0\nENDSEC\n0\nSECTION\n2\nENTITIES\n');

% Write each boundary as a polyline
for k = 1:length(B)
    boundary = B{k};
    fprintf(fid, '0\nPOLYLINE\n8\n0\n66\n1\n');

    for i = 1:size(boundary, 1)
        x_scaled = (boundary(i,2) - cx) * scale_factor + originX; % Apply scaling and origin offset
        y_scaled = -(boundary(i,1) - cy) * scale_factor + originY; % Apply scaling, origin offset, and flip Y
        fprintf(fid, '0\nVERTEX\n8\n0\n10\n%f\n20\n%f\n', x_scaled, y_scaled);
    end

    fprintf(fid, '0\nSEQEND\n');
end

% Close DXF file
fprintf(fid, '0\nENDSEC\n0\nEOF\n');
fclose(fid);

fprintf('DXF file saved as: %s\n', outputDXFPath);
end