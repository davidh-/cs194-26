% CS194-26 (cs219-26): Project 3

% name of the input file
imname = ["mona.jpg", "fire.jpg"];

sharpenImage(imname{2})

% for i=1:length(imname)
%     sharpenImage(imname{i})
% end

function [gR, gG, gB] = blurImage(name, sigma)
    im = im2double(imread(name));
    red = im(:,:,1); % Red channel
    green = im(:,:,2); % Green channel
    blue = im(:,:,3); % Blue channel
    
    gR = imgaussfilt(red, sigma);
    gG = imgaussfilt(green, sigma);
    gB = imgaussfilt(blue, sigma);
    
end
function sharpenImage(name)
    im = im2double(imread(name));
    sigma = 5;
    
    [gR, gG, gB] = blurImage(name, sigma);
    
    imB = cat(3, gR, gG, gB);
    
%     figure, imshow(im);
%     figure, imshow(imB);
    
    detail = im - imB;
    
    alpha = 3;
    
    sharpened = im + alpha*detail;
   
    subplot(2,2,1), imshow(im)
    subplot(2,2,2), imshow(imB)
    subplot(2,2,3), imshow(detail)
    subplot(2,2,4), imshow(sharpened)
end
% function sharpenImageFilter(name)
%     sigma = 5;
%     
%     im = im2double(imread(name));
%     
%     log = fspecial('log', sigma); 
%     
%     bFinal = convn(im,2*log,'same');
%     imshow(bFinal);
%     
% %     rF = conv2(red,log,'same');
% %     rF = conv2(red,log,'same');
% %     rF = conv2(red,log,'same');
%     
% end
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

