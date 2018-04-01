function [result] = stitch(leftI,rightI,overlap);

% 
% stitch together two grayscale images with a specified overlap
%
% leftI : the left image of size (H x W1)  
% rightI : the right image of size (H x W2)
% overlap : the width of the overlapping region.
%
% result : an image of size H x (W1+W2-overlap)
%
if (size(leftI,1)~=size(rightI,1)); % make sure the images have compatible heights
  error('left and right image heights are not compatible');
end

% dummy code that produces result by 
% simply pasting the left image over the
% right image. replace this with your own
% code!
%get the left overlap
left_image_overlap = leftI(:, (size(leftI, 2) - overlap + 1):size(leftI, 2)); 
%get the right overlap
right_image_overlap = rightI(:, 1:overlap);
%get the midest part
mid_image_overlap = double(abs(left_image_overlap - right_image_overlap));
%run find path
findpath = shortest_path(mid_image_overlap);
%set new width
new_width = (size(leftI, 2) +size(rightI, 2) - overlap);
%create result for store
result = zeros(size(rightI, 1), new_width);
for i = 1:size(result, 1)
    k = findpath(i);
    for j = 1:size(result, 2)
        if j < ((size(leftI, 2) - overlap) + findpath(i));
            result(i,j) = leftI(i, j);
        else
            result(i,j) = rightI(i, k);
            k = k + 1;
        end;
    end;
end;
%result = [leftI rightI(:,overlap+1:end)];

end

