function nn = nnff(nn, x, y, res)
%NNFF performs a feedforward pass
% nn = nnff(nn, x, y) returns an neural network structure with updated
% layer activations, error and loss (nn.a, nn.e and nn.L)
    
    n = nn.n;
    m = size(x, 1);

    if nargin == 3
        x = [ones(m,1) x];
        nn.a{1} = x;

        %feedforward pass
        for i = 2 : n-1
            switch nn.activation_function 
                case 'sigm'
                    % Calculate the unit's outputs (including the bias term)
                    nn.a{i} = sigm(nn.a{i - 1} * nn.W{i - 1}');
                case 'sigm_hard'
                    nn.a{i} = sigm_hard(nn.a{i - 1} * nn.W{i - 1}');
                case 'tanh_opt'
                    nn.a{i} = tanh_opt(nn.a{i - 1} * nn.W{i - 1}');
                case 'relu'
                    nn.a{i} = relu(nn.a{i - 1} * nn.W{i - 1}');
            end

            %dropout
            if(nn.dropoutFraction > 0)
                if(nn.testing)
                    nn.a{i} = nn.a{i}.*(1 - nn.dropoutFraction);
                else
                    nn.dropOutMask{i} = (rand(size(nn.a{i}))>nn.dropoutFraction);
                    nn.a{i} = nn.a{i}.*nn.dropOutMask{i};
                end
            end

            %calculate running exponential activations for use with sparsity
            if(nn.nonSparsityPenalty>0)
                nn.p{i} = 0.99 * nn.p{i} + 0.01 * mean(nn.a{i}, 1);
            end

            %Add the bias term
            nn.a{i} = [ones(m,1) nn.a{i}];
        end
        switch nn.output 
            case 'sigm'
                nn.a{n} = sigm(nn.a{n - 1} * nn.W{n - 1}');
            case 'sigm_hard'
                nn.a{n} = sigm_hard(nn.a{n - 1} * nn.W{n - 1}');
            case 'linear'
                nn.a{n} = nn.a{n - 1} * nn.W{n - 1}';
            case 'relu'
                nn.a{n} = relu(nn.a{n - 1} * nn.W{n - 1}');
            case 'softmax'
                nn.a{n} = nn.a{n - 1} * nn.W{n - 1}';
                nn.a{n} = exp(bsxfun(@minus, nn.a{n}, max(nn.a{n},[],2)));
                nn.a{n} = bsxfun(@rdivide, nn.a{n}, sum(nn.a{n}, 2)); 
        end

        %error and loss
        nn.e = y - nn.a{n};

        switch nn.output
            case {'sigm', 'sigm_hard', 'linear', 'relu'}
                nn.L = 1/2 * sum(sum(nn.e .^ 2)) / m; 
            case 'softmax'
                nn.L = -sum(sum(y .* log(nn.a{n}))) / m;
                %disp(nn.L)
        end

        
    elseif nargin == 4
        macunit = fimath('OverflowAction','Saturate','RoundingMethod','nearest',...
            'ProductMode','SpecifyPrecision',...
            'ProductWordLength',48,'ProductFractionLength',28,...
            'SumMode','SpecifyPrecision','SumWordLength',48,'SumFractionLength',28);
        WL = res.WL;
        IL = res.IL;
        FL = res.FL;
        P_f = res.P_flip; %possibility of bit flip
        P_s0 = res.P_stuck0;
        %P_s1 = res.P_stuck1;
        
        res.sigmunit = fimath('OverflowAction','Saturate','RoundingMethod','nearest',...
            'ProductMode','SpecifyPrecision',...
            'ProductWordLength',2*WL,'ProductFractionLength',2*FL);
        
        
        x = [ones(m,1) x];
        nn.a{1} = sfi(x,WL,FL);
        nn.a{1} = setfimath(nn.a{1},macunit);

        for i = 1:n-1
            nn.W{i} = sfi(nn.W{i},WL,FL);
            nn.W{i} = setfimath(nn.W{i},macunit);
            
            if(P_f ~= 0)
            
                assert(P_f<=1&&P_f>0,'Bit flip probability error!!!')
                disp(['>>>Injection bit flip to weights at a probability of ' num2str(P_f) '...' ])
                biterror = binornd(1,P_f,size(nn.W{i},1)*size(nn.W{i},2)*WL,1);
                rindex = find(biterror==1);
                N_item = ceil(rindex/WL);
                N_pos = rindex - WL*(N_item-1);

                fixedbin = bin(nn.W{i}); 
                for bcc= 1:length(rindex)
                    %disp(bcc)
                    item = N_item(bcc);
                    pos = N_pos(bcc);                    
                    row = ceil(item/size(nn.W{i},2));
                    col = item - (row - 1) * size(nn.W{i},2);
                    
                    orgin_bit = fixedbin(row,(col-1)*(WL+3)+N_pos);
                    if pos == 1
                         if(orgin_bit == '0') 
                            nn.W{i}(row,col) = nn.W{i}(row,col) - 2^(IL-1);
                         else
                            nn.W{i}(row,col) = nn.W{i}(row,col) + 2^(IL-1); 
                         end
                    else
                         tmp = WL - pos;
                         if(orgin_bit == '0')
                             nn.W{i}(row,col) = nn.W{i}(row,col) + 2^(tmp-FL);
                         else
                             nn.W{i}(row,col) = nn.W{i}(row,col) - 2^(tmp-FL);
                         end                            
                    end
                    
                end
            
            end
        
        end
        

        
        
        %feedforward pass
        for i = 2 : n-1           
            %nn.a{i - 1} * nn.W{i - 1}' is MACC unit 48 bits [20,28]
            %sfi(nn.a{i - 1} * nn.W{i - 1}',WL,FL) rounding to [16,14]
            %convert to double then perform activation
            
            A0 = nn.a{i - 1};
            B0 = nn.W{i - 1}';
            if(P_s0 ~= 0)
            	mask_height = size(A0,1);
            	mask_width = size(A0,2);                        
            	mask = binornd(1,1 - P_s0, mask_height, mask_width);
            	A0 = A0 .* mask; % the width is extended because of multiplication                       
            end
            
            fiaccel multi -args {A0 B0};            
            mac_partial = double(sfi(multi_mex(A0,B0), WL, FL));
            
            switch nn.activation_function 
                case 'sigm'                                     
                    nn.a{i} = sigm(mac_partial);                   
                case 'sigm_hard'
                    nn.a{i} = sigm_hard(mac_partial,res);
                case 'tanh_opt'
                    nn.a{i} = tanh_opt(mac_partial);
                case 'relu'
                    nn.a{i} = relu(mac_partial);
            end
            
            nn.a{i} = sfi(nn.a{i},WL,FL);

            %dropout
            if(nn.dropoutFraction > 0)
                if(nn.testing)
                    nn.a{i} = nn.a{i}.*(1 - nn.dropoutFraction);
                else
                    nn.dropOutMask{i} = (rand(size(nn.a{i}))>nn.dropoutFraction);
                    nn.a{i} = nn.a{i}.*nn.dropOutMask{i};
                end
            end

            %calculate running exponential activations for use with sparsity
            if(nn.nonSparsityPenalty>0)
                nn.p{i} = 0.99 * nn.p{i} + 0.01 * mean(nn.a{i}, 1);
            end

            %Add the bias term
            nn.a{i} = [ones(m,1) nn.a{i}];
        end
        switch nn.output 
            case 'sigm'
                nn.a{n} = sfi(sigm(nn.a{n - 1} * nn.W{n - 1}'),WL,FL );
            case 'sigm_hard'
                nn.a{n} = sigm_hard(nn.a{n - 1} * nn.W{n - 1}');
            case 'linear'
                nn.a{n} = nn.a{n - 1} * nn.W{n - 1}';
            case 'relu'
                nn.a{n} = relu(nn.a{n - 1} * nn.W{n - 1}');
            case 'softmax'
                nn.a{n} = double(sfi(nn.a{n - 1} * nn.W{n - 1}',WL,FL));
                nn.a{n} = exp(bsxfun(@minus, nn.a{n}, max(nn.a{n},[],2)));
                nn.a{n} = bsxfun(@rdivide, nn.a{n}, sum(nn.a{n}, 2)); 
        end

        %error and loss
        nn.e = y - nn.a{n};
        

        switch nn.output
            case {'sigm', 'sigm_hard', 'linear', 'relu'}
                nn.L = 1/2 * sum(sum(nn.e .^ 2)) / m; 
                
            case 'softmax'
                nn.L = -sum(sum(y .* log(nn.a{n}))) / m;
        end        
        %disp(nn.L)
    end
end
