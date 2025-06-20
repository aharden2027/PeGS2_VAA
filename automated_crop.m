% ChatGPT automated cropping function

imagePath = 'uncropped_images/baby_boy.png';

auto_crop(imagePath, 'cropped_output_folder', 2, 2, .70)

function auto_crop(image_path, output_folder, rows, cols, overlap)
    % Read the image
    img = imread(image_path);
    [H, W, ~] = size(img);

    % Compute tile size
    tileH = round(H / (1 + (1 - overlap) * (rows - 1)));
    tileW = round(W / (1 + (1 - overlap) * (cols - 1)));

    % Compute stride
    strideH = round(tileH * (1 - overlap));
    strideW = round(tileW * (1 - overlap));

    % Generate exact starting positions
    y_starts = 1 + (0:(rows - 1)) * strideH;
    x_starts = 1 + (0:(cols - 1)) * strideW;

    % Ensure output folder exists
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    for yi = 1:length(y_starts)
        for xi = 1:length(x_starts)
            y = y_starts(yi);
            x = x_starts(xi);

            % Keep crop inside image bounds
            y_end = min(y + tileH - 1, H);
            x_end = min(x + tileW - 1, W);

            crop = img(y:y_end, x:x_end, :);

            % Save crop as piece_row_column (0-based)
            row_idx = yi - 1;
            col_idx = xi - 1;
            filename = fullfile(output_folder, sprintf('piece_%d_%d.png', row_idx, col_idx));
            imwrite(crop, filename);
        end
    end

    fprintf('Saved %d crops to %s\n', rows * cols, output_folder);
end