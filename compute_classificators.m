clear;
close all;

load("features_data.mat");

%creiamo l'oggetto cvpartition
cv = cvpartition(labels, "holdout", 0.2);

example = test_classifier_cart(qhist, labels, cv);
fprintf(1, "Classificatore CART con QHISt: %.1f%%\n", example.test_perf.accuracy*100);
example = test_classifier_cart(CEDD, labels, cv);
fprintf(1, "Classificatore CART con CEDD: %.1f%%\n", example.test_perf.accuracy*100);
example = test_classifier_cart(lbp, labels, cv);
fprintf(1, "Classificatore CART con LBP: %.1f%%\n", example.test_perf.accuracy*100);

%example = test_classifier_bayes(qhist, labels, cv);
%example.test_perf.accuracy
%example = test_classifier_bayes(CEDD, labels, cv);
%example.test_perf.accuracy
%example = test_classifier_bayes(lbp, labels, cv);
%example.test_perf.accuracy

example = test_classifier_knn(qhist, labels, cv, 54);
fprintf(1, "Classificatore KNN con QHIST: %.1f%%\n", example.test_perf.accuracy*100);
example = test_classifier_knn(CEDD, labels, cv, 54);
fprintf(1, "Classificatore KNN con CEDD: %.1f%%\n", example.test_perf.accuracy*100);
example = test_classifier_knn(lbp, labels, cv, 54);
fprintf(1, "Classificatore KNN con LBP: %.1f%%\n", example.test_perf.accuracy*100);

%concatenazione di feature per cercare di aumentare l'accuratezza
f1 = cat(2, lbp, qhist);
example = test_classifier_cart(f1, labels, cv);
fprintf(1, "Classificatore CART con LBP e QHIST: %.1f%%\n", example.test_perf.accuracy*100);
example = test_classifier_knn(f1, labels, cv, 54);
fprintf(1, "Classificatore CART con LBP e QHIST: %.1f%%\n", example.test_perf.accuracy*100);