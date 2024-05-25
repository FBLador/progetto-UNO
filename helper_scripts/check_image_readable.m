clear;
close all;
warning("off");

data_set_name = "data_no_colors_224x224";
data_set_folders = dir(data_set_name);

for i = 4 : numel(data_set_folders) %parto da 4 per saltare gli elementi non necessari
    if(data_set_folders(i).isdir)
        current_folder_name = data_set_folders(i).name;
        current_folder_content = dir(data_set_name + "/" + current_folder_name);

        for j = 4 : numel(current_folder_content)
            try
                im = imread(data_set_name + "/" + current_folder_name + "/" + current_folder_content(j).name);
                %fprintf(1, "Immagine: %s di %dx%dx%d\n", current_folder_content(j).name, size(im, 1), size(im, 2), size(im, 3));

                if(size(im, 1) ~= 224 || size(im, 2) ~= 224 || size(im, 3) ~= 1)
                    fprintf(2, "Errore di dimensioni in: %s\n", current_folder_content(j).name);
                end
            catch e1
                fprintf(2,'Errore: %s - %s\nImmagine: %s\n', e1.identifier, e1.message, current_folder_content(j).name);
            end
        end
    end
end