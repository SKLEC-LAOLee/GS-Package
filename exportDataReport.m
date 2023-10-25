function exportDataReport(statisticalParams,outputConfig)
%----------------------------------------------------------------------------------------------------
% @file name:   exportDataReport.m
% @description: Output statistical reports and plots
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.1, 2023.10.22
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
%  exportToAnalySize: export the sample data to AnalySize. =0, disable; =1, enable
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
%        Q3_GBT12763: cumulative volume percentage of the channels which are defined in GBT12763, (%)
%          spht_50_2: median value of sphericity, calculated using the original exported accumulation curve of particle shape
%           spht_m_2: mean value of sphericity, calculated using the original exported accumulation curve of particle shape
%           b_l_50_2: median value of aspect ratio, calculated using the original exported accumulation curve of particle shape
%            b_l_m_2: mean value of aspect ratio, calculated using the original exported accumulation curve of particle shape
%        B_LRec_50_2: median value of minimum aspect ratio, calculated using the original exported accumulation curve of particle shape
%         B_LRec_m_2: mean value of minimum aspect ratio, calculated using the original exported accumulation curve of particle shape
%          symm_50_2: median value of symmetry, calculated using the original exported accumulation curve of particle shape
%           symm_m_2: mean value of symmetry, calculated using the original exported accumulation curve of particle shape
%         rdnsc_50_2: median value of roundness, calculated using the original exported accumulation curve of particle shape
%          rdnsc_m_2: mean value of roundness, calculated using the original exported accumulation curve of particle shape
%          conv_50_2: median value of convexity, calculated using the original exported accumulation curve of particle shape
%           conv_m_2: mean value of convexity, calculated using the original exported accumulation curve of particle shape
%        sigmav_50_2: median value of sigmav?, calculated using the original exported accumulation curve of particle shape
%         sigmav_m_2: mean value of sigmav?, calculated using the original exported accumulation curve of particle shape
%            spht_50: median value of sphericity, calculated using the grainsize indexed particle shape
%             spht_m: mean value of sphericity, calculated using the grainsize indexed particle shape
%             b_l_50: median value of aspect ratio, calculated using the grainsize indexed particle shape
%              b_l_m: mean value of aspect ratio, calculated using the grainsize indexed particle shape
%          B_LRec_50: median value of minimum aspect ratio, calculated using the grainsize indexed particle shape
%           B_LRec_m: mean value of minimum aspect ratio, calculated using the grainsize indexed particle shape
%            symm_50: median value of symmetry, calculated using the grainsize indexed particle shape
%             symm_m: mean value of symmetry, calculated using the grainsize indexed particle shape
%           rdnsc_50: median value of roundness, calculated using the grainsize indexed particle shape
%            rdnsc_m: mean value of roundness, calculated using the grainsize indexed particle shape
%            conv_50: median value of convexity, calculated using the grainsize indexed particle shape
%             conv_m: mean value of convexity, calculated using the grainsize indexed particle shape
%          sigmav_50: median value of sigmav?, calculated using the grainsize indexed particle shape
%           sigmav_m: mean value of sigmav?, calculated using the grainsize indexed particle shape
%         sfCorey_50: median value of Corey shape factor, calculated using the grainsize indexed  particle shape
%          sfCorey_m: mean value of Corey shape factor=channelSize_xFe_min/sqrt(channelSize_xFe_avg*channelSize_xFe_max), calculated using the grainsize indexed  particle shape
%      userComponent: parameters of the user-specified components
%             .upSize       : upper size of the user-specified components
%             .downSize     : lower size of the user-specified components
%             .density      : percentage of all
%             .dm           : mean size in unit of um
%             .dm_Mcmanus   : mean size in unit of phi(Mcmanus method)
%             .sigma_Mcmanus: sorting (Mcmanus method)
%             .sk_Mcmanus   : skewness (Mcmanus method)
%             .kg_Mcmanus   : Kurtosis (Mcmanus method)
%             .spht_m       : mean value of sphericity, calculated using the grainsize indexed particle shape
%             .symm_m       : mean value of symmetry, calculated using the grainsize indexed particle shape
%             .b_l_m        : mean value of aspect ratio, calculated using the grainsize indexed particle shape
%             .B_LRec_m     : mean value of minimum aspect ratio, calculated using the grainsize indexed particle shape
%             .sigmav_m     : mean value of sigmav?, calculated using the grainsize indexed particle shape
%             .conv_m       : mean value of convexity, calculated using the grainsize indexed particle shape
%             .rdnsc_m      : mean value of roundness, calculated using the grainsize indexed particle shape
%             .sfCorey_m    : mean value of Corey shape factor
%  outputConfig.
%         outputPath: full path of the output files
%       prefixString: Prefixes for archive file names
% GradationCurveFigWidth: figure width of gradation curve, in unit of cm
%GradationCurveFigHeight: figure height of gradation curve, in unit of cm
%           language: 
%               ='cn'   Particle grading curves are labeled in Chinese
%               ='en'   Particle grading curves are labeled in English
%     exportGBT12763: output GBT12763-format report
% exportGradingCurve: output particle grading curve figures
%     exportMetadata: output metadata report
%      exportAllData: output all the statistical parameters
%exportUserComponent: output statistical parameters of the user-speicified components
% @return: 
% NONE
% @references:
% NONE
%----------------------------------------------------------------------------------------------------

