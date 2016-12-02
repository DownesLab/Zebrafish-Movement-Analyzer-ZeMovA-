h=figure('Position', [100, 00, 1300, 1000]);
prefix='a';
for  i = [1:10]
   videoSource = VideoReader(strcat('../Mittal share/',prefix,'_',int2str(i),'.avi'));
%    videoPlayqer = vision.VideoPlayer('Position', [100, 100, 1000, 1000]);
   k=1;
   I=readFrame(videoSource);
%    I=rgb2gray(I);
%    oI=I;
% %    detect the head
%    head=detectHead(I);
%    
%    
%    I=preProcess(I,0.955,140);
%    I=fillSmallHoles(I);
%    
%    
%    se=strel('disk',1);
%    I=imdilate(I,se);
%    skel=bwmorph(skeleton(I)>35,'skel',Inf);
%    oI=im2double(oI);
%    k=imadd(oI,im2double(skel));
   
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
        subplot(2,3,6),subimage(I),title('preprocessed');
%         I=fillSmallHoles(I);
        se=strel('disk',1);
        I=imclose(I,se);
        skel=bwmorph(skeleton(I)>25,'skel',Inf);
        k=imadd(originalI,im2double(skel));
        subplot(2,3,3),subimage(k),title('skeleton');
        
        k=imadd(k,im2double(head));
        subplot(2,3,4),subimage(k),title('joined');
        
        
        
        hp=headPoint(head,skel,I);
        z=originalI;
        z(hp(1,1),hp(1,2))=1;
        subplot(2,3,5),subimage(z);
        pause(5);
%                 pause(1);
        
        for j=[1:20]
           if hasFrame(videoSource)
            readFrame(videoSource);
           end
        end
%                 saveas(h,strcat('custom/',prefix,int2str(i),'_',int2str(k),'.jpg'));  
                k=k+1;
           end
end
function hp=headPoint(headRegion,skel,img)
    [dmap, endCR, branchCR]=anaskel(skel);
    endPoints=zeros(size(skel));
    endPoints(endCR)=1;
%     approach is to compute the geodesic distance transform with
%     headRegion as seed and then find the endpoint with the min value
    [headRgnRow, headRgnCol]=find(headRegion);
    D=bwdistgeodesic(img,headRgnCol,headRgnRow);
    headRC=[0 0];
    minDist=Inf;
    
    for i = [1:size(endCR,2)]
        if D(endCR(2,i),endCR(1,i))<minDist
            minDist=D(endCR(2,i),endCR(1,i));
            headRC(1,1)=endCR(2,i);
            headRC(1,2)=endCR(1,i);
        end
    end
    
    D=bwdistgeodesic(img,[headRC(1,2)],[headRC(1,1)]);
    headRC=[0 0];
    minDist=Inf;
    for j = [1:size(headRgnRow)]
        if D(headRgnRow(i),headRgnCol(i))<minDist
            minDist=D(headRgnRow(i),headRgnCol(i));
            headRC(1,1)=headRgnRow(i);
            headRC(1,2)=headRgnCol(i);
        end
    end
    hp=headRC;
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
