function rename_images (riimageFolder, riimageDestination, rows, cols, riimageFormat)
  
    imageFiles = dir(fullfile(riimageFolder, riimageFormat));
    
    % Load images
    [~, idx] = sort({imageFiles.name});
    imageFiles = imageFiles(idx);
    
    % Check that the number of images matches the grid size
    expectedCount = rows * cols; 
    if length(imageFiles) ~= expectedCount
        error('Number of images (%d) does not match grid size (%d x %d = %d)', ...
            length(imageFiles), rows, cols, expectedCount);
    end
    
    % Rename the images in the order the gantry takes them
    k = 1;
    for row = rows-1:-1:0  % Start from bottom (rows-1) up to 0
        if mod(rows - 1 - row, 2) == 0
            % Even-numbered row from bottom → Right to Left
            col_range = cols-1:-1:0;
        else
            % Odd-numbered row from bottom → Left to Right
            col_range = 0:cols-1;
        end
    
        for col = col_range
            oldFile = fullfile(riimageFolder, imageFiles(k).name);
            newName = sprintf('piece_%d_%d.png', row, col); % Unfortunately you have to change this line manually
            newFile = fullfile(riimageDestination, newName);
            movefile(oldFile, newFile);
            k = k + 1;
        end
    end
end