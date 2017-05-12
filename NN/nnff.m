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
        end
        
    elseif nargin == 4
 
        WL = res.WL;
        %IL = res.IL;
        FL = res.FL;
        
        x = [ones(m,1) x];
        nn.a{1} = sfi(x,WL,FL);

        %feedforward pass
        for i = 2 : n-1
            switch nn.activation_function 
                case 'sigm'
                    % Calculate the unit's outputs (including the bias term)
                    nn.a{i} = sfi(sigm(nn.a{i - 1} * nn.W{i - 1}'),WL,FL);
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
                nn.a{n} = sfi(sigm(nn.a{n - 1} * nn.W{n - 1}'),WL,FL );
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
        end        
        
    end
end