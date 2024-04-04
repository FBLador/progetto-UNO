clear;

data_set_folders = dir("data");
images_list = fopen("images.list", "w");
labels_list = fopen("labels.list", "w");

for i = 4 : numel(data_set_folders) %parto da 4 per saltare gli elementi non necessari
    if(data_set_folders(i).isdir)
        current_folder_name = data_set_folders(i).name;
        current_folder_content = dir("data/" + current_folder_name);

        for j = 4 : numel(current_folder_content)
            %rinomino le immagini nel dataset
            estensione = split(current_folder_content(j).name, ".");
            estensione = estensione{size(estensione, 1)};
            oldfilename = "data/" + current_folder_name + "/" + current_folder_content(j).name;
            newfilename = "data/" + current_folder_name + "/"+current_folder_name+"_" + (j-3) + "."+estensione;
            
            try
                movefile(oldfilename, newfilename);
            catch
            end

            %scrivo nei .list
            fprintf(images_list, newfilename + "\n");
            fprintf(labels_list, current_folder_name + "\n");
        end
    end
end

