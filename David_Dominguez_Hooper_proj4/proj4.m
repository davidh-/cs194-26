% CS194-26 (cs219-26): Project 4
% David Dominguez Hooper 24828373

close all; % closes all figures

% Part 1: Defining Correspondences


% PART 2: Computing the "Mid-way Face"

tri1_pts = 0;
tri2_pts = 0;


A = computeAffine(tri1_pts,tri2_pts);


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

function A = computeAffine(tri1_pts,tri2_pts)
    A = 0;
end

function morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);
    morphed_im = 0;
end
