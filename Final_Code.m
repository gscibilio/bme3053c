% BME 3053C Final Project

% Authors: Gianna Scibilio, Sarah Parrett, Jenny Noa
% Group Members: Gianna Scibilio, Sarah Parrett, Jenny Noa
% Course: BME3053C Computer Applications for BME
% Term: Fall 2021
% J. Crayton Pruitt Family Department of Biomedical Engineering
% University of Florida
% Email: gianna.scibilio@ufl.edu, sparrett@ufl.edu
% November 15, 2021

%This is pretty close but doesn't work great unless youre really good at picking points.
%We might need to edit the filtering a bit before we chose points to fix this but thresholding beforehand does not work as I've tried that. I can try more methods later possibly
%To Do: Dot where we select points, Maybe allow a zoom?, Change color of highlight and put unto original, Other things like sizing and stuff
%STrat by clearing everything
clc; clear; close all;

 %Input of the MR image to be analyzed
 Original_I = input('Filename of the image to be analyzed: ','s');

 %Stops code if file doesn't exist
 if isfile(Original_I)~=1
     fprintf('This file does not exist'); %Notify if file doesn't exist
     return;%Stop code if file doesn't exist
 end

 %Set variables
 choice = 'No';
 choice2 = 'No';
 count = 0;
 
 %Give user chance to improve accuracy (might not be needed)
 k = input('\nYou will be given a high contrast version of the Patient''s MR image, \nand will be asked to choose reference points along the edge of the tumor. \nThese reference points will be used to create an outline of the tumor. \n\nHow many reference points would you like to use?  ');
 %Confirm that the input is a positive, whole number
 while k<=0 || rem(k,1)~=0
     fprintf('\nPlease insert a positive whole number \n');%Warn user that previous choice was not correct
     k = input('How many reference points would you like to use?  ');%Allow user to try again
 end
 
 %Read image before the loop because it will onlu read once
 Original_I = imread(Original_I);
 
 %FIND TUMOR
 %While the image is not highlighted, continue asking to choose points
 %until it works
 while strcmp(choice,'No')
      if count>=1
          k = input('How many reference points would you like to use?  ');
          %Confirm that the input is a positive, whole number
          while k<=0 || rem(k,1)~=0
              fprintf('\nPlease insert a positive whole number \n');%Warn user that previous choice was not correct
              k = input('How many reference points would you like to use?  ');%Allow user to try again
          end
      end
     %Set variables
       pmin = 255;
     %Prep Image for Filtering
        close all %Close previous images
        gray_I = im2gray (Original_I);%Set image to gray to filter laterI = im2gray(I);
        n = 2;
        Idouble = im2double(gray_I);
        avg = mean2(Idouble);
        sigma = std2(Idouble);
        filter_I = imadjust(gray_I,[abs(avg-n*sigma) abs(avg+n*sigma)],[]);
        figure(1); imshow(filter_I); %Show original
        title('Select the edge of the tumor'); %Instructions
        
     %Input selection of the edge of the tumor
        [x1, y1, int] = ginput(k);%Allow user to select the edges of the tumor
         close all%Close the image so you can see the command window again

     %Save avg pixel intensity for binary threshold
         for i = 1:k %Run to the set accuracy
             p1 = impixel(Original_I,x1(i),y1(i));
              if p1(1)<pmin %Find smallest pixel intensity
                  pmin = p1(1);
              end
         end
 
     %Thresholding
        Ithresh = gray_I; %Create new variable
        Ithresh(Ithresh<pmin) = 0; %Binary threshold
        
     %Find connectivity of the tumor and delete everything else
        [L,n1] = bwlabeln(Ithresh);%Segment tumor into different connectivity values
        L_new = L;
        L_new(L>0)=0;
        
        %THIS CAN PROBABLY NOT BE AN IF STATEMENT BUT IM LAZY
        for j = 1:k%Single out the values of the tumor using the location to user selected
        contumor(j) = L(round(y1(j)),round(x1(j)));%Find connectivity value of selected points
        L_new(find(L==contumor(j)))=1;%Mark tumor on new matrix
        end
        Ithresh(L_new==0)=0;%Delete everything but the tumor
 
     %Show for everyone to see the results. I think this should change to a
     %merged image
        figure(1);
        subplot(1,2,1);imshow(Original_I);title('Original Image');
        subplot(1,2,2);imshow(Ithresh);title('Segmented Image');
 
     %Ask the user a question if 
         dlgTitle    = 'User Question';
         dlgQuestion = 'Is the whole tumor outlined? If the outline is incomplete, or you see other parts of the brain try choosing more or less points.';
         choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'No');
         close all;
         count = 1;
 end

  %Setup next figure
 subplot(1,2,1); imshow(Ithresh); title('Original');
 
