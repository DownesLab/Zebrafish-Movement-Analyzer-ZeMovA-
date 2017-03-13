function points = getPoints(img,bodyDist)
% img : The input image
% points : The set of head, body and tail points
    headR=detectHeadRegion(img);
    img =preProcess(img,0.955,100);
    se=strel('disk',1);
    img=imclose(img,se);
    skel=bwmorph(skeleton(img)>25,'skel',Inf);
    points.head=detectHeadPoint(headR,skel,img);
    if isequal(points.head,[0,0])
        return;
    end
    [bdRC,tailRC]=detectBodyTail(points.head,skel,bodyDist);
    points.body=bdRC;
    points.tail=tailRC;
    if isequal(bdRC,[0 0])
        return;
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






function dImg=detectHeadRegion(img)
% get a rough idea of the head region
% erode twice using two different structuring element sizes,
% then sharpen the image, filter it using a gaussian filter and
% finally binarize it.
% dImg : A mask for the head region
% img : The input image 
        img=im2double(img); % Double required for imbinarize (threshold should be in double)
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


function hp=detectHeadPoint(headRegion,skel,img)
%     approach is to compute the geodesic distance transform with
%     headRegion as seed and then find the endpoint with the min value
% hp : The head point
% headRegion : The region determined by detectHeadRegion
% skel : The skeleton of the image
% img : The input image
    [dmap, endCR, branchCR]=anaskel(skel); %determine the end and branch points
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