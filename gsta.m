function [trendStrength,trendDirection]=gsta(dcGrainsize,dcShape,x,y,dm,sorting,skewness,shape,scaleRange,methodName)
%----------------------------------------------------------------------------------------------------
% @file name:   gsta.m
% @description: 沉积物粒度、粒型输移趋势计算
% @author:      Li Weihua, whli@sklec.ecnu.edu.cn
% @version:     Ver1.0, 2023.10.01
%----------------------------------------------------------------------------------------------------
% @param:
% dcGrainsize, 粒径的有效采样距离(趋势相关的临近点判据), n(采样点个数)*2数组, 第一列为最小有效距离,第二列为最大有效距离
% dcShape, 粒型的有效采样距离(趋势相关的临近点判据), n(采样点个数)*2数组, 第一列为最小有效距离,第二列为最大有效距离
% x, 2D模式下为x坐标, 1D模式下为起点距, n(采样点个数)*1数组
% y, 2D模式下为y坐标, 1D模式下无用, n(采样点个数)*1数组
% dm, 平均粒径(phi), n(采样点个数)*1数组
% sorting, 分选系数(phi一阶距), n(采样点个数)*1数组
% skewness, 偏态(phi二阶距) , n(采样点个数)*1数组
% shape, 粒型参数, n(采样点个数)*1数组
% scaleRange, 粒度粒型参数范围(离差归一化用途), 4*2数组, var模式下采用相同scaleRange以比较矢量长度变化;
%             scaleRange=[]时取各参数极值, 定义规则如下:
%             [1,1]=min(dm)
%             [1,2]=max(dm)
%             [2,1]=min(sorting)
%             [2,2]=max(sorting)
%             [3,1]=min(skewness)
%             [3,2]=max(skewness)
%             [4,1]=min(shape)
%             [4,2]=max(shape)
% methodName, 计算方法名称, 定义如下:
%    ='2d-fix-grain'     二维定长粒径趋势, 标准gao-collins方法
%    ='2d-fix-combine'   二维定长粒径、粒型趋势, gao-collins方法增加一条粒型变好的独立输移趋势规则
%    ='2d-fix-shape'     二维定长粒型趋势, gao-collins方法仅使用粒型变好的独立输移趋势规则
%    ='1d-fix-grain'     一维定长粒径趋势, gao-collins方法降维至1d,输移轴向已知
%    ='1d-fix-combine'   一维定长粒径、粒型趋势, gao-collins方法降维至1d,输移轴向已知, 
%                           增加一条粒型变好的独立输移趋势规则
%    ='1d-fix-shape'    一维定长粒型趋势, gao-collins方法降维至1d,输移轴向已知, 仅使用粒型变好的独立输移趋势规则
%    ='1d-var-grain'    一维变长粒径趋势, gao-collins方法降维至1d,输移轴向已知, 归一化参数等权且梯度越大矢量越长 
%    ='1d-var-combine'  一维定长粒径、粒型趋势, gao-collins方法降维至1d,输移轴向已知, 归一化参数等权且梯度越大矢量越长
%                           , 增加一条粒型变好的独立输移趋势规则
%    ='1d-var-shape'    一维定长粒型趋势, gao-collins方法降维至1d,输移轴向已知, 粒型梯度越大矢量越长
%                           , 仅使用粒型变好的独立输移趋势规则
%
% @return: 
% trendStrength, 输移趋势矢量长度, n(采样点个数)*1数组
% trendDirection, 输移趋势矢量角度(去向,正北为0,顺时针变大), n(采样点个数)*1数组

% @references:
% 
%----------------------------------------------------------------------------------------------------
if strcmpi(methodName,'2d-fix-grain')
    methodCode=1;
elseif strcmpi(methodName,'2d-fix-combine')
    methodCode=2;
elseif strcmpi(methodName,'2d-fix-shape')
    methodCode=3;
elseif strcmpi(methodName,'1d-fix-grain')
    methodCode=4;
elseif strcmpi(methodName,'1d-fix-combine')
    methodCode=5;
elseif strcmpi(methodName,'1d-fix-shape')
    methodCode=6;
elseif strcmpi(methodName,'1d-var-grain')
    methodCode=7;
elseif strcmpi(methodName,'1d-var-combine')
    methodCode=8;
elseif strcmpi(methodName,'1d-var-shape')
    methodCode=9;
end
if (methodCode==3)||(methodCode==6)||(methodCode==9)
    haveGrain=false; %shape模式下，粒度参数不参与运算。
else
    haveGrain=true;
end
if (methodCode==1)||(methodCode==4)||(methodCode==7)
    haveShape=false; %grain模式下，粒型参数不参与运算。
else
    haveShape=true;
end
if (methodCode==7)||(methodCode==8)||(methodCode==9)
    strengthIsVar=true; %var模式下，矢量长度与参数变化梯度相关
else
    strengthIsVar=false;
end
if methodCode>=4 %1d模式下，只允许输入起点距在x变量
    y=x.*0;
end
if isempty(scaleRange)
    scaleRange=zeros(4,2);
    if (haveGrain==true)
        scaleRange(1,1:2)=[min(dm),max(dm)];
        scaleRange(2,1:2)=[min(sorting),max(sorting)];
        scaleRange(3,1:2)=[min(skewness),max(skewness)];
    end
    if (haveShape==true)
        scaleRange(4,1:2)=[min(shape),max(shape)];
    end
