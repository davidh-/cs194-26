% CS194-26 (cs219-26): Project 4
% David Dominguez Hooper 24828373

close all; % closes all figures

imname = ["george.jpg", "jack.jpg"];

im1 = imresize(im2double(imread(imname{1})),[300 300]);
im2 = imresize(im2double(imread(imname{2})),[300 300]);

% Part 1: Defining Correspondences

load('im1_pts.mat', 'im1_pts');
load('im2_pts.mat', 'im2_pts');

% h  = cpselect(im1,im2, im1_pts, im2_pts);
% save('im1_pts.mat', 'im1_pts');
% save('im2_pts.mat', 'im2_pts');


% PART 2: Computing the "Mid-way Face"
mid_pts = (im1_pts + im2_pts)/2;
tri = delaunay(mid_pts); % triangle pts for both images

% figure, set(gca,'Ydir','reverse'), triplot(tri1_pts);
% figure, set(gca,'Ydir','reverse'), triplot(tri2_pts);
% figure, set(gca,'Ydir','reverse'), triplot(mid_pts);


num_tris = length(tri);
aff_trans_matrices = cell(num_tris, 1);

tri1 = delaunay(im1_pts);
for i = 1:num_tris
    aff_trans_matrices{i} = computeAffine(tri1(i, :), tri(i, :), im1_pts, mid_pts);
end

[h, w, channel] = size(im1);
[Y, X] = meshgrid(1:h, 1:w);
[YN, XN] = meshgrid(1:h, 1:w);
t = mytsearch(mid_pts(:,1), mid_pts(:,2), tri, Y, X);


for i = 1:h %y
    for j = 1:w %x
        t_m = aff_trans_matrices{t(i, j)};
        new = t_m*([j, i, 1].');
        YN(i, j) = new(1, :);
        XN(i, j) = new(2, :);
    end
end
r = interp2(Y,X,im1(:, :, 1),YN,XN,'linear');
g = interp2(Y,X,im1(:, :, 2),YN,XN,'linear');
b = interp2(Y,X,im1(:, :, 3),YN,XN,'linear');
figure, imshow(cat(3, r, g, b));

% morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);


% PART 3: The Morph Sequence
im1 = 0;
im2 = 0;

im1_pts = 0;
im2_pts = 0;

tri = 0;


warp_frac = 0;
dissolve_frac = 0;

morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);

% PART 4: The "Mean face" of a population



% PART 5: Caricatures: Extrapolating from the mean


% PART 6: Bells and Whistles #1


% PART 7: Bells and Whistles #2



% Functions:

function A = computeAffine(tri1_pts,tri2_pts, xy1_pts, xy2_pts)
    r1 = [xy1_pts(tri1_pts(1, 1), :), 1];
    r2 = [xy1_pts(tri1_pts(1, 2), :), 1];
    r3 = [xy1_pts(tri1_pts(1, 3), :), 1];
    x = vertcat(r1, r2, r3).';
    
    r1 = [xy2_pts(tri2_pts(1, 1), :), 1];
    r2 = [xy2_pts(tri2_pts(1, 2), :), 1];
    r3 = [xy2_pts(tri2_pts(1, 3), :), 1];
    
    b = vertcat(r1, r2, r3).';
    
    A = b/x;
    A(3, :) = [0, 0, 1];
    
end

function morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);
    morphed_im = 0;
end
