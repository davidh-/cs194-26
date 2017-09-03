% CS194-26 (cs219-26): Project 1, starter Matlab code

% name of the input file
imname = 'monastery.jpg';

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
offset = 15;
widthPad = width + offset*2;
heightPad = height + offset*2;

Bpad = padarray(B, [offset offset], 0, 'both');
Gpad = padarray(G, [offset*2 offset*2], 0, 'post');
Rpad = padarray(R, [offset*2 offset*2], 0, 'post');

Bnorm = normc(Bpad);


displacement = zeros(offset*2, offset*2);



% figure, imshow(Gpad)
for h = 1:(offset*2)+1
    for w = 1:(offset*2)
        Gpad = circshift(Gpad,1,2);
        
        Gnorm = normc(Gpad);
        GBdot = dot(Gnorm, Bnorm);
        displacement(h, w) = sum(GBdot)/widthPad;
    end
    if h ~= (offset*2)+1
        Gpad = circshift(Gpad,-offset*2,2);
        Gpad = circshift(Gpad,1,1);
    end
end
Gpad = circshift(Gpad,[-offset*2,-offset*2]);

[M,I] = max(displacement(:));
[I_row, I_col] = ind2sub(size(displacement),I);

Gpad = circshift(Gpad,[I_row,I_col]);
% imshow(Gpad)



displacement = zeros(offset*2, offset*2);
for h = 1:(offset*2)+1
    for w = 1:(offset*2)
        Rpad = circshift(Rpad,1,2);
        
        Rnorm = normc(Rpad);
        RBdot = dot(Rnorm, Bnorm);
        displacement(h, w) = sum(RBdot)/widthPad;
    end
    if h ~= (offset*2)+1
        Rpad = circshift(Rpad,-offset*2,2);
        Rpad = circshift(Rpad,1,1);
    end
end
Rpad = circshift(Rpad,[-offset*2,-offset*2]);

[M,I] = max(displacement(:));
[I_row, I_col] = ind2sub(size(displacement),I);

Rpad = circshift(Rpad,[I_row,I_col]);


GB = cat(3, Gpad, Bpad);
RGB = cat(3, Rpad, GB);


figure(), imshow(RGB)

        
        
% aG = align(G,B);



% aR = align(R,B);


% open figure
%% figure(1);

% create a color image (3D array)
% ... use the "cat" command
% show the resulting image
% ... use the "imshow" command
% save result image
%% imwrite(colorim,['result-' imname]);
