  %
  % morphing script
  %
  clear
  % load in two images...
  %I1 = im2double(imread('switch.jpg'));
  %I2 = im2double(imread('psv.jpg'));
  I1 = im2double(imread('face1.jpg'));
  I2 = im2double(imread('face2.jpg'));
  % get user clicks on keypoints using either ginput or cpselect tool
  imshow(I1);
  [x1, y1] = getpts;
  %[x1, y1] = cpselect(I1, I2);
  
  imshow(I2);
  [x2, y2] = getpts;
  %[x2, y2] = cpselect;
  % the more pairs of corresponding points the better... ideally for 
  % faces ~20 point pairs is good include several points around the
  % outside contour of the head and hair.
  save test.mat x1 y1 x2 y2
  % you may want to save pts_img1 and pts_img2 out to a .mat file at
  % this point so you can easily reload it without having to click
  % again. 
  
  pts_img1(1,:) = transpose(x1);
  pts_img1(2,:) = transpose(y1);
  pts_img2(1,:) = transpose(x2);
  pts_img2(2,:) = transpose(y2);
  % append the corners of the image to your list of points
  % this assumes both images are the same size and that your
  % points are in a 2xN array
  
  [h,w,~] = size(I1);  
  %4 corner added
  pts_img1 = [pts_img1 [0 0]' [w 0]' [0 h]' [w h]'];
  pts_img2 = [pts_img2 [0 0]' [w 0]' [0 h]' [w h]'];
  
  % generate triangulation 
  %pts_halfway = 0.5*pts_img1 + 0.5*pts_img2;
  tri = delaunay(x1,y1);
  tri2= delaunay(x2,y2);

  % now produce the frames of the morph sequence
  frames = 5;
  for fnum = 1:frames %originally 61
    t = (fnum-1)/frames;

    % intermediate key-point locations
    pts_target = (1-t)*pts_img1 + t*pts_img2;                

    %warp both images towards target shape
    I1_warp = warp(I1,pts_img1,pts_target,tri);              
    I2_warp = warp(I2, pts_img2, pts_target, tri2);

    % blend the two warped images
    Iresult = (1-t)*I1_warp + t*I2_warp;                     

    % display frames
    figure(1); clf; imagesc(Iresult); axis image; drawnow;   

    subplot(1,2,1);
    imagesc(I1); axis image; hold on;
    triplot(tri,pts_img1(1,:),pts_img1(2,:),'r','linewidth',2);
    
    subplot(1,2,2);
    imagesc(I2); axis image; hold on;
    triplot(tri,pts_img2(1,:),pts_img2(2,:),'r','linewidth',2);
    axis image; drawnow;
    
    % alternately save them to a file to put in your writeup
    imwrite(Iresult,sprintf('frame_%2.2d.jpg',fnum),'jpg');   
  end
