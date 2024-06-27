function newPoints = rotationAroundPoint(points,rotationPoint,angle)
    arguments
        points (2,:) double
        rotationPoint (2,1) double
        angle (1,1) double
    end
    R = [cos(angle), -sin(angle);
         sin(angle), cos(angle)];
    newPoints = R*(points-rotationPoint) + rotationPoint;
end