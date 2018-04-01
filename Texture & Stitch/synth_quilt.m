function output = synth_quilt(tindex,tile_vec,tilesize,overlap)
%
% synthesize an output image given a set of tile indices
% where the tiles overlap, stitch the images together
% by finding an optimal seam between them
%
%  tindex : array containing the tile indices to use
%  tile_vec : array containing the tiles
%  tilesize : the size of the tiles  (should be sqrt of the size of the tile vectors)
%  overlap : overlap amount between tiles
%
%  output : the output image

if (tilesize ~= sqrt(size(tile_vec,1)))
  error('tilesize does not match the size of vectors in tile_vec');
end

% each tile contributes this much to the final output image width 
% except for the last tile in a row/column which isn't overlapped 
% by additional tiles
tilewidth = tilesize-overlap;  

% compute size of output image based on the size of the tile map
outputsize = size(tindex)*tilewidth+overlap;


% 
% stitch each row into a separate image by repeatedly calling your stitch function
% 
newimage = zeros(tilesize, outputsize(2), outputsize(1));
for i = 1:size(tindex, 1)
    rimage = tile_vec(:, tindex(i, 1));
    rimage = reshape(rimage, tilesize, tilesize);
    for j = 2:size(tindex, 2)
        timage = tile_vec(:, tindex(i,j));
        timage = reshape(timage, tilesize, tilesize);
        rimage = stitch(rimage, timage, overlap);
    end;
    newimage(:,:,i) = rimage;
end
%
% now stitch the rows together into the final result 
% (I suggest calling your stitch function on transposed row 
% images and then transpose the result back)
%
for i = 1:size(tindex, 1)
    if(i == 1)
        output = transpose(newimage(:,:,1));
    else
        output = stitch(output, transpose(newimage(:,:,i)), overlap);
    end
end
output = transpose(output);

