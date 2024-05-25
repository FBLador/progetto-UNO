% Image Category Classification Using Bag of Features (SURF) and multiclass linear SVM
% https://it.mathworks.com/help/vision/ug/image-category-classification-using-bag-of-features.html

% Load data
imds = imageDatastore('data_no_colors','IncludeSubfolders',true, 'LabelSource','foldernames');

% Inspect the number of images per category
tbl = countEachLabel(imds)

% Separate the sets into training and validation data. Pick 60% of images from each set for the training data and the remainder, 40%, for the validation data.
% Randomize the split to avoid biasing the results.
[trainingSet, validationSet] = splitEachLabel(imds, 0.6, 'randomize');

% Create a Visual Vocabulary
bag = bagOfFeatures(trainingSet);

% Train an Image Category Classifier
categoryClassifier = trainImageCategoryClassifier(trainingSet, bag);
save("SVMClassifier.mat", "categoryClassifier");

% Evaluate the classifier with the training set, which should produce near perfect confusion matrix
trainConfMatrix = evaluate(categoryClassifier, trainingSet);

% Evaluate the classifier on the validation set, which was not used during the training
validationConfMatrix = evaluate(categoryClassifier, validationSet);
















