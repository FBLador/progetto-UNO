%quest script converte le immagini risolvendo questo errore
%MAP must be a m x 3 array. Use im2gray for RGB and grayscale images

[images, labels] = readlists();
n_images = numel(images);

for i = 151 : n_images
    try
        [im, map] = imread(images{i});
        im = ind2rgb(im, map);
    catch e
        e.message
        images{i}
    end
    imwrite(im, images{i});
end