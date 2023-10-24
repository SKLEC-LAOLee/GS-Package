function [velocity,direction]=en2vd(uSpeed,vSpeed, rotation)
%----------------------------------------------------------------------------------------------------
% @file name：  en2vd.m
% @description：composition U(east) and V(north) component to speed and direction(0 degrees eastward, increasing clockwise)
% @author：     Li Weihua, whli@sklec.ecnu.edu.cn
% @version：    Ver1.0, 10/21/2023
%----------------------------------------------------------------------------------------------------
% @param:
% uSpeed, east component
% vSpeed, north component
% rotation
% @return:
% speed, speed like current, wind, air ....
% direction, 0 degrees eastward, increasing clockwise, degree
% @references:
% NONE
%----------------------------------------------------------------------------------------------------
velocity=sqrt(uSpeed.^2+vSpeed.^2);
direction=velocity.*0;
flag1=uSpeed>=0;
flag2=uSpeed<0;
direction(flag1)=90-asin(vSpeed(flag1)./velocity(flag1)).*180./pi;
direction(flag2)=-90+asin(vSpeed(flag2)./velocity(flag2)).*180./pi;
if nargin<3
    rotation=0;
end
direction=mod(direction+rotation,360);
direction(velocity==0)=0;