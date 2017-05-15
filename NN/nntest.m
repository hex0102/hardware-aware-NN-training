function [er, bad, loss] = nntest(nn, x, y, res)
    if nargin == 3
        [labels, out_pred] = nnpredict(nn, x);
    elseif nargin == 4
        [labels, out_pred] = nnpredict(nn, x, res);
    end
        [dummy, expected] = max(y,[],2);
        bad = find(labels ~= expected);    
        er = numel(bad) / size(x, 1);
        
    %get inference loss
    e = y - out_pred;
    switch nn.output
        case {'sigm', 'sigm_hard', 'linear', 'relu'}
            loss = 1/2 * sum(sum(e .^ 2)) / length(y); 
                
        case 'softmax'
            loss = -sum(sum(y .* log(out_pred))) / length(y);
    end        
        

end
