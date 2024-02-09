close all;
clear;

poor_lightinng = imread("data_set/uno-test-15.jpg");
good_lightinng = imread("data_set/uno-test-23.jpg");

% im = rgb2hsv(poor_lightinng); 
% channel_h_poor = im(:,:,1);
% channel_s_poor = im(:,:,2);
% channel_v_poor = im(:,:,3);
% 
% im = rgb2hsv(good_lightinng);  
% channel_h_good = im(:,:,1);
% channel_s_good = im(:,:,2);
% channel_v_good = im(:,:,3);

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

% figure(1);
% subplot(2,3,1), imshow(channel_h_poor), title("H poor lightning");
% subplot(2,3,2), imshow(channel_s_poor), title("S poor lightning");
% subplot(2,3,3), imshow(channel_v_poor), title("V poor lightning");
% subplot(2,3,4), imshow(channel_h_good), title("H good lightning");
% subplot(2,3,5), imshow(channel_s_good), title("S good lightning");
% subplot(2,3,6), imshow(channel_v_good), title("V good lightning");

figure(2),  imshow(niblack(channel_cr_good, [11, 11]));

% I = im2double(imread('medtest.png'));
% x=198; y=359;
% J = regiongrowing(I,x,y,0.2); 
% figure(1);
% subplot(1,3,1), imshow(I);
% subplot(1,3,2), imshow(J);
% subplot(1,3,3), imshow(I+J);
