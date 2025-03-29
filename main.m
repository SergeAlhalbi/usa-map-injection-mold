% Add path to core logic
addpath(fullfile('core'));

% Paths (relative)
imgPath = fullfile('assets', 'USA_Map.jpg');
outputDXFPath = fullfile('designs', 'USA_Map_Simplified.dxf');

% Parameters
tolerance = 0.001;
originX = 0; originY = 0;
desiredSize = 2.8;
invertImg = false;
useEdges = false;

% Run conversion
imgToDXF(imgPath, outputDXFPath, tolerance, originX, originY, desiredSize, invertImg, useEdges);