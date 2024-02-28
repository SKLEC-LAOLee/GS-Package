function rawData=readCamSizerData(userSettings,sampleSettings)
%----------------------------------------------------------------------------------------------------
% @file name:   readCamSizerData.m
% @description: Batch read all XLE or XLD data files in the CamSizer data directory (xle files are
%               retrieved first by default, xld files are retrieved when xle does not exist).
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.1, 10/21/2023
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

hidWait=waitbar(0,'Reading CamSizer data, please wait...');
if exist([userSettings.dataPath,'rawData.mat'],'file')&&(userSettings.forceReadRawData==false)
    load([userSettings.dataPath,'rawData.mat'],'-mat','rawData');
    close(hidWait);
    return;
end

suffix='.xle';
tempVar=dir([userSettings.dataPath,'*',suffix]);
if isempty(tempVar)
    suffix='.xld';
    tempVar=dir([userSettings.dataPath,'*',suffix]);
end
allFile=char(tempVar.name);
sampleNum=size(allFile,1);
validFileNum=0;
if sampleNum<1
    close(hidWait);
    return;
end

for iSample=1:sampleNum
    % readdata
    thisDataFileName=allFile(iSample,:);

    fidIn=fopen(strcat(userSettings.dataPath,thisDataFileName),'r', 'n' , 'UTF16LE');
    tailId=strfind(thisDataFileName,'_x');
    thisSampleName=thisDataFileName(1:(tailId(end)-1));

    thisDiscardFlag=false;
    thisSampleId=nan;
    validSizeLim=[0,inf];
    thisGroupName='undefined';
    thisGroupId=-999;
    exportToAnalySize=1;
    % retrieve user settings
    if ~isempty(sampleSettings)
        userSetRecordNum=length(sampleSettings.name);
        for iSet=1:userSetRecordNum
            % sample search principle: file name and directory are the same
            if (strcmpi(strrep(thisDataFileName,' ',''),strrep(sampleSettings.fileName{iSet},' ',''))==true)&&(strcmpi(userSettings.dataPath,sampleSettings.dataPath{iSet})==true)
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

    shapeRecordStartFlag=false;
    getValidDataFlag=false;

    channelDownSizeId=1;
    channelUpSizeId=2;
    p3Id=3;
    q3Id=4;
    spht3Id=0;
    symm3Id=0;
    b_l3Id=0;
    B_LRec3Id=0;
    sigmav3Id=0;
    conv3Id=0;
    rdnsc3Id=0;
    pdvId=0;
    xMean3Id=0;
    xFe3Id=0;
    xMa3Id=0;
    xc3Id=0;
    xFe_min3Id=0;
    xMa_min3Id=0;
    xc_min3Id=0;
    xFe_max3Id=0;
    xMa_max3Id=0;
    xc_max3Id=0;
    trans3Id=0;
    transb3Id=0;
    ellipse3Id=0;
    
    channelDownShapeId=1;
    channelUpShapeId=2;
    q3SphtId=0;
    q3SymmId=0;
    q3_b_lId=0;
    q3B_LRecId=0;
    q3SigmavId=0;
    q3ConvId=0;
    q3RdnscId=0;
    q0SphtId=0;
    q0SymmId=0;
    q0_b_lId=0;
    q0B_LRecId=0;
    q0SigmavId=0;
    q0ConvId=0;
    q0RdnscId=0;

    while feof(fidIn)~=1
        tempStr=fgetl(fidIn);
        switch true
            case contains(tempStr,'.afg	')&&contains(tempStr,char(9))
                tabsId=strfind(tempStr,char(9));
                if length(tabsId)~=5
                    continue;
                end
                validFileNum=validFileNum+1;
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
                rawData(validFileNum).instrumentId=userSettings.instrumentId;
                rawData(validFileNum).sampleName=thisSampleName;
                if isnan(thisSampleId)
                    thisSampleId=-validFileNum;
                end
                rawData(validFileNum).sampleId=thisSampleId;
                rawData(validFileNum).groupName=thisGroupName;
                rawData(validFileNum).groupId=thisGroupId;
                rawData(validFileNum).dataPath=userSettings.dataPath;
                rawData(validFileNum).fileName=thisDataFileName;
                rawData(validFileNum).exportToAnalySize=exportToAnalySize;

                rawData(validFileNum).configInfo=tempStr(tabsId(1)+1:tabsId(2)-1);
                rawData(validFileNum).type=tempStr(tabsId(2)+1:tabsId(3)-1);
                rawData(validFileNum).analysisTime=datetime(tempStr(tabsId(3)+1:tabsId(5)-1));
                rawData(validFileNum).validSizeLim=validSizeLim;
                period=str2num(strrep(tempStr(tabsId(5)+1:end-1),'min',' '));
                rawData(validFileNum).analysisPeriod=period(1)*60+period(2);
                rawData(validFileNum).obscuration=0;
            case contains(tempStr,'[mm]	p3 [%]	Q3 [%]	q3 [%/mm]	p0 [%]	Q0 [%]	q0 [%/mm]')||contains(tempStr,'[µm]	p3 [%]	Q3 [%]	q3 [%/µm]	p0 [%]	Q0 [%]	q0 [%/µm]')
                if contains(tempStr,'[mm]	p3 [%]	Q3 [%]	q3 [%/mm]	p0 [%]	Q0 [%]	q0 [%/mm]')
                    convertToUM=1000;
                else
                    convertToUM=1;
                end
                getValidDataFlag=true;
                channelNum=0;


                tabsId=strfind(tempStr,char(9));
                nVar=length(tabsId)+1;
                nodes=[0,tabsId,length(tempStr)+1];
                thisSampleData=zeros(500,nVar);
                for iVar=1:nVar
                    thisVarName=tempStr(nodes(iVar)+1:nodes(iVar+1)-1);
                    if strcmpi(thisVarName,'SPHT3')
                        spht3Id=iVar;
                    elseif strcmpi(thisVarName,'Symm3')
                        symm3Id=iVar;
                    elseif strcmpi(thisVarName,'b/l3')
                        b_l3Id=iVar;
                    elseif strcmpi(thisVarName,'B/L_rec3')
                        B_LRec3Id=iVar;
                    elseif strcmpi(thisVarName,'Sigma_v3')
                        sigmav3Id=iVar;
                    elseif strcmpi(thisVarName,'Conv3')
                        conv3Id=iVar;
                    elseif strcmpi(thisVarName,'RDNS_C3')
                        rdnsc3Id=iVar;
                    elseif strcmpi(thisVarName,'PDV')
                        pdvId=iVar;
                    elseif contains(thisVarName,'x_mean3')
                        xMean3Id=iVar;
                    elseif contains(thisVarName,'xFe3')
                        xFe3Id=iVar;
                    elseif contains(thisVarName,'xMa3')
                        xMa3Id=iVar;
                    elseif contains(thisVarName,'xc3')
                        xc3Id=iVar;
                    elseif contains(thisVarName,'xFe_min3')
                        xFe_min3Id=iVar;
                    elseif contains(thisVarName,'xMa_min3')
                        xMa_min3Id=iVar;
                    elseif contains(thisVarName,'xc_min3')
                        xc_min3Id=iVar;
                    elseif contains(thisVarName,'xFe_max3')
                        xFe_max3Id=iVar;
                    elseif contains(thisVarName,'xMa_max3')
                        xMa_max3Id=iVar;
                    elseif contains(thisVarName,'xc_max3')
                        xc_max3Id=iVar;
                    elseif contains(thisVarName,'Trans3')
                        trans3Id=iVar;
                    elseif contains(thisVarName,'Transb3')
                        transb3Id=iVar;
                    elseif contains(thisVarName,'Ellipse3')
                        ellipse3Id=iVar;
                    end
                end

                while feof(fidIn)~=1
                    tempStr=fgetl(fidIn);
                    tempStr=strrep(tempStr,',','.');
                    if contains(tempStr,'Shape	class')
                        shapeRecordStartFlag=true;
                        break;
                    end
                    tempVal=str2num(tempStr); %#ok<*ST2NM>
                    if length(tempVal)==nVar
                        channelNum=channelNum+1;
                        thisSampleData(channelNum,:)=tempVal;
                    end
                end
                if channelNum<3
                    validFileNum=validFileNum-1;
                    continue;
                end
                rawData(validFileNum).channelDownSize=thisSampleData(1:channelNum,channelDownSizeId).*convertToUM;
                rawData(validFileNum).channelUpSize=thisSampleData(1:channelNum,channelUpSizeId).*convertToUM;
                userSettings.MAX_CHANNEL_SIZE_UM=max([userSettings.MAX_CHANNEL_SIZE_UM,max(rawData(validFileNum).channelDownSize)]);
                rawData(validFileNum).channelDownSize(rawData(validFileNum).channelDownSize<userSettings.MIN_CHANNEL_SIZE_UM)=userSettings.MIN_CHANNEL_SIZE_UM;
                rawData(validFileNum).channelUpSize(rawData(validFileNum).channelUpSize>userSettings.MAX_CHANNEL_SIZE_UM)=userSettings.MAX_CHANNEL_SIZE_UM;
                thisSampleLogMidSize=(log2(rawData(validFileNum).channelDownSize)+log2(rawData(validFileNum).channelUpSize))./2;
                rawData(validFileNum).channelMidSize=2.^(thisSampleLogMidSize);
                rawData(validFileNum).p3=thisSampleData(1:channelNum,p3Id);
                rawData(validFileNum).q3=thisSampleData(1:channelNum,q3Id);
                rawData(validFileNum).adjustP3=rawData(validFileNum).p3;
                rawData(validFileNum).adjustQ3=rawData(validFileNum).q3;
                rawData(validFileNum).haveShapeData=0;
                rawData(validFileNum).spht3=zeros(channelNum,1);
                rawData(validFileNum).symm3=zeros(channelNum,1);
                rawData(validFileNum).b_l3=zeros(channelNum,1);
                rawData(validFileNum).B_LRec3=zeros(channelNum,1);
                rawData(validFileNum).sigmav3=zeros(channelNum,1);
                rawData(validFileNum).conv3=zeros(channelNum,1);
                rawData(validFileNum).rdnsc3=zeros(channelNum,1);
                rawData(validFileNum).pdv=zeros(channelNum,1);
                rawData(validFileNum).channelMeanSize=zeros(channelNum,1);
                rawData(validFileNum).channelSize_xFe_avg=zeros(channelNum,1);
                rawData(validFileNum).channelSize_xMa_avg=zeros(channelNum,1);
                rawData(validFileNum).channelSize_xc_avg=zeros(channelNum,1);
                rawData(validFileNum).channelSize_xFe_min=zeros(channelNum,1);
                rawData(validFileNum).channelSize_xMa_min=zeros(channelNum,1);
                rawData(validFileNum).channelSize_xc_min=zeros(channelNum,1);
                rawData(validFileNum).channelSize_xFe_max=zeros(channelNum,1);
                rawData(validFileNum).channelSize_xMa_max=zeros(channelNum,1);
                rawData(validFileNum).channelSize_xc_max=zeros(channelNum,1);
                rawData(validFileNum).trans3=zeros(channelNum,1);
                rawData(validFileNum).transb3=zeros(channelNum,1);
                rawData(validFileNum).ellipse3=zeros(channelNum,1);

                if spht3Id>0
                    rawData(validFileNum).spht3=thisSampleData(1:channelNum,spht3Id);
                end
                if symm3Id>0
                    rawData(validFileNum).symm3=thisSampleData(1:channelNum,symm3Id);
                end
                if b_l3Id>0
                    rawData(validFileNum).b_l3=thisSampleData(1:channelNum,b_l3Id);
                end
                if B_LRec3Id>0
                    rawData(validFileNum).B_LRec3=thisSampleData(1:channelNum,B_LRec3Id);
                end
                if sigmav3Id>0
                    rawData(validFileNum).sigmav3=thisSampleData(1:channelNum,sigmav3Id);
                end
                if conv3Id>0
                    rawData(validFileNum).conv3=thisSampleData(1:channelNum,conv3Id);
                end
                if rdnsc3Id>0
                    rawData(validFileNum).rdnsc3=thisSampleData(1:channelNum,rdnsc3Id);
                end
                if pdvId>0
                    rawData(validFileNum).pdv=thisSampleData(1:channelNum,pdvId);
                end
                if xMean3Id>0
                    rawData(validFileNum).channelMeanSize=thisSampleData(1:channelNum,xMean3Id)*convertToUM;
                    rawData(validFileNum).channelMeanSize(rawData(validFileNum).channelMeanSize>userSettings.MAX_CHANNEL_SIZE_UM)=userSettings.MAX_CHANNEL_SIZE_UM;
                end

                if xFe3Id>0
                    rawData(validFileNum).channelSize_xFe_avg=thisSampleData(1:channelNum,xFe3Id)*convertToUM;
                end
                if xMa3Id>0
                    rawData(validFileNum).channelSize_xMa_avg=thisSampleData(1:channelNum,xMa3Id)*convertToUM;
                end
                if xc3Id>0
                    rawData(validFileNum).channelSize_xc_avg=thisSampleData(1:channelNum,xc3Id)*convertToUM;
                end
                if xFe_min3Id>0
                    rawData(validFileNum).channelSize_xFe_min=thisSampleData(1:channelNum,xFe_min3Id)*convertToUM;
                end
                if xMa_min3Id>0
                    rawData(validFileNum).channelSize_xMa_min=thisSampleData(1:channelNum,xMa_min3Id)*convertToUM;
                end
                if xc_min3Id>0
                    rawData(validFileNum).channelSize_xc_min=thisSampleData(1:channelNum,xc_min3Id)*convertToUM;
                end
                if xFe_max3Id>0
                    rawData(validFileNum).channelSize_xFe_max=thisSampleData(1:channelNum,xFe_max3Id)*convertToUM;
                end
                if xMa_max3Id>0
                    rawData(validFileNum).channelSize_xMa_max=thisSampleData(1:channelNum,xMa_max3Id)*convertToUM;
                end
                if xc_max3Id>0
                    rawData(validFileNum).channelSize_xc_max=thisSampleData(1:channelNum,xc_max3Id)*convertToUM;
                end
                if trans3Id>0
                    rawData(validFileNum).trans3=thisSampleData(1:channelNum,trans3Id);
                end
                if trans3Id>0
                    rawData(validFileNum).trans3=thisSampleData(1:channelNum,trans3Id);
                end
                if transb3Id>0
                    rawData(validFileNum).transb3=thisSampleData(1:channelNum,transb3Id);
                end
                if ellipse3Id>0
                    rawData(validFileNum).ellipse3=thisSampleData(1:channelNum,ellipse3Id);
                end
        end
        % shape data
        if shapeRecordStartFlag==true
            rawData(validFileNum).haveShapeData=1;
            channelNum=0;


            tabsId=strfind(tempStr,char(9));
            nVar=length(tabsId)+1;
            nodes=[0,tabsId,length(tempStr)+1];
            thisSampleData=zeros(500,nVar);
            for iVar=1:nVar
                thisVarName=tempStr(nodes(iVar)+1:nodes(iVar+1)-1);
                if strcmpi(thisVarName,'Q3(SPHT) [%]')
                    q3SphtId=iVar;
                elseif strcmpi(thisVarName,'Q3(Symm) [%]')
                    q3SymmId=iVar;
                elseif strcmpi(thisVarName,'Q3(b/l) [%]')
                    q3_b_lId=iVar;
                elseif strcmpi(thisVarName,'Q3(B/L_rec) [%]')
                    q3B_LRecId=iVar;
                elseif strcmpi(thisVarName,'Q3(Sigma_v) [%]')
                    q3SigmavId=iVar;
                elseif strcmpi(thisVarName,'Q3(Conv) [%]')
                    q3ConvId=iVar;
                elseif strcmpi(thisVarName,'Q3(RDNS_C) [%]')
                    q3RdnscId=iVar;
                elseif strcmpi(thisVarName,'Q0(SPHT) [%]')
                    q0SphtId=iVar;
                elseif strcmpi(thisVarName,'Q0(Symm) [%]')
                    q0SymmId=iVar;
                elseif strcmpi(thisVarName,'Q0(b/l) [%]')
                    q0_b_lId=iVar;
                elseif strcmpi(thisVarName,'Q0(B/L_rec) [%]')
                    q0B_LRecId=iVar;
                elseif strcmpi(thisVarName,'Q0(Sigma_v) [%]')
                    q0SigmavId=iVar;
                elseif strcmpi(thisVarName,'Q0(Conv) [%]')
                    q0ConvId=iVar;
                elseif strcmpi(thisVarName,'Q0(RDNS_C) [%]')
                    q0RdnscId=iVar;
                end
            end

            while feof(fidIn)~=1
                tempStr=fgetl(fidIn);
                if length(tempStr)<2
                    break;
                end
                tempStr=strrep(tempStr,',','.');
                tempVal=str2num(tempStr);
                if length(tempVal)==nVar
                    channelNum=channelNum+1;
                    thisSampleData(channelNum,:)=tempVal;
                end
            end
            if channelNum<3
                continue;
            else
                rawData(validFileNum).haveShapeData=2;
            end
            rawData(validFileNum).channelDownShape=thisSampleData(1:channelNum,channelDownShapeId);
            rawData(validFileNum).channelUpShape=thisSampleData(1:channelNum,channelUpShapeId);
            thisSampleLogMidShape=(log2(rawData(validFileNum).channelDownShape)+log2(rawData(validFileNum).channelUpShape))./2;
            rawData(validFileNum).channelMidShape=2.^(thisSampleLogMidShape);
            rawData(validFileNum).q3Spht=zeros(channelNum,1);
            rawData(validFileNum).q3Symm=zeros(channelNum,1);
            rawData(validFileNum).q3_b_l=zeros(channelNum,1);
            rawData(validFileNum).q3B_LRec=zeros(channelNum,1);
            rawData(validFileNum).q3Sigmav=zeros(channelNum,1);
            rawData(validFileNum).q3Conv=zeros(channelNum,1);
            rawData(validFileNum).q3Rdnsc=zeros(channelNum,1);
            rawData(validFileNum).q0Spht=zeros(channelNum,1);
            rawData(validFileNum).q0Symm=zeros(channelNum,1);
            rawData(validFileNum).q0_b_l=zeros(channelNum,1);
            rawData(validFileNum).q0B_LRec=zeros(channelNum,1);
            rawData(validFileNum).q0Sigmav=zeros(channelNum,1);
            rawData(validFileNum).q0Conv=zeros(channelNum,1);
            rawData(validFileNum).q0Rdnsc=zeros(channelNum,1);
            if q3SphtId>0
                rawData(validFileNum).q3Spht=thisSampleData(1:channelNum,q3SphtId);
            end
            if q3SymmId>0
                rawData(validFileNum).q3Symm=thisSampleData(1:channelNum,q3SymmId);
            end
            if q3_b_lId>0
                rawData(validFileNum).q3_b_l=thisSampleData(1:channelNum,q3_b_lId);
            end
            if q3B_LRecId>0
                rawData(validFileNum).q3B_LRec=thisSampleData(1:channelNum,q3B_LRecId);
            end
            if q3SigmavId>0
                rawData(validFileNum).q3Sigmav=thisSampleData(1:channelNum,q3SigmavId);
            end
            if q3ConvId>0
                rawData(validFileNum).q3Conv=thisSampleData(1:channelNum,q3ConvId);
            end
            if q3RdnscId>0
                rawData(validFileNum).q3Rdnsc=thisSampleData(1:channelNum,q3RdnscId);
            end

            if q0SphtId>0
                rawData(validFileNum).q0Spht=thisSampleData(1:channelNum,q0SphtId);
            end
            if q0SymmId>0
                rawData(validFileNum).q0Symm=thisSampleData(1:channelNum,q0SymmId);
            end
            if q0_b_lId>0
                rawData(validFileNum).q0_b_l=thisSampleData(1:channelNum,q0_b_lId);
            end
            if q0B_LRecId>0
                rawData(validFileNum).q0B_LRec=thisSampleData(1:channelNum,q0B_LRecId);
            end
            if q0SigmavId>0
                rawData(validFileNum).q0Sigmav=thisSampleData(1:channelNum,q0SigmavId);
            end
            if q0ConvId>0
                rawData(validFileNum).q0Conv=thisSampleData(1:channelNum,q0ConvId);
            end
            if q0RdnscId>0
                rawData(validFileNum).q0Rdnsc=thisSampleData(1:channelNum,q0RdnscId);
            end
            break;
        end
    end
    fclose(fidIn);

    % reject the invalid components according to the user-defined "validSizeLim"
    if getValidDataFlag==true
        inValidId=(rawData(validFileNum).channelUpSize<rawData(validFileNum).validSizeLim(1))|(rawData(validFileNum).channelDownSize>rawData(validFileNum).validSizeLim(2));
        if sum(inValidId)>0
            newP3=rawData(validFileNum).p3;
            newP3(inValidId)=0;
            newP3=newP3./sum(newP3).*100;
            rawData(validFileNum).adjustP3=newP3;
            nChannel=length(newP3);
            newQ3=newP3.*0;
            for iChannel=1:nChannel
                newQ3(iChannel)=sum(newP3(1:iChannel));
            end
            rawData(validFileNum).adjustQ3=newQ3;
        else
            rawData(validFileNum).adjustP3=rawData(validFileNum).p3;
            rawData(validFileNum).adjustQ3=rawData(validFileNum).q3;
        end
        % evaluate the corey shape factor
        % 2D DIA can not measure the paticle thickness, use xMa_min instead.
        if (xFe_min3Id>0)&&(xMa_min3Id>0)&&(xFe_max3Id>0)
            rawData(validFileNum).sfCorey=rawData(validFileNum).channelSize_xMa_min ./ sqrt(rawData(validFileNum).channelSize_xFe_min .* rawData(validFileNum).channelSize_xFe_max);
            rawData(validFileNum).sfCorey(isnan(rawData(validFileNum).sfCorey))=0;
        else
            rawData(validFileNum).sfCorey=rawData(validFileNum).adjustQ3.*nan;
        end
    
        % useless for DIA method
        rawData(validFileNum).obscuration=0;
        rawData(validFileNum).pumpSpeed=0;
        rawData(validFileNum).SSa=0;
        rawData(validFileNum).waterRefractivity=0;
        rawData(validFileNum).particleRefractivity=0;
        rawData(validFileNum).particleAbsorptivity=0;
    end
    %
    waitbar(iSample./sampleNum,hidWait);
end
close(hidWait);
if validFileNum<1
    rawData=[];
else
    save([userSettings.dataPath,'rawData.mat'],'rawData');
end