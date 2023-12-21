function rawData=readLISSTData(userSettings,sampleSettings)
%----------------------------------------------------------------------------------------------------
% @file name:   readLISSTData.m
% @description: Batch read all *.csv data files in the LISST data directory
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.1, 11/27/2023
%----------------------------------------------------------------------------------------------------
% @param:
% userSettings.
%             dataPath: full path of the data files
%     forceReadRawData:
%            = true  allways read data from raw files
%            = false load the rawData.mat if exists in the dataPath; otherwise, read data from raw files
%  MIN_CHANNEL_SIZE_UM: lower limit of instrument detection (um), should be greater than 0, default is 0.01um
%  MAX_CHANNEL_SIZE_UM: upper limit of instrument detection (um), default is 10mm
%         instrumentId: 
%                     = 1, coulter LS 13320
%                     =11, camsizer X2
%                     =21, malvern
%                     =31, LISST200X
%                     =99, unknown
% sampleSettings.
%            dataPath: path of the raw data
%            fileName: file name of the raw data
%                name: sample name
%            sampleId: sample id, numeric and unique
%             discard: discard flag
%                      =0, the sample data is valid
%                      =1, discard the sample data
%        minValidSize: minimum valid particle size, in unit of um
%        maxValidSize: maximum valid particle size, in unit of um
%           groupName: Name of sample grouping
%             groupId: id of sample grouping, numeric and unique
%   exportToAnalySize: export the sample data to AnalySize
%                      =0, disable
%                      =1, enable
% @return: 
% rawData.
%           dataPath: full path of the raw data file
%           fileName: file name of the raw data file
%       instrumentId: instrument code
%                     = 1, coulter LS 13320
%                     =11, camsizer X2
%                     =21, malvern
%                     =31, LISST200X
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
%              depth: water depth, only for LISST200X
%        temperature: water temperature, only for LISST200X
%            extADC2: adc value of external port 2#, only for LISST200X
%            extADC3: adc value of external port 3#, only for LISST200X
%totalVolumeConcentration: total volume concentration, only for LISST200X
%opticalTransmission: optical transmission, only for LISST200X
%    beamAttenuation: beam attenuation, only for LISST200X
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
%             trans3: volume-based number of transparency
%            transb3: volume-based number of transparency B
%           ellipse3: volume-based number of ellipse index
%    channelMeanSize: mean value of the particle size, um, only valid in CamsizerX2 data
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
% @references:
%  Retsch Technology GmbH, Manual Evaluation Software CAMSIZER X2(18.10.2018 Version 0002), 2018.
%  malvern Panalytical. Mastersizer 2000 user manual issue 2.0, 2021. https://www.malvernpanalytical.com/en/learn/knowledge-center/user-manuals/man0247en
%  Sequoia SCI. LISST-200X user's manual (2022, version 2.3), 2022,https://www.sequoiasci.com/wp-content/uploads/2016/02/LISST-200X_Users_Manual_v2_3.pdf
%  BeckMan Coulter. LS13320 Laser Diffraction Particle Size Analyzer Instructions for Use, 2020. https://www.beckman.com/search#q=LS%2013%20320&t=coveo-tab-techdocs
%  https://www.sympatec.com/en/particle-measurement/glossary/particle-shape/
%----------------------------------------------------------------------------------------------------
rawData={};

if userSettings.dataPath(end)~='\'
    userSettings.dataPath(end+1)='\';
end

hidWait=waitbar(0,'Reading LISST data, please wait...');
if exist([userSettings.dataPath,'rawData.mat'],'file')&&(userSettings.forceReadRawData==false)
    load([userSettings.dataPath,'rawData.mat'],'-mat','rawData');
    close(hidWait);
    return;
end

suffix='.csv';
tempVar=dir([userSettings.dataPath,'*',suffix]);
allFile=char(tempVar.name);
fileNum=size(allFile,1);
instrumentDataTable=[];
validSampleNum=0;

