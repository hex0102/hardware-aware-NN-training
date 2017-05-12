function labels = nnpredict(nn, x, res)
    if nargin == 2
        nn.testing = 1;
        nn = nnff(nn, x, zeros(size(x,1), nn.size(end)));
        nn.testing = 0;
    elseif nargin == 3
        nn.testing = 1;
        nn = nnff(nn, x, zeros(size(x,1), nn.size(end)), res);
        nn.testing = 0;
    end
        
    [dummy, i] = max(nn.a{end},[],2);
    labels = i;
end
