function y = sigm_hard(x)
    dlength = 8;
    ind = 0:dlength;
    temp_y = sigm(ind);
    k = diff(temp_y);
    b = temp_y(1:end-1) - k.*ind(1:end-1);
    %k = [0.2311    0.1497    0.0718    0.0294    0.0113    0.0042    0.0016    0.0006];
    y = zeros(size(x));
    size(x,1);
    global cc;
    for i=1:size(x,1)
        for j=1:size(x,2)
            temp = abs(x(i,j));
            if temp >= dlength
                temp = dlength-0.000001;
                cc=cc+1;
            end
            temp_out=k(floor(temp)+1)*temp+b(floor(temp)+1);
            
            if(x(i,j)>=0)
                y(i,j)=temp_out;
            else
                y(i,j)=1-temp_out;
            end
        end
    end
%     if(x>=0)
%         y=k(floor(x)+1)*x+b(floor(x)+1);
%     end
        
    %end
    
end