%FILL TUMOR
 while strcmp(choice2,'No')
 Ifill = imfill(Ithresh,'holes'); %Fill holes in image so you can calculate size by amount of pixels
 area = bwarea(Ifill);%Find area of white spots in image
 
 %This is just to show what I'm doing above. We can delete this
 subplot(1,2,2);imshow(Ifill);title('Filled Tumor');
 
 %Confirm that the tumor is filled
 dlgTitle    = 'User Question';
 dlgQuestion = 'Is the tumor filled?';
 choice2 = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'No');
 
 %if it doesn't work, the image will be dialated to fill any holes
 Ithresh = imdilate(Ithresh,strel('square',10));
 end
close all;
 
%LOCATION OF THE TUMOR
 %Establishing variables based on image of tumor by itself
[rows, columns, colorchannels] = size(Ifill);

%These values will be changed based on the image size, need to do once we add this to the regular code
r = 250;
x = columns/2;
y = rows/2;

%Calculating the circle to be used for masking
th = 0:pi/50:2*pi;
xunit = r*cos(th) + x;
yunit = r*sin(th) + y;

%Creating a mask of the same size as the circle created
mask = poly2mask(xunit, yunit, rows, columns);

%Masking the image with the circle mask created
if colorchannels == 1
    maskedimage = Ifill;
    maskedimage(~mask) = 0;
else
    maskedimage = bsxfun(@times, Ifill, cast(mask, class(Ifill)));
end

%Determining if the tumor is centralized or not, based on the area within the circle (greater than 50% of tumor is centralized)
%If the tumor is not centralized, a quadrant of location will be determined
if bwarea(maskedimage) > (0.5*area)
    location = 'Centralized';
    treatment = 'Surgery or biopsy is possible, but it is likely that chemotherapy will be needed due to the location of the tumor';
else
    %Setting new image as duplicate of tumor image (just for ease of writing/splitting)
    I = Ifill;
    I = imbinarize(I);
    
    %Splitting image into 4 equal quadrants
    I1=I(1:(round(rows/2)),1:(round(columns/2)),:);
    I2=I((round(rows/2))+1:rows,1:(round(columns/2)),:);
    I3=I(1:(round(rows/2)),(round(columns/2))+1:columns,:);
    I4=I((round(rows/2))+1:rows,(round(columns/2))+1:columns,:);
    
    %Finding the area of the tumor in each quadrant
    A1 = bwarea(I1);
    A2 = bwarea(I2);
    A3 = bwarea(I3);
    A4 = bwarea(I4);
    
    %Setting a vector up with the areas, and finding the largest value
    vec = [A1 A2 A3 A4];
    maximum = find(vec == max(vec));
    
    %Finding the quadrant associated with the largest area
    if maximum == 1
        location = 'Front Left';
    elseif maximum == 2
        location = 'Back Left';
    elseif maximum == 3
        location = 'Front Right';
    elseif maximum == 4
        location = 'Back Right';
    end
    
 %SIZE TUMOR
 %Converting the area from pixels to cm^2
 %Find the scale bar
 [row,col] = find(L==1);
 %Find the Length of the scale bar
 dis = row(end) - row(1);
 %Use the length of the scale bar to find the area of the tumor in cm
 areacm = (100/dis^2)*area;
 if areacm >= 6
     treatment = 'Surgery or biopsy is possible, but it is likely that chemotherapy will be needed due to the size of the tumor';
 elseif areacm < 6
     treatment = 'Surgery is a likely option for treatment, due to the location and size of the tumor';
 end
 
end
 
%HIGHLIGHT TUMOR
I = imbinarize(Ifill);
 bw = im2uint8(I); %Change to uint8 so the gray connected works
for f = 1:k %For all the chosen points
 J = grayconnected(bw,round(y1(f)),round(x1(f))); %include all the chosen points
end

%FINAL PRODUCT
imshow(labeloverlay(Original_I,J))
annotation('textbox',[.11 0 .8 .1],'String',sprintf('Size: %.3f \nLocation: %s \nTreatment: %s ',areacm,location,treatment),'Color',[0 0 0],'FontWeight','normal','EdgeColor','none');
