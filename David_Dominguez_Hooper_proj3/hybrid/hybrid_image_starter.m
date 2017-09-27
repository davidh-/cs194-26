close all; % closes all figures

% read images and convert to single format
imname = ["man.jpg", "woman.jpg", "earth.jpg", "saturn.jpg", "dog.jpg", "cat.jpg"];

i = 1;
while i < length(imname)
    process(imname{i}, imname{i+1});
    i = i + 2;
end

function process(name1, name2)
    im1C = im2single(imread(name1));
    im2C = im2single(imread(name2));

    % use this if you want to align the two images (e.g., by the eyes) and crop
    % them to be of same size
    [im2C, im1C] = align_images(im2C, im1C);

    im1 = rgb2gray(im1C); 
    im2 = rgb2gray(im2C);
    
    imwrite(im1,[name1(1:end-4)  '_grayed.jpg']);
    imagesc(log(abs(fftshift(fft2(im1)))));
    saveas(gcf,[name1(1:end-4) '_fft'],'jpg');

    imwrite(im2,[name2(1:end-4)  '_grayed.jpg']);
    imagesc(log(abs(fftshift(fft2(im2)))));
    saveas(gcf,[name2(1:end-4) '_fft'],'jpg');
    
    % uncomment this when debugging hybridImage so that you don't have to keep aligning
    % keyboard; 

    %% Choose the cutoff frequencies and compute the hybrid image (you supply
    %% this code)
    hybridImage(im1, im2, name1, name2, false);
    hybridImage(im1C, im2, name1, name2, true);
end







% %% Compute and display Gaussian and Laplacian Pyramids (you need to supply this function)
% N = 5; % number of pyramid levels (you may use more or fewer, as needed)
% pyramids(im12, N);

function im12 = hybridImage(im1, im2, name1, name2, color)
    sigma = 4;
    low1 = imgaussfilt(im1, sigma);
    low2 = imgaussfilt(im2, sigma);
    
    high1 = im1 - low1;
    
    im12 = (low2 + high1);
    
    %% Crop resulting image (optional)
    figure(1), hold off, imagesc(im12), axis image, colormap gray
    disp('input crop points');
    [x, y] = ginput(2);  x = round(x); y = round(y);
    im12 = im12(min(y):max(y), min(x):max(x), :);
    figure(1), hold off, imagesc(im12), axis image, colormap gray
    
    if color ~= true
        imwrite(low2,[name2(1:end-4)  '_lowpass.jpg']);
        
        imagesc(log(abs(fftshift(fft2(low2)))));
        saveas(gcf,[name2(1:end-4) '_lowpass_fft'],'jpg');
        
        imwrite(high1,[name1(1:end-4)  '_highpass.jpg']);
        
        imagesc(log(abs(fftshift(fft2(high1)))));
        saveas(gcf,[name1(1:end-4) '_highpass_fft'],'jpg');
        
        imagesc(log(abs(fftshift(fft2(im12)))));
        saveas(gcf,[name1(1:end-4) '_' name2(1:end-4) '_hybrid_fft'],'jpg');
        imwrite(im12,[name1(1:end-4) '_' name2(1:end-4) '_hybrid.jpg']);
    else
        imwrite(im12,[name1(1:end-4) '_' name2(1:end-4) '_color_hybrid.jpg']);
    end
end