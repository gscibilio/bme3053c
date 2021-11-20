% BME 3053C Final Project

% Authors: Gianna Scibilio, Sarah Parrett, Jenny Noa
% Group Members: Gianna Scibilio, Sarah Parrett, Jenny Noa
% Course: BME3053C Computer Applications for BME
% Term: Fall 2021
% J. Crayton Pruitt Family Department of Biomedical Engineering
% University of Florida
% Email: gianna.scibilio@ufl.edu
% November 15, 2021

%Identifying Gliomas through Computer Led MR image analysis

%This code uses image analysis, filtering, edge detection, and other
%techniques to identify gliomas within the brain, based off of MRI results
%that are inputted by the user. The outputs consist of the original MR
%image uploaded, with the glioma present (if any) highlighted in *insert
%color*, as well as a document consisting of the location estimate of the
%glioma, a size estimate of the glioma, and a basic treatment scope. 

%Below, you will find all of the code necessary for the program. Sample
%data is provided in the final report, and demonstrated in the project
%spotlight video. The entire data set can be found in GitHub.


clc; clear; close all;

%Input of the MR image to be analyzed
I = input('Filename of the image to be analyzed: ','s');

%Stops code if file doesn't exist
if isfile(I)~=1
    fprintf('This file does not exist');
    return;
end

%Prep Image for Filtering
I = imread(I);
subplot(3,3,1); imshow(I);
I = im2gray (I);

%Loading image into matlab and filtering for high contrast, allowing the
%glioma to be more easily identified

%Noise Reduction of Image
I = im2double(I);
%IDK about these numbers. They were just on the slides
sigma = 0.1;
ksize = 5;
In = I + randn(size(I))*sigma;
h = ones(ksize)/ksize^2;
Ic = conv2(In,h,'same');
subplot(3,3,2);imshow(Ic);

%Top-hat filtering for sharpness. Again numbers were just what I found on
%the Matworks site
se = strel('disk', 12);
If = imtophat(Ic,se);
If = imadjust(If);
subplot(3,3,3); imshow(If);

%Watershed Segmentation
gI = imgradient(If);
L = watershed(gI);
Lrgb = label2rgb(L);
subplot(3,3,4); imshow(Lrgb);

se2 = strel('disk',20);
Io = imopen(I,se2);

Ie = imerode(I,se2);
Iobr = imreconstruct(Ie,I);

Ioc = imclose(Io, se2);

%Rainbow Picture
Iobrd = imdilate(Iobr,se2);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
subplot(3,3,5); imshow(Iobrcbr);

fgm = imregionalmax(Iobrcbr);
subplot(3,3,6);imshow(fgm)

I2 = labeloverlay(If,fgm);
subplot(3,3,7);imshow(I2);

figure(2)
imshow(I);
figure (3);
imshow (I2);
%Comparison of inputted image to standard image (standard = no glioma 
%present). This allows us to identify if a glioma is present or not. If no 
%glioma is present, the code will end.


%The glioma will be highlighted using thresholding, in order to clearly see
%where the glioma is and identify attributes such as size and location.


%A rough size estimate of the glioma will be made, and a center point will
%be identified. 


%A rough location estimate of the glioma will be made by sectioning the
%image into quadrants, and identifying which quadrant the center of the
%glioma lies in.


%Based on the size and location of the glioma, a basic treatment scope will
%be calculated. Larger, more centralized gliomas will have a more
%complicated treatment requiring chemotherapy/radiation along with surgical
%removal, while smaller, less centralized gliomas can likely be treated
%with surgical removal.
