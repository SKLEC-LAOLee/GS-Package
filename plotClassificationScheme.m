function plotClassificationScheme(statisticalParams,userSettings)
%----------------------------------------------------------------------------------------------------
% @file name:   plotClassificationScheme.m
% @description: Diagnostic triangular phase mapping of sediments
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 2023.10.22
%----------------------------------------------------------------------------------------------------
% @param:
% statisticalParams.
%           dataPath: full path of the raw data file
%           fileName: file name of the raw data file
%       instrumentId: instrument code
%                     = 1, coulter LS 13320
%                     =11, camsizer X2
%                     =21, malvern
%                     =99, unknown
%          groupName: sample group
%            groupId: unique numeric id of the group
%         sampleName: sample name
%           sampleId: unique numeric id of the sample
%         configInfo: configuration file name of the instrument (xxx.cfg)
%               type: Rules for particle size statistics(string)
%                     ='xc_min', perpendicular to sieving methods
%                     ='x_area', perpendicular to laser diffraction methods
%                     ='xFemin', perpendicular to the width of the vernier methods
%                     ='xFemax', perpendicular to the length of the vernier methods
%                     ='xMamin', martin diameter
%             gravel: (2mm, inf](%)
%               sand: (63um,2mm](%)
%               silt: (3.9um,63um](%)
%               clay: (0,3.9um](%)
%  classificationCode: 
%             have gravel: following Folk(1954) method, see folk1954.fig
%             no gravel: following Blair-McPherson(1999) method, see BlairMcPherson1999.fig
%classificationMethod: 
%             ='Blair-McPherson1999', have gravel
%             ='Folk1954'  , no gravel
%  userSettings.
%         outputPath: full path of the output files
%       prefixString: Prefixes for archive file names
%           language: 
%               ='cn'   Particle grading curves are labeled in Chinese
%               ='en'   Particle grading curves are labeled in English
% @return: 
%  NONE
% @references:
% Folk, R.L. and Ward, W.C. (1957) A Study in the Significance of Grain-Size Parameters. Journal of Sedimentary Petrology, 27, 3-26.
%                                  https://doi.org/10.1306/74D70646-2B21-11D7-8648000102C1865D
% Terence C. Blair, John G. McPherson; Grain-size and textural classification of coarse sedimentary particles. Journal of Sedimentary Research 1999;; 69 (1): 6–19.
%                                  https://doi.org/10.2110/jsr.69.6
%----------------------------------------------------------------------------------------------------
nSample=length(statisticalParams);
allGroupId=zeros(nSample,1);
data=zeros(nSample,4);
groupStyle={'b.','k*','rO','gsqare','b^','bpentagram','bdiamond','bhexgram','b<','b>','r.','k*','bO','bsqare','g^','rpentagram','rdiamond','rhexgram','r<','r>'};

for iSample=1:nSample
    allGroupId(iSample,1)=statisticalParams(iSample).groupId;
    data(iSample,1)=statisticalParams(iSample).gravel;
    data(iSample,2)=statisticalParams(iSample).sand;
    data(iSample,3)=statisticalParams(iSample).silt;
    data(iSample,4)=statisticalParams(iSample).clay;
end
[uniqueGroupIds,groupNameIndex]=unique(allGroupId);
nGroup=length(uniqueGroupIds);

BMPSchemeId=find(data(:,1)>1e-4);
FolkSchemeId=find(data(:,1)<=1e-4);
if isempty(BMPSchemeId) && isempty(FolkSchemeId)
    return;
end

[~,~]=mkdir([userSettings.outputPath]); %if not eixst, create it
[~,~]=mkdir([userSettings.outputPath,'figures']); %if not eixst, create it

if ~isempty(FolkSchemeId)
    %Folk(1954) rule
    figureId=openfig('folk1954.fig');
    x=data(FolkSchemeId,3)./100;%percent to decimal, silt
    nx=data(FolkSchemeId,2).*(1-2.*x)./sqrt(3)+200./sqrt(3).*x;
    y=data(FolkSchemeId,2); %sand
    hold(figureId.Children,'on');
    for iGroup=1:nGroup
        thisGroupIndex=uniqueGroupIds(iGroup)==allGroupId(FolkSchemeId);
        if isempty(thisGroupIndex)
            plot(figureId.Children,nan,nan,groupStyle{iGroup});
        else
            plot(figureId.Children,nx(thisGroupIndex),y(thisGroupIndex),groupStyle{iGroup});
        end
    end
    if nGroup>1
        legend(figureId.Children,statisticalParams(groupNameIndex).groupName,'Location','northwest','box','off');
    end
    % save
    print(figureId,'-dpng',[userSettings.outputPath,'figures\',userSettings.prefixString,'_Folk1954.png'], '-loose', '-r600');
    savefig(figureId,[userSettings.outputPath,'figures\',userSettings.prefixString,'_Folk1954.fig']);
    close(figureId);
end
if ~isempty(BMPSchemeId)
    %BlairMcPherson(1999) rule
    figureId=openfig('BlairMcPherson1999.fig');
    x=data(BMPSchemeId,2)./100;%percent to decimal, sand
    nx=data(BMPSchemeId,1).*(1-2.*x)./sqrt(3)+200./sqrt(3).*x;
    y=data(BMPSchemeId,1); %graval
    hold(figureId.Children,'on');
    for iGroup=1:nGroup
        thisGroupIndex=uniqueGroupIds(iGroup)==allGroupId(BMPSchemeId);
        if isempty(thisGroupIndex)
            plot(figureId.Children,nan,nan,groupStyle{iGroup});
        else
            plot(figureId.Children,nx(thisGroupIndex),y(thisGroupIndex),groupStyle{iGroup});
        end
    end
    if nGroup>1
        legend(figureId.Children,statisticalParams(groupNameIndex).groupName,'Location','northwest','box','off');
    end
    % save
    print(figureId,'-dpng',[userSettings.outputPath,'figures\',userSettings.prefixString,'_BlairMcPherson1999.png'], '-loose', '-r600');
    savefig(figureId,[userSettings.outputPath,'figures\',userSettings.prefixString,'_BlairMcPherson1999.fig']);
    close(figureId);
end