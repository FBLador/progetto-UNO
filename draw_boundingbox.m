close all;
clear;

in = imread("data_set/uno-test-01.jpg");
image = rgb2ycbcr(in);
channel_cb = image(:,:,2);
binarized = imbinarize(channel_cb, graythresh(channel_cb));
segmented = imfill(imbinarize(channel_cb, graythresh(channel_cb)), "holes");

% labels = bwlabel(segmented);
% figure(1), imagesc(labels), axis image, colorbar;

%The regionprops function measures properties such as area, centroid, and
%bounding box, for each object (connected component) in an image
boundingbox = regionprops(segmented, "BoundingBox");

%inserisce testo per ogni bounding box
positions = [];
for k = 1 : length(boundingbox)
  thisBB = boundingbox(k).BoundingBox;
  %calcola il centro della boundingbox
  x = thisBB(1) + thisBB(3)/2;
  y = thisBB(2) + thisBB(4)/2;
  positions = [positions; x, y];
end
in_text = insertText(in, positions, "numero, colore", FontSize=18, TextBoxColor="red");
figure(1), imshow(in_text);

%disegna un rettangolo attorno all'immagine
for k = 1 : length(boundingbox)
  thisBB = boundingbox(k).BoundingBox;
  rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)], 'EdgeColor','r','LineWidth',2 )
end



