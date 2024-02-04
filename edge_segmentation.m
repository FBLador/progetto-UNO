function edge_segmentation()
    % Chiude tutte le figure aperte e pulisce l'ambiente di lavoro
    close all;
    clear;

    % Carica e mostra le immagini tipica e overlay
    typical_img = 'training_set/uno-test-23.jpg';
    overlay_img = 'training_set/uno-test-20.jpg';
    displayImages(typical_img, overlay_img);
    
    % Estrazione e visualizzazione degli edge
    edgeDetection(typical_img, overlay_img);
    
    % Edge linking e visualizzazione del risultato
    linkedEdges = edgeLinking(typical_img);
    figure('Name', 'Edge Linked Image');
    imshow(linkedEdges);
    title('Linked Edges');
    
    % Filtraggio dei contorni e correzione dell'orientamento
    filteredContours = filterAndCorrectContours(linkedEdges);
    figure('Name', 'Filtered and Oriented Contours');
    imshow(filteredContours);
    title('Filtered and Oriented Contours');
end

function displayImages(typical_img_path, overlay_img_path)
    % Mostra le immagini e le loro componenti Cb e Cr
    typical_img = imread(typical_img_path);
    overlay_img = imread(overlay_img_path);
    
    figure('Name', 'Componenti Cb e Cr');
    displayChannelComponents(typical_img, 'Tipica');
    %displayChannelComponents(overlay_img, 'Overlay');
end

function displayChannelComponents(img, titlePrefix)
    im = rgb2ycbcr(img);
    subplot(2,2,1), imshow(im(:,:,2)), title([titlePrefix, ' - Cb']);
    subplot(2,2,2), imshow(im(:,:,3)), title([titlePrefix, ' - Cr']);
end

function edgeDetection(typical_img_path, overlay_img_path)
    % Rilevamento degli edge per le immagini tipica e overlay
    typical_img = imread(typical_img_path);
    overlay_img = imread(overlay_img_path);
    
    figure('Name', 'Rilevamento Edge');
    detectAndDisplayEdges(rgb2ycbcr(typical_img), 'Tipica');
    %detectAndDisplayEdges(rgb2ycbcr(overlay_img), 'Overlay');
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

function filteredContours = filterAndCorrectContours(binaryImage)
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
        if contourArea > 500 % esempio di soglia, da aggiustare
            % Calcola il rettangolo di delimitazione minimo e l'orientamento
            rect = minAreaRect(contour, size(binaryImage));
            
            % Aggiungi il contorno all'immagine filtrata
            filteredContours = filteredContours | poly2mask(contour(:,2), contour(:,1), size(binaryImage, 1), size(binaryImage, 2));
        end
    end
end

function rect = minAreaRect(contour, imageSize)
    % Calcola il rettangolo di delimitazione minimo per il contorno fornito
    % imageSize è un vettore [altezza, larghezza] dell'immagine
    props = regionprops(poly2mask(contour(:,2), contour(:,1), imageSize(1), imageSize(2)), 'BoundingBox', 'Orientation');
    rect = props.BoundingBox;
end
