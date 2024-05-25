clear;

data_set_name = "data_no_colors_224x224";
data_set_folders = dir(data_set_name);

%conta le carte prima di rinominarle
fprintf(1, "Check numero di immagini prima dell'esecuzione: %d\n", count_images(data_set_name));

for i = 4 : numel(data_set_folders) %parto da 4 per saltare gli elementi non necessari
    if(data_set_folders(i).isdir)
        current_folder_name = data_set_folders(i).name;
        current_folder_content = dir(data_set_name + "/" + current_folder_name);

        for j = 4 : numel(current_folder_content)
            img = imread(data_set_name + "/" + current_folder_name + "/" + current_folder_content(j).name);
            resizedImg = imresize(img, [224 224]);
            finalImg = im2gray(resizedImg);

            imwrite(finalImg, data_set_name + "/" + current_folder_name + "/" + current_folder_content(j).name);
        end
    end
end

%conta le carte dopo avere rinominate, ho avuto esperienze di cancellazioni
%impreviste
fprintf(1, "Check numero di immagini dopo l'esecuzione: %d\n", count_images(data_set_name));