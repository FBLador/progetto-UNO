clear;
close all;

[images, labels] = readlists();
n_images = numel(images);

%features descriptors
lbp = zeros(n_images, 59); %prealloco l'array perchè so che per ogni immagine vengono prodotti 59 descrittori
qhist = zeros(n_images, 4096);
CEDD = zeros(n_images, 144);

%calculate descriptors
for i = 1 : n_images
    %ci sono delle immagini che imread non riesce a leggere
    %"Error using imread>get_format_info"
    try
        im = imread(images{i});

        lbp(i, :) = compute_lbp(rgb2gray(im));
        qhist(i, :) = compute_qhist(im);
        CEDD = compute_CEDD(im);
    catch
        images{i}
    end
    
end

save('features_data.mat', "images", "labels", "lbp", "qhist", "CEDD");
