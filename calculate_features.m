clear;
close all;

[images, labels] = readlists();
n_images = numel(images);

%features descriptors
lbp = zeros(n_images, 59); %prealloco l'array perchè so che per ogni immagine vengono prodotti 59 descrittori
qhist = zeros(n_images, 4096);
CEDD = [];

%calculate descriptors
for i = 1 : n_images
    im = imread(images{i});

    lbp(i, :) = compute_lbp(rgb2gray(im));
    qhist(i, :) = compute_qhist(im);
    CEDD = [CEDD; compute_CEDD(im)];
end

save('features_data.mat', "images", "labels", "lbp", "qhist", "CEDD");
