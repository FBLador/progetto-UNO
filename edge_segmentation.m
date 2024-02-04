function edge_segmentation()
    close all;

    % Carica l'immagine
    training_img = 'training_set/uno-test-14.jpg';
    
    % Estrazione e visualizzazione degli edge
    edgeDetection(training_img);
    
    % Edge linking e visualizzazione del risultato
    linkedEdges = edgeLinking(training_img);
    figure('Name', 'Edge Linked Image');
    imshow(linkedEdges);
    title('Linked Edges');
    
    % Filtraggio dei contorni
    filteredContours = filterContours(linkedEdges);
    figure('Name', 'Filtered Contours');
    imshow(filteredContours);
    title('Filtered Contours');

    % Estrazione carte e orientamento
    extractAndRotateCards(filteredContours, imread(training_img));
end

function displayChannelComponents(img, titlePrefix)
    im = rgb2ycbcr(img);
    subplot(2,2,1), imshow(im(:,:,2)), title([titlePrefix, ' - Cb']);
    subplot(2,2,2), imshow(im(:,:,3)), title([titlePrefix, ' - Cr']);
end

function edgeDetection(training_img_path)
    % Rilevamento degli edge per le immagini tipica e overlay
    training_img = imread(training_img_path);
    
    figure('Name', 'Rilevamento Edge');
    detectAndDisplayEdges(rgb2ycbcr(training_img), 'Tipica');
end

function detectAndDisplayEdges(im, titlePrefix)
    channel_cb = im(:,:,2);
    channel_cr = im(:,:,3);
    subplot(2,2,1), imshow(edge(channel_cb)), title([titlePrefix, ' - Cb']);
    subplot(2,2,2), imshow(edge(channel_cr)), title([titlePrefix, ' - Cr']);
end

function linkedEdges = edgeLinking(img_path)
    % Effettua l'edge linking su una immagine specificata
    img = imread(img_path);
    im = rgb2ycbcr(img);
    channel_cr = im(:,:,3);
    
    % Rileva i bordi utilizzando un operatore di bordo
    edges = edge(channel_cr);
    
    % Elemento strutturante per operazioni morfologiche
    se = strel('disk', 1);
    
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
end

function extractAndRotateCards(binaryImage, originalImage)
    % Identifica le proprietà delle regioni bianche (carte)
    props = regionprops(binaryImage, 'BoundingBox', 'Orientation', 'MajorAxisLength', 'MinorAxisLength');
    
    for i = 1:length(props)
        % Estrai il BoundingBox e l'Orientation di ciascuna carta
        boundingBox = round(props(i).BoundingBox);
        orientation = props(i).Orientation;
        correctedOrientation = orientation + 90;
        
        % Estrai l'immagine della carta utilizzando il BoundingBox
        cardImage = imcrop(originalImage, boundingBox);
        
        % Ruota l'immagine della carta in base al suo orientamento
        rotatedCardImage = imrotate(cardImage, -correctedOrientation , 'bilinear', 'crop');
        
        % Visualizza l'immagine estratta e ruotata
        figure, imshow(rotatedCardImage);
        title(['Card ', num2str(i)]);
    end
end

