
%
% load in keypoints for the two image sequences
%
% the variables "tcoords" and "ecoords" are 2xKxT arrays containing 
% the (x,y) coordintes for keypoints for Elvis Presley and Audrey 
% Hepburn's faces in the "tiffany" and "elvis" sequences.
%
% For example, tcoords(1,i,t) and tcoords(2,i,t) contains the
% x and y coordinates for the ith keypoint in frame t.
%
load keypoints.mat

% visualize the data
for t = 1:25
  % load in the frames
  %I1 = im2double(imread(sprintf('elvis/elvis_frames3/%2.2d.jpg',t)));
  I1 = im2double(imread(sprintf('elvis/elvis_frames3/%2.2d.jpg',t)));
  I2 = im2double(imread(sprintf('tiffany/tiffany_frames3/%2.2d.jpg',t)));

  figure(1); clf;

  subplot(1,2,1); imagesc(I1); axis image;
  hold on; plot(ecoords(1,:,t),ecoords(2,:,t),'.');

  subplot(1,2,2); imagesc(I2); axis image;
  hold on; plot(tcoords(1,:,t),tcoords(2,:,t),'.');

  drawnow;
end


%
% perform the face swap on each frame
%
for t = 1:25

  % load in the two frames
  I1 = im2double(imread(sprintf('elvis/elvis_frames3/%2.2d.jpg',t)));
  I2 = im2double(imread(sprintf('tiffany/tiffany_frames3/%2.2d.jpg',t)));

  % warp face from I1 to match face position in I2

  % to get a stable warping, triangulate the target coordinates
  pts_source = ecoords(:,:,t);
  pts_target = tcoords(:,:,t);
  tri1 = delaunay(pts_target(1,:),pts_target(2,:));
  [Iwarp1,tindex] = warp(I1,pts_source,pts_target,tri1);

  % since pixels outside the face aren't warped, the interp2 
  % function fills them with "NaN".  Convert those pixels to
  % black pixels
  Iwarp1(isnan(Iwarp1)) = 0;

  % build a feathered mask similar to the mosaic warping assignment
  mask = double(tindex~=0);

  % experiment with the appropiate setting of sigma to get a good
  % blending.  you will likely want to have a different sigma for
  % each swap since the faces are different sizes.
  sigma = 8;
  alpha = imgaussfilt(mask,sigma);

  % the blurred mask will have nonzero values outside the original
  % mask and will be ~0.5 on the boundary.  offset it so it goes to
  % zero on the boundary and scale so it still has a max of 1
  alpha = 2*(alpha-0.5);
  alpha = max(alpha,0);  %make sure alpha is still positive everywhere

  % now eliminate nonzero values outside the mask
  alpha(~mask) = 0;
 
  % blend Iwarp1 into I2.
  %for c = 1:3 %for each color channel
  %  I1swap(:,:,c) = (1-alpha2).*I1(:,:,c) + alpha2.*Iwarp2(:,:,c);
  %end

  %
  % now repeat the process but going back the other direction
  %
  pts_source = tcoords(:,:,t);
  pts_target = ecoords(:,:,t);
  tri2 = delaunay(pts_target(1,:),pts_target(2,:));
  [Iwarp2,tindex2] = warp(I2,pts_source,pts_target,tri2);
  Iwarp2(isnan(Iwarp2)) = 0;
  % build a feathered mask similar to the mosaic warping assignment
  mask2 = double(tindex2~=0);
  alpha2 = imgaussfilt(mask2,sigma);
  alpha2 = 2*(alpha2-0.5);
  alpha2 = max(alpha2,0);  %make sure alpha is still positive everywhere

  % now eliminate nonzero values outside the mask
  alpha2(~mask2) = 0;
  for c = 1:3
     I2swap(:,:,c) = (1-alpha).*I2(:,:,c) + alpha.*Iwarp1(:,:,c);
     I1swap(:,:,c) = (1-alpha2).*I1(:,:,c) + alpha2.*Iwarp2(:,:,c);
  end
  % 
  % visualize the results
  %
  figure(1); clf;

  subplot(2,2,1); imagesc(I1); axis image; axis off;
  title('The king of rock and roll');
  %hold on; triplot(tri1,ecoords(1,:,t),ecoords(2,:,t));

  subplot(2,2,2); imagesc(I2); axis image; axis off; 
  title('Breakfast at Tiffany''s');
  %hold on; triplot(tri2,tcoords(1,:,t),tcoords(2,:,t));

  subplot(2,2,3); imagesc(I1swap); axis image; axis off; 
  title('The queen of rock and roll');

  subplot(2,2,4); imagesc(I2swap); axis image; axis off; 
  title('Breakfast at Presly''s');

  drawnow;

  %
  % save out frames to include in your writeup
  %
 imwrite(Iresult,sprintf('face_frame_%2.2d.jpg',fnum),'jpg')

end

