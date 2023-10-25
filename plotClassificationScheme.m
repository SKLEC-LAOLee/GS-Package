function plotClassificationScheme(statisticalParams,outputConfig)
%----------------------------------------------------------------------------------------------------
% @file name:   plotClassificationScheme.m
% @description: Diagnostic triangular phase mapping of sediments
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 2023.10.22
%----------------------------------------------------------------------------------------------------
% @param:
% statisticalParams.
%           dataPath: full path of the data file
%           fileName: file name of the xle/xld file
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
%       analysisTime: Time to start on-board measurements(datetime)
%       validSizeLim: user defined valid range of grainsize [minLim(um),maxLim(um)]
%     analysisPeriod: measurement period(s)
%        obscuration: obscuration(%), only for laser diffraction method
%          pumpSpeed: pump speed, only for laser diffraction method
%                SSa: specific surface area, only for laser diffraction method
%  waterRefractivity: water refractivity, only for laser diffraction method
%particleRefractivity: particle refractivity, only for laser diffraction method
%particleAbsorptivity: particle absorptivity, only for laser diffraction method
%    channelDownSize: lower limit size of the channel(um)
%      channelUpSize: upper limit size of the channel(um)
%     channelMidSize: logarithmic midpoint size of the channel(um)
%                 p3: raw differential volume(%)
%                 q3: raw cumulative volume(%)
%           adjustP3: differential volume percentage after removal of invalid components (%)
%           adjustQ3: cumulative volume percentage after removal of invalid components (%)
%      haveShapeData:
%                = 0, no particle shape information
%                = 1, particle shape information only indexed by particle size
%                = 2, particle shape information both indexed by particle size and normalized shape factor
%              spht3: sphericity, =4*pi*area/(round^2)
%              symm3: Symmetry
%               b_l3: Aspect ratio = Xc_min (particle width: sieve size)/XFe_Max (particle length)
%            B_LRec3: Minimum aspect ratio = min(Xc/XFe)
%            sigmav3: Standard deviation of ?
%              conv3: Convexity = sqrt(real area / convex particle area)
%             rdnsc3: Roundness, ratio of the averaged radius of curvature of all convex regions to the circumscribed cricle of the particle
%                pdv: volume-based number of particle detections
%    channelMeanSize: mean value of the particle size
%channelSize_xFe_avg: average feret diameter
%channelSize_xMa_avg: average martin diameter
% channelSize_xc_avg: average chord diameter
%channelSize_xFe_min: minimum feret diameter, particle width
%channelSize_xMa_min: minimum martin diameter, paticle thickness
% channelSize_xc_min: minimum chord diameter, sieve size
%channelSize_xFe_max: maxmum feret diameter, paticle length
%channelSize_xMa_max: maxmum martin diameter
% channelSize_xc_max: maxmum chord diameter
%   channelDownShape: lower limit of normalized shape index(0~1), only when haveShapeData==2
%     channelUpShape: upper limit of normalized shape index(0~1), only when haveShapeData==2
%    channelMidShape: logarithmic midpoint of normalized shape index(0~1), only when haveShapeData==2
%             q3Spht: cumulative volume percentage of sphericity, only when haveShapeData==2
%             q3Symm: cumulative volume percentage of symmetry, only when haveShapeData==2
%             q3_b_l: cumulative volume percentage of aspect ratio, only when haveShapeData==2
%           q3B_LRec: cumulative volume percentage of minimum aspect ratio, only when haveShapeData==2
%           q3Sigmav: cumulative volume percentage of Sigmav, only when haveShapeData==2
%             q3Conv: cumulative volume percentage of convexity, only when haveShapeData==2
%            q3Rdnsc: cumulative volume percentage of roundness, only when haveShapeData==2
%             q0Spht: cumulative number percentage of sphericity, only when haveShapeData==2
%             q0Symm: cumulative number percentage of symmetry, only when haveShapeData==2
%             q0_b_l: cumulative number percentage of aspect ratio, only when haveShapeData==2
%           q0B_LRec: cumulative number percentage of minimum aspect ratio, only when haveShapeData==2
%           q0Sigmav: cumulative number percentage of Sigmav, only when haveShapeData==2
%             q0Conv: cumulative number percentage of convexity, only when haveShapeData==2
%            q0Rdnsc: cumulative number percentage of roundness, only when haveShapeData==2
%            sfCorey: Corey shape factor=channelSize_xMa_min/sqrt(channelSize_xFe_min*channelSize_xFe_max)
%                d05:  5% of all particles are no larger than d05, (um)
%                d10: 10% of all particles are no larger than d10, (um)
%                d16: 16% of all particles are no larger than d16, (um)
%                d25: 25% of all particles are no larger than d25, (um)
%                d50: median size, 50% of all particles are no larger than d50, (um)
%                d75: 75% of all particles are no larger than d75, (um)
%                d84: 84% of all particles are no larger than d84, (um)
%                d90: 90% of all particles are no larger than d90, (um)
%                d95: 95% of all particles are no larger than d95, (um)
%                 dm: mean size(um)
%         dm_Mcmanus: mean size(phi), Mcmanus
%      sigma_Mcmanus: sorting, Mcmanus
%         sk_Mcmanus: skewness, Mcmanus
%         kg_Mcmanus: Kurtosis, Mcmanus
%        dm_GBT12763: mean size(phi), GBT12763
%     sigma_GBT12763: sorting, GBT12763
%        sk_GBT12763: skewness, GBT12763
%        kg_GBT12763: Kurtosis, GBT12763
%       sortingLevel: sorting level(GBT 12763.8-2007)
%                     very good(1),             sigma_GBT12763 < 0.35 phi
%                          good(2), 0.35 phi <= sigma_GBT12763 < 0.71 phi
%                        middle(3), 0.71 phi <= sigma_GBT12763 < 1.00 phi
%                           bad(4), 1.00 phi <= sigma_GBT12763 < 4.00 phi
%                      very bad(5), 4.00 phi <= sigma_GBT12763
%           variance: variance =sqrt(D84_um/D16_um)
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
%  outputConfig.
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

[~,~]=mkdir([outputConfig.outputPath]); %if not eixst, create it
[~,~]=mkdir([outputConfig.outputPath,'figures']); %if not eixst, create it

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
    print(figureId,'-dpng',[outputConfig.outputPath,'figures\',outputConfig.prefixString,'_Folk1954.png'], '-loose', '-r600');
    savefig(figureId,[outputConfig.outputPath,'figures\',outputConfig.prefixString,'_Folk1954.fig']);
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
    print(figureId,'-dpng',[outputConfig.outputPath,'figures\',outputConfig.prefixString,'_BlairMcPherson1999.png'], '-loose', '-r600');
    savefig(figureId,[outputConfig.outputPath,'figures\',outputConfig.prefixString,'_BlairMcPherson1999.fig']);
    close(figureId);
end