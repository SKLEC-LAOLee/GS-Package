function [channelUpperSize,cumuPercent,medianVal,meanVal,passingVal]=diff2cum(indexVar,diffPercentage,rangeOfIndexVar,userPercentLevel)
%----------------------------------------------------------------------------------------------------
% @file name:   diff2cum.m
% @description: calculate the cumulative percentage from differential data
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 10/21/2023
%----------------------------------------------------------------------------------------------------
% @param:
% indexVar, the variable being counted, for example: grainsize, shape factor, age......
% diffPercentage, channel content. Channel width considered as half-logarithmic width on both side, percentage
% rangeOfIndexVar, minimun and maximum index size, used for evaluating the lower/upper limit of the minimum/maximum channel
% userPercentLevel, the percent level to find the passing value of indexVar
% @return:
% channelUpperSize, variable that corresponds to cumuPercent one-to-one.
% cumuPercent, cumulative curve of the input var, %
% medianVal, median value of the input var
% meanVal, mean value of the input var
% passingVal, passing value of input userPercentLevel
% @references:
% NONE
%----------------------------------------------------------------------------------------------------
channelUpperSize=[];
cumuPercent=[];
medianVal=nan;
meanVal=nan;
passingVal=nan;
% discard invalid value
validValId=(indexVar>=rangeOfIndexVar(1))&(indexVar<=rangeOfIndexVar(2));
indexVar=indexVar(validValId);
diffPercentage=diffPercentage(validValId);
% order the variable to make it monotonically increasing
[newIndexVar,iRaw]=sort(indexVar);
newDiffPercentage=diffPercentage(iRaw);
middleSizeAndMaxLim=unique([newIndexVar(:);rangeOfIndexVar(2)]);

tempVar=log2(middleSizeAndMaxLim-min(middleSizeAndMaxLim)+1e-7);
halfLogarithmicSize=(tempVar(2:end)+tempVar(1:end-1))./2;
channelUpperSize=2.^(halfLogarithmicSize)+min(middleSizeAndMaxLim)-1e-7;

nChannel=length(channelUpperSize);
if nChannel<2
    return;
end
%channelLowerSize=zeros(nChannel,1);
cumuPercent=zeros(nChannel,1);
%medianVal=nan;
for iChannel=1:nChannel
    passingId=newIndexVar<=channelUpperSize(iChannel,1);
    cumuPercent(iChannel,1)=sum(newDiffPercentage(passingId));
end
%channelLowerSize(1)=rangeOfIndexVar(1);
%channelLowerSize(2:end)=channelUpperSize(1:end-1);
meanVal=sum(indexVar.*diffPercentage)./sum(diffPercentage);
% make the variable monotonically increasing
uniqueCumuPercent=cumuPercent(:)+(1:nChannel)'.*1e-7;
medianVal=interp1(uniqueCumuPercent,channelUpperSize,50);
if nargin==4
    passingVal=interp1(uniqueCumuPercent,channelUpperSize,userPercentLevel);
else
    passingVal=[];
end