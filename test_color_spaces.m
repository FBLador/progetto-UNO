close all;
clear;

poor_lightinng = imread("test_set/uno-test-28.jpg");
good_lightinng = imread("test_set/uno-test-24.jpg");

%RGB poor_lightning
figure(1);
channel1 = poor_lightinng(:,:,1);
channel2 = poor_lightinng(:,:,2);
channel3 = poor_lightinng(:,:,3);
subplot(2,3,1), imshow(channel1), title("RED poor lightning");
subplot(2,3,2), imshow(channel3), title("BLUE poor lightning");
subplot(2,3,3), imshow(channel2), title("GREEN poor lightning");
subplot(2,3,4), imhist(channel1);
subplot(2,3,5), imhist(channel3);
subplot(2,3,6), imhist(channel2);

%RGB good_lightning
figure(2);
channel1 = good_lightinng(:,:,1);
channel2 = good_lightinng(:,:,2);
channel3 = good_lightinng(:,:,3);
subplot(2,3,1), imshow(channel1), title("RED good lightning");
subplot(2,3,2), imshow(channel3), title("BLUE good lightning");
subplot(2,3,3), imshow(channel2), title("GREEN good lightning");
subplot(2,3,4), imhist(channel1);
subplot(2,3,5), imhist(channel3);
subplot(2,3,6), imhist(channel2);

%YCbCr poor_lightning
im = rgb2ycbcr(poor_lightinng);
figure(3);
channel1 = im(:,:,1);
channel2 = im(:,:,2);
channel3 = im(:,:,3);
subplot(2,3,1), imshow(channel1), title("Y poor lightning");
subplot(2,3,2), imshow(channel3), title("Cb poor lightning");
subplot(2,3,3), imshow(channel2), title("Cr poor lightning");
subplot(2,3,4), imhist(channel1);
subplot(2,3,5), imhist(channel3);
subplot(2,3,6), imhist(channel2);

%YCbCr good_lightning
im = rgb2ycbcr(good_lightinng);
figure(4);
channel1 = im(:,:,1);
channel2 = im(:,:,2);
channel3 = im(:,:,3);
subplot(2,3,1), imshow(channel1), title("Y good lightning");
subplot(2,3,2), imshow(channel3), title("Cb good lightning");
subplot(2,3,3), imshow(channel2), title("Cr good lightning");
subplot(2,3,4), imhist(channel1);
subplot(2,3,5), imhist(channel3);
subplot(2,3,6), imhist(channel2);

%HSV poor_lightning
im = rgb2hsv(poor_lightinng);
figure(5);
channel1 = im(:,:,1);
channel2 = im(:,:,2);
channel3 = im(:,:,3);
subplot(2,3,1), imshow(channel1), title("H poor lightning");
subplot(2,3,2), imshow(channel3), title("S poor lightning");
subplot(2,3,3), imshow(channel2), title("V poor lightning");
subplot(2,3,4), imhist(channel1);
subplot(2,3,5), imhist(channel3);
subplot(2,3,6), imhist(channel2);

%HSV good_lightning
im = rgb2hsv(good_lightinng);
figure(6);
channel1 = im(:,:,1);
channel2 = im(:,:,2);
channel3 = im(:,:,3);
subplot(2,3,1), imshow(channel1), title("H good lightning");
subplot(2,3,2), imshow(channel3), title("S good lightning");
subplot(2,3,3), imshow(channel2), title("V good lightning");
subplot(2,3,4), imhist(channel1);
subplot(2,3,5), imhist(channel3);
subplot(2,3,6), imhist(channel2);

