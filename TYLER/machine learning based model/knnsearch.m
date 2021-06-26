function [idx, dist] = knnsearch(X,Y,varargin)

pnames = { 'k' 'nsmethod' 'bucketsize', 'includeties'};
dflts =  { 1   []         []             false};
[numNN, nsmethod, bSize, includeTies, ~,args] =...
     internal.stats.parseArgs(pnames, dflts, varargin{:});

O=createns(X,args{:},'nsmethod', nsmethod,'bucketSize',bSize);
if nargout < 2
    idx = knnsearch(O,Y,'k',numNN, 'includeties', includeTies);
else
    [idx, dist] = knnsearch(O,Y,'k',numNN, 'includeties',includeTies);
end
end