channelSize=[1
    1.48
    1.74
    2.05
    2.42
    2.86
    3.38
    3.98
    4.7
    5.55
    6.55
    7.72
    9.12
    10.8
    12.7
    15
    17.7
    20.9
    24.6
    29.1
    34.3
    40.5
    47.7
    56.3
    66.5
    78.4
    92.6
    109
    129
    152
    180
    212
    250
    297
    354
    420
    500];

dataFileId=nan(195*fileNum,1);
instrumentDataTable=nan(195*fileNum,61);
sampleNum=0;
for iFile=1:fileNum
    thisDataFileName=allFile(iFile,:);
    thisDataTable=load(strcat(userSettings.dataPath,thisDataFileName),'-ascii');
    fileIds=zeros(size(thisDataTable,1),1)+iFile;
    instrumentDataTable(sampleNum+1:sampleNum+size(thisDataTable,1),:)=thisDataTable;
    dataFileId(sampleNum+1:sampleNum+size(thisDataTable,1),1)=fileIds;
    sampleNum=sampleNum+size(thisDataTable,1);
end
instrumentDataTable=instrumentDataTable(1:sampleNum,:);
dataFileId=dataFileId(1:sampleNum,:);
[sampleNum,varNum]=size(instrumentDataTable);
if sampleNum<1
    fprintf('No valid data in the selected file.\n');
    close(hidWait);
    return;
end
if varNum~=61
    fprintf('Invalid LISST data files.\n');
    close(hidWait);
    return;
end


allSampleTime=datetime(instrumentDataTable(:,43),instrumentDataTable(:,44),instrumentDataTable(:,45),instrumentDataTable(:,46),instrumentDataTable(:,47),instrumentDataTable(:,48));

