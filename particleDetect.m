% particleDetect.m
% ------------------------------------------------------------------------------
% Detects circular particles across a grid of images using the Circular Hough Transform.
%
% Main Function:
%   particleDetect(fileParams, pdParams)
%
% Description:
%   Iterates through a grid of images (e.g., 'piece_row_col.png') and performs 
%   particle detection on each using circular Hough transform techniques.
%   Detected particles are filtered to remove overlapping detections, annotated 
%   if they touch image edges, and saved as center files for downstream analysis.
%
% INPUTS:
%   fileParams - Struct containing:
%       .topDir      : Root directory containing image and output folders
%       .imgDir      : Subdirectory under topDir containing input images
%       .particleDir : Subdirectory for saving particle center outputs
%
%   pdParams - Struct containing detection parameters:
%       .rows               : Number of rows in the image grid
%       .cols               : Number of columns in the image grid
%       .radiusRange        : Two-element vector specifying circle radius limits
%       .sensitivity        : imfindcircles sensitivity parameter (0-1)
%       .edgeThreshold      : Edge threshold for circle detection
%       .minCenterDistance  : Minimum distance between circle centers to avoid overlaps
%       .tol                : Tolerance for overlap suppression
%       .showFigures        : (Optional) Flag to show detection figures
%
% OUTPUT:
%   For each image, saves:
%       - '[piece_row_col]_centers.txt': Detected particle centers and edge flags
%       - 'particleDetect_params.txt': Parameters used during detection
%
% NOTES:
%   - Particles are marked as touching edges using codes: 
%       -1 (left), 1 (right), -2 (bottom), 2 (top), or 0 (none).
%   - Assumes image filenames follow the pattern: 'piece_ROW_COL.png'
%   - Designed to support downstream particle matching/tracking algorithms.
%
% DEPENDENCIES:
%   Requires Image Processing Toolbox for imfindcircles and viscircles.
%
% EXAMPLE USAGE:
%   fileParams.topDir = 'testdata';
%   fileParams.imgDir = 'images';
%   fileParams.particleDir = 'particles';
%   pdParams.rows = 3;
%   pdParams.cols = 3;
%   pdParams.radiusRange = [10, 30];
%   pdParams.sensitivity = 0.9;
%   pdParams.edgeThreshold = 0.1;
%   pdParams.minCenterDistance = 20;
%   pdParams.tol = 5;
%   pdParams.showFigures = true;
%   particleDetect(fileParams, pdParams);
% 
% Authors: [Vir Goyal, Arno Harden, Ashe Tanemura]
% Last updated: [6/20/2025]
% ------------------------------------------------------------------------------

function particleDetect(fileParams, pdParams)
    fprintf("\n")
    for a = 0:(pdParams.rows-1)
        for b = 0:(pdParams.cols-1)
            imagePath = fullfile(fileParams.topDir, fileParams.imgDir, ...
                                 sprintf('piece_%d_%d.png', a, b));
            fprintf('Processing %s\n', imagePath);
            detect(imagePath, pdParams, fileParams);
        end
    end
end

%% Helper Function: detect
% DESCRIPTION:
%   Performs particle detection on a single image using circular Hough transform.
%   Filters overlapping circles, identifies edge particles, saves particle data
%   and parameters, and optionally visualizes the detection.
%
% INPUTS:
%   imagePath - Path to the image to process
%   pdParams  - Particle detection parameters struct (see above)
%   fileParams - File path parameters struct (see above)

