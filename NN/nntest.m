function [er, bad] = nntest(nn, x, y, res)
    if nargin == 3
        labels = nnpredict(nn, x);
    elseif nargin == 4
        labels = nnpredict(nn, x, res);
    end
        [dummy, expected] = max(y,[],2);
        bad = find(labels ~= expected);    
        er = numel(bad) / size(x, 1);
end