% CS194-26 (cs219-26): Project 5
% David Dominguez Hooper 24828373
a
close all; % closes all figures

% imname = ["george.jpg", "jack.jpg"];
% 
% im1 = imresize(im2double(imread(imname{1})),[300 300]);
% im2 = imresize(im2double(imread(imname{2})),[300 300]);

% Part 1: Depth Refocusing

dirData = dir('**/rectified/*');
c = 0.25;
img = refocus(dirData, c);

img = mat2gray(img);
imshow(img);




% PART 2: Aperture Adjustment

mid_pts = (im1_pts + im2_pts)/2;
tri = delaunay(mid_pts); % triangle pts for both images

im_mid1 = morph_mid(im1, im2, im1_pts, mid_pts, tri, 0, 0);
figure, imshow(im_mid1);
imwrite(im_mid1, [imname{1}(1:end-4) '_mid.jpg']);

im_mid2 = morph_mid(im2, im2, im2_pts, mid_pts, tri, 0, 0);
figure, imshow(im_mid2);
imwrite(im_mid2, [imname{2}(1:end-4) '_mid.jpg']);

mid_face = im_mid1*0.5 + im_mid2*0.5;
figure, imshow(mid_face);
imwrite(mid_face, [imname{1}(1:end-4) '_' imname{2}(1:end-4)  '_mid.jpg']);


% Bells & Whistles: Using Real Data

function img = refocus(dirData, c)
    dirData = dir('**/rectified/*');
    dirData = dirData(3:end, :);
    num_files = length(dirData);
    factor = 1/num_files;
    rows_cols = sqrt(num_files);
    img_data = cell(rows_cols, rows_cols);

    center =  dirData(8*17+9).name;
    str_split =  strsplit(center, "_");
    v_cen = str2double(str_split(4));
    u_cen = str2double(str_split(5));
    avg_img = zeros(size(im2double(imread(['./rectified/' center]))));

    count = 1;
    c = 0.25;
    figure;
    while (count < num_files)
        imname =  dirData(count).name;
        str_split =  strsplit(imname, "_");
        v = str2double(str_split(4));
        u = str2double(str_split(5));
        img = im2double(imread(['./rectified/' imname]));

        v_dif = v - v_cen;
        u_dif = u - u_cen;

        img_shifted = circshift(img, [floor(v_dif*c) floor(u_dif*c)]);
        avg_img = avg_img + img_shifted*factor;
        imshow(mat2gray(avg_img));
        count = count + 1;
    end
    img = mat2gray(avg_img);

end