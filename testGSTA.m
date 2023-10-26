data=readtable('D:\temp\长江流域全样\output\data.txt');

dm=data.dm;
sorting=data.sorting;
skewness=data.skewness;
shape=data.corey;
scaleRange=[0.558	6.905
0.141	2.323
0.027	1.874
0.657	0.827
];

 x=[51.64
76.11
0
128.27
142.73
232.15
263.96
319.67
341.6
387.38
413.68
445.78
462.44
368
475.27
565.03
535.08
686.72
626.42
600.78
650.89
771.2
857
864];% 删除NZ1
%% 
all_method = {'1d-fix-grain','1d-fix-combine','1d-fix-shape','1d-var-grain','1d-var-combine','1d-var-shape'};

dc=200;
y=x.*0;
for iComponent=1:6
    for iMethod=1:length(all_method)
     [trendStrength(iComponent,iMethod,:),trendDirection(iComponent,iMethod,:)]=gsta(dc,x,y,dm(iComponent:10:end),sorting(iComponent:10:end),skewness(iComponent:10:end),shape(iComponent:10:end),scaleRange,all_method{iMethod}); 
    end
end
clc;
for iComponent=1:6
    for iMethod=1:length(all_method)
        for iStation=1:length(x)
            fprintf('%d\t%s\t%.3f\t%.0f\n',iComponent,all_method{iMethod},trendStrength(iComponent,iMethod,iStation),trendDirection(iComponent,iMethod,iStation));
        end
    end
end
