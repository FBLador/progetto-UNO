function edge_segmentation()
    close all;

    % Carica l'immagine
    training_img = 'training_set/uno-test-04.jpg';
    template_img = 'templates/5_blue_symbol.png';
    
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

    % Estrazione carte, orientamento e ricezione dell'array di immagini
    cardImages = extractAndRotateCards(filteredContours, imread(training_img));
    
    % Template matching su ciascuna immagine della carta
    for i = 1:length(cardImages)
        templateMatching(cardImages{i}, imread(template_img));
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
        
        % Ruota l'immagine della carta in base al suo orientamento
        rotatedCardImage = imrotate(cardImage, -correctedOrientation , 'bilinear', 'crop');
        
        % Aggiungi l'immagine ruotata all'array
        cardImages{end+1} = rotatedCardImage;
    end
end

function approximateEdges(linkedEdges, originalImage)
    % Prepara l'immagine di sfondo per il disegno dei contorni
    % Puoi usare l'immagine originale come sfondo per disegnare i contorni approssimati
    % Oppure, per una visualizzazione più chiara, usa una maschera bianca della stessa dimensione dell'immagine originale
    background = originalImage; % Sostituisci con '255 * ones(size(linkedEdges))' per una maschera bianca
    
    % Trova contorni
    contours = bwboundaries(linkedEdges, 'noholes');
    
    figure; imshow(background); title('Contorni Approssimati su Immagine Originale');
    hold on;
    
    for i = 1:length(contours)
        boundary = contours{i};
        
        % Calcola l'approssimazione poligonale del contorno e cattura il risultato
        polygon = approximatePolygon(boundary, 90); % Assicurati che questa chiamata restituisca 'polygon'
        
        % Disegna il poligono approssimato, se ha almeno 4 vertici (+1
        % perché il primo è doppio)
        if size(polygon, 1) == 5
            plot(polygon(:,2), polygon(:,1), 'r', 'LineWidth', 2);
        end
    end
    
    hold off;
end

function polygon = approximatePolygon(contour, angleThreshold)
    % Initialize the polygon with the first point of the contour
    first_point = contour(1, :);
    polygon = first_point; % Initialize polygon with the first point
    
    % Loop through the contour starting from the second point
    for i = 3:size(contour, 1)
        last_point = contour(i-1, :);
        new_point = contour(i, :);
        
        % Calculate vectors for the two segments
        vector1 = last_point - first_point;
        vector2 = new_point - last_point;
        
        % Calculate the angle between the two segments
        angle = calculateAngleBetweenVectors(vector1, vector2);
        
        % Check if the angle exceeds the threshold
        if angle > angleThreshold
            % Add last_point as a new vertex of the polygon
            polygon = [polygon; last_point];
            
            % Update first_point to be the new vertex
            first_point = last_point;
        end
    end
    
    % Add the final point if not already added
    if ~isequal(polygon(end, :), contour(end, :))
        polygon = [polygon; contour(end, :)];
    end
end

function angle = calculateAngleBetweenVectors(v1, v2)
    % Calculate the angle between two vectors using the dot product
    dotProd = dot(v1, v2);
    norms = norm(v1) * norm(v2);
    angle = acosd(dotProd / norms); % Angle in degrees
end

function templateMatching(cardImage, template)
    % Converte le immagini in scala di grigi se sono a colori
    if size(cardImage, 3) == 3
        cardImageGray = rgb2gray(cardImage);
    else
        cardImageGray = cardImage;
    end
    
    if size(template, 3) == 3
        templateGray = rgb2gray(template);
    else
        templateGray = template;
    end
    
    % Si assicura che il template sia più piccolo dell'immagine della carta
    if any(size(templateGray) > size(cardImageGray))
        scaleFactor = min(size(cardImageGray) ./ size(templateGray));
        templateGray = imresize(templateGray, scaleFactor); % Ridimensiona il template
    end
    
    % Calcola la correlazione incrociata normalizzata
    correlationOutput = normxcorr2(templateGray, cardImageGray);
    
    % Trova la posizione di massima corrispondenza
    %[maxCorrValue, maxIndex] = max(abs(correlationOutput(:)));
    %[yPeak, xPeak] = ind2sub(size(correlationOutput), maxIndex(1));
    
    % Calcola la posizione del template match nell'immagine della carta
    %yOffSet = yPeak - size(templateGray, 1);
    %xOffSet = xPeak - size(templateGray, 2);
    
    figure;
    %imshow(cardImageGray);
    imagesc(correlationOutput), axis image, colorbar;
    %hold on;
    %rectangle('Position', [xOffSet, yOffSet, size(templateGray, 2), size(templateGray, 1)], 'EdgeColor', 'red', 'LineWidth', 2);
    %title('Template Matching Result');
    %hold off;
end



