% CS194-26 (cs219-26): Project 1, starter Matlab code

% name of the input file
imname_small = ["monastery.jpg", "nativity.jpg", "settlers.jpg", "cathedral.jpg"];
imname_large = ["harvesters.tif", "emir.tif", "three_generations.tif", "turkmen.tif", "lady.tif", "train.tif", "icon.tif", "self_portrait.tif", "village.tif"];
imname_extra = ["sailors.tif", "stream.tif", "wood_boat.tif", "flowers.tif"];

for i=1:length(imname_small)
    processImage(imname_small{i}, true)
end

for i=1:length(imname_large)
    processImage(imname_large{i}, false)
end
for i=1:length(imname_extra)
    processImage(imname_extra{i}, false)
end

function processImage(name, small)
    % read in the image
    fullim = imread(name);

    % convert to double matrix (might want to do this later on to same memory)
    fullim = im2double(fullim);

    % compute the height & width of each part (just 1/3 of total)
    height = floor(size(fullim,1)/3);
    width = floor(size(fullim,2));
    
    % separate color channels
    B = fullim(1:height,:);
    G = fullim(height+1:height*2,:);
    R = fullim(height*2+1:height*3,:);

    % Align the images

    % crop image by 10% around border
    cropAmount = ((height+width)/2)*(0.10);
    
    % compute the height & width with crop
    Hcrop = height - cropAmount;
    Wcrop = width - cropAmount;

    % create cropped color channels
    Bcropped=B(1+cropAmount:Hcrop,1+cropAmount:Wcrop);
    Gcropped=G(1+cropAmount:Hcrop,1+cropAmount:Wcrop);
    Rcropped=R(1+cropAmount:Hcrop,1+cropAmount:Wcrop);
    
    % define displacement offset ([-15,15] pixels) 
    offset = 15;

    if (small)
        % Using option "SSD" will produce images using SSD method:         
        [gx,gy] = align(Gcropped, Bcropped, offset, "SSD");
        gNew = circshift(G, [gy, gx]);
        [rx,ry] = align(Rcropped, Bcropped, offset, "SSD");
        rNew = circshift(R, [ry, rx]);
        RGB = cat(3, rNew, gNew, B);
        imwrite(RGB,['small_SSD_(' num2str(gx) '.' num2str(gy) ')_(' num2str(rx) '.' num2str(ry) ')_' name]);
        
        % Using option "NCC" will produce images using SSD method:      
        [gx,gy] = align(Gcropped, Bcropped, offset, "NCC");
        gNew = circshift(G, [gy, gx]);
        [rx,ry] = align(Rcropped, Bcropped, offset, "NCC");
        rNew = circshift(R, [ry, rx]);
        RGB = cat(3, rNew, gNew, B);
        imwrite(RGB,['small_NCC_(' num2str(gx) '.' num2str(gy) ')_(' num2str(rx) '.' num2str(ry) ')_' name]);
        
    else     
        % pyramid: (blue as base)
        [gx, gy, rx, ry] = alignPyramid(Gcropped, Rcropped, Bcropped, offset);
        gNew = circshift(G, [gy, gx]);
        rNew = circshift(R, [ry, rx]);
        RGB_B = cat(3, rNew, gNew, B);
        imwrite(RGB_B,[name(1:end-4) '_large_pyramid_blue_base_(' num2str(gx) '.' num2str(gy) ')_(' num2str(rx) '.' num2str(ry) ')_.png']);
        
        % pyramid: (green as base)
        [bx, by, rx, ry] = alignPyramid(Bcropped, Rcropped, Gcropped, offset);
        bNew = circshift(B, [by, bx]);
        rNew = circshift(R, [ry, rx]);
        RGB = cat(3, rNew, G, bNew);
        imwrite(RGB,[name(1:end-4) '_large_pyramid_green_base_(' num2str(bx) '.' num2str(by) ')_(' num2str(rx) '.' num2str(ry) ')_.png']);



        % Better Features: Pyramid with image gradient

        Bgrad = imgradient(Bcropped);
        Ggrad = imgradient(Gcropped);
        Rgrad = imgradient(Rcropped);

        [gx, gy, rx, ry] = alignPyramid(Ggrad, Rgrad, Bgrad, offset);
        gNew = circshift(G, [gy, gx]);
        rNew = circshift(R, [ry, rx]);
        RGB = cat(3, rNew, gNew, B);
        imwrite(RGB,[name(1:end-4) '_large_pyramid_feature_gradient_(' num2str(gx) '.' num2str(gy) ')_(' num2str(rx) '.' num2str(ry) ')_.png']);


        % Automatic Contrasting:
        RGB_B = histeq(RGB_B);
        imwrite(RGB_B,[name(1:end-4) '_large_pyramid_auto_contrast_(' num2str(gx) '.' num2str(gy) ')_(' num2str(rx) '.' num2str(ry) ')_.png']);
        
    end


end
function [x, y] = align(img, base, offset, option)
    baseV = base(:);
    displacement = zeros((offset*2));
    baseNorm = baseV/norm(baseV);
    
    for h = -offset+1:offset
        for w = -offset+1:offset
            imgShifted = circshift(img,[h,w]);
            x1 = w+offset;
            y1 = h+offset;
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
    [y, x] = ind2sub(size(displacement), I);
    x = x-offset;
    y = y-offset;

end

function [gxe, gye, rxe, rye] = alignPyramid(imgG, imgR, base, offset)
    
    scale = 1/16;
    gx = 0;
    gy = 0;
    
    gxe = 0;
    gye = 0;
    
    rx = 0;
    ry = 0;
    
    rxe = 0;
    rye = 0;
    while (scale <= 1)
        imgGScaled = imresize(imgG, scale);
        imgRScaled = imresize(imgR, scale);
        baseScaled= imresize(base, scale);
        
        imgGScaled_Shifted = circshift(imgGScaled, [gye, gxe]);
        imgRScaled_Shifted = circshift(imgRScaled, [rye, rxe]);
        
        [gx, gy] = align(imgGScaled_Shifted, baseScaled, offset, "SSD");
        [rx, ry] = align(imgRScaled_Shifted, baseScaled, offset, "SSD");
        
        gxe = gxe*2 + gx;
        gye = gye*2 + gy;
        
        rxe = rxe*2 + rx;
        rye = rye*2 + ry;
        
        scale = scale *2;
        offset = 1;
    end
end


