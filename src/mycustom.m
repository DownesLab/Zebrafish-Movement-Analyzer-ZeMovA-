h=figure('Position', [100, 00, 1300, 1000]);
prefix='b';
for  i = [1:10]
   videoSource = vision.VideoFileReader(strcat('../Mittal share/',prefix,'_',int2str(i),'.avi'));
   videoPlayer = vision.VideoPlayer('Position', [100, 100, 1000, 1000]);
    k=1;
   I=step(videoSource);
   I=preProcess(I,0.955,140);
   prevI=I;
   while(~isDone(videoSource))
        I=step(videoSource);
       
        I=rgb2gray(I);
         oI=I;
        I=imcomplement(I);
        I=imclearborder(I,4);
        subplot(2,3,1),subimage(I),title('original image');
%         I=imgaussfilt(I,2.8);
%         subplot(2,3,6),subimage(I),title('gaussian smooth 3');
        
%         i2=imfill(I);
%         subplot(2,3,6),subimage(i2);
%         
        se=strel('square',5);
          I=imerode(I,se);
          subplot(2,3,2),subimage(I),title('erode once');

            
%           second erosion of disk
          se=strel('disk',3);
          J=imerode(I,se);
          
          subplot(2,3,3),subimage(J),title('eroded twice ');
          Y=J;
        Y=imsharpen(Y);
        subplot(2,3,4),subimage(Y),title('sharpened');
         I=imgaussfilt(Y,1.2);
%         diskFilter=fspecial('disk',3);
%         I=imfilter(Y,diskFilter);
        subplot(2,3,5),subimage(I),title('gaussian');
        b=max(I(:));
        c=imbinarize(I,b-0.05);
        subplot(2,3,6),subimage(c),title('max');
        subplot(2,3,5),subimage(imadd(oI,im2single(c))),title('added');
%         Y=imdilate(Y,se);
%         subplot(2,3,6),subimage(Y),title('dilated');




%         second erosion of square
%         se1=strel('square',1);
%         J=imerode(I,se1);
%         subplot(2,3,5),subimage(J);
%         

%       second erosion of line
%         se1=strel('line',4,0);
%         se2=strel('line',4,90);
%         J=imerode(I,se1);
%         subplot(2,3,5),subimage(J);
%         J=imerode(J,se2);
%         subplot(2,3,6),subimage(J);

        for j=[1:30]
           if ~isDone(videoSource)
            step(videoSource);
           end
        end
                saveas(h,strcat('custom/',prefix,int2str(i),'_',int2str(k),'.jpg'));  
                k=k+1;
           end
end