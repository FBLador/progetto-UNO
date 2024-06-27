
# UNO Card Localization and Recognition

## Overview
This project aims to locate and recognize UNO cards from images. It utilizes various image processing techniques and machine learning models to accurately identify UNO cards under certain assumptions and operational decisions.

## Assumptions and Operational Decisions

### Assumptions:
- The project is not designed to locate and recognize heavily overlapped cards. Slightly overlapping cards (a few millimeters) are acceptable.
- Photos are assumed to be taken from the same distance and angle to the table, allowing for the identification of foreign objects based on geometric characteristics.
- The background is always the same (wooden surface).
- There are no execution time requirements.

### Operational Decisions:
- We decided to create our own dataset for training and validation instead of using the provided images, which are directly used for application evaluation.
- Color recognition of the card is handled by a separate script to reduce the number of classes the model needs to train on.
- Wild and wild_draw cards are defined as black.

## Dataset Evolution
The dataset contains images of complete UNO cards from various official and unofficial editions, sourced through various search strategies.

## General Processing Pipeline

1. **Edge Detection and Linking:**
   - The wooden surface in the Cr channel of the YCbCr space has a specific gray tone, while card edges appear much darker, aiding in edge identification.
   - Originally, the Sobel edge detector was used, but it was replaced by Canny for its lower rate of "open" edges and better noise handling.

2. **Hole Filling:**
   - Uses connected component labeling to identify and fill partial card regions.
   - The watershed transformation separates slightly overlapping cards by identifying touching points.
   - Removal of regions smaller than 1000px, adjustable up to 25000px to eliminate objects not typical of a card.

3. **Card Extraction and Rotation:**
   - Regions with fewer than 25000 pixels are eliminated to ensure complete cards are identified.
   - Cards are straightened to provide the classifier with the best possible image for minimizing errors.

4. **Classification:**
   - The model trains on a grayscale image to speed up the training process, focusing on shape and pattern rather than color.

## Model Training

### Initial Classifier: SVM with Bag of Features (SURF)
- Trained a multi-class linear SVM with a Bag of Features.
- Poor performance with an average accuracy of 36%.

### Simple CNN
- Significant performance improvement, reaching around 70% accuracy in 100 epochs.
- Augmentation played a key role by artificially increasing the training data variety.

### ResNet
- Achieved approximately 90% accuracy with a much deeper and complex network structure.
- Training took significantly longer (111 minutes) compared to the simple CNN.

![image](https://github.com/FBLador/progetto-UNO/assets/44242903/41787104-25d7-449d-9455-c288d4503aa3)
![image](https://github.com/FBLador/progetto-UNO/assets/44242903/4f63f1e1-e383-4058-85c3-a7909905e374)

## Color Identification
- Uses color slicing to identify specific color ranges.
- Handles errors where white is confused with blue in low light by generating a white mask.

## Application Evaluation

### Segmentation
- Metrics to describe segmentation errors are defined.
- An area is considered incorrect if its bounding box is not present in the ground truth or the overlap ratio is less than 0.85.

### Card Category Classification
- Some combinations, like the 3 and 8 cards, posed difficulties.
- The "N/A" class represents instances where ground truth or predictions had no information.

### Color Classification
- Good performance with the highest error concentration between real blue and predicted red.
- The color is set to unknown for unknown regions, explaining the dispersion in the unknown column.

## Team Contributions

### Marcello Peluso (60%)
- Dataset management, edge detection optimization, script enhancements, model training and evaluation, color identification optimization, and final pipeline integration.

### Flavius Beniamin Lador (40%)
- Image analysis assistance, script development for edge detection, hole filling, card extraction, and color identification, ResNet training and optimization, and ground truth creation for the test set.
