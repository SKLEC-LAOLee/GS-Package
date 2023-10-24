function statisticalParams=calcStatisticalParams(rawData,userSettings)
%----------------------------------------------------------------------------------------------------
% @file name：  calcStatisticalParams.m
% @description：Calculation of particle size and shape statistical parameters
% @author：     Li Weihua, whli@sklec.ecnu.edu.cn
% @version：    Ver1.1, 2023.10.22
%----------------------------------------------------------------------------------------------------
% @param:
% rawData.
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
% userSettings.
%    componentUpSize: upper size of the user components (um)
%  componentDownSize: lower size of the user components (um)
% @return：
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
%    upSize_GBT12763: upper limit size of the channels which are defined in GBT12763, (um)
%        Q3_GBT12763：cumulative volume percentage of the channels which are defined in GBT12763, (%)
%            spht_50_2: median value of sphericity, calculated using the original exported accumulation curve of particle shape
%             spht_m_2: mean value of sphericity, calculated using the original exported accumulation curve of particle shape
%             b_l_50_2: median value of aspect ratio, calculated using the original exported accumulation curve of particle shape
%              b_l_m_2: mean value of aspect ratio, calculated using the original exported accumulation curve of particle shape
%        B_LRec_m_50_2: median value of minimum aspect ratio, calculated using the original exported accumulation curve of particle shape
%         B_LRec_m_m_2: mean value of minimum aspect ratio, calculated using the original exported accumulation curve of particle shape
%            symm_50_2: median value of symmetry, calculated using the original exported accumulation curve of particle shape
%             symm_m_2：mean value of symmetry, calculated using the original exported accumulation curve of particle shape
%           rdnsc_50_2：median value of roundness, calculated using the original exported accumulation curve of particle shape
%            rdnsc_m_2：mean value of roundness, calculated using the original exported accumulation curve of particle shape
%            conv_50_2：median value of convexity, calculated using the original exported accumulation curve of particle shape
%             conv_m_2：mean value of convexity, calculated using the original exported accumulation curve of particle shape
%          sigmav_50_2: median value of sigmav?, calculated using the original exported accumulation curve of particle shape
%           sigmav_m_2: mean value of sigmav?, calculated using the original exported accumulation curve of particle shape
%            spht_50: median value of sphericity, calculated using the grainsize indexed particle shape
%             spht_m: mean value of sphericity, calculated using the grainsize indexed particle shape
%             b_l_50: median value of aspect ratio, calculated using the grainsize indexed particle shape
%              b_l_m: mean value of aspect ratio, calculated using the grainsize indexed particle shape
%        B_LRec_m_50: median value of minimum aspect ratio, calculated using the grainsize indexed particle shape
%         B_LRec_m_m: mean value of minimum aspect ratio, calculated using the grainsize indexed particle shape
%            symm_50: median value of symmetry, calculated using the grainsize indexed particle shape
%             symm_m：mean value of symmetry, calculated using the grainsize indexed particle shape
%           rdnsc_50：median value of roundness, calculated using the grainsize indexed particle shape
%            rdnsc_m：mean value of roundness, calculated using the grainsize indexed particle shape
%            conv_50：median value of convexity, calculated using the grainsize indexed particle shape
%             conv_m：mean value of convexity, calculated using the grainsize indexed particle shape
%          sigmav_50: median value of sigmav?, calculated using the grainsize indexed particle shape
%           sigmav_m: mean value of sigmav?, calculated using the grainsize indexed particle shape
%         sfCorey_50: median value of Corey shape factor, calculated using the grainsize indexed  particle shape
%          sfCorey_m: mean value of Corey shape factor=channelSize_xFe_min/sqrt(channelSize_xFe_avg*channelSize_xFe_max), calculated using the grainsize indexed  particle shape
% @references:
% Bagheri, G. H., C. Bonadonna, I. Manzella, and P. Vonlanthen. “On the Characterization of Size and Shape of Irregular Particles.” 
%          Powder Technology 270 (January 1, 2015): 141–53. https://doi.org/10.1016/j.powtec.2014.10.015.
% Folk, R.L. and Ward, W.C. (1957) A Study in the Significance of Grain-Size Parameters. Journal of Sedimentary Petrology, 27, 3-26.
%                                  https://doi.org/10.1306/74D70646-2B21-11D7-8648000102C1865D
% Li, Linzhu, and Magued Iskander. “Comparison of 2D and 3D Dynamic Image Analysis for Characterization of Natural Sands.” 
%          Engineering Geology 290 (September 5, 2021): 106052. https://doi.org/10.1016/j.enggeo.2021.106052.
% State market regulatory administration of P.R.C. "Specifications for oceanographic survey - Part 8：marine geology and geophysics survey
%          (海洋调查规范 第8部分: 海洋地质地球物理调查.)" GB/T 12763.8-2007(2007).
% Terence C. Blair, John G. McPherson; Grain-size and textural classification of coarse sedimentary particles. Journal of Sedimentary Research 1999;; 69 (1): 6–19.
%                                  https://doi.org/10.2110/jsr.69.6
%----------------------------------------------------------------------------------------------------
statisticalParams=rawData;
nSample=length(rawData);
stdSortingLevel=[-inf 0.35,0.71,1.00,4.00];
for iSample=1:nSample
    %--------------------------------------
    %for particle size of complete sample
    %--------------------------------------
    thisQ3=rawData(iSample).adjustQ3+(1:length(rawData(iSample).adjustQ3))'.*1e-7; %Add incremental minima to avoid non-monotonic incremental problems
    try
        Di=interp1(thisQ3,rawData(iSample).channelUpSize,[5 10 16 25 50 75 84 90 95]); %um
    catch
        continue;
    end
    statisticalParams(iSample).d05=Di(1);
    statisticalParams(iSample).d10=Di(2);
    statisticalParams(iSample).d16=Di(3);
    statisticalParams(iSample).d25=Di(4);
    statisticalParams(iSample).d50=Di(5);
    statisticalParams(iSample).d75=Di(6);
    statisticalParams(iSample).d84=Di(7);
    statisticalParams(iSample).d90=Di(8);
    statisticalParams(iSample).d95=Di(9);
    statisticalParams(iSample).dm=sum(rawData(iSample).channelMidSize.*rawData(iSample).adjustP3)./100;
    channelMidSize_phi=-log2(rawData(iSample).channelMidSize./1000);
    statisticalParams(iSample).dm_Mcmanus   =sum(channelMidSize_phi.*rawData(iSample).adjustP3)./100;
    statisticalParams(iSample).sigma_Mcmanus=(sum((channelMidSize_phi-statisticalParams(iSample).dm_Mcmanus).^2.*rawData(iSample).adjustP3)./100).^(1./2);
    statisticalParams(iSample).sk_Mcmanus   =(sum((channelMidSize_phi-statisticalParams(iSample).dm_Mcmanus).^3.*rawData(iSample).adjustP3)./100).^(1./3);
    statisticalParams(iSample).kg_Mcmanus   =(sum((channelMidSize_phi-statisticalParams(iSample).dm_Mcmanus).^4.*rawData(iSample).adjustP3)./100).^(1./4);

    phi05=-log2(statisticalParams(iSample).d95./1000);
    phi16=-log2(statisticalParams(iSample).d84./1000);
    phi25=-log2(statisticalParams(iSample).d75./1000);
    phi50=-log2(statisticalParams(iSample).d50./1000);
    phi75=-log2(statisticalParams(iSample).d25./1000);
    phi84=-log2(statisticalParams(iSample).d16./1000);
    phi95=-log2(statisticalParams(iSample).d05./1000);
    statisticalParams(iSample).dm_GBT12763=mean(phi16+phi50+phi84); %phi
    statisticalParams(iSample).sigma_GBT12763=((phi84-phi16)/4+(phi95-phi05)/6.6);%phi
    tempVar11=(phi84+phi16-2*phi50);
    tempVar12=2*(phi84-phi16);
    tempVar21=(phi95+phi05-2*phi50);
    tempVar22=2*(phi95-phi05);
    statisticalParams(iSample).sk_GBT12763=tempVar11/tempVar12+tempVar21/tempVar22;
    statisticalParams(iSample).kg_GBT12763=(phi95-phi05)/(phi75-phi25)/2.44;
    levelId=find(statisticalParams(iSample).sigma_GBT12763>=stdSortingLevel);
    statisticalParams(iSample).sortingLevel=levelId(end);
    statisticalParams(iSample).variance=sqrt(phi84/phi16);
    
    %contents of gravel, sand, silt and clay
    stdSizeLevel=[3.9 62.5 2000];
    levelFreq=interp1(rawData(iSample).channelUpSize,rawData(iSample).adjustQ3,stdSizeLevel);
    statisticalParams(iSample).gravel=100-levelFreq(3);
    statisticalParams(iSample).sand=levelFreq(3)-levelFreq(2);
    statisticalParams(iSample).silt=levelFreq(2)-levelFreq(1);
    statisticalParams(iSample).clay=levelFreq(1);
    [statisticalParams(iSample).classificationCode,statisticalParams(iSample).classificationMethod]=getclassificationCode( ...
        statisticalParams(iSample).gravel,statisticalParams(iSample).sand,statisticalParams(iSample).silt,statisticalParams(iSample).clay);

    %contents of the user defined components
    levelFreq=interp1(rawData(iSample).channelUpSize,rawData(iSample).adjustQ3,[userSettings.componentDownSize(1);userSettings.componentUpSize(:)]);
    statisticalParams(iSample).userComponent.downSize=userSettings.componentDownSize;
    statisticalParams(iSample).userComponent.upSize=userSettings.componentUpSize;
    statisticalParams(iSample).userComponent.Content=diff(levelFreq);

    %for GBT12763.8
    statisticalParams(iSample).pai_GBT12763=11:-1:-3;
    gbSizeLevel=(2.^(-statisticalParams(iSample).pai_GBT12763)).*1000;
    gbLevelFreq=interp1(rawData(iSample).channelUpSize,rawData(iSample).adjustQ3,gbSizeLevel);
    zeroId=isnan(gbLevelFreq)&(gbSizeLevel<rawData(iSample).channelUpSize(1));
    gbLevelFreq(zeroId)=0;
    fullId=isnan(gbLevelFreq)&(gbSizeLevel>rawData(iSample).channelUpSize(end));
    gbLevelFreq(fullId)=100;

    statisticalParams(iSample).upSize_GBT12763=gbSizeLevel;  %um
    statisticalParams(iSample).Q3_GBT12763=gbLevelFreq;

    statisticalParams(iSample).sfCorey_m=-1;
    statisticalParams(iSample).b_l_m=-1;
    statisticalParams(iSample).spht_m=-1;
    %--------------------------------------
    %for particle shape of complete sample
    %--------------------------------------
    if rawData(iSample).haveShapeData>0
        if rawData(iSample).haveShapeData==2 %interpolate median value directly
            %mean and median values are calculated using the original exported accumulation curve of particle shape
            statisticalParams(iSample).spht_50_2=interp1(rawData(iSample).q3Spht+(1:length(rawData(iSample).q3Spht))'.*1e-7,rawData(iSample).channelUpShape,50);
            statisticalParams(iSample).symm_50_2=interp1(rawData(iSample).q3Symm+(1:length(rawData(iSample).q3Symm))'.*1e-7,rawData(iSample).channelUpShape,50);
            statisticalParams(iSample).b_l_50_2=interp1(rawData(iSample).q3_b_l+(1:length(rawData(iSample).q3_b_l))'.*1e-7,rawData(iSample).channelUpShape,50);
            statisticalParams(iSample).B_LRec_m_50_2=interp1(rawData(iSample).q3B_LRec+(1:length(rawData(iSample).q3B_LRec))'.*1e-7,rawData(iSample).channelUpShape,50);
            statisticalParams(iSample).sigmav_50_2=interp1(rawData(iSample).q3Sigmav+(1:length(rawData(iSample).q3Sigmav))'.*1e-7,rawData(iSample).channelUpShape,50);
            statisticalParams(iSample).conv_50_2=interp1(rawData(iSample).q3Conv+(1:length(rawData(iSample).q3Conv))'.*1e-7,rawData(iSample).channelUpShape,50);
            statisticalParams(iSample).rdnsc_50_2=interp1(rawData(iSample).q3Rdnsc+(1:length(rawData(iSample).q3Rdnsc))'.*1e-7,rawData(iSample).channelUpShape,50);
            
            statisticalParams(iSample).spht_m_2=sum(rawData(iSample).channelMidShape.*diff(rawData(iSample).q3Spht))./sum(diff(rawData(iSample).q3Spht));
            statisticalParams(iSample).symm_m_2=sum(rawData(iSample).channelMidShape.*diff(rawData(iSample).q3Symm))./sum(diff(rawData(iSample).q3Symm));
            statisticalParams(iSample).b_l_m_2=sum(rawData(iSample).channelMidShape.*diff(rawData(iSample).q3_b_l))./sum(diff(rawData(iSample).q3_b_l));
            statisticalParams(iSample).B_LRec_m_2=sum(rawData(iSample).channelMidShape.*diff(rawData(iSample).q3B_LRec))./sum(diff(rawData(iSample).q3B_LRec));
            statisticalParams(iSample).sigmav_m_2=sum(rawData(iSample).channelMidShape.*diff(rawData(iSample).q3Sigmav))./sum(diff(rawData(iSample).q3Sigmav));
            statisticalParams(iSample).conv_m_2=sum(rawData(iSample).channelMidShape.*diff(rawData(iSample).q3Conv))./sum(diff(rawData(iSample).q3Conv));
            statisticalParams(iSample).rdnsc_m_2=sum(rawData(iSample).channelMidShape.*diff(rawData(iSample).q3Rdnsc))./sum(diff(rawData(iSample).q3Rdnsc));
        else
            statisticalParams(iSample).spht_50_2=nan;
            statisticalParams(iSample).symm_50_2=nan;
            statisticalParams(iSample).b_l_50_2=nan;
            statisticalParams(iSample).B_LRec_m_50_2=nan;
            statisticalParams(iSample).sigmav_50_2=nan;
            statisticalParams(iSample).conv_50_2=nan;
            statisticalParams(iSample).rdnsc_50_2=nan;
            
            statisticalParams(iSample).spht_m_2=nan;
            statisticalParams(iSample).symm_m_2=nan;
            statisticalParams(iSample).b_l_m_2=nan;
            statisticalParams(iSample).B_LRec_m_2=nan;
            statisticalParams(iSample).sigmav_m_2=nan;
            statisticalParams(iSample).conv_m_2=nan;
            statisticalParams(iSample).rdnsc_m_2=nan;
        end
        %mean and median values are calculated using the grainsize indexed particle shape. Very different with the results calculated via the original 
        % exported accumulation curve of particle shape. I don't know which one should be reasonable for sediments.
        [~,~,statisticalParams(iSample).spht_50,statisticalParams(iSample).spht_m]=diff2cum(rawData(iSample).spht3,rawData(iSample).adjustP3,[1e-3,1]);
        [~,~,statisticalParams(iSample).b_l_50,statisticalParams(iSample).b_l_m]=diff2cum(rawData(iSample).b_l3,rawData(iSample).adjustP3,[1e-3,1]);
        [~,~,statisticalParams(iSample).B_LRec_50,statisticalParams(iSample).B_LRec_m]=diff2cum(rawData(iSample).B_LRec3,rawData(iSample).adjustP3,[1e-3,1]);
        [~,~,statisticalParams(iSample).symm_50,statisticalParams(iSample).symm_m]=diff2cum(rawData(iSample).symm3,rawData(iSample).adjustP3,[1e-3,1]);
        [~,~,statisticalParams(iSample).conv_50,statisticalParams(iSample).conv_m]=diff2cum(rawData(iSample).conv3,rawData(iSample).adjustP3,[1e-3,1]);
        [~,~,statisticalParams(iSample).rdnsc_50,statisticalParams(iSample).rdnsc_m]=diff2cum(rawData(iSample).rdnsc3,rawData(iSample).adjustP3,[1e-3,1]);
        [~,~,statisticalParams(iSample).sigmav_50,statisticalParams(iSample).sigmav_m]=diff2cum(rawData(iSample).sigmav3,rawData(iSample).adjustP3,[1e-3,1]);
        % 2D DIA have no paticle thickness. So Corey shape factor only can be infered from Xc_Mamin.
        [~,~,statisticalParams(iSample).sfCorey_50,statisticalParams(iSample).sfCorey_m]=diff2cum(rawData(iSample).sfCorey,rawData(iSample).adjustP3,[1e-3,1]);
    end
    %--------------------------------------
    %for particle size and shape of user components
    %--------------------------------------
    nUserComponent=length(userSettings.componentUpSize);
    statisticalParams(iSample).userComponent.upSize=userSettings.componentUpSize;
    statisticalParams(iSample).userComponent.downSize=userSettings.componentDownSize;
    for iUserComponent=1:nUserComponent
        thisComponentlId=(rawData(iSample).channelDownSize>=(userSettings.componentDownSize(iUserComponent)))&(rawData(iSample).channelUpSize<(userSettings.componentUpSize(iUserComponent)));
        thisComponentP3=rawData(iSample).adjustP3(thisComponentlId)./sum(rawData(iSample).adjustP3(thisComponentlId)); %normalized to 1
        thisComponentUpSize=rawData(iSample).channelUpSize(thisComponentlId);
        thisComponentDownSize=rawData(iSample).channelDownSize(thisComponentlId);
        thisComponentMidSizeUm=2.^((log2(thisComponentUpSize)+log2(thisComponentDownSize))/2); %logarithmic midpoint, um
        thisComponentMidSizePhi=-log2(thisComponentMidSizeUm./1000);
        statisticalParams(iSample).userComponent.density(iUserComponent)=sum(rawData(iSample).adjustP3(thisComponentlId));
        statisticalParams(iSample).userComponent.dm(iUserComponent) =sum(thisComponentMidSizeUm.*thisComponentP3);%mean size, um
        statisticalParams(iSample).userComponent.dm_Mcmanus(iUserComponent)   =sum(thisComponentMidSizePhi.*thisComponentP3); %mean size, phi
        statisticalParams(iSample).userComponent.sigma_Mcmanus(iUserComponent)=(sum((thisComponentMidSizePhi-statisticalParams(iSample).userComponent.dm_Mcmanus(iUserComponent)).^2.*thisComponentP3)).^(1./2);
        statisticalParams(iSample).userComponent.sk_Mcmanus(iUserComponent)   =(sum((thisComponentMidSizePhi-statisticalParams(iSample).userComponent.dm_Mcmanus(iUserComponent)).^3.*thisComponentP3)).^(1./3);
        statisticalParams(iSample).userComponent.kg_Mcmanus(iUserComponent)   =(sum((thisComponentMidSizePhi-statisticalParams(iSample).userComponent.dm_Mcmanus(iUserComponent)).^4.*thisComponentP3)).^(1./4);

        if rawData(iSample).haveShapeData>0
            statisticalParams(iSample).userComponent.spht_m(iUserComponent) =sum(rawData(iSample).spht3(thisComponentlId).*thisComponentP3);%meanspht
            statisticalParams(iSample).userComponent.symm_m(iUserComponent) =sum(rawData(iSample).symm3(thisComponentlId).*thisComponentP3);%meansymm
            statisticalParams(iSample).userComponent.b_l_m(iUserComponent) =sum(rawData(iSample).b_l3(thisComponentlId).*thisComponentP3);%meanb/l
            statisticalParams(iSample).userComponent.B_LRec_m(iUserComponent) =sum(rawData(iSample).B_LRec3(thisComponentlId).*thisComponentP3);%meanB_LRec
            statisticalParams(iSample).userComponent.sigmav_m(iUserComponent) =sum(rawData(iSample).sigmav3(thisComponentlId).*thisComponentP3);%meansigmav
            statisticalParams(iSample).userComponent.conv_m(iUserComponent) =sum(rawData(iSample).conv3(thisComponentlId).*thisComponentP3);%meanconv
            statisticalParams(iSample).userComponent.rdnsc_m(iUserComponent) =sum(rawData(iSample).rdnsc3(thisComponentlId).*thisComponentP3);%meanrdnsc
            if sfCoreyEnabled==true
                statisticalParams(iSample).userComponent.sfCorey_m(iUserComponent) =sum(rawData(iSample).sfCorey(thisComponentlId).*thisComponentP3);
            else
                statisticalParams(iSample).userComponent.sfCorey_m(iUserComponent) =nan;
            end
        else
            statisticalParams(iSample).userComponent.spht_m(iUserComponent) =nan;
            statisticalParams(iSample).userComponent.symm_m(iUserComponent) =nan;
            statisticalParams(iSample).userComponent.b_l_m(iUserComponent) =nan;
            statisticalParams(iSample).userComponent.B_LRec_m(iUserComponent) =nan;
            statisticalParams(iSample).userComponent.sigmav_m(iUserComponent) =nan;
            statisticalParams(iSample).userComponent.conv_m(iUserComponent) =nan;
            statisticalParams(iSample).userComponent.rdnsc_m(iUserComponent) =nan;
            statisticalParams(iSample).userComponent.sfCorey_m(iUserComponent) =nan;
        end
    end
    %
end