function y = sigm_hard(x,res)
    
    dlength = res.N_sigm;
    ind = 0:dlength;
    temp_y = sigm(ind);
    
    k = diff(temp_y);
    b = temp_y(1:end-1) - k.*ind(1:end-1);
    if nargin == 2
        k = sfi(k, res.WL, res.FL);
        b = sfi(b, res.WL, res.FL);
        k = setfimath(k,res.sigmunit);
        b = setfimath(b,res.sigmunit);
    end
        
%     k = sfi(diff(temp_y),);
%     b = sfi(,res.WL, res.FL);
%     k = setfimath(k,res.);
%     b = setfimath(b,res.);
    %k = [0.2311    0.1497    0.0718    0.0294    0.0113    0.0042    0.0016    0.0006];
    %y = zeros(size(x));
    intermed = abs(x);
    
%     if intermed >= dlength
%     	intermed = intermed*0.99;
%     end
    intermed(intermed>=dlength) = dlength*0.99; 
    %intermed(intermed>=dlength)= (intermed(intermed>=dlength) = dlength)*0.99;
    u = k(floor(intermed)+1).*intermed;
    v = b(floor(intermed)+1);
    intermed_out = u + v;

    
    mask = ones(size(x));
    mask(x>=0)=0;
    
    intermed_out(x<0) = intermed_out(x<0)*(-1);
    %x_1 = intermed_out(x<0)*(-1);
    
    y = mask + intermed_out;

    
%     for i=1:size(x,1)
%         for j=1:size(x,2)
%             temp = abs(x(i,j));
%             if temp >= dlength
%                 temp = dlength-0.000001;
%             end
%             temp_out= k(floor(temp)+1)*temp+b(floor(temp)+1);
%             
%             if(x(i,j)>=0)
%                 y(i,j)=temp_out;
%             else
%                 y(i,j)=1-temp_out;
%             end
%         end
%     end
%     
    
%     if(x>=0)
%         y=k(floor(x)+1)*x+b(floor(x)+1);
%     end
        
    %end
    
end