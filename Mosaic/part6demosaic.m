function demosaic

I = imread('IMG_1308.pgm');
I = im2double(I);
s = size(I);
W = s(1);
H = s(2);
figure(1); clf; imshow(I(1:W,1:H));
colorbar;
J = mydemosaic(I(1:W, 1:H));
figure(2);clf;imshow(J);
colorbar;


function[J] = mydemosaic(I)

A = size(I);
%give them cooresponding masks at positions
RMask = I.*repmat([1 0;0 0], (A(1)/2), (A(2)/2)); 
GMask = I.*repmat([0 1;1 0], (A(1)/2), (A(2)/2));
BMask = I.*repmat([0 0;0 1], (A(1)/2), (A(2)/2));

%create filters
Rfilter = [1 0 1; 0 0 0; 1 0 1]/4;

Gfilter = [0 1 0; 1 0 1; 0 1 0]/4;

Bfilter = [1 0 1; 0 0 0; 1 0 1]/4;

%applying Filters
RMask = RMask + imfilter(RMask, Rfilter);
RMask = RMask + imfilter(RMask, Gfilter);

BMask = BMask + imfilter(BMask, Bfilter);
BMask = BMask + imfilter(BMask, Gfilter);

%toss this in to balance the number of g
GMask = GMask + imfilter(GMask, Gfilter);

%toss in the color!!!
J(:,:,1)=RMask; 
J(:,:,2)=GMask; 
J(:,:,3)=BMask;

end

end