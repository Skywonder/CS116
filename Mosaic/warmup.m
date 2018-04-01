%CS116 by Kuan-Ping Chang 71018021

I = rgb2gray(imread('flower.jpg')); %from color to grayscale
I = im2double(I);
s = size(I);
x = s(2);
y = s(1);
rect = [(x/2)-50, (y/2)-50, 99,99];
A = imcrop(I, rect);

%4a
figure;
s = size(A);
num = s(1)*s(2);
nA = A(:);
nA = A(:)';
nA = reshape(A,[],1);
nA = reshape(A,1,[]);
x = sort(nA);
plot(x);
ylabel('Intensity');
xlabel('# of Entry');
title('4a')

%4b
figure;
hist(x, 32);
ylabel('# of Entry in bin');
xlabel('Intensity');
title('4b');

%4c
bA = zeros(s); %reading s
threshold = median(x);
bA(find(nA > threshold)) = 1;
figure, imshow(bA);
colorbar;
title('4c');

%4d
B = A - mean(x); %copy and create a new matrix called
B(B < 0) = 0; %any value below zero is set to zero
figure
imshow(B);
colorbar;
title('4d');

%4e
y = 1:6;
z = reshape(y, 3, 2);

%4f
x = min(min(A));%this will just show the min one from the results in min(A)
[r,c]= find(A == x);

%4g
v = [1 8 8 2 1 3 9 8]
sz = size(unique(v));
total_number = sz(2); %unique v returns all unique value in array 





