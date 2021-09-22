

function [dim, r_sq_d] = fractal_dimension_rotate_0_90_average(image_r, t, max_index)

% the image is read and first its changed to grayscale image and then to 
% black and white
%[folder, baseFileNameNoExt, extension] = fileparts(filename);
%subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.01 0.01]);

% tic
% angle = 0;

%image_orig=image_r;

% image_crop = imcrop(image_orig, [750 0 255 256]); % xtop ytop width height
%image_crop = image_orig;
%subplot(2,4,1)
%imshow(image_crop)
% figure;

% image=rgb2gray(image_crop);
%image_crop_blue = image_crop(:,:,3);


% [~,threshold] = edge(image_crop_blue,'sobel');
% fudgeFactor = 0.5;
% BWs = edge(image_crop_blue ,'sobel',threshold * fudgeFactor);
% imshow(BWs);
% imshow(edge(imbinarize(image_crop_blue),'canny'));

%image = imbinarize(image_crop_blue);
%global imfilled
%imfilled = imfill(image,'holes');
%subplot(2,4,2)
%imshow(imfilled);
% figure;


%s = regionprops(imfilled,{'Centroid','Orientation','MajorAxisLength','MinorAxisLength'});
%max_axes = 0;
%max_index = 1;
%for i=1:numel(s)
%    if (s(i).MajorAxisLength + s(i).MinorAxisLength) > max_axes
%        max_axes = (s(i).MajorAxisLength + s(i).MinorAxisLength);
%        max_index = i;
%    end
%end
%rotation_angle = -s(max_index).Orientation;
%angle = rem(rotation_angle,90);
%angle2 = 90 - rem(rotation_angle,90);
%s=s(max_index);

%min_axis_x = s.Centroid(1) + [s.MinorAxisLength/2 s.MinorAxisLength/2].*[cosd(angle2) -cosd(angle2)];
%min_axis_y = s.Centroid(2) + [s.MinorAxisLength/2 s.MinorAxisLength/2].* [-sind(angle2) sind(angle2)];

%maj_axis_x = s.Centroid(1) + [s.MajorAxisLength/2 s.MajorAxisLength/2].*[cosd(angle) -cosd(angle)];
%maj_axis_y = s.Centroid(2) + [s.MajorAxisLength/2 s.MajorAxisLength/2].* [sind(angle) -sind(angle)];

%hold on
%plot(maj_axis_x,maj_axis_y,'LineWidth',2,'Color','green');
%plot(min_axis_x,min_axis_y,'LineWidth',2,'Color','red');
%rotation_angle = 0;
image_orig=image_r;
image_crop = image_orig;
image_crop_blue = image_crop(:,:,3);
image = imbinarize(image_crop_blue);
imfilled = imfill(image,'holes');
image_rotated = image_crop;



image_rotated_blue =imfilled;
% check the orientation
% regionprops(image_rotated_blue, 'Orientation')
% getting the bounding box size

[ind_y,ind_x]=find(image_rotated_blue==1);
x_len = max(ind_x)-min(ind_x);
y_len = max(ind_y)-min(ind_y);
box_size_power = ceil(log2(max(x_len,y_len)));
box_size = 2^box_size_power;

%subplot(2,4,3)
%imshow(image_rotated_blue)
s = regionprops(image_rotated_blue,{'Centroid','Orientation','MajorAxisLength','MinorAxisLength'});
% s.Centroid - [s.MinorAxisLength/2 0]
hold on

s=s(max_index);
%plot([s.Centroid(1) s.Centroid(1)],[s.Centroid(2)-s.MinorAxisLength/2 s.Centroid(2)+s.MinorAxisLength/2],'LineWidth',2,'Color','red')
%plot([s.Centroid(1)-s.MajorAxisLength/2 s.Centroid(1)+s.MajorAxisLength/2],[s.Centroid(2) s.Centroid(2)],'LineWidth',2,'Color','green')
% figure

% add pixels to picture for it to be several sizes of bbox
image_size=size(image_rotated);

