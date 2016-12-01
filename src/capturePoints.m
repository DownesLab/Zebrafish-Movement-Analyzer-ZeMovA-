h=figure('Position', [100, 00, 1300, 1000]);
prefix='a';
for  i = [1:1]
   videoSource = VideoReader(strcat('../Mittal share/',prefix,'_',int2str(i),'.avi'));
%    videoPlayqer = vision.VideoPlayer('Position', [100, 100, 1000, 1000]);
   k=1;
   I=readFrame(videoSource);
   I=rgb2gray(I);
   oI=I;
%    detect the head
   head=detectHead(I);
   
   
   I=preProcess(I,0.955,140);
   I=fillSmallHoles(I);
   
   
   se=strel('disk',1);
   I=imdilate(I,se);
   skel=bwmorph(skeleton(I)>35,'skel',Inf);
   oI=im2double(oI);
   k=imadd(oI,im2double(skel));
   
   prevI=I;
   while(hasFrame(videoSource))
%       Read the image and convert it to grayscale
        I=readFrame(videoSource);
        I=rgb2gray(I);
        originalI=I; %oI is a copy for I
        originalI=im2double(originalI);
        
%         Display the image
        subplot(2,3,1),subimage(I),title('original');
        
%       Detect the head and show it in a figure
        head=detectHead(I);
        subplot(2,3,2),subimage(imadd(im2double(I),im2double(head))),title('head');
        
%         Draw the skeleton
        
        I=preProcess(I,0.955,140);
        I=fillSmallHoles(I);
        skel=bwmorph(skeleton(I)>35,'skel',Inf);
        k=imadd(originalI,im2double(skel));
        subplot(2,3,3),subimage(k),title('skeleton');

        
        pause(1);
%                 pause(1);
        
        for j=[1:5]
           if hasFrame(videoSource)
            readFrame(videoSource);
           end
        end
%                 saveas(h,strcat('custom/',prefix,int2str(i),'_',int2str(k),'.jpg'));  
                k=k+1;
           end
end

function fillImg=fillSmallHoles(img)
    filled = imfill(img,'holes');
    holes=filled&~img;
%     identify big holes
    bigHoles=bwareaopen(holes,5);
    smallHoles=holes & ~bigHoles;
    fillImg= img | smallHoles;
end

function dImg=detectHead(img)   
        img=im2double(img);
        img=imcomplement(img);
        img=imclearborder(img,4);
        se=strel('square',5);
        img=imerode(img,se);
        se=strel('disk',3);
        img=imerode(img,se);
        img=imsharpen(img);
        img=imgaussfilt(img,1.2);
        [maxVal maxLoc]=max(img(:));
        dImg=imbinarize(img,maxVal-0.05);
end
