clc;
clear;
TL=load('trainlabels.txt');
TD=load('trainfeatures.txt');
test_label=load('tesoutabels.txt');
test_data=load('estfeatures.txt');
TD=transpose(maxmin(transpose(TD)));
test_data=transpose(maxmin(transpose(test_data)));
[a, b] = knnsearch(TD, test_data, 'K',1);