function [dim, r_sq_d] = fractal_dimension_rotate_0_90_average(image_r, t, max_index)


image_orig=image_r;
image_crop = image_orig;
image_crop_blue = image_crop(:,:,3);
image = imbinarize(image_crop_blue);
imfilled = imfill(image,'holes');
image_rotated = image_crop;



image_rotated_blue=imfilled;
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

% padding the image for proper box alignment
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

% calculating the FD for all scale factors
for i=box_size_power:-1:1
    sf=2^i;
%     sepblockfun(image, [sf sf],'min');
    scale(1,i)=sf;
    count(1,i)=sum(sepblockfun(image,[sf sf],'min')==0,'all');
end

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

end