nSample=length(statisticalParams);
if nSample<1
    return;
end

figureId=-1;
exportTime=datetime("now");
exportTime.Format="yyyyMMddHHmmss";
[~,~]=mkdir([outputConfig.outputPath]); %if not eixst, create it
if outputConfig.exportGradingCurve
    [~,~]=mkdir([outputConfig.outputPath,'figures']); %if not eixst, create it
end

if outputConfig.exportMetadata
    outputMetadatafileName=[outputConfig.outputPath,outputConfig.prefixString,'_Metadata_',char(exportTime),'.csv'];
    if strcmpi(outputConfig.language,'cn')
        fidoutMetadata=fopen(outputMetadatafileName,"wt","n","GB2312");
        fprintf(fidoutMetadata,'目录,文件名,批次,样品名称,样品序号,仪器类型,上机配置文件,统计标准,上机时间,上机时长(s),循环泵速,比表面积,分散剂折射率,颗粒折射率,颗粒吸收率,遮光度,存在粒形数据,有效下限um,有效上限um\n');
    else
        fidoutMetadata=fopen(outputMetadatafileName,"wt","n","UTF-8");
        fprintf(fidoutMetadata,'path,fileName,group,name,id,instrument,configFile,sizeMethod,on_boardTime,on_boardPeriod,pumpSpeed,SSa,waterRefractivity,particleRefractivity,particleAbsorptivity,obscuration,shapeDataStatus,validLowerSize,validUpperSize\n');
    end
end

if outputConfig.exportGBT12763
    outputGBfileName=[outputConfig.outputPath,outputConfig.prefixString,'_GBT12763_',char(exportTime),'.csv']; %GBT12763
    fidoutGB=fopen(outputGBfileName,"wt","n","GB2312");
    fprintf(fidoutGB,'批次,样品名称,样品序号,D50(um),Dm(um),D5(um),D95(um),中值球形度,平均球形度,中值宽长比,平均宽长比,分选系数,偏态,峰态,粘土(%%),粉砂(%%),砂(%%),砾石(%%),命名');
    channelUp=statisticalParams(1).upSize_GBT12763;
    nChannel=length(channelUp);
    for iChannel=1:nChannel
        fprintf(fidoutGB,',<%dum(%%)',channelUp(iChannel));
    end
    fprintf(fidoutGB,'\n');
end

if outputConfig.exportAllData
    outputAllDatafileName=[outputConfig.outputPath,outputConfig.prefixString,'_AllData_',char(exportTime),'.csv'];
    if strcmpi(outputConfig.language,'cn')
        fidoutAllData=fopen(outputAllDatafileName,"wt","n","GB2312");
    else
        fidoutAllData=fopen(outputAllDatafileName,"wt","n","UTF-8");
    end
    fprintf(fidoutAllData,'group,name,id,d05,d10,d16,d25,d50,d75,d84,d90,d95,Dm_um,'...
        'dm_phi,sigma_Mcmanus,sk_Mcmanus,kg_Mcmanus,variance,'...
        'clay,silt,sand,gravel,classificationCode,classificationMethod,'...
        'spht_50_2,spht_m_2,b_l_50_2,b_l_m_2,B_LRec_50_2,B_LRec_m_2,symm_50_2,symm_m_2,rdnsc_50_2,rdnsc_m_2,conv_50_2,conv_m_2,sigmav_50_2,sigmav_m_2,'...
        'spht_50,spht_m,b_l_50,b_l_m,B_LRec_50,B_LRec_m,symm_50,symm_m,rdnsc_50,rdnsc_m,conv_50,conv_m,sigmav_50,sigmav_m,sfCorey_50,sfCorey_m\n');
end

