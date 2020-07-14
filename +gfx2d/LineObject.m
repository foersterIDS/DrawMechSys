classdef LineObject < handle
    
    properties
        p1
        p2
    end
    
    properties (Dependent)
        angle
        L
        localTransformMatrix
    end
    
    events
        changedPosition
    end
    
    methods
        function obj = LineObject(p1,p2)
            if nargin > 1
                obj.p1 = p1(:);
                obj.p2 = p2(:);
            end
        end
        
        function globalPosition = local2global(obj,localPosition)
            globalPosition = obj.p1 + obj.localTransformMatrix * localPosition(:);
        end
        
        function localPosition = global2local(obj,globalPosition)
            localPosition = obj.localTransformMatrix \ (globalPosition(:) - obj.p1);
        end
        
        function angle = get.angle(obj) 
            dp = obj.p2 - obj.p1;
            angle = atan2(dp(2),dp(1));
        end
        function L = get.L(obj) 
            L = norm(obj.p2 - obj.p1);
        end
       
        function localTransformMatrix = get.localTransformMatrix(obj) 
            dp = obj.p2 - obj.p1;
            dpOrth = [-dp(2);dp(1)];
            dpOrth = dpOrth./norm(dpOrth);
            localTransformMatrix = [dp, dpOrth];
        end
        
        function bind(obj,target,localOffset,bindFirstEnd)
            addlistener(target,'changedPosition',@(src,evt) obj.updatePosition(src,evt,localOffset,bindFirstEnd));
        end
        
        function updatePosition(obj,src,~,localOffset,updateFirstEnd)
            globalPosition = src.local2global(localOffset);
            if updateFirstEnd
                Xnew = [globalPosition(1) obj.p2(1)];
                Ynew = [globalPosition(2) obj.p2(2)];
            else
                Xnew = [obj.p1(1) globalPosition(1)];
                Ynew = [obj.p1(2) globalPosition(2)];
            end
            setPosition(obj,Xnew,Ynew);
        end
        
    end
end

