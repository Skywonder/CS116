filelist = dir('images/*.jpg');
for i=1:length(filelist) %for the number of image
     imname = ['images/' filelist(i).name]; %set the name for image
     nextim = imread(imname); %read the image
     nextim = im2double(nextim);
     
     if i == 1
         %set the base
         result = nextim;
     else
         %add all the colours together
         result = result + nextim;
     end
end

%average the colour
result = result/length(filelist);
figure;
imshow(result);