end

nPoint=length(x);
trendU=zeros(nPoint,1);
trendV=zeros(nPoint,1);
smoothedTrendU=trendU;
smoothedTrendV=trendV;
%参数无量纲归一化, 仅用于计算梯度
if (haveGrain==true)
    unifiedDm=(dm-scaleRange(1,1))./(scaleRange(1,2)-scaleRange(1,1));
    unifiedSorting=(sorting-scaleRange(2,1))./(scaleRange(2,2)-scaleRange(2,1));
    unifiedSkewness=(skewness-scaleRange(3,1))./(scaleRange(3,2)-scaleRange(3,1));
end
if (haveShape==true)
    unifiedShape=(shape-scaleRange(4,1))./(scaleRange(4,2)-scaleRange(4,1));
end
%计算矢量
for iPoint=1:nPoint
    allDistance=sqrt((x-x(iPoint)).^2+(y-y(iPoint)).^2);
    if strengthIsVar==true
        if (haveGrain==true)
            variationDm=abs(unifiedDm(iPoint)-unifiedDm);
            variationSorting=abs(unifiedSorting(iPoint)-unifiedSorting);
            variationSkewness=abs(unifiedSkewness(iPoint)-unifiedSkewness);
        end
        if (haveShape==true)
            variationShape=abs(unifiedShape(iPoint)-unifiedShape);
        end
    end
    [~,allDir]=en2vd(x-x(iPoint),y-y(iPoint));
    
    if (haveGrain==true)
        isGrainsizeNeighbor=(allDistance>1e-9)&(allDistance>=dcGrainsize(iPoint,1))&(allDistance<=dcGrainsize(iPoint,2));
        grainsizeNeighborId=find(isGrainsizeNeighbor);
        %沉积物在运移方向上分选变好（sorting变小）、粒径变细（dm变大）且更加负偏（skewness变小）
        trendRuleA=(isGrainsizeNeighbor==true)&(sorting(iPoint)>sorting)&((dm(iPoint)<dm)&(skewness(iPoint)>skewness));
        %沉积物在运移方向上分选变好（sorting变小）、粒径变粗（dm变小）且更加正偏（skewness变大）
        trendRuleB=(isGrainsizeNeighbor==true)&(sorting(iPoint)>sorting)&((dm(iPoint)>dm)&(skewness(iPoint)<skewness));
        % var方法下，认为各个参数是等权的，在1d确定性的上下游输沙路径上，梯度越大输移概率越高
        nNeighbor=length(grainsizeNeighborId);
        for iNeighbor=1:nNeighbor
            thisNeighbor=grainsizeNeighborId(iNeighbor);
            uGrainsize=0;
            vGrainsize=0;
            if (trendRuleA(thisNeighbor))||(trendRuleB(thisNeighbor))
                if strengthIsVar==true
                    trendLength=variationDm(thisNeighbor)+variationSorting(thisNeighbor)+variationSkewness(thisNeighbor);
                else
                    trendLength=1;
                end
                [uGrainsize,vGrainsize]=vd2en(trendLength,allDir(thisNeighbor));
            end
            trendU(iPoint)=trendU(iPoint)+uGrainsize;
            trendV(iPoint)=trendV(iPoint)+vGrainsize;
        end
    end
    if (haveShape==true)
        isShapeNeighbor=(allDistance>1e-9)&(allDistance>=dcShape(iPoint,1))&(allDistance<=dcShape(iPoint,2));
        shapeNeighborId=find(isShapeNeighbor);
        %沉积物在运移方向上颗粒变圆（shape变大）
        trendRuleC=(isShapeNeighbor==true)&(shape(iPoint)<shape);
        % var方法下，认为各个参数是等权的，在1d确定性的上下游输沙路径上，梯度越大输移概率越高
        nNeighbor=length(shapeNeighborId);
        for iNeighbor=1:nNeighbor
            thisNeighbor=shapeNeighborId(iNeighbor);
            uShape=0;
            vShape=0;
            if (trendRuleC(thisNeighbor)==true) %考虑一个粒型参数
                if strengthIsVar==true
                    trendLength=variationShape(thisNeighbor);
                else
                    trendLength=1;
                end
                [uShape,vShape]=vd2en(trendLength,allDir(thisNeighbor));
            end
            trendU(iPoint)=trendU(iPoint)+uShape;
            trendV(iPoint)=trendV(iPoint)+vShape;
        end
    end
end
%平滑矢量,滤去可能的搬运趋势"噪音": dcGrainsize范围内取均值, 认为粒度最大可显现趋势的距离小于粒型
for iPoint=1:nPoint
    allDistance=sqrt((x-x(iPoint)).^2+(y-y(iPoint)).^2);
    isGrainsizeNeighbor=(allDistance<=dcGrainsize(iPoint,2));
    nNeighbor=sum(isGrainsizeNeighbor);
    smoothedTrendU(iPoint)=sum(trendU(isGrainsizeNeighbor))./nNeighbor;
    smoothedTrendV(iPoint)=sum(trendV(isGrainsizeNeighbor))./nNeighbor;
end
%
[trendStrength,trendDirection]=en2vd(smoothedTrendU,smoothedTrendV);