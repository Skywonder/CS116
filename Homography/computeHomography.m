function H = computeHomography(x1,y1,x2,y2)

% H = computeHomography(x1,y1,x2,y2)
%   Solves for homography H which maps (x1,y1) to (x2,y2)
%
%  input: coordinates for N pairs of points
%
%    x1 : Nx1 vector containing x coordinates
%    y1 : Nx1 vector containing y coordinates
%    x2 : Nx1 vector containing x coordinates
%    y2 : Nx1 vector containing y coordinates
%
%  output:
%    H  : 3x3 transformation matrix that maps
%         performs the mapping from 1->2
%
% number of points
N = size(x1,1);
% some simple checks on the inputs
assert(size(x1,2)==1,'x1 should be an Nx1 vector but second dimension is not 1');
assert(size(y1,2)==1,'y1 should be an Nx1 vector but second dimension is not 1');
assert(size(x2,2)==1,'x2 should be an Nx1 vector but second dimension is not 1');
assert(size(y2,2)==1,'y2 should be an Nx1 vector but second dimension is not 1');
assert(all(size(x1,1)==size(y1,1)),'y1 is not the same size as x1');
assert(all(size(x1,1)==size(x2,1)),'x2 is not the same size as x1');
assert(all(size(x1,1)==size(y2,1)),'y2 is not the same size as x1');
assert(N>=4,'At least 4 point pairs are needed to estimate a homography');

A = zeros(2*N,9);
for i= 1:N
     A((2*i-1):2*i,:) = [-x1(i,1), -y1(i,1),1*-1, 0, 0, 0, x1(i,1)*x2(i,1), y1(i,1)*x2(i,1), x2(i,1); 0, 0, 0, -x1(i,1), -y1(i,1), -1.0, x1(i,1)*y2(i,1), y1(i,1)*y2(i,1), y2(i,1)];
end
[~,~,V] = svd(A);
temp_H = V(:,9);
H = reshape(temp_H, [3,3])';

end





