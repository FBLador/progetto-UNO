% Carica l'immagine
img = imread('uno-test-26.jpg');

% Converti l'immagine in scala di grigi se è a colori
if size(img, 3) == 3
    img_gray = rgb2gray(img);
else
    img_gray = img;
end

% Applica un filtro di denoising gaussiano
% 'hsize' è la dimensione del filtro e 'sigma' è la deviazione standard del rumore
hsize = [5 5]; % Dimensione del kernel del filtro
sigma = 2; % Deviazione standard per il rumore gaussiano
img_filtered = imgaussfilt(img_gray, sigma, 'FilterSize', hsize);

% Applica la trasformazione di Anscombe
f = @(x) 2 * sqrt(x + 3/8);
img_gray_double = double(img_gray); % Converti in double per la trasformazione
img_anscombe = f(img_gray_double);

% Applica un filtro di denoising gaussiano
hsize = [5 5]; % Dimensione del kernel del filtro
sigma = 1; % Deviazione standard per il rumore gaussiano
img_filtered_anscombe = imgaussfilt(img_anscombe, sigma, 'FilterSize', hsize);

% Normalizza l'immagine filtrata per l'intervallo di pixel 0-255
img_filtered_anscombe_normalized = mat2gray(img_filtered); % Converti nell'intervallo [0, 1]
img_filtered_anscombe_normalized = uint8(img_filtered_anscombe_normalized * 255); % Scala a 0-255

% Visualizza l'immagine originale e filtrata insieme ai loro istogrammi
figure;
% Immagine originale
subplot(3, 3, 1);
imshow(img_gray);
title('Original Image');

subplot(3, 3, 4);
imhist(img_gray);
title('Histogram of Original Image');

% Immagine filtrata
subplot(3, 3, 2);
imshow(img_filtered);
title('Gaussian denoised');

subplot(3, 3, 5);
imhist(img_filtered);
title('Histogram of Gaussian denoised');

% filtrata anscombe
subplot(3, 3, 3);
imshow(img_filtered_anscombe_normalized);
title('anscombe denoised');

subplot(3, 3, 6);
imhist(img_filtered_anscombe_normalized);
title('Histogram of anscombe denoised');
