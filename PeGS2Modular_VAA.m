function PeGS2Modular_VAA(fileParams, moduleParams) %missing verbose

if exist('fileParams', 'var' ) == 0
    fileParams=struct;
end

% if exist('verbose', 'var' ) == 0
%    verbose = true;
% end

if ~exist('moduleParams', 'var')
    pdParams = struct;
    caParams = struct;
    cdParams = struct;
    % dsParams = struct;
    % amParams = struct;
else
    if isfield(moduleParams, 'pdParams') ==1
        pdParams = moduleParams.pdParams;
    else
        pdParams = struct;
    end

    if isfield(moduleParams, 'caParams') ==1
        caParams = moduleParams.caParams;
    else
        caParams = struct;
    end

    if isfield(moduleParams, 'cdParams') ==1
        cdParams = moduleParams.cdParams;
    else
        cdParams = struct;
    end

    % if isfield(moduleParams, 'dsParams') ==1
    %     dsParams = moduleParams.dsParams;
    % else
    %     dsParams = struct;
    % end
    % 
    % if isfield(moduleParams, 'pdParams') ==1
    %     amParams = moduleParams.amParams;
    % else
    %     amParams = struct;
    % end

end

% these are basic steps to run PeGS on the sample images

%% module to detect contacts between particles. Set parameters in cdParams structure

particleDetect(fileParams, pdParams);

%% module to automatically detect and track particles across a grid of images. Set parameters in caParams structure

canny_auto(fileParams, caParams);

%% module to consolidate tracking data from canny_auto 

preserveParticleID(fileParams)

%% module to detect contacts between particles. Set parameters in cdParams structure

contactDetect2(fileParams, cdParams);

%% module to solve the forces on the particles. Set parameters in dsParams structure


%diskSolve(fileParams, dsParams, verbose);


%% module create an adjacency matrix for all images in the data file. Set parameters in amParams structure

%adjacencyMatrix(fileParams, amParams, verbose);

fprintf(" \n PeGS2Modular_VAA Complete! \n")

return

end

%%%%%%%%%%%%%%%%%%%%%