% load in images

% you may want to replace these with absolute paths to where you stored the images
%imnames = {'atrium/IMG_1347.JPG','atrium/IMG_1348.JPG','atrium/IMG_1349.JPG'};
%imnames = {'garden/DSC_0018.JPG', 'garden/DSC_0019.JPG', 'garden/DSC_0020.JPG'};
imnames = {'room/DSC_0018.JPG', 'room/DSC_0019.JPG', 'room/DSC_0020.JPG'};
nimages = length(imnames);
baseim = 1; %index of the central "base" image which 

for i = 1:nimages
  ims{i} = im2double(imread(imnames{i}));
  %resize the image to 1/4 resolution so things run quicker while debugging your code
  ims{i} = imresize(ims{i},0.25);
  
  ims_gray{i} = rgb2gray(ims{i});
  [h(i),w(i),~] = size(ims{i});
end

% get corresponding points between each image and the central base image
for i = 1:nimages
   if (i ~= baseim)
     %run interactive select tool to click corresponding points on base and non-base image
     [image1pt, image2pt] = cpselect(ims{baseim},ims{i},'Wait',true);

     %optionally, you can also automatically refine the user clicks using cpcorr
     image1pt = cpcorr(image1pt,image2pt,ims_gray{i},ims_gray{baseim});
     adPts{i} = image1pt;
     fdPts{i} = image2pt;
     
   end
end


%
% verify visually that the points are good by plotting them
% overlayed on the input images.  this is a useful step for
% debugging.
%
% here is some example code to plot some points for a pair
% of images, you will need to modify this based on how you are storing the
% points etc.
%
base_image = ims{baseim};
for i = 2:nimages
    input_image{i} = ims{i};
    x1{i} = adPts{i}(:,1);
    y1{i} = adPts{i}(:,2);
    x2{i} = fdPts{i}(:,1);
    y2{i} = fdPts{i}(:,2);

    subplot(2,1,1); 
    imshow(base_image);
    hold on;
    
    plot(x1{i}(1),y1{i}(1),'r*',x1{i}(2),y1{i}(2),'b*',x1{i}(3),y1{i}(3),'g*',x1{i}(4),y1{i}(4),'y*');
    subplot(2,1,2);
    imshow(input_image{i});
    hold on;
    plot(x2{i}(1),y2{i}(1),'r*',x2{i}(2),y2{i}(2),'b*',x2{i}(3),y2{i}(3),'g*',x2{i}(4),y2{i}(4),'y*');
end
%
% at this point it is probably a good idea to save the results of all your clicking
% out to a file so you can easily load them in again later on without having to 
% do the clicking again.
%

%save mypts.mat var1 var2 var3 ....
%save atrium.mat
%save garden.mat
save room.mat
% to reload the points:   load mypts.mat
%load atrium.mat
%load garden.mat
load room.mat
% estimate homography for each image

for i = 1:nimages
   if (i ~= baseim)
     H{i} = computeHomography(x2{i},y2{i},x1{i},y1{i});
   else
     % homography for base image is just the identity matrix
     % this lets us treat it in the same way we treat all the
     % other images in the rest of the code.
     H{i} = eye(3); %return size 3x3 matrix
   end
end

%
% compute where corners of each warped image end up
%
for i = 1:nimages
  %original corner coordinates based on h,w for each image
  cx = [1;1;w(i);w(i)];  
  cy = [1;h(i);1;h(i)];
 
  % now apply the homography to get the warped corner points
  [xwrap{i},ywrap{i}] = applyHomography(H{i},cx,cy);

end

% 
% find a bounding rectangle that contains all the warped image
%  corner points (e.g., using mins and maxes of the cx/ywrap)
%
% NOTE: I suggest rounding these coordinates to integral values
%   
ul_x = w(baseim); %minX
lr_x = -w(baseim); %maxX
lr_y = h(baseim); %minY
ul_y = -h(baseim); %maxY 

for i = 1:nimages
% upper left corner of bounding rectangle : minX, maxY
% lower right corner of bounding rectangle: maxX, minY
    if(min(xwrap{i}) < ul_x)
        ul_x = min(xwrap{i}); %min X
    end
    if(max(xwrap{i}) > lr_x)
        lr_x = max(xwrap{i}); %max X
    end
    if(max(ywrap{i}) > ul_y)
        ul_y = max(ywrap{i}); %max Y
    end
    
    if(min(ywrap{i}) < lr_y)
    lr_y = min(ywrap{i}); %min Y
    end
end
%generate a grid of pixel coordinates that range over the 
% bounding rectangle%

% NOTE: at this point you may wish to verify a few things:
%
% 1. the arrays xx and yy should have size [out_height, out_width]
% 2. the values in the array xx should range from ul_x to lr_x
% 3. the values in the array yy should range from ul_y to lr_y
%
[xx, yy] = meshgrid(ul_x:lr_x, lr_y:ul_y);
[wp hp] = size(xx);

% Use H and interp2 to compute colors in the warped image

for i = 1:nimages
   % warp the pixel grid
   [nX, nY] = applyHomography(inv(H{i}), xx(:), yy(:));
   clear Ip;
   rX = reshape(nX, wp, hp)';
   rY = reshape(nY, wp, hp)';
   % interpolate colors from the source image onto the new grid
   R = interp2(ims{i}(:,:,1), rX, rY, '*bilinear')';
   G = interp2(ims{i}(:,:,2), rX, rY, '*bilinear')';
   B = interp2(ims{i}(:,:,3), rX, rY, '*bilinear')';
   J{i} = cat(3,R,G,B);

   %interp2 puts NaNs outside the support of the warped image
   % let's set them to 0 so that they appear as black in 
   % our result

    alphaMask = 1 - isnan(J{i});
    h = fspecial('gaussian', 50, 0.5 );
    alpha{i} = imfilter(alphaMask, h, 'replicate');
    
    %replace value with 0
    mask{i} = ~isnan(R);
    J{i}(isnan(J{i})) = 0; 

   % also create a binary image that tells us which pixels
   % are valid (that lie inside the warped image)


end


% scale alpha maps to sum to 1 at every pixel location
sum = zeros(size(J{1}));
for i = 1:nimages
    sum = sum + alpha{i};
end
%average
for i = 1:nimages
    alpha{i} = alpha{i}./sum;
end

% finally blend together the resulting images into the final mosaic

K = zeros(size(J{1}));
for i = 1:nimages
    K = K + J{i}.*alpha{i};
end

% display the result
%figure(1); 


imagesc(K); axis image;
imshow(K);
% save the result to include in your writeup


%imwrite(J{1},'Base_A.jpg');
%imwrite(J{2},'Top_A.jpg');
%imwrite(J{3},'Bottom_A.jpg');
%imwrite(K,'Final_A.jpg');
%imwrite(J{1}, 'gMid_G.jpg');
%imwrite(J{2}, 'gTop_G.jpg');
%imwrite(J{3}, 'gBot_G.jpg');
%imwrite(K, 'Final_G.jpg');
imwrite(J{1}, 'Mid_R.jpg');
imwrite(J{2}, 'Top_R.jpg');
imwrite(J{3}, 'Bot_R.jpg');
imwrite(K, 'Final_R.jpg');