% Runscipt Sample for PeGS2_VAA

%% Dimensions of Mosiac
rows = 2;
cols = 2;

%% File Parameters
fileParams = struct();
fileParams.topDir      = 'testdata';    % project root (current folder)
fileParams.imgDir      = 'images';      % folder with piece_*.png
fileParams.imgReg      = 'piece_*.png'; % glob for images
fileParams.particleDir = 'particles';   % centres from particleDetect_AA
fileParams.cannyDir    = 'canny_output';% outputs from canny_auto
fileParams.contactDir  = 'contacts';    % where contact files go
fileParams.solvedDir = 'solved';        % output directory for solved force information

%% particleDetect Parameters
pdParams = struct();
pdParams.rows = rows;
pdParams.cols = cols;
pdParams.radiusRange = [100 250];
pdParams.sensitivity = 0.9724; 
pdParams.edgeThreshold = 0.05;
pdParams.minCenterDistance = 200;
pdParams.tol = 50;
pdParams.showFigures = false;

%% canny_auto Parameters
caParams = struct();
caParams.rows = rows;
caParams.cols = cols;
caParams.distanceThreshold = 30;
caParams.displayFigures = false;
caParams.debugMode = false;
caParams.totalImages = rows * cols;
caParams.visualizeParticles = false;

%% contactDetect2 Parameters
cdParams = struct();
cdParams.metersperpixel       = 0.007/160;  % your calibration
cdParams.fsigma               = 140;        % PE stress coefficient
cdParams.g2cal                = 100;        % g²→force calibration
cdParams.dtol                 = 10;         % neighbour distance tol (px)
cdParams.contactG2Threshold   = 0.5;        % minimal g² in contact area
cdParams.CR                   = 10;         % contact radius margin (px)
cdParams.imadjust_limits      = [0 0.65];   % contrast stretch for green ch.
cdParams.rednormal            = 2;          % red‑leak subtraction factor
cdParams.figverbose= true;                  % show figures & save JPGs

%% compile module parameters into their own structure to pass into PeGS2Modular_VAA
moduleParams = struct();
moduleParams.pdParams = pdParams;
moduleParams.caParams = caParams;
moduleParams.cdParams = cdParams;
%moduleParams.dsParams = dsParams;
%moduleParams.amParams = amParams;

PeGS2Modular_VAA(fileParams, moduleParams)
