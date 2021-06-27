clc;
clear all;

image = imread('disc.jpg');
grayImage = rgb2gray(image);
zoom = 4;

%for color image (nearest neighborhood)
r = image(:,:,1);
g = image(:,:,2);
b = image(:,:,3);
nnImageColor(:,:,1) = nearestNeighborhood(r, zoom);
nnImageColor(:,:,2) = nearestNeighborhood(g, zoom);
nnImageColor(:,:,3) = nearestNeighborhood(b, zoom);

%for grayscale (nearest neighborhood)
nnImage = zeros(1, (size(grayImage, 1)*(zoom+1))-zoom); %pre allocating memory
nnImage = nearestNeighborhood(grayImage, zoom);

%bilinear
bilinearImage = zeros(1, (size(grayImage, 1)*(zoom+1))-zoom); %pre allocating memory
bilinearImage = bilinear(grayImage, zoom);

%bicubic
bicubicImage = zeros(1, (size(grayImage, 1)*(zoom+1))-zoom); %pre allocating memory
bicubicImage = bicubic(grayImage, zoom);
imshow(bicubicImage);

%show 
figure;
subplot(2,2,1);
imshow(grayImage);
title('original image 512x512');
subplot(2,2,2);
imshow(nnImage);
title('nearest neighborhood 2556x2556');
subplot(2,2,3);
imshow(bilinearImage);
title('bilinear 2556x2556');
subplot(2,2,4);
imshow(bicubicImage);
title('bicubic 2556x2556');

originalHistogram = myHistogram(grayImage);
eqOriginalImage = eqImage(grayImage, originalHistogram);
eqHistogram = myHistogram(eqOriginalImage);

nnHistogram = myHistogram(nnImage);
eqNnImage = eqImage(nnImage, nnHistogram);
eqNnHistogram = myHistogram(eqNnImage);

bilinearHistogram = myHistogram(bilinearImage);
eqBilinearImage = eqImage(bilinearImage, bilinearHistogram);
eqBilinearHistogram = myHistogram(eqBilinearImage);

bicubicHistogram = myHistogram(bicubicImage);
eqBicubicImage = eqImage(bicubicImage, bicubicHistogram);
eqBicubicHistogram = myHistogram(eqBicubicImage);



figure;
subplot(2,2,1);
imshow(uint8(grayImage));
title('original image');
subplot(2,2,3);
imshow(uint8(eqOriginalImage));
title('original image equalized');

subplot(2,2,2);
stem(originalHistogram);
title('histogram original image');
subplot(2,2,4);
stem(eqHistogram);
title('histogram original image equalized');

figure;
subplot(2,2,1);
imshow(uint8(nnImage));
title('nn image');
subplot(2,2,3);
imshow(uint8(eqNnImage));
title('nn equalized');

subplot(2,2,2);
stem(nnHistogram);
title('histogram nearest neighborhood');
subplot(2,2,4);
stem(eqNnHistogram);
title('histogram nearest neighborhood equalized');


figure;
subplot(2,2,1);
imshow(uint8(bilinearImage));
title('Bilinear image');
subplot(2,2,3);
imshow(uint8(eqBilinearImage));
title('Bilinear equalized');

subplot(2,2,2);
stem(bilinearHistogram);
title('histogram bilinear');
subplot(2,2,4);
stem(eqBilinearHistogram);
title('histogram bilinear equalized');

figure;
subplot(2,2,1);
imshow(uint8(bicubicImage));
title('Bicubic image');
subplot(2,2,3);
imshow(uint8(eqBicubicImage));
title('Bicubic equalized');

subplot(2,2,2);
stem(bicubicHistogram);
title('histogram bicubic');
subplot(2,2,4);
stem(eqBicubicHistogram);
title('histogram bicubic equalized');






% nearest neighborhood (one channel)
function nnImg = nearestNeighborhood(img, zoom)
    for y = 1:size(img)
       for x = 1:size(img) % 1:size(img4, i)
            column = (x*(zoom+1))-(zoom);
            row = (y*(zoom+1))-(zoom);
            nnImg(row, column) = img(y,x);
            if x < size(img)
                for i = 0:zoom/2
                    nnImg(row, column+i) = img(y,x);
                    if y <size(img)
                        for j = 0:zoom/2
                            nnImg(row+j, column+i) = img(y,x);
                        end
                    end
                    if y > 1
                        for j = 0:zoom/2
                            nnImg(row-j, column+i) = img(y,x);
                        end
                    end
                end
            end
            if x > 1
                  for i = 0:zoom/2
                      nnImg(row, column-i) = img(y,x);
                      if y < size(img)
                        for j = 0:zoom/2
                            nnImg(row+j, column-i) = img(y,x);
                        end
                      end
                      if y > 1
                        for j = 0:zoom/2
                            nnImg(row-j, column-i) = img(y,x);
                        end
                      end
                  end
            end  
       end
    end
end

