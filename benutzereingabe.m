function [ eingabe ] = benutzereingabe( text, krit )
    temp = 1;
    while temp
        try
%             fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
            eingabe = input([text,' '],'s');
            if krit(eingabe)
                temp = 0;
            else
                temp = 1;
            end
        catch
            temp = 1;
        end
    end
end