for iSample=1:sampleNum
    thisSampleName=char(allSampleTime(iSample),'yyyy-MM-dd-HH-mm-ss');
    thisDiscardFlag=false;
    thisSampleId=nan;
    validSizeLim=[0,inf];
    thisGroupName='undefined';
    thisGroupId=-999;
    exportToAnalySize=1;

    %read user defined infomation.
    if ~isempty(sampleSettings)
        userSetRecordNum=length(sampleSettings.name);
        for iSet=1:userSetRecordNum
            % sample search principle: file name and directory are the same
            if (strcmpi(strrep(thisSampleName,' ',''),strrep(sampleSettings.name{iSet},' ',''))==true)&&(strcmpi(userSettings.dataPath,sampleSettings.dataPath{iSet})==true)
                if sampleSettings.discard(iSet)==1
                    thisDiscardFlag=true;
                end
                thisSampleName=sampleSettings.name{iSet};
                validSizeLim=[sampleSettings.minValidSize(iSet),sampleSettings.maxValidSize(iSet)];
                thisGroupName=sampleSettings.groupName{iSet};
                thisGroupId=sampleSettings.groupId(iSet);
                thisSampleId=sampleSettings.sampleId(iSet);
                exportToAnalySize=sampleSettings.exportToAnalySize(iSet);
                break;
            end
        end
    end
    if thisDiscardFlag==true
        continue;
    end
    % replace invalid characters with '-' in SampleName, invalid characters: '*."/\[]:;|,?<>' 
    thisSampleName=strrep(thisSampleName,'*','-');
    thisSampleName=strrep(thisSampleName,'"','-');
    thisSampleName=strrep(thisSampleName,'/','-');
    thisSampleName=strrep(thisSampleName,'\','-');
    thisSampleName=strrep(thisSampleName,'[','-');
    thisSampleName=strrep(thisSampleName,']','-');
    thisSampleName=strrep(thisSampleName,':','-');
    thisSampleName=strrep(thisSampleName,';','-');
    thisSampleName=strrep(thisSampleName,'|','-');
    thisSampleName=strrep(thisSampleName,',','-');
    thisSampleName=strrep(thisSampleName,'?','-');
    thisSampleName=strrep(thisSampleName,'<','-');
    thisSampleName=strrep(thisSampleName,'>','-');

    validSampleNum=validSampleNum+1;
    rawData(validSampleNum).instrumentId=userSettings.instrumentId;
    rawData(validSampleNum).sampleName=thisSampleName;
    if isnan(thisSampleId)
        thisSampleId=-validSampleNum;
    end
    rawData(validSampleNum).sampleId=thisSampleId;
    rawData(validSampleNum).groupName=thisGroupName;
    rawData(validSampleNum).groupId=thisGroupId;
    rawData(validSampleNum).dataPath=userSettings.dataPath;
    rawData(validSampleNum).fileName=allFile(dataFileId(iSample),:);
    rawData(validSampleNum).exportToAnalySize=exportToAnalySize;
    rawData(validSampleNum).configInfo='LISST';
    rawData(validSampleNum).type='x_area';
    rawData(validSampleNum).analysisTime=allSampleTime(iSample); %datetime类型
    rawData(validSampleNum).validSizeLim=validSizeLim;
    rawData(validSampleNum).analysisPeriod=0;
    rawData(validSampleNum).pumpSpeed=0;
    rawData(validSampleNum).SSa=0;
    rawData(validSampleNum).waterRefractivity=0;
    rawData(validSampleNum).particleRefractivity=0;
    rawData(validSampleNum).particleAbsorptivity=0;
    rawData(validSampleNum).obscuration=0;
    rawData(validSampleNum).depth=instrumentDataTable(iSample,41);
    rawData(validSampleNum).temperature=instrumentDataTable(iSample,42);
    rawData(validSampleNum).extADC2=instrumentDataTable(iSample,49);
    rawData(validSampleNum).extADC3=instrumentDataTable(iSample,59);
    rawData(validSampleNum).totalVolumeConcentration=instrumentDataTable(iSample,51);
    rawData(validSampleNum).opticalTransmission=instrumentDataTable(iSample,60);
    rawData(validSampleNum).beamAttenuation=instrumentDataTable(iSample,61);

    rawData(validSampleNum).channelDownSize=channelSize(1:end-1,1);
    rawData(validSampleNum).channelUpSize=channelSize(2:end,1);
    thisSampleLogMidSize=(log2(rawData(validSampleNum).channelDownSize)+log2(rawData(validSampleNum).channelUpSize))./2;
    rawData(validSampleNum).channelMidSize=2.^(thisSampleLogMidSize);

    rawData(validSampleNum).p3=instrumentDataTable(iSample,1:36)'./sum(instrumentDataTable(iSample,1:36)).*100;
    % reject the invalid components according to the user-defined "validSizeLim"
    inValidId=(rawData(validSampleNum).channelUpSize<rawData(validSampleNum).validSizeLim(1))|(rawData(validSampleNum).channelDownSize>rawData(validSampleNum).validSizeLim(2));
    newP3=rawData(validSampleNum).p3;
    newP3(inValidId)=0;
    newP3=newP3./sum(newP3).*100;

    nChannel=length(newP3);
    q3=newP3.*0;
    newQ3=newP3.*0;
    for iChannel=1:nChannel
        q3(iChannel,1)=sum(rawData(validSampleNum).p3(1:iChannel,1));
        newQ3(iChannel,1)=sum(newP3(1:iChannel,1));
    end
    rawData(validSampleNum).q3=q3;
    rawData(validSampleNum).adjustP3=newP3;
    rawData(validSampleNum).adjustQ3=newQ3;
    rawData(validSampleNum).haveShapeData=false;
    waitbar(iSample./sampleNum,hidWait);
end
close(hidWait);
if validSampleNum<1
    rawData=[];
else
    save([userSettings.dataPath,'rawData.mat'],'rawData');
end