% bilinear (one channel)
function bilinearImg = bilinear(img, zoom)
    for y = 1:size(img)
       for x = 1:size(img) % 1:size(img4, i)
            column = (x*(zoom+1))-(zoom);
            row = (y*(zoom+1))-(zoom);
            bilinearImg(row, column) = img(y,x);
            if x == size(img) & y == size(img)
                point1 = img(y-1,x-1);
                point2 = img(y-1,x);
                point3 = img(y,x-1);
                point4 = img(y,x);

            elseif y == size(img)
                point1 = img(y-1,x);
                point2 = img(y-1,x+1);
                point3 = img(y,x);
                point4 = img(y,x+1);
            elseif x == size(img)
                point1 = img(y,x-1);
                point2 = img(y,x);
                point3 = img(y+1,x-1);
                point4 = img(y+1,x);
            else
                point1 = img(y,x);
                point2 = img(y,x+1);
                point3 = img(y+1,x);
                point4 = img(y+1,x+1);
            end

            if x < size(img)
                for i = 0:zoom/2
                    if y <size(img)
                        for j = 0:zoom/2
                            bilinearImg(row+j, column+i) = bilinearInt(point1, point2, point3, point4, zoom, i, j);
                        end
                    end
                    if y > 1
                        for j = 0:zoom/2
                            bilinearImg(row-j, column+i) = bilinearInt(point1, point2, point3, point4, zoom, i, j);
                        end
                    end
                end
            end

            if x > 1
                  for i = 0:zoom/2
                      if y < size(img)
                        for j = 0:zoom/2
                            bilinearImg(row+j, column-i) = bilinearInt(point1, point2, point3, point4, zoom, i, j);
                        end
                      end
                      if y > 1
                        for j = 0:zoom/2
                            bilinearImg(row-j, column-i) = bilinearInt(point1, point2, point3, point4, zoom, i, j);
                        end
                      end
                  end
            end  
            bilinearImg(row, column) = img(y,x);
       end
    end
end

% bicubic (one channel)
function bicubicImg = bicubic(img, zoom)
    for y = 1:size(img)
       for x = 1:size(img) % 1:size(img4, i)
            column = (x*(zoom+1))-(zoom);
            row = (y*(zoom+1))-(zoom);
            bicubicImg(row, column) = img(y,x);
            if x < zoom+2
                NrOfRows = 3;
                startX = 1;
            elseif x == size(img, 1)
                NrOfRows = 2;
                startX = size(img, 1)-1;
            elseif x > size(img)-zoom-2
                startX = size(img, 1)-2;
                NrOfRows = 3;
            else
                startX = x;
                NrOfRows = 4;
            end
            
            if y < zoom+2
                NrOfColumns = 3;
                startY = 1;
            elseif y == size(img, 1)
                NrOfColumns = 2;
                startY = size(img, 1)-1;
            elseif y > size(img)-zoom-2
                startY = size(img, 1)-2;
                NrOfColumns = 3;
            else
                startY = y;
                NrOfColumns = 4;
            end
            
            if x == 229 & y == 305
                bicubicInt(startX, startY, NrOfRows, NrOfColumns, img);
            end
            
            
            

            if x < size(img)
                for i = 0:zoom/2
                    if y <size(img)
                        for j = 0:zoom/2
                            bicubicImg(row+j, column+i) = bicubicInt(startX, startY, NrOfRows, NrOfColumns, img);
                        end
                    end
                    if y > 1
                        for j = 0:zoom/2
                            bicubicImg(row-j, column+i) = bicubicInt(startX, startY, NrOfRows, NrOfColumns, img);
                        end
                    end
                end
            end

            if x > 1
                  for i = 0:zoom/2
                      if y < size(img)
                        for j = 0:zoom/2
                            bicubicImg(row+j, column-i) = bicubicInt(startX, startY, NrOfRows, NrOfColumns, img);
                        end
                      end
                      if y > 1
                        for j = 0:zoom/2
                            bicubicImg(row-j, column-i) = bicubicInt(startX, startY, NrOfRows, NrOfColumns, img);
                        end
                      end
                  end
            end  
            %bicubicImg(row, column) = img(y,x);
       end
    end
end

function v = bicubicInt(startX, startY, NrOfRows, NrOfColumns, img)
    
    points = zeros(1, NrOfRows*NrOfColumns);
    counter = 0;
    for y = 0:NrOfColumns-1
        for x = 0:(NrOfRows-1)
            counter = counter+1;
            points(counter) = img(startY+y, startX+x);
        end
    end
    
    v = mean2(points); %avarage of matrix
end

function v = bilinearInt(point1, point2, point3, point4, numberOfSteps, currentStepX, currentStepY);
    val = linearInt(point1, point2, numberOfSteps, currentStepX);
    val2 = linearInt(point3, point4, numberOfSteps, currentStepX);
    v = linearInt(val, val2, numberOfSteps, currentStepY);
end

function v = linearInt(num1, num2, numberOfSteps, currentStep)
    a = num2-num1;
    steps = a /(numberOfSteps+1);
    v = num1 + steps * currentStep;
end

function histo = myHistogram(image)
    imageSize = size(image);
    histo = zeros(1,256);
    for y = 1:imageSize(1)
       for x = 1:imageSize(2)
           index = image(y, x)+1;
           histo(index) = 1+histo(index);
       end
    end
   
end

function img = eqImage(image, hist)
    imageSize = size(image);
    %Generating PDF 
    pdf=(1/(imageSize(1)*imageSize(2)))*hist;

    %Generating CDF 
    cdf = zeros(1,256);
    cdf(1)=pdf(1);
    for i=2:256
        cdf(i)=cdf(i-1)+pdf(i);
    end
    cdf = round(255*cdf);

    img = zeros(imageSize);
    for i=1:imageSize(1)                                        
        for j=1:imageSize(2)                                  
            t=(image(i,j)+1);                             
            img(i,j)=cdf(t);                            
        end 
    end
    
end



