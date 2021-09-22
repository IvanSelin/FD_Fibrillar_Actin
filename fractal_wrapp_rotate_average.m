function fractal_wrapp_rotate_average(file_mask)
%Matlab function for measuring Minkovsky's fractal dimension of cellular
%fibrillar actin on a set of images.
%
%USAGE:
%
%      fractal_wrapp_rotate_average('*.tiff')
%
%in:
%
%
%   file_mask: A file mask describing set of files. Could point for a
%              signle file, set of files, files in subdirectory, etc.
%
%
%out:
%
%   An excel file with filename "fractals_MM_DD_HH_mm_SS.xls" will be
%            produced within the same directory.
%            It will have 2 columns: filename and dimension
%            A row with filename and fractal dimension of given image will
%            be inserted for every image specufied by the file_mask
%
%
%EXAMPLE 1: Process a single file.
%
%   fractal_wrapp_rotate_average('example.tiff')
%
%EXAMPLE 2: Process all .tiff files in current folder.
%
%   fractal_wrapp_rotate_average('*.tiff')
%
%EXAMPLE 3: Process all .tiff files in subdirectory foo.
%
%   fractal_wrapp_rotate_average('foo/*.tiff')
%
% Written by Ivan Selin and Alla Revittser, 2021

tStart = tic;

files = dir(file_mask);

c = fix(clock);
xls_name = sprintf('fractals_%02d_%02d_%02d_%02d_%02d.xls',c(2),c(3),c(4),c(5),c(6));

results = cell(360,100);
t=0;
count_cell_col=1;
count_cell_num =1;
results{count_cell_num, count_cell_col} = ('filename');
results{count_cell_num, count_cell_col+1}= ('dimension');

for j=1:numel(files)
    fprintf('%s\n',files(j).name);
    image_nr = imread (fullfile(files(j).folder,files(j).name));
    
    % advancing the cells counter for writing the result
    %count_cell_col=3;
    count_cell_num =j+1;
    
    
    % reading the image from file, changing it to grayscale and then to
    % black and white
    
    
    results{count_cell_num, 1} = files(j).name;
    image_crop = image_nr;
    % figure;
    
    % selecting the only the blue chanell (aka the core)
    image_crop_blue = image_crop(:,:,3);
    
    % binarizing the image
    image = imbinarize(image_crop_blue);
    % filling the holes for making a good round core
    imfilled = imfill(image,'holes');
    % figure;
    
    % determining the center of the core
    f = regionprops(imfilled,{'Centroid','Orientation','MajorAxisLength','MinorAxisLength'});
    max_axes = 0;
    max_index = 1;
    % finding the biggest ellipse
    for i=1:numel(f)
        if (f(i).MajorAxisLength + f(i).MinorAxisLength) > max_axes
            max_axes = (f(i).MajorAxisLength + f(i).MinorAxisLength);
            max_index = i;
        end
    end
    % getting the rotation angle of the core
    rotation_angle = -f(max_index).Orientation;
    
    % rotate image aligning by the core
    image_rotated = imrotate(image_crop, rotation_angle);
    
    % getting the red channel
    image_rotated_red = image_rotated(:,:,1);
    % binarizing it
    BW = imbinarize(image_rotated_red, 'adaptive');
    % building the skeleton (for debug purposes)
    % BW1 = bwmorph(BW,'skel',Inf);
    
    % setting the sum of fractal dimensions to 0 for this image
    sum_dim = 0;
    
    % rotating the image with step of 15 degrees
    for angle_r=0:15:90
        image_r = imrotate(image_nr, angle_r);
        
        %BW3 = imrotate(BW1, angle_r);
        %imshow(BW3)
        
        % calculating the FD for rotated image
        [dim, r_sq_d] = fractal_dimension_rotate_0_90_average(image_r, t, max_index);
        
        % summing up FD (for calculating average)
        sum_dim = sum_dim + dim;
        
        % code leftovers for outputting not just average FD, but FD by
        % angle
        
        %results{count_cell_num,count_cell_col} = angle_r;
        %     results{count_cell_num,count_cell_col} = dim;
        %     results{count_cell_num,count_cell_col+7} = r_sq_d;
        %count_cell_col = count_cell_col+1;
        
    end
    
    % calculating average FD
    average_dim=sum_dim/7;
    % writing it to result cell array
    results{count_cell_num, 2}=average_dim;
    
end

% writing the results to excel spreadsheet
xlswrite(xls_name, results);

% measuring end time, just in case
tEnd = toc(tStart) ;
