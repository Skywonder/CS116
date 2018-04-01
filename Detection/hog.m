function ohist = hog(I)
%
% compute orientation histograms over 8x8 blocks of pixels
% orientations are binned into 9 possible bins
%
% I : grayscale image of dimension HxW
% ohist : orinetation histograms for each block. ohist is of dimension (H/8)x(W/8)x9
%

[h,w] = size(I); %size of the input
h2 = ceil(h/8); %the size of the output
w2 = ceil(w/8);
nori = 9;       %number of orientation bins

[mag,ori] = mygradient(I);
ori = (ori./360).*pi;
thresh = 0.1*max(mag(:));  %threshold for edges


% separate out pixels into orientation channels
% you should divide up the range of edge orientations [-pi/2 , pi/2]
% into 9 equal sized bins.
% as a sanity check, we will make sure that every pixel gets
% assigned to exactly one orientation bin in the for loop below
pixelbincount = zeros(size(I));

ohist = zeros(h2,w2,nori);
iOri = -pi/2;
step = pi/9;
for i = 1:nori
  % create a binary image containing 1's for the pixels that are edges at this orientation
  B = zeros(h,w);
  for k = 1:(h*w)
    if mag(k) > thresh && (ori(k) >= iOri && ori(k) < (iOri + step))
     B(k) = 1;
    else
     B(k) = 0;
    end
  end
  iOri = iOri + step;
  % this is just for checking correctness
  pixelbincount = pixelbincount + B;

  % record which pix
  % sum up the values over 8x8 pixel blocks.
  chblock = im2col(B,[8 8],'distinct');  %useful function for grabbing blocks
                                         %sum over each block and store result in ohist
  ohist(:,:,i) = reshape(sum(chblock, 1), h2, w2);                     
end

% At this point, if each pixel has been included in exactly
% one orientation bin, then all the entries in pixelbincount
% should be == 1. If this assertion fails then you should 
% visualize pixelbincount, ori etc. to help debug.
%assert(all(pixelbincount(:)==1),'every pixel should appear in only a single bin');

% normalize the histogram so that sum over orientation bins is 1 for each block
%   NOTE: Don't divide by 0! If there are no edges in a block (ie. this counts sums to 0 for the block) then just leave all the values 0. 

for i = 1:nori
    k = sum(sum(ohist(:,:,i)), 2);
    if k ~= 0
        ohist(:,:,i) = ohist(:,:,i)/k;
    end
end
