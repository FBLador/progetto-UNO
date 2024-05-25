clear;

data_set_name = "data_all_colors";
data_set_folders = dir(data_set_name);

%conta le carte prima di rinominarle
fprintf(1, "Check numero di immagini prima dell'esecuzione: %d\n", count_images(data_set_name));

for i = 4 : numel(data_set_folders) %parto da 4 per saltare gli elementi non necessari
    if(data_set_folders(i).isdir)
        current_folder_name = data_set_folders(i).name;
        current_folder_content = dir(data_set_name + "/" + current_folder_name);

        for j = 4 : numel(current_folder_content)
            %rinomino le immagini nel dataset
            estensione = split(current_folder_content(j).name, ".");
            estensione = estensione{size(estensione, 1)};
            oldfilename = data_set_name + "/" + current_folder_name + "/" + current_folder_content(j).name;
            newfilename = data_set_name + "/" + current_folder_name + "/" + current_folder_name + "_" + (j-3) + "."+estensione;
            
            try
                movefile(oldfilename, newfilename);
            catch
            end
        end
    end
end

%conta le carte dopo avere rinominate, ho avuto esperienze di cancellazioni
%impreviste
fprintf(1, "Check numero di immagini prima dell'esecuzione: %d\n", count_images(data_set_name));