%in = imread("data_set/uno-test-23.jpg");
%image = rgb2ycbcr(in);
%channel_cb = image(:,:,2);
%binarized = imbinarize(channel_cb, graythresh(channel_cb));
%segmented = imfill(imbinarize(channel_cb, graythresh(channel_cb)), "holes");

% labels = bwlabel(segmented);
% figure(1), imagesc(labels), axis image, colorbar;

function image_with_boxes = draw_boundingbox(segmented_image, original_image)
    %The regionprops function measures properties such as area, centroid, and
    %bounding box, for each object (connected component) in an image
    segmented_image = imbinarize(segmented_image);
    boundingbox = regionprops(segmented_image, "BoundingBox");
    areas = regionprops(segmented_image, "Area");
    
    %inserisce testo per ogni bounding box
    image_with_boxes = original_image;
    for k = 1 : length(boundingbox)
        thisBB = boundingbox(k).BoundingBox;
        
        %calcola il centro della boundingbox
        x = thisBB(1) + thisBB(3)/2;
        y = thisBB(2) + thisBB(4)/2;
        
        %positions = [positions; x, y];
        
        if areas(k).Area > 30000 && areas(k).Area < 35000
            image_with_boxes = insertText(image_with_boxes, [x, y], "numero, colore", FontSize=18, TextBoxColor="red");
        else
            image_with_boxes = insertText(image_with_boxes, [x, y], "unknown", FontSize=18, TextBoxColor="black");
        end
    end
    
    %figure(1), imshow(image_with_boxes);
    
    %disegna un rettangolo attorno all'immagine
    for k = 1 : length(boundingbox)
      thisBB = boundingbox(k).BoundingBox;
      rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)], 'EdgeColor','r','LineWidth',2 )
    end
end