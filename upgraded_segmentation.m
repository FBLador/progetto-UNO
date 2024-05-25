function upgraded_segmentation()
    close all;
    
    %Debug flag
    showDebugImages = false;

    data_set_folder = dir("data_set");
    for i = 4 : numel(data_set_folder)
        
        %Carica immagine
        testImage = imread("./data_set/" + data_set_folder(i).name);
        %Edge linking e visualizzazione del risultato
        linkedEdges = edgeWithSobelAndLinking(testImage, showDebugImages);       
        %Riempimento buchi
        segmentedImage = fillHoles(linkedEdges, showDebugImages);
        segmentedImage = imbinarize(segmentedImage);

        %Estrazione carte, orientamento e ricezione dell'array di immagini
        cardImages = extractAndRotateCards(segmentedImage, testImage);

        %Predico il tipo della carta estratta dalla foto
        %SVMClassifier = load("SVMClassifier.mat");
        simpleCNNClassifier = load("SimpleCNNClassifier.mat");
        net = simpleCNNClassifier.net;
        imageSize = net.Layers(1).InputSize;

        predictedLabels = strings(1, length(cardImages));
        confidences = zeros(length(cardImages));
        classes = {'back', 'card_0' , 'card_1', 'card_2', 'card_3' , 'card_4', 'card_5', 'card_6' , 'card_7', 'card_8', 'card_9' , 'draw_card', 'reverse_card', 'skip_card', 'wild' , 'wild_draw'};
        for j = 1 : length(cardImages)
            % --- Per BoW_SURF_SVM ---

            %[predictedLabelIndex, scores] = predict(SVMClassifier, cardImages{j});
            %predictedLabel = SVMClassifier.Labels{predictedLabelIndex};
            %predictedLabels(j) = predictedLabel;

            % --- Fine BoW_SURF_SVM ---



            % --- Per SimpleCNN ---
            im = imresize3(cardImages{j}, imageSize);
            im = imgaussfilt(im, 1);

            scores = predict(net, single(im));
            predictedLabel = classes{find(scores == max(scores))}
            predictedLabels(j) = predictedLabel;
            confidences(j) = scores(find(scores == max(scores))) * 100;
 
            % --- Fine SimpleCNN ---
        end

        %Disegna le bounding box
        [image_with_text, boundingboxes] = drawBoundingbox(segmentedImage, testImage, predictedLabels, confidences);

        if showDebugImages
            f = figure("Name", data_set_folder(i).name), f.WindowState = "maximized";
            subplot(1, 3, 1), imshow(testImage);
            subplot(1, 3, 2), imshow(segmentedImage);
            subplot(1, 3, 3), imshow(image_with_text);
        end

        %disegna un rettangolo attorno all'immagine
        for k = 1 : length(boundingboxes)
            thisBB = boundingboxes(k).BoundingBox;
            rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)], 'EdgeColor','r','LineWidth',2 )
        end
        
        close all;
    end
end

function linkedEdges = edgeWithSobelAndLinking(im, debug_flag)
    % Effettua l'edge linking su una immagine specificata
    im = rgb2ycbcr(im);
    channel_cr = im(:,:,3);
    
    % Rileva i bordi utilizzando un operatore di bordo
    edges = edge(channel_cr);
    if debug_flag
        figure("Name", "Rileva i bordi utilizzando Sobel"), imshow(edges);
    end
    
    % Elemento strutturante per operazioni morfologiche
    se = strel('disk', 1);
    
    % Chiusura morfologica per colmare le lacune nei bordi
    closedEdges = imclose(edges, se);
    if debug_flag
        figure("Name", "Chiusura morfologica per colmare le lacune nei bordi"), imshow(closedEdges);
    end

    % Dilatazione degli edge per unire eventuali parti disconnesse
    dilatedEdges = imdilate(closedEdges, se);
    if debug_flag
        figure("Name", "Dilatazione degli edge per unire eventuali parti disconnesse"), imshow(closedEdges);    
    end

    % Ulteriore chiusura morfologica per colmare le lacune nei bordi
    closedEdges2 = imclose(dilatedEdges, se);
    if debug_flag
        figure("Name", "Ulteriore hiusura morfologica per colmare le lacune nei bordi"), imshow(closedEdges2);    
    end

    % Apertura morfologica per rimuovere piccoli oggetti o sporgenze
    openedEdges = imopen(closedEdges2, se);
    if debug_flag
        figure("Name", "Apertura morfologica per rimuovere piccoli oggetti o sporgenze"), imshow(openedEdges);    
    end

    % Rimozione delle aree più piccole per pulire ulteriormente l'immagine
    linkedEdges = bwareaopen(openedEdges, 1000);
    if debug_flag
        figure("Name", "Rimozione delle aree più piccole per pulire ulteriormente l'immagine"), imshow(linkedEdges);    
    end
end

function filledImage = fillHoles(im, debug_flag)

    %Riempio i buchi
    temp = imfill(im, "holes");
    if debug_flag
        figure("Name", "Riempio i buchi"), imshow(temp);    
    end
    
    %Questa parte risolve il problema per cui imfill non considera i buchi
    %tagliati dai bordi dell'immagine
    %Creo un'immagine maschera
    mask = ones(size(im, 1), size(im, 2));
    mask = mask - temp;
    %Etichetto le componenti connesse dell'inverso dell'immagine segmentata
    labeled_mask = bwlabel(mask);
    %filtro le componenti connesse (elimino sfondo e carte complete)
    final_mask = labeled_mask > 1;

    %l'immagine finale è datta dalla segmentazione iniziale più la maschera
    %completa
    filledImage = temp + final_mask;
    if debug_flag
        figure("Name", "Somma della maschera all'immagine parzialmente segmentata"), imshow(filledImage);    
    end
end

function filteredContours = filterContours(binaryImage, debug_flag)
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
    
    if debug_flag
        figure("Name", "Risultato finale con i contorni filtrati"), imshow(filteredContours);
    end
end

function [image_with_text, boundingboxes] = drawBoundingbox(segmented_image, original_image, predicted_labels, confidences)
    %The regionprops function measures properties such as area, centroid, and bounding box, for each object (connected component) in an image
    %segmented_image = imbinarize(segmented_image);
    boundingboxes = regionprops(segmented_image, "BoundingBox");
    areas = regionprops(segmented_image, "Area");
    
    %inserisce testo per ogni bounding box
    image_with_text = original_image;
    for k = 1 : length(boundingboxes)
        thisBB = boundingboxes(k).BoundingBox;
        
        %calcola il centro della boundingbox
        x = thisBB(1) + thisBB(3)/2;
        y = thisBB(2) + thisBB(4)/2;
        
        %positions = [positions; x, y];
        
        if areas(k).Area > 30000 && areas(k).Area < 35000
            image_with_text = insertText(image_with_text, [x, y], predicted_labels(k) + " - " + confidences(k) + "%, colore", FontSize=18, TextBoxColor="red");
        else
            image_with_text = insertText(image_with_text, [x, y], "unknown", FontSize=18, TextBoxColor="black");
        end
    end
    
    figure(1), imshow(image_with_text);
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
        cardImages{end+1} = cardImage;
    end
end