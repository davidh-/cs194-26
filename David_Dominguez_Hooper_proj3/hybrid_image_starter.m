 close all; % closes all figures

% read images and convert to single format
imname = ["man.jpg", "woman.jpg", "earth.jpg", "saturn.jpg", "dog.jpg", "cat.jpg"];
stack_images = ["gala.jpg", "man_woman_color_hybrid.jpg", "earth_saturn_color_hybrid.jpg", "dog_cat_color_hybrid.jpg"];

b_dir = "./spline/";
b_pics = ["apple.jpg", "orange.jpg", "mask_ao.jpg"];
pb_pics = ["trey_s.jpg", "daph_s.jpg", "trey_s_mask.jpg"];


% % part 1.2:
% i = 1;
% 
% while i < length(imname)
%     im12 = process(imname{i}, imname{i+1});   
%     i = i + 2;
% end


% part 1.3:
i = 1;

% N = 5; % number of pyramid levels (you may use more or fewer, as needed)
for i = 1:length(stack_images)
    % %% Compute and display Gaussian and Laplacian Pyramids (you need to supply this function)
    im = im2double(imread(stack_images{i}));
    pyramids(im, N, [1 1]);
end

% part 1.4:
b_chan = blend(char(b_dir + b_pics{1}), char(b_dir + b_pics{2}), char(b_dir + b_pics{3}));
imB = cat(3, b_chan{1}, b_chan{2}, b_chan{3});
imwrite(imB,char(b_dir +'oraple.jpg'));
figure, imshow(imB);

pb_chan = blend(char(b_dir + pb_pics{1}), char(b_dir + pb_pics{2}), char(b_dir + pb_pics{3}));
impB = cat(3, pb_chan{1}, pb_chan{2}, pb_chan{3});
imwrite(impB,char(b_dir +'trey_daph.jpg'));
figure, imshow(impB);


function b_chan = blend(name1, name2, namemask)
    close all;
    
    N = 7;
    chans = cell(1, 3);
    names = {name1, name2, namemask};
    
    for i = 1:length(chans)
        im = im2double(imread(names{i}));
        
        red = im(:,:,1); % Red channel
        green = im(:,:,2); % Green channel
        blue = im(:,:,3); % Blue channel
        
        chans{i}  = {red, green, blue}; 
    end

    b_chan = cell(1, 3);
    for i = 1:3 % for each channel R, G, B
        sigma = 4;
        [l1, g1] = pyramids(chans{1}{i}, N, sigma);
        [l2, g2] = pyramids(chans{2}{i}, N, sigma);
        [lm, gm] = pyramids(chans{3}{i}, N, sigma);
        
        height = floor(size(im,1));
        width = floor(size(im,2));
        
        f_img = zeros(height,width);

        for j = 1:N
%             subplot(2,3,1), imshow(gm{j})
%             subplot(2,3,2), imshow(l1{j})
%             subplot(2,3,3), imshow((1 - gm{j}))
%             subplot(2,3,4), imshow(l2{j})
            p1 = gm{j}.*l1{j};
            p2_1 = 1 - gm{j};
            p2 = p2_1.*l2{j};
            img = p1 + p2;
            f_img = f_img + img;
%             subplot(2,3,6), imshow(mat2gray(f_img));
        end
%         imshow(f_img);
        b_chan{i} = mat2gray(f_img);
    end
    
end


function [laplacians, gaussians] = pyramids(imG, N, sigma)
    close all;
    
    laplacians = cell(1, N);
    gaussians = cell(1, N);
    for i = 1:N
        imGN = imgaussfilt(imG, sigma);
        gaussians{i} = imGN;
        sigma = sigma*2;
        
        detail_lap = imG - imGN;

        laplacians{i} = detail_lap;
        imG = imGN;
%       option for 1.3  
%         subplot(2,N,i), imshow(imGN);
%         subplot(2,N,N+i), imshow(mat2gray(detail_lap));
    end
    

end

function im12 = process(name1, name2)
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
%     hybridImage(im1, im2, name1, name2, false);
    im12 = hybridImage(im1C, im2, name1, name2, true);
end

function im12 = hybridImage(im1, im2, name1, name2, color)
    sigma = [3 3];
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