function detect(imagePath, pdParams, fileParams)

    % Read image and extract grayscale channel
    img = imread(imagePath);
    if size(img, 3) == 3
        grayImg = img(:,:,2);
    else
        grayImg = img;
    end

    % Find circles using parameters from pdParams
    [centers, radii] = imfindcircles(grayImg, pdParams.radiusRange, ...
        'Sensitivity', pdParams.sensitivity, ...
        'EdgeThreshold', pdParams.edgeThreshold, ...
        'Method', 'PhaseCode');

    % Filter overlapping circles
    if ~isempty(centers)
        originalCount = size(centers, 1);
        keepCircles = true(originalCount, 1);

        i = 1;
        while i <= originalCount
            if keepCircles(i)
                j = i + 1;
                while j <= originalCount
                    if keepCircles(j)
                        dist = norm(centers(i,:) - centers(j,:));
                        radii_sum = radii(i) + radii(j);
                        if dist < pdParams.minCenterDistance
                            if dist < (radii_sum - pdParams.tol)
                                keepCircles(j) = false; % Remove overlapping circle
                            end
                        end
                    end
                    j = j + 1;
                end
            end
            i = i + 1;
        end

        centers = centers(keepCircles, :);
        radii = radii(keepCircles);
        numRemoved = originalCount - size(centers, 1);
        if numRemoved > 0
            disp(['Removed ' num2str(numRemoved) ' overlapping circles.']);
        end
    end

    % Show detection figures if requested
    if isfield(pdParams, 'showFigures') && pdParams.showFigures
        figure; 
        subplot(1, 2, 1); imshow(img); title('Original Image');
        subplot(1, 2, 2); imshow(img); 
        title(['Detected: ' num2str(size(centers, 1)) ' circles']);
        viscircles(centers, radii, 'EdgeColor', "b");
    end

    % If circles found, classify edges and save results
    if ~isempty(centers)
        dtol = 10; % edge detection tolerance

        % Compute boundary positions
        lpos = min(centers(:,1) - radii);
        rpos = max(centers(:,1) + radii);
        upos = max(centers(:,2) + radii);
        bpos = min(centers(:,2) - radii);

        % Find particles touching edges
        lwi = centers(:,1) - radii <= lpos + dtol;
        rwi = centers(:,1) + radii >= rpos - dtol;
        uwi = centers(:,2) + radii >= upos - dtol;
        bwi = centers(:,2) - radii <= bpos + dtol;

        edges = zeros(length(radii), 1);
        edges(rwi) = 1;    % right edge
        edges(lwi) = -1;   % left edge
        edges(uwi) = 2;    % top edge
        edges(bwi) = -2;   % bottom edge

        particleData = [centers(:,1), centers(:,2), radii, edges];

        [~, fileName, ~] = fileparts(imagePath);
        mainOutDir = fileParams.topDir;
        detectOutDir = fullfile(mainOutDir, fileParams.particleDir);

        % Create directories if needed
        if ~exist(mainOutDir, 'dir'), mkdir(mainOutDir); end
        if ~exist(detectOutDir, 'dir'), mkdir(detectOutDir); end

        % Save particle centers
        centersFileName = fullfile(detectOutDir, [fileName '_centers.txt']);
        writematrix(particleData, centersFileName, 'Delimiter', ',');
        disp(['Centers data saved to: ' centersFileName]);

        % Save parameters used for detection
        paramsFileName = fullfile(detectOutDir, 'particleDetect_params.txt');

        params = struct();
        params.radiusRange = pdParams.radiusRange;
        params.sensitivity = pdParams.sensitivity;
        params.edgeThreshold = pdParams.edgeThreshold;
        params.minCenterDistance = pdParams.minCenterDistance;
        params.tol = pdParams.tol;
        params.dtol = dtol;
        params.boundaryType = 'rectangle';
        params.time = datestr(now);
        params.imgDir = fullfile(fileParams.topDir, fileParams.imgDir);

        fields = fieldnames(params);
        values = struct2cell(params);
        paramsData = [fields, values];

        writecell(paramsData, paramsFileName, 'Delimiter', 'tab');
        disp(['Parameters saved to: ' paramsFileName]);
    else
        text(size(img,2)/2-100, size(img,1)/2, 'No circles detected', ...
            'Color', 'red', 'FontSize', 14, 'BackgroundColor', 'black');
    end

    % Display used parameters
    disp('Parameters used:');
    disp(['Radius Range: [' num2str(pdParams.radiusRange(1)) ', ' num2str(pdParams.radiusRange(2)) ']']);
    disp(['Sensitivity: ' num2str(pdParams.sensitivity)]);
    disp(['Edge Threshold: ' num2str(pdParams.edgeThreshold)]);
    disp(['Minimum Center Distance: ' num2str(pdParams.minCenterDistance)]);
    disp(['Tolerance: ' num2str(pdParams.tol)]);
end