%
% This is a simple test script to exercise the detection code.
%
% It assumes that the template is exactly 16x16 blocks = 128x128 pixels.  
% You will want to modify it so that the template s in blocks is a
% variable you can specify in order to run on your own test examples
% where you will likely want to use a different sd template
%

% load a training example image
%Itrain = im2double(rgb2gray(imread('facetest/faces1.jpg')));
Itrain = im2double(rgb2gray(imread('signtest/test1.jpg')));
%have the user click on some training examples.  
% If there is more than 1 example in the training image (e.g. faces), you could set nclicks higher here and average together
nclick = 1;
figure(1); clf;
imshow(Itrain);
[x,y] = ginput(nclick); %get nclicks from the user

%compute 8x8 block in which the user clicked
%modify s
s = 16;
blockx = round(x/8);
blocky = round(y/8); 

%visualize image patch that the user clicked on
% the patch shown will be the s of our template
% since the template will be 16x16 blocks and each
% block is 8 pixels, visualize a 128pixel square 
% around the click location.
figure(2); clf;
%mod = 2;
for i = 1:nclick
  %patch = Itrain(8*blocky(i)+(-63:64),8*blockx(i)+(-63:64));
  ns = (-s * 8) + 1;
  patch = Itrain(8*blocky(i)+(ns:s*8),8*blockx(i)+(ns:s*8));
  figure(2); subplot(3,2,i); imshow(patch);
end

% compute the hog features
f = hog(Itrain);

% compute the average template for the user clicks
postemplate = zeros(s*2,s*2,9);%zeros(16,16,9);
for i = 1:nclick
  ns = -s + 1;
  postemplate = postemplate + f(blocky(i)+(ns:s),blockx(i)+(ns:s),:); 
end
postemplate = postemplate/nclick;


% TODO: also have the user click on some negative training
% examples.  (or alternately you can grab random locations
% from an image that doesn't contain any instances of the
% object you are trying to detect).

nnclick = 2;
figure(3); clf;
imshow(Itrain);
[xx,yy] = ginput(nnclick); %get nclicks from the user
ns = 16;
nblockx = round(xx/8);
nblocky = round(yy/8); 
figure(4); clf;

for i = 1:nnclick
  %patch = Itrain(8*blocky(i)+(-63:64),8*blockx(i)+(-63:64));
  npatch = Itrain(8*nblocky(i)+(-ns*8+1:ns*8),8*nblockx(i)+(-ns*8+1:ns*8));
  figure(4); subplot(3,2,i); imshow(npatch);
end
% compute the hog features
ff = hog(Itrain);

% compute the average template for the user clicks
negtemplate = zeros(ns*2,ns*2,9);
for i = 1:nclick
  negtemplate = negtemplate + ff(nblocky(i)+(-ns+1:ns),nblockx(i)+(-ns+1:ns),:); 
end
negtemplate = negtemplate/nnclick;


% our final classifier is the difference between the positive
% and negative averages
template = postemplate - negtemplate;


%
% load a test image
%
%Itest = im2double(rgb2gray(imread('facetest/faces1.jpg')));
%Itest = im2double(rgb2gray(imread('facetest/faces2.jpg')));
%Itest = im2double(rgb2gray(imread('facetest/faces3.jpg')));
%Itest = im2double(rgb2gray(imread('facetest/faces4.jpg')));
%Itest = im2double(rgb2gray(imread('facetest/faces5.jpg')));

%Itest = im2double(rgb2gray(imread('signtest/test0.jpg')));
%Itest = im2double(rgb2gray(imread('signtest/test1.jpg')));
%Itest = im2double(rgb2gray(imread('signtest/test2.jpg')));
%Itest = im2double(rgb2gray(imread('signtest/test3.jpg')));
%Itest = im2double(rgb2gray(imread('signtest/test4.jpg')));
Itest = im2double(rgb2gray(imread('signtest/test5.jpg')));
%Itest = im2double(rgb2gray(imread('signtest/test6.jpg')));

% find top 8 detections in Itest
ndet = 4;
[x,y,score] = detect(Itest,template,ndet);
ndet = length(x);

%display top ndet detections
figure; clf; imshow(Itest);
for i = 1:ndet
  % draw a rectangle.  use color to encode confidence of detection
  %  top scoring are green, fading to red
  hold on; 
  %h = rectangle('Position',[x(i)-64 y(i)-64 128 128],'EdgeColor',[(i/ndet) ((ndet-i)/ndet)  0],'LineWidth',3,'Curvature',[0.3 0.3]);
  h = rectangle('Position',[x(i)-s*8 y(i)-s*8 s*8*2 s*8*2],'EdgeColor',[(i/ndet) ((ndet-i)/ndet)  0],'LineWidth',3,'Curvature',[0.3 0.3]);
  hold off;
end


