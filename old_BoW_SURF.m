%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image Classification using Bag of Visual Words                      %
%                                                                         %
% Copyright (C) 03-2017 Hesham M. Eraqi. All rights reserved.             %
%                    hesham.eraqi@gmail.com                               %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear Variables, Close Current Figures, and Create Results Directory 
clc;
clear all;
close all;
mkdir('Results//'); %Directory for Storing Results

%% Configurations
%classes = {'back', 'blue_0' , 'blue_1', 'blue_2', 'blue_3' , 'blue_4', 'blue_5', 'blue_6' , 'blue_7', 'blue_8', 'blue_9' , 'blue_draw', 'blue_reverse', 'blue_skip', 'green_0' , 'green_1', 'green_2', 'green_3' , 'green_4', 'green_5', 'green_6' , 'green_7', 'green_8', 'green_9' , 'green_draw', 'green_reverse', 'green_skip', 'red_0' , 'red_1', 'red_2', 'red_3' , 'red_4', 'red_5', 'red_6' , 'red_7', 'red_8', 'red_9' , 'red_draw', 'red_reverse', 'red_skip', 'wild', 'wild_draw', 'yellow_0' , 'yellow_1', 'yellow_2', 'yellow_3' , 'yellow_4', 'yellow_5', 'yellow_6' , 'yellow_7', 'yellow_8', 'yellow_9' , 'yellow_draw', 'yellow_reverse', 'yellow_skip'}; % Should be sorted alphapetically to match test data automatic labeling by folder
classes = {'back', 'card_0' , 'card_1', 'card_2', 'card_3' , 'card_4', 'card_5', 'card_6' , 'card_7', 'card_8', 'card_9' , 'draw_card', 'reverse_card', 'skip_card', 'wild' , 'wild_draw'}; % Should be sorted alphapetically to match test data automatic labeling by folder
trainingDataSizePercent = 80; % How much percentage of the data is for training, the rest is for validation
numberOfClusters = 500; % The number of clusters representing the number of features in the bag of features. Default can be 500.
ratioOfStrongFeatures = 0.8; % Default can be 0.8
SVM_Kernel = 'rbf'; % Can be either 'polynomial' or 'rbf' for example.
SVM_C = 0.1; % Smaller is less overfitting. Default can be 0.1.
SVM_RBF_Gamma = 0.6; % The RBF SVM Kernel gamma. The higher the more complex model, and more prune to overfitting. Default can be 0.6.
visualize_train_val_data = 0; % Boolean (0 or 1) to visualize training and validation data
visualize_sample_FV = 0;
visualize_test_data = 0;

%% Load Image Datastore and make them of equal size (size of class with lowest number of images)
imgSets = [];
for i = 1:length(classes)
    imgSets = [ imgSets, imageSet(fullfile('data_no_colors', classes{i})) ];
end

% Look for the class with least elements
minClassCount = min([imgSets.Count]);
index = find([imgSets.Count] == minClassCount);
fprintf(1, "%s class with %d elements\n", classes{index(1)}, minClassCount); 

% Balance the data count between of all classes
imgSets = partition(imgSets, minClassCount, 'sequential'); % Or 'randomize'

%% Prepare Training and Validation Image Sets
[trainingSets, validationSets] = partition(imgSets, trainingDataSizePercent/100, 'sequential'); % Or 'randomize'

%% Visulizing Training and Validation Data (Press any key to procceed to next figure) 
if (visualize_train_val_data)
    data = {trainingSets, validationSets};
    for d = length(data)
        for i=1:data{d}(1).Count
            for c=1:length(classes)
                subplot(1,length(classes),c);
                imshow(read(data{d}(c),i));
            end
            sgtitle(['Sample ' int2str(i) ' out of ' int2str(data{d}(1).Count)]);
            saveas(gcf,['Results//TrainValData-Img' int2str(d) '-' int2str(i) '.png']);
%             pause;
        end
    end
end

%% Forming Bag of Features
% Extracts SURF features from all training images &
% reducing the number of features through quantization of feature space using K-means clustering
bag = bagOfFeatures(trainingSets, 'StrongestFeatures', ratioOfStrongFeatures, 'VocabularySize', numberOfClusters);

%% Visulize a feature vector
if (visualize_sample_FV)
    figure;
    img = read(imgSets(1), 1); % First image of first class as an example
    featureVector = encode(bag, img);

    % Plot the histogram of visual word occurrences
    figure;
    bar(featureVector);
    title('Visual word occurrences');
    xlabel('Visual word index');
    ylabel('Frequency of occurrence');
    saveas(gcf,['Results//TrainData-SampleFeatureVector.png']);
end

%% Train SVM Classifier
% opts = templateSVM('KernelFunction', 'rbf', 'BoxConstraint', SVM_C, 'kernelScale', SVM_RBF_Gamma);
opts = templateSVM('KernelFunction', SVM_Kernel, 'BoxConstraint', SVM_C);
% opts = templateSVM('KernelFunction', 'rbf');
classifier = trainImageCategoryClassifier(trainingSets, bag, 'LearnerOptions', opts);

% Save the classifier for future utilization
save("classifier.mat", "classifier");
    
%% Evaluate the classifier on training then validation data
confMatrix_train = evaluate(classifier, trainingSets);
confMatrix_val = evaluate(classifier, validationSets);
tran_val_avg_accuracy = (mean(diag(confMatrix_val)) + mean(diag(confMatrix_train))) / 2; % This information should be used to tweak the system parameters for better accuracy

display(['The training and validation average accuracy is ' num2str(tran_val_avg_accuracy) '.']);

%% Deployment (test the system on newly unseen images)
testSet = imageSet('Test_Data', 'recursive');
randomSet = testSet(2);
testSet(2) = [];
confMatrix_test = evaluate(classifier, testSet);
test_accuracy = mean(diag(confMatrix_test));
display(['The test accuracy is ' num2str(test_accuracy) '.']);

if (visualize_test_data)
    figure;
    for i=1:testSet(1).Count
        for c=1:length(classes)
            subplot(1,length(classes),c);
            imshow(read(testSet(c),i));
        end
        suptitle(['Sample ' int2str(i) ' out of ' int2str(testSet(1).Count)]);
%         pause;
        saveas(gcf,['Results//TestData-Img' int2str(i) '.png']);
    end
end

%% Test random data (images that do not contain any of the trained classes)
if (visualize_test_data)
    figure;
end
for i = 1:randomSet.Count
    img = read(randomSet,i);
    [labelIdx, scores] = predict(classifier, img);
    class_label = classifier.Labels(labelIdx); % Display the string label
    
    if (visualize_test_data)
        subplot(2,3,i);
        imshow(img);
        title(['Classified as ' strrep(class_label{1}, '_', '\_')]);
%         pause;
    end
end
if (visualize_test_data)
    saveas(gcf,['Results//TestRandomData.png']);
end