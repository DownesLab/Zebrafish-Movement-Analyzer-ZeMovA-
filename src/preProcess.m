function [Img] = preProcess(Img, bThresh, minPixel)
%PREPROCESS Function to remove noise and probe from the video and threshold
%the image
%   This function converts the image into a binary representatioin, removes
%   all the elements touching the border of the image (Mainly useful for
%   noise and autoremoval of probe). Img is the image, bThresh is the
%   threshold used for converting the image to binary and minPixel is the
%   minimum number of pixels that any connected component must have
%     Img=rgb2gray(Img);
    Img=imcomplement(Img); 
    Img=imclearborder(Img,4);
    Img=imcomplement(Img);
    Img=imbinarize(Img,bThresh);
    Img=imcomplement(Img);
    BWdfill = imfill(Img, 'holes');
    Img=bwareaopen(Img,minPixel);
end

