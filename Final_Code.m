% BME 3053C Final Project

% Authors: Gianna Scibilio, Sarah Parrett, Jenny Noa
% Group Members: Gianna Scibilio, Sarah Parrett, Jenny Noa
% Course: BME3053C Computer Applications for BME
% Term: Fall 2021
% J. Crayton Pruitt Family Department of Biomedical Engineering
% University of Florida
% Email: gianna.scibilio@ufl.edu, sparrett@ufl.edu
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


%Loading image into matlab and filtering for high contrast, allowing the
%glioma to be more easily identified


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
