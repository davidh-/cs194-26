% CS194-26 (cs219-26): Project 4
% David Dominguez Hooper 24828373

close all; % closes all figures

imname = ["george.jpg", "jack.jpg"];

im1 = imresize(im2double(imread(imname{1})),[300 300]);
im2 = imresize(im2double(imread(imname{2})),[300 300]);

% Part 1: Defining Correspondences

load('im1_pts.mat', 'im1_pts');
load('im2_pts.mat', 'im2_pts');

% cpselect(im1,im2); %, im1_pts, im2_pts);
% 
% [h, w, chan] = size(im1);
% im1_pts = [im1_pts; 1,1; 1,h; w,1; w,h];
% im2_pts = [im2_pts; 1,1; 1,h; w,1; w,h];
% 
% save('im1_pts.mat', 'im1_pts');
% save('im2_pts.mat', 'im2_pts');


% PART 2: Computing the "Mid-way Face"

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


% % PART 3: The Morph Sequence
% 
% morph_rate = 1/20; % Morphing rate
% 
% vidWriObj = VideoWriter('morph.avi');
% 
% vidWriObj.FrameRate = 4;
% open(vidWriObj);
% 
% for frac = 0 : morph_rate : 1
%     warp_frac     = frac; 
%     dissolve_frac = frac; 
%     
%     morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);
%     
%     imshow(morphed_im); axis image; axis off; drawnow;
%     writeVideo(vidWriObj, getframe(gcf));
% end
% close(vidWriObj);
% clear vidWriObj;

% PART 4: The "Mean face" of a population


dirData = dir('**/data/*');
dirData = dirData(3:end, :);
num_files = length(dirData);

img_data = cell(num_files/2, 3);
h = 0;
w = 0;
for i = 1 : 2 :num_files
    imdata =  dirData(i).name;

    fid = fopen(['./data/' imdata]);
    tline = fgetl(fid);
    
    for j = 1:9
        tline = fgetl(fid);
    end
    num_pts = str2double(tline);

    for j = 1:7
        tline = fgetl(fid);
    end
    k = i+2;
    if k > 2
        k = (k-1)/2;
    end
    img = im2double(imread(['./data/' dirData(i+1).name]));
    img_data{k, 3} = img;
    [h, w, c] = size(img);
    for j = 1:num_pts
        str = strsplit(tline);
        img_data{k, 1} = [img_data{k, 1}; str2double(str(3))*w, str2double(str(4))*h];

        img_data{k, 2} = [img_data{k, 2}; str2double(str(5)), str2double(str(6)), str2double(str(7))];
        tline = fgetl(fid);
    end
    img_data{k, 1} = [img_data{k, 1}; 1,1; 1,h; w,1; w,h];
    
    fclose(fid);
end

num_imgs = length(img_data);

avg_pts = img_data{1, 1};
for i = 2:num_imgs
    avg_pts = avg_pts + img_data{i, 1};
end

avg_pts = avg_pts/num_imgs;
avg_tri = delaunay(avg_pts); 
save('avg_pts.mat', 'avg_pts');
save('avg_tri.mat', 'avg_tri');

% figure, triplot(tri, avg_pts(:, 1), avg_pts(:, 2)), set(gca,'Ydir','reverse');

factor = (1/num_imgs);
avg_img = morph_mid(img_data{1, 3}, 0, img_data{1, 1}, avg_pts, avg_tri, 0, 0) * factor;
for i = 2:num_imgs
    avg_img = avg_img + (morph_mid(img_data{i, 3}, 0, img_data{i, 1}, avg_pts, avg_tri, 0, 0) * factor);
end
figure, imshow(avg_img);
imwrite(avg_img, 'avg_img.jpg');

% load('avg_pts.mat', 'avg_pts');
% load('avg_tri.mat', 'avg_tri');
% avg_img = im2double(imread('avg_img.jpg'));


female = [5, 9, 11, 12, 19, 27, 32];
len_females = length(female);

avg_pts_f = img_data{5, 1};
for i = 2:len_females
    avg_pts_f = avg_pts_f + img_data{female(i), 1};
end

avg_pts_f = avg_pts_f/len_females;
avg_tri_f = delaunay(avg_pts_f); 
save('avg_pts_f.mat', 'avg_pts_f');
save('avg_tri_f.mat', 'avg_tri_f');