% TODO: proper bbox mounting (center of ellipse)
% avg_x = ceil(mean(ind_x));
% avg_y = ceil(mean(ind_y));
%avg_x = ceil( ( max(ind_x) - min(ind_x) ) / 2 + min(ind_x));
%avg_y = ceil( ( max(ind_y) - min(ind_y) ) / 2 + min(ind_y));

avg_x = round(s.Centroid(1))+t;
avg_y = round(s.Centroid(2));

bbox_x = avg_x - box_size/2;
bbox_y = avg_y - box_size/2;

pixels_to_add_x_pre = ceil(bbox_x/box_size)*box_size-bbox_x;
pixels_to_add_y_pre = ceil(bbox_y/box_size)*box_size-bbox_y;

image_size_x = image_size(2) + pixels_to_add_x_pre;
image_size_y = image_size(1) + pixels_to_add_y_pre;
% image_size(1) = image_size(1) + pixels_to_add_x_pre;
% image_size(2) = image_size(2) + pixels_to_add_y_pre;

pixels_to_add_x_post = ceil(image_size_x/box_size) * box_size - image_size_x;
pixels_to_add_y_post = ceil(image_size_y/box_size) * box_size - image_size_y;


% get red channel
image_rotated_red = image_rotated(:,:,1);
%subplot(2,4,4)
%imshow(image_rotated_red);
%hold on
%h = imshow(image_rotated_blue);
%alpha(h,0.5);
%plot([s.Centroid(1) s.Centroid(1)],[s.Centroid(2)-s.MinorAxisLength/2 s.Centroid(2)+s.MinorAxisLength/2],'LineWidth',2,'Color','red')
%plot([s.Centroid(1)-s.MajorAxisLength/2 s.Centroid(1)+s.MajorAxisLength/2],[s.Centroid(2) s.Centroid(2)],'LineWidth',2,'Color','green')
%rectangle('Position',[bbox_x bbox_y box_size box_size],'EdgeColor','r');
% figure

% pad image
% matlab stores image columnwise, not rowwise, so padding is by y,x and not
% by x,y
% pad pre
image_padded_red = padarray(image_rotated_red, [pixels_to_add_y_pre pixels_to_add_x_pre],0,'pre');
% pad post
image_padded_red = padarray(image_padded_red, [pixels_to_add_y_post pixels_to_add_x_post],0,'post');


% and blue image to draw it on top of grid
image_padded_blue = padarray(image_rotated_blue, [pixels_to_add_y_pre pixels_to_add_x_pre],0,'pre');
image_padded_blue = padarray(image_padded_blue, [pixels_to_add_y_post pixels_to_add_x_post],0,'post');



% now it's time to calculate the fractal dimension!
BW = imbinarize(image_padded_red, 'adaptive');
%subplot(2,4,5)
%imshow(BW);
rectangle('Position',[bbox_x+pixels_to_add_x_pre bbox_y+pixels_to_add_y_pre box_size box_size],'EdgeColor','r','LineWidth',2);
% figure
% skeletonize
BW3 = bwmorph(BW,'skel',Inf);
%subplot(2,4,6)
%imshow(BW3);
hold on
% figure
% draw the core
%im = imshow(image_padded_blue);
%alpha(im,0.5);


scale=zeros(1,box_size_power);
count=zeros(1,box_size_power);
[height,width,cols]=size(BW3);
image = BW3;
image = imcomplement(image);

for i=box_size_power:-1:1
    sf=2^i;
%     sepblockfun(image, [sf sf],'min');
    scale(1,i)=sf;
    count(1,i)=sum(sepblockfun(image,[sf sf],'min')==0,'all');
end
%for i=box_size_power:-1:1
    % scaling factors are taken as 2,4,8,16... 512. 

   % For each scaling factor, the total number of pieces are to be calculated,
   % and the number of pieces which contain the black dots (pixels) among them are to
   % be counted.

   % For eg, when the scaling factor is 2, it means the image is divided in to
   % half, hence we will get 4 pieces. And have to see how many of pieces
   % have the black dots. 
  % sf=2^i;
