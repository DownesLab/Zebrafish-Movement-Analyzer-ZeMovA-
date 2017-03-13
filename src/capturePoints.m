h=figure('Position', [100, 00, 1300, 1000]);
prefix='a';
for  i = [1 :1]
   videoSource = VideoReader(strcat('../Mittal share/',prefix,'_',int2str(i),'.avi'));
   frameCount=1;
   I=readFrame(videoSource);
   prevI=I;
   while(hasFrame(videoSource))
%       Read the image and convert it to grayscale
        I=readFrame(videoSource);
        I=rgb2gray(I);
        originalI=I; %oI is a copy for I
        originalI=im2double(originalI);
        
%         Display the image
%         subplot(2,3,1),subimage(I),title('original');
        
%       Detect the head and show it in a figure
        head=detectHead(I);
        subplot(2,3,2),subimage(imadd(im2double(I),im2double(head))),title('head');
        
%         Draw the skeleton
        
        I=preProcess(I,0.955,100);
         subplot(2,3,1),subimage(I),title('preprocessed');
%         I=fillSmallHoles(I);
        se=strel('disk',1);
        I=imclose(I,se);
        
        badSkel=bwmorph(I,'skel',Inf);
        subplot(2,3,5),subimage(imadd(originalI,im2double(badSkel))),title('originalSkel');
        
        
        skel=bwmorph(skeleton(I)>25,'skel',Inf);
        k=imadd(originalI,im2double(skel));
        subplot(2,3,3),subimage(k),title('skeleton');
        
        k=imadd(k,im2double(head));
        subplot(2,3,4),subimage(k),title('joined');
        
        
        mask=zeros(size(originalI));
        hp=headPoint(head,skel,I);
        if isequal(hp,[0 0])
            continue;
        end
        [bdRC,tailRC]=detectBodyTail(hp,skel,20);
        if isequal(bdRC,[0 0])
            continue;
        end
        z=originalI;
        mask(hp(1,1),hp(1,2))=1;
        mask(tailRC(1,1),tailRC(1,2))=1;
        mask(bdRC(1,1),bdRC(1,2))=1;
        se=strel('square',7);
        mask=imdilate(mask,se);
        subplot(2,3,6),subimage(imadd(z,im2double(mask)));
        
%         pause(1);
%                 pause(1);
        
%         for j=[1:1]
%            if hasFrame(videoSource)
%             readFrame(videoSource);
%            end
%         end
%                 saveas(h,strcat('custom/',prefix,int2str(i),'_',int2str(frameCount),'.jpg'));  
                frameCount=frameCount+1;
   end
end
function hp=headPoint(headRegion,skel,img)
    [dmap, endCR, branchCR]=anaskel(skel); %determine the end and branch points
%     approach is to compute the geodesic distance transform with
%     headRegion as seed and then find the endpoint with the min value
    [headRgnRow, headRgnCol]=find(headRegion);
    D=bwdistgeodesic(img,headRgnCol,headRgnRow); %compute geodesic transform from the head region
    headRC=[0 0];
    minDist=Inf;
    
    for i = [1:size(endCR,2)]%find the endpoint with min. geodesic distance 
        if D(endCR(2,i),endCR(1,i))<minDist
            minDist=D(endCR(2,i),endCR(1,i));
            headRC(1,1)=endCR(2,i);
            headRC(1,2)=endCR(1,i);
        end
    end
    
%     D=bwdistgeodesic(img,[headRC(1,2)],[headRC(1,1)]);
%     headRC=[0 0];
%     minDist=Inf;
%     for j = [1:size(headRgnRow)]
%         if D(headRgnRow(i),headRgnCol(i))<minDist
%             minDist=D(headRgnRow(i),headRgnCol(i));
%             headRC(1,1)=headRgnRow(i);
%             headRC(1,2)=headRgnCol(i);
%         end
%     end
    hp=headRC;
end

function [bodyRC,tailRC]=detectBodyTail(headPoint,skel,bodyDist)
% Function to determine the body and tail points for the larvae
% headPoint - the head of the larvae
% skel - the skeleton
% bodyDist - The distance from the head to the body point
    [dmap,endCR,branchCR]=anaskel(skel);  % get the end and branch points of the skeleton
    
    tailRC=[0 0]; %initialize tail coordinates to be 0,0
     D=bwdistgeodesic(skel,headPoint(1,2),headPoint(1,1)); %calculate the geodesic distance from the head
    if size(endCR,2)>1 %if there are less than 2 end point of the skeleton then the fish is in a loop
        maxDist=-Inf;
        for i = [1:size(endCR,2)] % find the endpoint which is the furthest from the head
            if D(endCR(2,i),endCR(1,i))>maxDist
                maxDist=D(endCR(2,i),endCR(1,i));
                tailRC(1,1)=endCR(2,i);
                tailRC(1,2)=endCR(1,i);
            end
        end
    end
    
    bodyRC=[0 0];
    %Select the body point after some threshold
    if ~isequal(tailRC,[0 0]) %if no tail was found, then skip
        if(length(find(D==bodyDist))==1)% if multiple points are equidistant then it might mean that there is a loop
            [bodyRC(1,1), bodyRC(1,2)]=find(D==bodyDist);
        end
    end
end
function fillImg=fillSmallHoles(img)
% function to fill the small holes in an image
    filled = imfill(img,'holes');% fill all holes
    
    holes=filled&~img; %determien the holes
%     identify big holes
    bigHoles=bwareaopen(holes,5);
    smallHoles=holes & ~bigHoles; 
    fillImg= img | smallHoles;
end

function dImg=detectHead(img)
% get a rough idea of the head region
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
