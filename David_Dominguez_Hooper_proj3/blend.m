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