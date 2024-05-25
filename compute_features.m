clear;
close all;

[images, labels] = readlists();
n_images = numel(images);

%FEATURES DECRIPTORS
%lbp = zeros(n_images, 59);      %prealloco l'array perchè so che per ogni immagine vengono prodotti 59 descrittori
%qhist = zeros(n_images, 4096);  %prealloco l'array perchè so che per ogni immagine vengono prodotti 4096 descrittori
%CEDD = zeros(n_images, 144);    %prealloco l'array perchè so che per ogni immagine vengono prodotti 144 descrittori
%hog = [];
sift = [];
surf = [];
kaze = [];

%calculate descriptors
for i = 1 : n_images
    %fprintf(1,'Immagine: %s\n', images{i});

    try
        im = imread(images{i});

        %FOR TESTING INSIDE CONSOLE (cambia solo il nome della funzione)
        %extractFeatures(im2gray(imread("back_2.jpg")), detectBRISKFeatures(im2gray(imread("back_2.jpg"))), Method="BRISK")

        %lbp(i, :) = compute_lbp(rgb2gray(im));
        %qhist(i, :) = compute_qhist(im);
        %CEDD(i, :) = compute_CEDD(im);
        %hog(i, :) = [hog; extractHOGFeatures(im)];
        SIFTPoints = detectSIFTFeatures(im2gray(im));
        sift = [sift; extractFeatures(im2gray(im), SIFTPoints, Method="SIFT")];
        imshow(sift);
        SURFPoints = detectSURFFeatures(im2gray(im));
        surf = [surf; extractFeatures(im2gray(im), SURFPoints, Method="SURF")];
        KAZEPoints = detectKAZEFeatures(im2gray(im));
        kaze = [kaze; extractFeatures(im2gray(im), KAZEPoints, Method="KAZE")];
    catch e1
        fprintf(2,'Errore primo try-catch: %s - %s\nImmagine: %s\n', e1.identifier, e1.message, images{i});
        
        %quest script converte le immagini risolvendo questo errore:
        %MAP must be a m x 3 array. Use im2gray for RGB and grayscale images
        try
            [im, map] = imread(images{i});
            im = im2uint8(ind2rgb(im, map));

            %lbp(i, :) = compute_lbp(rgb2gray(im));
            %qhist(i, :) = compute_qhist(im);
            %CEDD(i, :) = compute_CEDD(im);
            %hog(i, :) = extractHOGFeatures(im);
            sift = [sift; detectSIFTFeatures(im2gray(im))];
        catch e2
            fprintf(2,'Errore secondo try-catch: %s - %s\nImmagine: %s\n', e2.identifier, e2.message, images{i});
        end
    end
    
end

%save('features_data.mat', "images", "labels", "lbp", "qhist", "CEDD");
save('features_data.mat', "images", "labels", "hog");
