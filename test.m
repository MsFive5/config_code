%test.m
clear all; 
datapath = '/home/celia/PAM_DATA/SIRRACT/sampledata/seth';

input = load([datapath '/' 'trainingMerge.mat']);
input.data(:,2:7) = input.data(:,2:7)/340;

template = load('signature');
template.data(:,2:4) = template.data(:,2:4)/340;

signature1 = template;
signature2 = template;
signature1.data = template.data(1:110,:);
signature2.data = template.data(342:513,:);

signature1.data(:,2:4) = signature1.data(:,2:4)*[-1 0 0;0 1 0; 0 0 -1];
signature2.data(:,2:4) = signature2.data(:,2:4)*[-1 0 0;0 1 0; 0 0 -1];

[distance1,flag1,sigarray1] = findsmallstring(input.data(:,5:7),signature1,6);
[distance2,flag2,sigarray2] = findsmallstring(input.data(:,5:7),signature2,7);
