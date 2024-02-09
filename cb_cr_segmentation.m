close all;
clear;

poor_lightinng = imread("data_set/uno-test-15.jpg");
good_lightinng = imread("data_set/uno-test-25.jpg");


im = rgb2ycbcr(poor_lightinng);    %YCbCr poor_lightning
channel_cb_poor = im(:,:,2);
channel_cr_poor = im(:,:,3);

im = rgb2ycbcr(good_lightinng);    %YCbCr good_lightning
channel_cb_good = im(:,:,2);
channel_cr_good = im(:,:,3);

figure(1);
subplot(2,2,1), imshow(channel_cb_poor), title("Cb poor lightning");
subplot(2,2,2), imshow(channel_cr_poor), title("Cr poor lightning");
subplot(2,2,3), imshow(channel_cb_good), title("Cb good lightning");
subplot(2,2,4), imshow(channel_cr_good), title("Cr good lightning");

%edge find (edge based segmentation)
figure(2);
subplot(2,2,1), imshow(edge(channel_cb_poor)), title("Cb poor lightning");
subplot(2,2,2), imshow(edge(channel_cr_poor)), title("Cr poor lightning");
subplot(2,2,3), imshow(edge(channel_cb_good)), title("Cb good lightning");
subplot(2,2,4), imshow(edge(channel_cr_good)), title("Cr good lightning");

%threshold (region based segmentation)
figure(3);
subplot(2,2,1), imshow(imbinarize(channel_cb_poor, graythresh(channel_cb_poor))), title("Cb poor lightning");
subplot(2,2,2), imshow(imbinarize(channel_cr_poor, graythresh(channel_cr_poor))), title("Cr poor lightning");
subplot(2,2,3), imshow(imbinarize(channel_cb_good, graythresh(channel_cb_good))), title("Cb good lightning");
subplot(2,2,4), imshow(imbinarize(channel_cr_good, graythresh(channel_cr_good))), title("Cr good lightning");
%tengo il cb perchè con cr la segmentazione ha una certa probabilità di
%venire in negativo

%hole filling after threshold 
figure(4);
subplot(1,2,1), imshow(imfill(imbinarize(channel_cb_poor, graythresh(channel_cb_poor)), "holes")), title("Cb poor lightning");
subplot(1,2,2), imshow(imfill(imbinarize(channel_cb_good, graythresh(channel_cb_good)), "holes")), title("Cb good lightning");
