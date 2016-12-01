h=figure('Position', [100, 00, 1300, 1000]);
prefix='a';
for  i = [1:1]
   videoSource = VideoReader(strcat('../Mittal share/',prefix,'_',int2str(i),'.avi'));
%    videoPlayqer = vision.VideoPlayer('Position', [100, 100, 1000, 1000]);
    k=1;
   I=readFrame(videoSource);
   I=preProcess(I,0.955,140);
   prevI=I;
   while(hasFrame(videoSource))
        I=readFrame(videoSource);
        oI=I;
        subplot(2,3,1),subimage(I),title('original image');
        I=preProcess(I,0.955,140);
        pI=fillSmallHoles(I);
        subplot(2,3,2),subimage(I),title('preprocessed image');
        subplot(2,3,3);
        skel=bwmorph(skeleton(I)>35,'skel',Inf);
        imshow(skel),title('skeleton');
        oI=im2double(rgb2gray(oI));
        k=imadd(oI,im2double(skel));
        subplot(2,3,4),subimage(k);
        
        
         skel=bwmorph(skeleton(pI)>35,'skel',Inf);
         oI=im2double(oI);
        k=imadd(oI,im2double(skel));
        subplot(2,3,5),subimage(k);
        g=imadd(oI,im2double(I));
        subplot(2,3,6),subimage(g);
        
        
        
        pause(7);
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

function procSkel=removeCycle(skel)
    
end