factor = (1/len_females);
avg_img_f = morph_mid(img_data{5, 3}, 0, img_data{1, 1}, avg_pts_f, avg_tri_f, 0, 0) * factor;
for i = 2:len_females
    avg_img_f = avg_img_f + (morph_mid(img_data{female(i), 3}, 0, img_data{female(i), 1}, avg_pts_f, avg_tri, 0, 0) * factor);
end
figure, imshow(avg_img_f);
imwrite(avg_img_f, 'avg_img_f.jpg');

% load('avg_pts_f.mat', 'avg_pts_f');
% load('avg_tri_f.mat', 'avg_tri_f');
% avg_img_f = im2double(imread('avg_img_f.jpg'));

for i = 7:8
    morph_rate = 1/20; % Morphing rate

    vidWriObj = VideoWriter(['morph_mean' num2str(i)]);

    vidWriObj.FrameRate = 4;
    open(vidWriObj);

    for frac = 0 : morph_rate : 1
        warp_frac     = frac; 
        dissolve_frac = frac; 

        morphed_im = morph(img_data{i, 3}, avg_img, img_data{i, 1}, avg_pts, avg_tri, warp_frac, dissolve_frac);

        imshow(morphed_im); axis image; axis off; drawnow;
        writeVideo(vidWriObj, getframe(gcf));
    end
    close(vidWriObj);
    clear vidWriObj;
end

% my face to mean face
im = im2double(imread('david_hooper.jpg'));
load('david_pts.mat', 'david_pts');


morphed_im = morph(im, avg_img, david_pts, avg_pts, avg_tri, 1, 0);
imshow(morphed_im); axis image; axis off; drawnow;
imwrite(morphed_im, 'morph_mean_david.jpg');


morphed_im = morph(avg_img, im, avg_pts, david_pts, avg_tri, 1, 0);
imshow(morphed_im); axis image; axis off; drawnow;
imwrite(morphed_im, 'morph_mean_into_myface.jpg');

% PART 5: Caricatures: Extrapolating from the mean

avg_pts_f = 1.5*david_pts - 0.5*avg_pts_f;

morphed_im = morph(im, avg_img_f, david_pts, avg_pts_f, avg_tri_f, 1, 0);
imshow(morphed_im); axis image; axis off; drawnow;
imwrite(morphed_im, 'morph_mean_david_fem_caricature.jpg');

% cpselect(im,avg_img, david_pts, avg_pts); %, im1_pts, im2_pts);


% PART 6: Bells and Whistles #1


img_trey = im2double(imread('trey2.jpg'));
img_david = im2double(imread('david_hooper.jpg'));
load('david_pts.mat', 'david_pts');
load('trey_pts.mat', 'trey_pts');
% cpselect(img_trey,img_david, david_pts, david_pts); %, im1_


mid_pts = (david_pts + trey_pts)/2;
tri = delaunay(mid_pts); % triangle pts for both images


morph_rate = 1/20; % Morphing rate

vidWriObj = VideoWriter('morph_trey_shape.avi');

vidWriObj.FrameRate = 5;
open(vidWriObj);

for frac = 0 : morph_rate : 1
    warp_frac     = frac; 
    dissolve_frac = frac; 
    
    morphed_im = morph(img_trey, img_david, trey_pts, david_pts, tri, warp_frac, 0);
    
    imshow(morphed_im); axis image; axis off; drawnow;
    writeVideo(vidWriObj, getframe(gcf));
end
close(vidWriObj);
clear vidWriObj;


vidWriObj = VideoWriter('morph_trey_appearance.avi');

vidWriObj.FrameRate = 5;
open(vidWriObj);

for frac = 0 : morph_rate : 1
    warp_frac     = frac; 
    dissolve_frac = frac; 
    
    morphed_im = morph(img_trey, img_david, trey_pts, david_pts, tri, 0, dissolve_frac);
    
    imshow(morphed_im); axis image; axis off; drawnow;
    writeVideo(vidWriObj, getframe(gcf));
end
close(vidWriObj);
clear vidWriObj;


vidWriObj = VideoWriter('morph_trey_both.avi');

vidWriObj.FrameRate = 5;
open(vidWriObj);

