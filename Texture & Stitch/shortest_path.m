function [path] = shortest_path(costs)

%
% given a 2D array of costs, compute the minimum cost vertical path
% from top to bottom which, at each step, either goes straight or
% one pixel to the left or right.
%
% costs:  a HxW array of costs
%
% path: a Hx1 vector containing the indices (values in 1...W) for 
%       each step along the path
%
%
%
pcost = zeros(size(costs)); %store the cost of each path
pcost(1,:) = costs(1,:);
for i = 2:size(pcost, 1)
    pcost(i, 1) = costs(i, 1) + min(pcost(i-1,1), pcost(i - 1, 2));
    for j = 2:size(pcost, 2) -1
        pcost(i, j) = costs(i, j) + min([pcost(i-1, j-1), pcost(i-1, j), pcost(i-1, j+1)]);

    end
    pcost(i, end) = costs(i, end) + min(pcost(i-1, end - 1), pcost(i-1, end));
end;

%backtracing
path = zeros(size(costs, 1), 1);
[c, index] = min(pcost(end, 1:end));
path(i, 1) = index;
for i = size(pcost,1)-1:-1:1
    for j = 1: size(c, 2)
        if (index > 1 & (pcost(i , index -1 )==min(pcost(i, index-1:min(index+1,size(costs, 2))))))
            index = index - 1;
        elseif(index < size(pcost, 2) & pcost(i, index + 1) == min(pcost(i, max(index - 1, 1): index + 1))); 
        end
        path(i, 1) = index;
    end
end

end