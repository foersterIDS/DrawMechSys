function [ sgnx ] = sgn( x )
    if sign(x)==0
        sgnx = 1;
    else
        sgnx = sign(x);
    end
end