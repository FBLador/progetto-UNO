[images, labels] = readlists();
n_images = numel(images);

for i = 151 : n_images
    [im, map] = imread(images{i});
    im = ind2rgb(im, map);

    imwrite(im, images{i});
end