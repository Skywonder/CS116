function [I_target,tindex] = warp(I_source,pts_source,pts_target,tri)

%
% I_source : color source image  (HxWx3)
% pts_source : coordinates of keypoints in the source image  (2xN)
% pts_target : coordinates of where the keypoints end up after the warp (2xN)
% tri : list of triangles (triples of indices into pts_source)  (Kx3)
%       for example, the coordinates of the Tth triangle should be 
%       given by the expression:
%
%           pts_source(:,tri(T,:))
% 
%
% I_target : resulting warped image, same size as source image (HxWx3)
% tindex : HxW array of indices which specifies the index of the 
%          triangle for each each pixel of the resulting warped image 
%          (I_target).  If a pixel does not fall in any triangle, you
%          should set tindex to 0.
%
% 
%

% you may want to turn visualization off later on once you are
% done debugging this function so make it an option here.
DISPLAYVIS = true;  


% check inputs
[h,w,d] = size(I_source);
assert(d == 3)  % we only are going to deal with color images
num_tri = size(tri,1);
assert(size(tri,2)==3,'tri must be a Kx3 array');

% for debugging you may also wish to check that pts_source 
% and pts_target are both inside the dimensions of the image


% for each triangle, compute tranformation that 
% maps it to points in the source
T = zeros(3,3,num_tri); % tranformation matricies
for t = 1:num_tri
  %get coordinates for the 3 corners of each triangle
  T(:,:,t) = ttform(pts_target(:,tri(t,:)), pts_source(:,tri(t,:)));
end


% for each pixel in the target image, figure
% out which triangle it falls inside so we 
% know which transformation to use for those
% pixels
%
%  tindex(i,j) should contain a value in [1...num_tri]
%    which indicate what triangle contains pixel (i,j)
%
%  you can leave tindex(i,j) = 0 if pixel (i,j) doesn't
%  fall inside any triangle.
%    
tindex = zeros(h,w);
for t = 1:num_tri
  % get the 3 corners of this triangle t
  corners = pts_target(:,tri(t,:));

  % generate a binary mask image of size HxW which is 
  % 1 for pixels that are inside the triangle and 0 otherwise
  mask = poly2mask(corners(1,:),corners(2,:),h,w);
  tindex(mask) = t;
end


%
% visualize the result to make sure it looks reasonable. 
%

if (DISPLAYVIS)
  figure(1); clf;

  subplot(1,2,1);
  imagesc(I_source); axis image; hold on;
  triplot(tri,pts_source(1,:),pts_source(2,:),'g','linewidth',2);
  plot(pts_source(1,:),pts_source(2,:),'ko');
  title('source triangulation');

  subplot(1,2,2);
  imagesc(tindex); axis image; hold on;
  triplot(tri,pts_target(1,:),pts_target(2,:),'g','linewidth',2);
  plot(pts_target(1,:),pts_target(2,:),'ro');
  title('target triangulation');
end



% coordinates of pixels in target image we will assume 
% target image is same size as source
[xx,yy] = meshgrid(1:w,1:h);
Xtarg = [xx(:) yy(:) ones(h*w,1)]';

% now tranform target pixels back to 
% source image
Xsrc = zeros(size(Xtarg));
for t = 1:num_tri
  % find the indicies of pixels in triangle t using the tindex array 
  % computed previously
  ptind = find(tindex == t);

  % warp the coordinates of those pixels that belong to triangle t
  % using the corresponding transformation for triangle t
  Xsrc(:,ptind) = T(:,:,t)*Xtarg(:,ptind);
  %Xsrc(t,:) = transpose(T(:,:,t)*transpose(Xtarg(t,:)) );
end

% now we know where each point in the target 
% image came from in the source, we can interpolate
% to figure out the colors
R = interp2(I_source(:,:,1),Xsrc(1,:),Xsrc(2,:));
G = interp2(I_source(:,:,2),Xsrc(1,:),Xsrc(2,:));
B = interp2(I_source(:,:,3),Xsrc(1,:),Xsrc(2,:));

% reshape and assemble interpolated values
%I_target = zeros(h,w,3);
I_target(:,:,1) = reshape(R,h,w);
I_target(:,:,2) = reshape(G,h,w);
I_target(:,:,3) = reshape(B,h,w);

end





