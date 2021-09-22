%??????? ??? ????? ? ???? ?????
%?????????? fractal_wrapper
%??????? ??? ? ???? ??????? ???? ? ?????????
%files = dir('test\*.tiff');
%? ?????? ?????? ??? ????? ? ???????? test
%?????? ??? ???????? ???? 
%???????? ??????? ??? ?????? ???????? ? ???????? ???? results_????_?????.xls, ??? ????? ????? ?? ???_???????? ???????????_???????????

tStart = tic;   

files = dir('5x_frsn_5_10_lat_b\*.tif');

c = fix(clock);
xls_name = sprintf('fractals_%02d_%02d_%02d_%02d_%02d.xls',c(2),c(3),c(4),c(5),c(6));

results = cell(360,100);
t=0;
count_cell_col=1;
count_cell_num =1;
results{count_cell_num, count_cell_col} = ('filename');
%results{count_cell_num, count_cell_col+1}=average_dim;

for angle_r=1:7
     results{count_cell_num, count_cell_col+2} =('dim %angle_r');
     results{count_cell_num, count_cell_col+9}=('r^2 %angle_r');
     count_cell_col=count_cell_col+1;
end

count_cell_col=1;
count_cell_num =1;

for j=1:numel(files)
    fprintf('%s\n',files(j).name);
    image_nr = imread (fullfile(files(j).folder,files(j).name));
 
 
    
    % the image is read and first its changed to grayscale image and then to 
% black and white

% tic
% angle = 0;

count_cell_col=3;
count_cell_num =j+1;
results{count_cell_num, 1} = files(j).name;
% image_crop = imcrop(image_orig, [750 0 255 256]); % xtop ytop width height
image_crop = image_nr;
% figure;

% image=rgb2gray(image_crop);
image_crop_blue = image_crop(:,:,3);


% [~,threshold] = edge(image_crop_blue,'sobel');
% fudgeFactor = 0.5;
% BWs = edge(image_crop_blue ,'sobel',threshold * fudgeFactor);
% imshow(BWs);
% imshow(edge(imbinarize(image_crop_blue),'canny'));

image = imbinarize(image_crop_blue);
%global imfilled
imfilled = imfill(image,'holes');
% figure;


f = regionprops(imfilled,{'Centroid','Orientation','MajorAxisLength','MinorAxisLength'});
max_axes = 0;
max_index = 1;
for i=1:numel(f)
    if (f(i).MajorAxisLength + f(i).MinorAxisLength) > max_axes
        max_axes = (f(i).MajorAxisLength + f(i).MinorAxisLength);
        max_index = i;
    end
end
rotation_angle = -f(max_index).Orientation;


image_rotated = imrotate(image_crop, rotation_angle);

image_r = image_rotated; 
image_rotated_red = image_rotated(:,:,1);
BW = imbinarize(image_rotated_red, 'adaptive');
BW1 = bwmorph(BW,'skel',Inf);


image_r = image_nr;   
sum_dim = 0;
  
    %image_nr = imread(fullfile(files(i).folder,files(i).name));
    for angle_r=0:15:90
        image_r = imrotate(image_nr, angle_r);
        
        %BW3 = imrotate(BW1, angle_r);
        %imshow(BW3)
   
    [dim, r_sq_d] = fractal_dimension_rotate_0_90_average(image_r, t, max_index);
    %results{count_cell_num,count_cell_col} = angle_r;
    results{count_cell_num,count_cell_col} = dim;
    sum_dim = sum_dim + dim;
    results{count_cell_num,count_cell_col+7} = r_sq_d;
    %results{count_cell_num,2+count_cell_col} = files(j).name;
    count_cell_col = count_cell_col+1;
    

    
    end
    
    average_dim= sum_dim/7;
    results{count_cell_num, 2}=average_dim;
   
    count_cell_num =count_cell_num + 1;
    
    xlswrite(xls_name, results);
end


%plot (cell2mat(results(:,1)),cell2mat(results(:,2)), 'LineWidth',2)

%sheet=i;
%xlswrite(xls_name, results, sheet);


tEnd = toc(tStart) ; 
