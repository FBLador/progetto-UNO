function edge_segmentation()
    close all;

    % Carica l'immagine
    training_img = 'data_set/uno-test-27.jpg';

    % Estrazione e visualizzazione degli edge
    edgeDetection(training_img);
    
    % Edge linking e visualizzazione del risultato
    linkedEdges = edgeLinking(training_img);
    
    % Filtraggio dei contorni
    filteredContours = filterContours(linkedEdges);
    figure('Name', 'Filtered Contours');
    imshow(filteredContours);
    title('Filtered Contours');

    % Estrazione carte, orientamento e ricezione dell'array di immagini
    cardImages = extractAndRotateCards(filteredContours, imread(training_img));

     % Per ogni carta, cerca di capirne il colore analizzando l'immagine
    cardColors = cell(numel(cardImages), 1);
    for i = 1:numel(cardImages)
        % Determinazione del colore
        cardColors{i} = determineCardColor(cardImages{i});
    end

    % Poi mostra tutte le immagini in una finestra
    figure('Name', 'Card Images');
    numImages = length(cardImages);
    for i = 1:numImages
        subplot(ceil(sqrt(numImages)), ceil(sqrt(numImages)), i);
        imshow(cardImages{i});
        title(['Card ', num2str(i), ' - ', cardColors{i}]);
    end

end

function displayChannelComponents(img, titlePrefix)
    im = rgb2ycbcr(img);
    subplot(2,2,1), imshow(im(:,:,2)), title([titlePrefix, ' - Cb']);
    subplot(2,2,2), imshow(im(:,:,3)), title([titlePrefix, ' - Cr']);
end

function edgeDetection(training_img_path)
    % Rilevamento degli edge per le immagini tipica e overlay
    training_img = imread(training_img_path);
    
    %figure('Name', 'Rilevamento Edge');
    detectAndDisplayEdges(rgb2ycbcr(training_img), 'Tipica');
end

function detectAndDisplayEdges(im, titlePrefix)
    channel_cb = im(:,:,2);
    channel_cr = im(:,:,3);
    %subplot(2,2,1), imshow(edge(channel_cb)), title([titlePrefix, ' - Cb']);
    %subplot(2,2,2), imshow(edge(channel_cr)), title([titlePrefix, ' - Cr']);
end

function linkedEdges = edgeLinking(img_path)
    % Effettua l'edge linking su una immagine specificata
    img = imread(img_path);
    im = rgb2ycbcr(img);
    channel_cr = im(:,:,3);
    
    % Rileva i bordi utilizzando un operatore di bordo
    edges = edge(channel_cr);
    
    % Elemento strutturante per operazioni morfologiche
    se = strel('disk', 3);
    
    % Chiusura morfologica per colmare le lacune nei bordi
    closedEdges = imclose(edges, se);
    
    % Dilatazione degli edge per unire eventuali parti disconnesse
    dilatedEdges = imdilate(closedEdges, se);
    
    % Chiusura morfologica per colmare le lacune nei bordi
    closedEdges2 = imclose(dilatedEdges, se);
    
    % Apertura morfologica per rimuovere piccoli oggetti o sporgenze
    openedEdges = imopen(closedEdges2, se);
    
    % Rimozione delle aree più piccole per pulire ulteriormente l'immagine
    linkedEdges = bwareaopen(openedEdges, 1000);
end

function filteredContours = filterContours(binaryImage)
    % Identifica i contorni nell'immagine binaria
    [contours, ~] = bwboundaries(binaryImage, 'noholes');
    
    % Inizializza un'immagine per mostrare i contorni filtrati
    filteredContours = false(size(binaryImage));
    
    % Cicla su ogni contorno trovato
    for i = 1:length(contours)
        contour = contours{i};
        
        % Calcola l'area del contorno
        contourArea = polyarea(contour(:,2), contour(:,1));
        
        % Filtra i contorni basati sull'area
        if contourArea > 1000 % esempio di soglia, da aggiustare
          
            % Aggiungi il contorno all'immagine filtrata
            filteredContours = filteredContours | poly2mask(contour(:,2), contour(:,1), size(binaryImage, 1), size(binaryImage, 2));
        end
    end

    % Riempie i buchi nelle regioni connesse dell'immagine binaria
    filteredContours = imerode(filteredContours, strel('disk', 17));
    filteredContours = imdilate(filteredContours, strel('disk', 1));
    filteredContours = imfill(filteredContours, 'holes');
    filteredContours = imopen(filteredContours, strel('disk', 1));
end

function cardImages = extractAndRotateCards(binaryImage, originalImage)
    % Identifica le proprietà delle regioni bianche (carte)
    props = regionprops(binaryImage, 'BoundingBox', 'Orientation', 'MajorAxisLength', 'MinorAxisLength');
    
    % Inizializza un array per memorizzare le immagini delle carte
    cardImages = {};
    
    for i = 1:length(props)
        % Estrai il BoundingBox e l'Orientation di ciascuna carta
        boundingBox = round(props(i).BoundingBox);
        orientation = props(i).Orientation;
        correctedOrientation = orientation + 90;
        
        % Estrai l'immagine della carta utilizzando il BoundingBox
        cardImage = imcrop(originalImage, boundingBox);
        
        % Estrai la maschera della regione corrispondente
        cardMask = imcrop(binaryImage, boundingBox);
   
        
        % Applica la maschera alla carta per mantenere solo i pixel della carta
        cardImageMasked = bsxfun(@times, cardImage, cast(cardMask, 'like', cardImage));
        
        % Ruota l'immagine della carta in base al suo orientamento
        rotatedCardImage = imrotate(cardImageMasked, -correctedOrientation, 'bilinear', 'crop');
        
        % Aggiungi l'immagine ruotata all'array
        cardImages{end+1} = rotatedCardImage;
        
        % Visualizza l'immagine estratta e ruotata (facoltativo)
        %figure, imshow(rotatedCardImage);
        %title(['Card ', num2str(i)]);
    end
end



function color = determineCardColor(cardImage)
    % Ridimensiona l'immagine per facilitare l'analisi del colore
    resizedCard = imresize(cardImage, [100, 100]);

    % Converte l'immagine in spazio colore HSV
    hsvImage = rgb2hsv(resizedCard);

    % Estrae i canali H, S, V
    H = hsvImage(:, :, 1);
    S = hsvImage(:, :, 2);
    V = hsvImage(:, :, 3);

    % Definizione dei range per i colori principali
    redMask = (H <= 0.11 | H >= 0.90) & S > 0.25 & V > 0.3;
    blueMask = H > 0.51 & H < 0.90 & S > 0.35 & V > 0.3;
    greenMask = H >= 0.22 & H <= 0.51 & S >  0.25 & V > 0.3;
    yellowMask = H > 0.11 & H < 0.22 & S >  0.25 & V > 0.3;

    % Definisci un elemento strutturante
    se = strel('disk', 3);

    % Applica un'operazione di apertura a ogni maschera
    redMask = imopen(redMask, se);
    blueMask = imopen(blueMask, se);
    greenMask = imopen(greenMask, se);
    yellowMask = imopen(yellowMask, se);

    % Conta i pixel per ciascun colore
    numRed = sum(redMask(:))
    numBlue = sum(blueMask(:))
    numGreen = sum(greenMask(:));
    numYellow = sum(yellowMask(:));

    % Determina il colore predominante
    [~, idx] = max([1, numRed, numBlue, numGreen, numYellow]);
    colors = {'unknown', 'Red', 'Blue', 'Green', 'Yellow'};
    color = colors{idx};
end