%    pieces=(width/sf)^2;
 %  pieces = width/sf*height/sf;
%   pieces_in_line = width/sf;
%   pieceWidth=sf;
%   pieceHeight=sf;

   %initially we assume, we have 0 black pieces
 %  blackPieces=0; 
   
   % Now we have to iterate through each pieces to see how many pieces have the
   % black dots (pixel) in it. We will consider the collection of pieces as
   % a matrix. We are counting from 0 for the ease of calculations.
%   for pieceIndex=0:pieces-1

       % row and column indices of each pieces are calculated to estimate the
       % xy cordinates of the starting and ending of each piece.
%       pieceRow=idivide(int32(pieceIndex), int32(pieces_in_line));
%       pieceCol=rem(pieceIndex,pieces_in_line);
    %   xmin=(pieceCol*pieceWidth)+1;
   %    xmax=(xmin+pieceWidth)-1;
  %     ymin=(pieceRow*pieceHeight)+1;
 %      ymax=(ymin+pieceHeight)-1;

       % each piece is extracted and stored in another array for
       % convenience.
%       eachPiece=image(ymin:ymax,xmin:xmax);
       %each piece obtained is plotted on a plot for getting a view 
       %of the splitting of the whole image.
       %subplot(sf,sf,pieceIndex+1), imshow(eachPiece);

       % now, we will check whether the piece has some black dots in it.
       % then the count of the black pieces will be incremented.
       %if (min(min(eachPiece))== 0)
        %   blackPieces=blackPieces+1;
       %end
      % if i==box_size_power
     %      rectangle('Position',[xmin ymin xmax ymax],'EdgeColor','r');
    %   end
   %end

   % the count of pieces which contains the black dots for a given scaling value 
   % will be obtained here and will be stored in the respective variables.
%    scale = 2^(box_size_power-i)
%    scale_factor = pieces_in_line;
   scale_factor = sf;
%    fprintf('%d\t->\t%d\n', sf, blackPieces);
%    scale(1,i)=2^i;

%     fprintf('%d\t->\t%d\n', scale_factor, blackPieces);
  % scale(1,i)=scale_factor;
 %  count(1,i)=blackPieces;
%end

%subplot(2,4,7);
%imshow(BW3);
%hold on
% draw the core
%im = imshow(image_padded_blue);
%alpha(im,0.5);
%for i=1:width/box_size*2
%    for j=1:height/box_size*2
%        rectangle('Position',[(i-1)*box_size/2 (j-1)*box_size/2 box_size/2 box_size/2],'EdgeColor','r');
%    end
%end

% Now the process is over, the graph is plotted and the fractal dimension
% is calculated using the 'ployfit' function.
%subplot(2,4,8)
scatter(log(scale),log(count),'filled');
hold on
res = polyfit(log(scale),log(count),1);

% time to count r^2 
r_sq_d_s = regstats(log(scale),log(count),'linear', 'rsquare');
r_sq_d_m = struct2cell (r_sq_d_s);
r_sq_d = r_sq_d_m {2,1};

dim = res(1) * -1;
% x_gr = linspace(max(0,min(log(scale))-1),max(log(scale))+1,50);
x_gr = linspace(min(log(scale)),max(log(scale))+1,50);
y_gr = res(1) * x_gr + res(2);
set(gca,'linewidth',2,'fontsize',16)
%plot(x_gr,y_gr,'LineWidth',2);
grid on
yticks ([0 : 1 : max(y_gr) ]);
xlabel('log(box count)','FontSize',16);
ylabel('log(box size)','FontSize',16);
axis([0 inf 0 inf]);
xticks ([0 : 1 : max(x_gr) ]);
set(gcf, 'Position', get(0, 'Screensize'));
%saveas(gcf, strcat(baseFileNameNoExt,'_plot.png'));
close(gcf);


% toc
% 

end