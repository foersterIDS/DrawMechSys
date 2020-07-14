function [ rgb ] = getRGB( value, maxvalue, minvalue, skal )
    %% init:
    temp_func = @(v) v/maxvalue;
    seperator = linspace(0,maxvalue,5);
    mode = 'lin';
    if nargin>2
        if nargin>3
            switch skal
                case 'lin'
                    mode = 'lin';
                case 'log'
                    minvalue = log(minvalue)/log(10);
                    value = log(value)/log(10);
                    maxvalue = log(maxvalue)/log(10);
                    mode = 'log';
                case 'cycle_open'
                    mode = 'cycle_open';
                case 'cycle_closed'
                    mode = 'cycle_closed';
                case 'cycle_open_twice'
                    mode = 'cycle_open_twice';
                case 'cycle_open_mix'
                    mode = 'cycle_open_mix';
                otherwise
                    error('%s-mode not supported.',skal);
            end
        end
        value=value-minvalue;
        maxvalue=maxvalue-minvalue;
        temp_func = @(v) v/maxvalue;
        seperator = linspace(0,1,5);
    end
    r=0;
    g=0;
    b=0;
    %% calc:
    if strcmp(mode,'lin') || strcmp(mode,'log')
        %% lin or log:
        if maxvalue==0
            r = 0;
            g = 1;
            b = 0;
        else
            temp=temp_func(value);
            if temp<seperator(2)
                r=0;
                b=1;
                g=((4*value-0*maxvalue)/maxvalue);
            elseif temp<seperator(3)
                r=0;
                g=1;
                b=1-((4*value-1*maxvalue)/maxvalue);
            elseif temp<seperator(4)
                b=0;
                g=1;
                r=((4*value-2*maxvalue)/maxvalue);
            else
                b=0;
                r=1;
                g=(-4/maxvalue)*value+4;
            end
        end
    elseif strcmp(mode,'cycle_open')
        %% cycle_open:
        seperator = linspace(0,1,6);
        if maxvalue==0
            r = 0;
            g = 1;
            b = 0;
        else
            temp=temp_func(value);
            if temp<seperator(2)
                r=0;
                g=1*((temp-seperator(1))/(seperator(2)-seperator(1)));
                b=1;
            elseif temp<seperator(3)
                r=0;
                g=1;
                b=1-1*((temp-seperator(2))/(seperator(3)-seperator(2)));
            elseif temp<seperator(4)
                r=1*((temp-seperator(3))/(seperator(4)-seperator(3)));
                g=1;
                b=0;
            elseif temp<seperator(5)
                r=1;
                g=1-1*((temp-seperator(4))/(seperator(5)-seperator(4)));
                b=0;
            else
                r=1;
                g=0;
                b=1*((temp-seperator(5))/(seperator(6)-seperator(5)));
            end
        end
    elseif strcmp(mode,'cycle_closed')
        %% cycle_closed:
        seperator = linspace(0,1,7);
        if maxvalue==0
            r = 0;
            g = 1;
            b = 0;
        else
            temp=temp_func(value);
            if temp<seperator(2)
                r=0;
                g=1*((temp-seperator(1))/(seperator(2)-seperator(1)));
                b=1;
            elseif temp<seperator(3)
                r=0;
                g=1;
                b=1-1*((temp-seperator(2))/(seperator(3)-seperator(2)));
            elseif temp<seperator(4)
                r=1*((temp-seperator(3))/(seperator(4)-seperator(3)));
                g=1;
                b=0;
            elseif temp<seperator(5)
                r=1;
                g=1-1*((temp-seperator(4))/(seperator(5)-seperator(4)));
                b=0;
            elseif temp<seperator(6)
                r=1;
                g=0;
                b=1*((temp-seperator(5))/(seperator(6)-seperator(5)));
            else
                r=1-1*((temp-seperator(6))/(seperator(7)-seperator(6)));
                g=0;
                b=1;
            end
        end
    elseif strcmp(mode,'cycle_open_twice')
        %% cycle_open_twice:
        seperator = linspace(0,1,12);
        if maxvalue==0
            r = 0;
            g = 1;
            b = 0;
        else
            temp=temp_func(value);
            if temp<seperator(2)
                r=0;
                g=1*((temp-seperator(1))/(seperator(2)-seperator(1)));
                b=1;
            elseif temp<seperator(3)
                r=0;
                g=1;
                b=1-1*((temp-seperator(2))/(seperator(3)-seperator(2)));
            elseif temp<seperator(4)
                r=1*((temp-seperator(3))/(seperator(4)-seperator(3)));
                g=1;
                b=0;
            elseif temp<seperator(5)
                r=1;
                g=1-1*((temp-seperator(4))/(seperator(5)-seperator(4)));
                b=0;
            elseif temp<seperator(6)
                r=1;
                g=0;
                b=1*((temp-seperator(5))/(seperator(6)-seperator(5)));
            elseif temp<seperator(7)
                r=1-1*((temp-seperator(6))/(seperator(7)-seperator(6)));
                g=0;
                b=1-0.5*((temp-seperator(6))/(seperator(7)-seperator(6)));
            elseif temp<seperator(8)
                r=0;
                g=0.5*((temp-seperator(7))/(seperator(8)-seperator(7)));
                b=0.5;
            elseif temp<seperator(9)
                r=0;
                g=0.5;
                b=0.5-0.5*((temp-seperator(8))/(seperator(9)-seperator(8)));
            elseif temp<seperator(10)
                r=0.5*((temp-seperator(9))/(seperator(10)-seperator(9)));
                g=0.5;
                b=0;
            elseif temp<seperator(11)
                r=0.5;
                g=0.5-0.5*((temp-seperator(10))/(seperator(11)-seperator(10)));
                b=0;
            else
                r=0.5;
                g=0;
                b=0.5*((temp-seperator(11))/(seperator(12)-seperator(11)));
            end
        end
    elseif strcmp(mode,'cycle_open_mix')
        %% cycle_open_mix:
        seperator = linspace(0,1,9);
        if maxvalue==0
            r = 0;
            g = 1;
            b = 0;
        else
            temp=temp_func(value);
            if temp<seperator(2)
                r=0;
                g=0;
                b=0.5+0.5*((temp-seperator(1))/(seperator(2)-seperator(1)));
            elseif temp<seperator(3)
                r=0;
                g=1*((temp-seperator(2))/(seperator(3)-seperator(2)));
                b=1;
            elseif temp<seperator(4)
                r=0;
                g=1;
                b=1-1*((temp-seperator(3))/(seperator(4)-seperator(3)));
            elseif temp<seperator(5)
                r=0;
                g=1-0.5*((temp-seperator(4))/(seperator(5)-seperator(4)));
                b=0;
            elseif temp<seperator(6)
                r=1*((temp-seperator(5))/(seperator(6)-seperator(5)));
                g=0.5+0.5*((temp-seperator(5))/(seperator(6)-seperator(5)));
                b=0;
            elseif temp<seperator(7)
                r=1;
                g=1-1*((temp-seperator(6))/(seperator(7)-seperator(6)));
                b=0;
            elseif temp<seperator(8)
                r=1-0.5*((temp-seperator(7))/(seperator(8)-seperator(7)));
                g=0;
                b=0;
            else
                r=0.5+0.5*((temp-seperator(8))/(seperator(9)-seperator(8)));
                g=0;
                b=1*((temp-seperator(8))/(seperator(9)-seperator(8)));
            end
        end
    end
    %% check result:
    if r>1
        r=1;
    end
    if b>1
        b=1;
    end
    if g>1
        g=1;
    end
    if r<0
        r=0;
    end
    if b<0
        b=0;
    end
    if g<0
        g=0;
    end
    if isnan(r) || isnan(g) || isnan(b)
        r = 1;
        g = 1;
        b = 1;
    end
    %% export result:
    rgb=[r,g,b];
end