if outputConfig.exportUserComponent
    outputUserComponentfileName=[outputConfig.outputPath,outputConfig.prefixString,'_UserComponent_',char(exportTime),'.csv'];
    if strcmpi(outputConfig.language,'cn')
        fidoutUserComponent=fopen(outputUserComponentfileName,"wt","n","GB2312");
    else
        fidoutUserComponent=fopen(outputUserComponentfileName,"wt","n","UTF-8");
    end
    fprintf(fidoutUserComponent,'group,name,id,lowerSize,upperSize,volumePercentage,Dm_um,'...
        'dm_phi,sigma_Mcmanus,sk_Mcmanus,kg_Mcmanus,'...
        'spht_m,b_l_m,B_LRec_m,symm_m,rdnsc_m,conv_m,sigmav_m,sfCorey_m\n');
end

for iSample=1:nSample
    if outputConfig.exportMetadata
        fprintf(fidoutMetadata,'''%s,''%s',statisticalParams(iSample).dataPath,statisticalParams(iSample).fileName);
        fprintf(fidoutMetadata,',''%s,''%s,%d',statisticalParams(iSample).groupName,statisticalParams(iSample).sampleName,statisticalParams(iSample).sampleId);
        fprintf(fidoutMetadata,',%d',statisticalParams(iSample).instrumentId);
        fprintf(fidoutMetadata,',''%s''',statisticalParams(iSample).configInfo);
        fprintf(fidoutMetadata,',''%s',statisticalParams(iSample).type);
        fprintf(fidoutMetadata,',%s,%d',char(statisticalParams(iSample).analysisTime,'uuuu/MM/dd HH:mm:ss'),statisticalParams(iSample).analysisPeriod);
        fprintf(fidoutMetadata,',%.0f',statisticalParams(iSample).pumpSpeed);
        fprintf(fidoutMetadata,',%.3f',statisticalParams(iSample).SSa);
        fprintf(fidoutMetadata,',%.3f',statisticalParams(iSample).waterRefractivity);
        fprintf(fidoutMetadata,',%.3f',statisticalParams(iSample).particleRefractivity);
        fprintf(fidoutMetadata,',%.3f',statisticalParams(iSample).particleAbsorptivity);
        fprintf(fidoutMetadata,',%.3f',statisticalParams(iSample).obscuration);
        fprintf(fidoutMetadata,',%d',statisticalParams(iSample).haveShapeData);
        fprintf(fidoutMetadata,',%.1f,%.1f',statisticalParams(iSample).validSizeLim(1),statisticalParams(iSample).validSizeLim(2));
        fprintf(fidoutMetadata,'\n');
    end

    if outputConfig.exportGBT12763
        fprintf(fidoutGB,'''%s',statisticalParams(iSample).groupName);
        fprintf(fidoutGB,',''%s,%d',statisticalParams(iSample).sampleName,statisticalParams(iSample).sampleId);
        fprintf(fidoutGB,',%.3f,%.3f',statisticalParams(iSample).d50,statisticalParams(iSample).dm);
        fprintf(fidoutGB,',%.3f,%.3f',statisticalParams(iSample).d05,statisticalParams(iSample).d95);
        if statisticalParams(iSample).haveShapeData
            fprintf(fidoutGB,',%.3f,%.3f',statisticalParams(iSample).spht_50,statisticalParams(iSample).spht_m);
            fprintf(fidoutGB,',%.3f,%.3f',statisticalParams(iSample).b_l_50,statisticalParams(iSample).b_l_m);
        else
            fprintf(fidoutGB,',,,,');
        end
        fprintf(fidoutGB,',%.3f,%.3f,%.3f',statisticalParams(iSample).sigma_GBT12763,statisticalParams(iSample).sk_GBT12763,statisticalParams(iSample).kg_GBT12763);
        fprintf(fidoutGB,',%.1f,%.1f,%.1f,%.1f',statisticalParams(iSample).clay,statisticalParams(iSample).silt,statisticalParams(iSample).sand,statisticalParams(iSample).gravel);
        fprintf(fidoutGB,',%s',statisticalParams(iSample).classificationCode);
        for iChannel=1:nChannel
            fprintf(fidoutGB,',%.2f',statisticalParams(iSample).Q3_GBT12763(iChannel));
        end
        fprintf(fidoutGB,'\n');
    end

    if outputConfig.exportAllData
        fprintf(fidoutAllData,'''%s',statisticalParams(iSample).groupName);
        fprintf(fidoutAllData,',''%s,%d',statisticalParams(iSample).sampleName,statisticalParams(iSample).sampleId);
        fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).d05,statisticalParams(iSample).d10);
        fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).d16,statisticalParams(iSample).d25);
        fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).d50,statisticalParams(iSample).d75);
        fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).d84,statisticalParams(iSample).d90);
        fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).d95,statisticalParams(iSample).Dm_um);
        fprintf(fidoutAllData,',%.3f,%.3f,%.3f,%.3f',statisticalParams(iSample).dm_Mcmanus,statisticalParams(iSample).sigma_Mcmanus,statisticalParams(iSample).sk_Mcmanus,statisticalParams(iSample).kg_Mcmanus);
        fprintf(fidoutAllData,',%.3f',statisticalParams(iSample).variance);
        fprintf(fidoutAllData,',%.1f,%.1f,%.1f,%.1f',statisticalParams(iSample).clay,statisticalParams(iSample).silt,statisticalParams(iSample).sand,statisticalParams(iSample).gravel);
        fprintf(fidoutAllData,',%s,%s',statisticalParams(iSample).classificationCode,statisticalParams(iSample).classificationMethod);
        if statisticalParams(iSample).haveShapeData
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).spht_50_2,statisticalParams(iSample).spht_m_2);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).b_l_50_2,statisticalParams(iSample).b_l_m_2);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).B_LRec_50_2,statisticalParams(iSample).B_LRec_m_2);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).symm_50_2,statisticalParams(iSample).symm_m_2);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).rdnsc_50_2,statisticalParams(iSample).rdnsc_m_2);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).conv_50_2,statisticalParams(iSample).conv_m_2);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).sigmav_50_2,statisticalParams(iSample).sigmav_m_2);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).spht_50,statisticalParams(iSample).spht_m);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).b_l_50,statisticalParams(iSample).b_l_m);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).B_LRec_50,statisticalParams(iSample).B_LRec_m);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).symm_50,statisticalParams(iSample).symm_m);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).rdnsc_50,statisticalParams(iSample).rdnsc_m);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).conv_50,statisticalParams(iSample).conv_m);
            fprintf(fidoutAllData,',%.3f,%.3f',statisticalParams(iSample).sigmav_50,statisticalParams(iSample).sigmav_m);
        else
            fprintf(fidoutAllData,',,,,,,,,,,,,,,,,,,,,,,,,,,,,,');
        
        end
        fprintf(fidoutAllData,'\n');
    end

    if outputConfig.exportUserComponent
        nUserComponent=length(statisticalParams(iSample).userComponent.upSize);
        for iUserComponent=1:nUserComponent
            fprintf(fidoutUserComponent,'''%s',statisticalParams(iSample).groupName);
            fprintf(fidoutUserComponent,',''%s,%d',statisticalParams(iSample).sampleName,statisticalParams(iSample).sampleId);
            fprintf(fidoutUserComponent,',%.1f,%.1f,%.2f,%.1f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n',...
                statisticalParams(iSample).userComponent.downSize(iUserComponent),...
                statisticalParams(iSample).userComponent.upSize(iUserComponent),...
                statisticalParams(iSample).userComponent.density(iUserComponent),...
                statisticalParams(iSample).userComponent.dm(iUserComponent),...
                statisticalParams(iSample).userComponent.dm_Mcmanus(iUserComponent),...
                statisticalParams(iSample).userComponent.sigma_Mcmanus(iUserComponent),...
                statisticalParams(iSample).userComponent.sk_Mcmanus(iUserComponent),...
                statisticalParams(iSample).userComponent.kg_Mcmanus(iUserComponent),...
                statisticalParams(iSample).userComponent.spht_m(iUserComponent),...
                statisticalParams(iSample).userComponent.b_l_m(iUserComponent),...
                statisticalParams(iSample).userComponent.B_LRec_m(iUserComponent),...
                statisticalParams(iSample).userComponent.symm_m(iUserComponent),...
                statisticalParams(iSample).userComponent.rdnsc_m(iUserComponent),...
                statisticalParams(iSample).userComponent.conv_m(iUserComponent),...
                statisticalParams(iSample).userComponent.sigmav_m(iUserComponent),...
                statisticalParams(iSample).userComponent.sfCorey_m(iUserComponent));
        end
    end
    if outputConfig.exportGradingCurve
        figureId=plotcomulativeCurve(statisticalParams(iSample),outputConfig);
    end
end

if outputConfig.exportGBT12763
    fclose(fidoutGB);
end

if outputConfig.exportMetadata
    fclose(fidoutMetadata);
end

if outputConfig.exportUserComponent
    fclose(fidoutUserComponent);
end

if outputConfig.exportAllData
    fclose(fidoutAllData);
end

if outputConfig.exportGradingCurve
    if figureId>0
        close(figureId);
    end
end