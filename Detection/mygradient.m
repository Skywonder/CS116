function [mag,ori] = mygradient(I)
%
% compute image gradient magnitude and orientation at each pixel
%
%

%I = im2double(rgb2gray(imread('signtest/test1.jpg')));
%I = im2double(rgb2gray(imread('signtest/test2.jpg')));
%I = im2double(rgb2gray(imread('signtest/test3.jpg')));
%I = im2double(rgb2gray(imread('signtest/test4.jpg')));
%I = im2double(rgb2gray(imread('facetest/faces4.jpg')));
%I = im2double(rgb2gray(imread('facetest/faces5.jpg')));
assert(ndims(I)==2,'input image should be grayscale');

matrix_x = [-1,0,1;-2,0,2;-1,0,1];
transpose_x = transpose(matrix_x);
 
dx = imfilter(I, matrix_x, 'replicate');
dy = imfilter(I, transpose_x, 'replicate');

mag = sqrt(dx.^2 + dy.^2);
ori = atan2(dy, dx).*-180/pi;


%imagesc(mag)
%colormap jet
%colorbar
%title('Magnitude');


%imagesc(ori)
%colormap jet
%colorbar
%title('Orientation');


assert(all(size(mag)==size(I)),'gradient magnitudes should be same size as input image');
assert(all(size(ori)==size(I)),'gradient orientations should be same size as input image');
