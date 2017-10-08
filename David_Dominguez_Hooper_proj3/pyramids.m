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
    end
end