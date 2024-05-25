function nImages=count_images(data_set_name)
    data_set_folders = dir(data_set_name);
    nImages = 0;
    for i = 4 : numel(data_set_folders)
        if(data_set_folders(i).isdir)
            current_folder_name = data_set_folders(i).name;
            current_folder_content = dir(data_set_name + "/" + current_folder_name);
    
            n1 = sum({current_folder_content.name} == ".");
            n2 = sum({current_folder_content.name} == "..");
            n3 = sum({current_folder_content.name} == ".DS_Store");
            unnecessary_file = n1 + n2 + n3;
    
            fprintf(1, "%d elements inside %s\n", numel(current_folder_content) - unnecessary_file, current_folder_name)
    
            nImages = nImages + numel(current_folder_content) - unnecessary_file;
        end
    end
end