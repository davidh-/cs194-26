
function sharpenImage(name)
    im = im2double(imread(name));
    sigma = [5 5];
    
    [gR, gG, gB] = blurImage(name, sigma);
    
    imB = cat(3, gR, gG, gB);
    imwrite(imB,[name(1:end-4)  '_blurred.jpg']);
    
    detail = im - imB;
    imwrite(detail,[name(1:end-4)  '_high-frequency.jpg']);
    
    alpha = 3;
    
    sharpened = im + alpha*detail;
    imwrite(sharpened,[name(1:end-4)  '_sharpened.jpg']);
end
function [gR, gG, gB] = blurImage(name, sigma)
    im = im2double(imread(name));
    red = im(:,:,1); % Red channel
    green = im(:,:,2); % Green channel
    blue = im(:,:,3); % Blue channel
    
    gR = imgaussfilt(red, sigma);
    gG = imgaussfilt(green, sigma);
    gB = imgaussfilt(blue, sigma);
    
end