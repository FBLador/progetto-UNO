function upgraded_segmentation()
    close all;
    
    %Debug flag
    showDebugImages = false;

    data_set_folder = dir("data_set");
    for i = 4 : numel(data_set_folder)
        
        %Carica immagine
        training_img = imread("./data_set/" + data_set_folder(i).name);
        %Edge linking e visualizzazione del risultato
        linkedEdges = edgeWithSobelAndLinking(training_img, showDebugImages);       
        %Riempimento buchi
        segmentedImage = fillHoles(linkedEdges, showDebugImages);
        
        %Disegna le bounding box
        BBImage = draw_boundingbox(segmentedImage, training_img);

        %-----OLD MARCELLO-----
        %channel_cb = training_img(:,:,2);
        %segmented = imfill(imbinarize(channel_cb, graythresh(channel_cb)), "holes");

        f = figure("Name", data_set_folder(i).name), f.WindowState = "maximized";
        subplot(1, 3, 1), imshow(training_img);
        subplot(1, 3, 2), imshow(segmentedImage);
        subplot(1, 3, 3), imshow(BBImage);

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
    %filtro le componenti connesse (elimino sfondo e carte complete
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