for frac = 0 : morph_rate : 1
    warp_frac     = frac; 
    dissolve_frac = frac; 
    
    morphed_im = morph(img_trey, img_david, trey_pts, david_pts, tri, warp_frac, dissolve_frac);
    
    imshow(morphed_im); axis image; axis off; drawnow;
    writeVideo(vidWriObj, getframe(gcf));
end
close(vidWriObj);
clear vidWriObj;










% Functions:

function A = computeAffine(tri1_pts,tri2_pts)
    r1 = [tri1_pts(1, :), 1];
    r2 = [tri1_pts(2, :), 1];
    r3 = [tri1_pts(3, :), 1];
    x = vertcat(r1, r2, r3).';
    
    r1 = [tri2_pts(1, :), 1];
    r2 = [tri2_pts(2, :), 1];
    r3 = [tri2_pts(3, :), 1];
    
    b = vertcat(r1, r2, r3).';
    
    A = b*x^-1;
    A(3, :) = [0, 0, 1];
    
end

function morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac)
    num_tris = length(tri);
    aff_trans_matrices = cell(num_tris, 2);

%     figure, triplot(tri1, im1_pts(:, 1), im1_pts(:, 2)), set(gca,'Ydir','reverse');
    immid_pts = (1 - warp_frac) * im1_pts + warp_frac * im2_pts;
    
    for i = 1:num_tris
        aff_trans_matrices{i, 1} = computeAffine(im1_pts(tri(i, :), :), immid_pts(tri(i, :), :)); 
        aff_trans_matrices{i, 2} = computeAffine(im2_pts(tri(i, :), :), immid_pts(tri(i, :), :));
    end

    [h, w, ~] = size(im1);
    [X, Y] = meshgrid(1:w, 1:h);
    [XN1, YN1] = meshgrid(1:w, 1:h);
    [XN2, YN2] = meshgrid(1:w, 1:h);
    
    
    t = mytsearch(immid_pts(:,1), immid_pts(:,2), tri, X, Y);


    for i = 1:h %y
        for j = 1:w %x
            t_m1 = aff_trans_matrices{t(i, j), 1};
            t_m2 = aff_trans_matrices{t(i, j), 2};
            
            new1 = t_m1^-1*([j, i, 1].');
            new2 = t_m2^-1*([j, i, 1].');
            
            XN1(i, j) = new1(1, :);
            YN1(i, j) = new1(2, :);
            XN2(i, j) = new2(1, :);
            YN2(i, j) = new2(2, :);
        end
    end
    rgb1 = cell(3);
    rgb2 = cell(3);
    for i = 1:3
        rgb1{i} = interp2(im1(:, :, i),XN1,YN1,'linear');
        rgb2{i} = interp2(im2(:, :, i),XN2,YN2,'linear');
    end
    
    morphed_im1 = cat(3, rgb1{1}, rgb1{2}, rgb1{3});
    morphed_im2 = cat(3, rgb2{1}, rgb2{2}, rgb2{3});
    morphed_im = (1-dissolve_frac) * morphed_im1 + dissolve_frac * morphed_im2;
%     figure, imshow(morphed_im);
end
function morphed_im = morph_mid(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);
    num_tris = length(tri);
    aff_trans_matrices = cell(num_tris, 1);

%     figure, triplot(tri1, im1_pts(:, 1), im1_pts(:, 2)), set(gca,'Ydir','reverse');

    for i = 1:num_tris
        index = tri(i, :);
        aff_trans_matrices{i} = computeAffine(im1_pts(index, :), im2_pts(index, :)); 
    end

    [h, w, ~] = size(im1);
    [X, Y] = meshgrid(1:w, 1:h);
    [XN, YN] = meshgrid(1:w, 1:h);
    t = mytsearch(im2_pts(:,1), im2_pts(:,2), tri, X, Y);


    for i = 1:h %y
        for j = 1:w %x
            t_m = aff_trans_matrices{t(i, j)};
            new = t_m^-1*([j, i, 1].'); %t_m\([j, i, 1].');
            XN(i, j) = new(1, :);
            YN(i, j) = new(2, :);
        end
    end
    rgb = cell(3);
    for i = 1:3
        rgb{i} = interp2(im1(:, :, i),XN,YN,'linear');
    end
    morphed_im = cat(3, rgb{1}, rgb{2}, rgb{3});
end