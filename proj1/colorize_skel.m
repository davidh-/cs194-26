% CS194-26 (cs219-26): Project 1, starter Matlab code

% name of the input file
% imname = 'monastery.jpg';
% imname = 'nativity.jpg';
% imname = 'settlers.jpg';
% imname = 'cathedral.jpg';

% read in the image
fullim = imread(imname);

% convert to double matrix (might want to do this later on to same memory)
fullim = im2double(fullim);

% compute the height of each part (just 1/3 of total)
height = floor(size(fullim,1)/3);
width = floor(size(fullim,2));
% separate color channels
B = fullim(1:height,:);
G = fullim(height+1:height*2,:);
R = fullim(height*2+1:height*3,:);

% Align the images
% Functions that might be useful to you for aligning the images include: 
% "circshift", "sum", and "imresize" (for multiscale)

% crop image by -19 to 19 pixels around border
cropAmount = 20;
Hcrop = height - cropAmount;
Wcrop = width - cropAmount;


Bcropped=B(1+cropAmount:Hcrop,1+cropAmount:Wcrop);
Gcropped=G(1+cropAmount:Hcrop,1+cropAmount:Wcrop);
Rcropped=R(1+cropAmount:Hcrop,1+cropAmount:Wcrop);

offset = 15;

[gx,gy] = align(Gcropped, Bcropped, offset, "SSD");
gNew = circshift(G, [gx, gy]);
[rx,ry] = align(Rcropped, Bcropped, offset, "SSD");
rNew = circshift(R, [rx, ry]);

RGB = cat(3, rNew, gNew, B);
figure, imshow(RGB);



[gx,gy] = align(Gcropped, Bcropped, offset, "NCC");
gNew = circshift(G, [gx, gy]);
[rx,ry] = align(Rcropped, Bcropped, offset, "NCC");
rNew = circshift(R, [rx, ry]);

RGB = cat(3, rNew, gNew, B);
figure, imshow(RGB)




%% imwrite(colorim,['result-' imname]);

function [x, y] = align(img, base, offset, option)
    baseV = base(:);
    displacement = zeros((offset*2));
    baseNorm = baseV/norm(baseV);
    
    for h = -offset+1:offset
        for w = -offset+1:offset
            imgShifted = circshift(img,[h,w]);
            y1 = h+15;
            x1 = w+15;
            if (option == "NCC")
                imgV = imgShifted(:);
                imgNorm = imgV/norm(imgV);
                displacement(y1, x1) = dot(baseNorm, imgNorm);
            else
                displacement(y1, x1) = sum(sum((base-imgShifted).^2));
            end
        end
    end
    
    if (option == "NCC")
        [M,I] = max(displacement(:));
    else
        [M,I] = min(displacement(:));
    end
    [x, y] = ind2sub(size(displacement), I);
    x = x-15;
    y = y-15;

end
