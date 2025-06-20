img1 = 'cropped_output_folder/piece_0_0.png'; % First image (R0,C0)
img2 = 'cropped_output_folder/piece_0_1.png'; % Second image (R0,C1)
img3 = 'cropped_output_folder/piece_1_0.png'; % Third image (R1,C0)

% Read images
template = double(rgb2gray(imread(img1)));
imageh = double(rgb2gray(imread(img2)));
imagev = double(rgb2gray(imread(img3)));

size(imread(img1))
size(imread(img2))
size(imread(img3))

% Compute normalized cross-correlation (horizontal)
% Includes logic to ensure normxcorr2 runs as piece_0_0 must be a smaller or equal sized image to its neighbors
%Creates row vectors for the offset of the images
if size(imageh) >= size(template) 
    C_h = normxcorr2 (template, imageh);
    [max_corr, idx] = max(C_h(:));
    [yh_peak, xh_peak] = ind2sub(size(C_h), idx);
    h_offset = [size(template,2) - xh_peak, size(template,1) - yh_peak];
else 
    C_h = normxcorr2 (imageh, template);
    [max_corr, idx] = max(C_h(:));
    [yh_peak, xh_peak] = ind2sub(size(C_h), idx);
    h_offset = (-1)*[size(template,2) - xh_peak, size(template,1) - yh_peak];
end

% Computer normalized cross-correlation (vertical)
% Includes logic to ensure normxcorr2 runs as piece_0_0 must be a smaller or equal sized image to its neighbors
% Creates row vectors for the offset of the images
if size(imagev) >= size(template)
    C_v = normxcorr2 (template, imagev);
    [max_corr, idx] = max(C_v(:));
    [yv_peak, xv_peak] = ind2sub(size(C_v), idx);
    v_offset = [size(template,2) - xv_peak, size(template,1) - yv_peak];
else
    C_v = normxcorr2 (imagev, template);
    [max_corr, idx] = max(C_v(:));
    [yv_peak, xv_peak] = ind2sub(size(C_v), idx);
    v_offset = (-1)*[size(template,2) - xv_peak, size(template,1) - yv_peak];
end

disp(h_offset)
disp(v_offset)

figure;
imagesc(C_h);
colormap('jet');     % Or 'gray', 'hot', etc.
colorbar;
title('Horizontal Cross-Correlation Output');
xlabel('X-axis (shift)');
ylabel('Y-axis (shift)');

figure;
imagesc(C_v);
colormap('jet');     % Or 'gray', 'hot', etc.
colorbar;
title('Vertical Cross-Correlation Output');
xlabel('X-axis (shift)');
ylabel('Y-axis (shift)');