function [bb,dev,stats] = glmfit(x,y,distr,varargin)

if nargin < 2
    error(message('stats:glmfit:TooFewInputs'));
end

if nargin < 3 || isempty(distr)
    distr = 'normal';
else
    distr = lower(distr);
end

if nargin < 4
    newSyntax = false;
else
    arg = varargin{1};
    if ischar(arg) 
        try
            validatestring(arg, ...
                {'identity' 'log' 'logit' 'probit' 'comploglog' 'reciprocal' 'logloglink'});
            newSyntax = false;
        catch
            newSyntax = true;
        end
    else 
        newSyntax = false;
    end
end


if newSyntax
    paramNames = {     'link' 'estdisp' 'offset' 'weights' 'constant' 'rankwarn' 'options' 'b0'};
    paramDflts = {'canonical'     'off'      []        []        'on'       true        [] []};
    [link,estdisp,offset,pwts,const,rankwarn,options,b0] = ...
                           internal.stats.parseArgs(paramNames, paramDflts, varargin{:});

else 
    link = 'canonical';
    estdisp = 'off';
    offset = [];
    pwts = [];
    const = 'on';
    rankwarn = true;
    options = [];
    b0 = [];
    if nargin > 3 && ~isempty(varargin{1}), link = varargin{1}; end
    if nargin > 4 && ~isempty(varargin{2}), estdisp = varargin{2}; end
    if nargin > 5 && ~isempty(varargin{3}), offset = varargin{3}; end
    if nargin > 6 && ~isempty(varargin{4}), pwts = varargin{4}; end
    if nargin > 7 && ~isempty(varargin{5}), const = varargin{5}; end
end

estdisp = internal.stats.parseOnOff(estdisp,'''estdisp''');

if isempty(options)
    iterLim = 100;
    convcrit = 1e-6;
else
    options = statset(statset('glmfit'),options);
    iterLim = options.MaxIter;
    convcrit = options.TolX;
end


[y,N] = internal.stats.getGLMBinomialData(distr,y);


[anybad,wasnan,y,x,offset,pwts,N] = statremovenan(y,x,offset,pwts,N);
if anybad > 0
    switch anybad
    case 2
        error(message('stats:glmfit:InputSizeMismatchX'))
    case 3
        error(message('stats:glmfit:InputSizeMismatchOffset'))
    case 4
        error(message('stats:glmfit:InputSizeMismatchPWTS'))

    end
end

if isequal(const,'on')
    x = [ones(size(x,1),1) x];
end
dataClass = superiorfloat(x,y);
x = cast(x,dataClass);
y = cast(y,dataClass);


[link,estdisp,sqrtvarFun,devFun,muLims] = ...
    internal.stats.getGLMVariance(distr,estdisp,link,N,y,dataClass);

[n,ncolx] = size(x);
if isempty(pwts)
    [~,R,perm] = qr(x,0);
else
    [~,R,perm] = qr(x .* pwts(:,ones(1,ncolx)),0);
end
if isempty(R)
    rankx = 0;
else
    rankx = sum(abs(diag(R)) > abs(R(1))*max(n,ncolx)*eps(class(R)));
end
if rankx < ncolx
    if rankwarn
        warning(message('stats:glmfit:IllConditioned'));
    end
    perm = perm(1:rankx);
    x = x(:,perm);
else
    perm = 1:ncolx;
end


[n,p] = size(x);

if isempty(pwts)
    pwts = 1;
elseif any(pwts == 0)

    n = n - sum(pwts == 0);
end
if isempty(offset), offset = 0; end
if isempty(N), N = 1; end


[linkFun,dlinkFun,ilinkFun] = stattestlink(link,dataClass);

if isempty(b0)

    mu = startingVals(distr,y,N);
    eta = linkFun(mu);
else

    if ~isvector(b0) || ~isreal(b0) || length(b0)~=size(x,2)
        error(message('stats:glmfit:BadIntialCoef'))
    end
    eta = offset + x * b0(:);
    mu = ilinkFun(eta);
end


iter = 0;
warned = false;
seps = sqrt(eps);
b = zeros(p,1,dataClass);

while iter <= iterLim
    iter = iter+1;

    deta = dlinkFun(mu);
    z = eta + (y - mu) .* deta;

 
    sqrtirls = abs(deta) .* sqrtvarFun(mu);
    sqrtw = sqrt(pwts) ./ sqrtirls;


    wtol = max(sqrtw)*eps(dataClass)^(2/3);
    t = (sqrtw < wtol);
    if any(t)
        t = t & (sqrtw ~= 0);
        if any(t)
            sqrtw(t) = wtol;
            if ~warned
                warning(message('stats:glmfit:BadScaling'));
            end
            warned = true;
        end
    end

 
    b_old = b;
    [b,R] = wfit(z - offset, x, sqrtw);

  
    eta = offset + x * b;


    mu = ilinkFun(eta);


    if isscalar(muLims)
  
        if any(mu < muLims(1))
            mu = max(mu,muLims(1));
        end
    elseif ~isempty(muLims)
      
        if any(mu < muLims(1) | muLims(2) < mu)
            mu = max(min(mu,muLims(2)),muLims(1));
        end
    end

    if (~any(abs(b-b_old) > convcrit * max(seps, abs(b_old)))), break; end
end
if iter > iterLim
    warning(message('stats:glmfit:IterationLimit'));
end

bb = zeros(ncolx,1,dataClass); bb(perm) = b;

if iter>iterLim && isequal(distr,'binomial')
    diagnoseSeparation(eta,y,N);
end

if nargout > 1

    di = devFun(mu,y);
    dev = sum(pwts .* di);
end

if nargout > 2

    switch(distr)
    case 'normal'
        ssr = sum(pwts .* (y - mu).^2);
        anscresid = y - mu;
    case 'binomial'
        ssr = sum(pwts .* (y - mu).^2 ./ (mu .* (1 - mu) ./ N));
        t = 2/3;
        anscresid = beta(t,t) * ...
            (betainc(y,t,t)-betainc(mu,t,t)) ./ ((mu.*(1-mu)).^(1/6) ./ sqrt(N));
    case 'poisson'
        ssr = sum(pwts .* (y - mu).^2 ./ mu);
        anscresid = 1.5 * ((y.^(2/3) - mu.^(2/3)) ./ mu.^(1/6));
    case 'gamma'
        ssr = sum(pwts .* ((y - mu) ./ mu).^2);
        anscresid = 3 * (y.^(1/3) - mu.^(1/3)) ./ mu.^(1/3);
    case 'inverse gaussian'
        ssr = sum(pwts .* ((y - mu) ./ mu.^(3/2)).^2);
        anscresid = (log(y) - log(mu)) ./ mu;
    end


    if (isequal(distr, 'binomial'))
        resid = (y - mu) .* N;
    else
        resid  = y - mu;
    end

    dfe = max(n - p, 0);
    stats.beta = bb;
    stats.dfe = dfe;
    if dfe > 0
        stats.sfit = sqrt(ssr / dfe);
    else
        stats.sfit = NaN;
    end
    if ~estdisp
        stats.s = 1;
        stats.estdisp = false;
    else
        stats.s = stats.sfit;
        stats.estdisp = true;
    end


    if ~isnan(stats.s)
        RI = R\eye(p);
        C = RI * RI';
        if estdisp, C = C * stats.s^2; end
        se = sqrt(diag(C)); se = se(:);  
        stats.covb = zeros(ncolx,ncolx,dataClass);
        stats.covb(perm,perm) = C;
        C = C ./ (se * se');
        stats.se = zeros(ncolx,1,dataClass); stats.se(perm) = se;
        stats.coeffcorr = zeros(ncolx,ncolx,dataClass);
        stats.coeffcorr(perm,perm) = C;
        stats.t = NaN(ncolx,1,dataClass); stats.t(perm) = b ./ se;
        if estdisp
            stats.p = 2 * tcdf(-abs(stats.t), dfe);
        else
            stats.p = 2 * normcdf(-abs(stats.t));
        end
    else
        stats.se = NaN(size(bb),class(bb));
        stats.coeffcorr = NaN(length(bb),class(bb));
        stats.t = NaN(size(bb),class(bb));
        stats.p = NaN(size(bb),class(bb));
        stats.covb = NaN(length(bb),class(bb));
    end

    stats.resid  = statinsertnan(wasnan, resid);
    stats.residp = statinsertnan(wasnan, (y - mu) ./ (sqrtvarFun(mu) + (y==mu)));
    stats.residd = statinsertnan(wasnan, sign(y - mu) .* sqrt(max(0,di)));
    stats.resida = statinsertnan(wasnan, anscresid);
    
    stats.wts = statinsertnan(wasnan,1./sqrtirls.^2);
end


function [b,R] = wfit(y,x,sw)

[~,p] = size(x);
yw = y .* sw;
xw = x .* sw(:,ones(1,p));

[Q,R] = qr(xw,0);
b = R \ (Q'*yw);


function mu = startingVals(distr,y,N)

switch distr
case 'poisson'
    mu = y + 0.25;
case 'binomial'
    mu = (N .* y + 0.5) ./ (N + 1);
case {'gamma' 'inverse gaussian'}
    mu = max(y, eps(class(y))); 
otherwise
    mu = y;
end


function diagnoseSeparation(eta,y,N)

[x,idx] = sort(eta);
if ~isscalar(N)
    N = N(idx);
end
p = y(idx);
if all(p==p(1))   
    return
end
if x(1)==x(end)   
    return
end

noFront = 0<p(1) && p(1)<1;    
noEnd = 0<p(end) && p(end)<1;   
if noFront && noEnd
    
    return
end


dx = 100*max(eps(x(1)),eps(x(end)));
n = length(p);
if noFront
    A = 0;
else
    A = find(p~=p(1),1,'first')-1;
    cutoff = x(A+1)-dx;
    A = sum(x(1:A)<cutoff);
end

if noEnd
    B = n+1;
else
    B = find(p~=p(end),1,'last')+1;
    cutoff = x(B-1)+dx;
    B = (n+1) - sum(x(B:end)>cutoff);
end

if A+1<B-1

    if x(B-1)-x(A+1)>dx
        return
    end
end


if A+1==B
    xmid = x(A) + 0.5*(x(B)-x(A));
else
    xmid = x(A+1);
    if isscalar(N)
        pmid = mean(p(A+1:B-1));
    else
        pmid = sum(p(A+1:B-1).*N(A+1:B-1)) / sum(N(A+1:B-1));
    end
end


if A>=1
    explanation = sprintf('\n   XB<%g: P=%g',xmid,p(1));
else
    explanation = '';
end


if A+1<B
    explanation = sprintf('%s\n   XB=%g: P=%g',explanation,xmid,pmid);
end
    

if B<=n
    explanation = sprintf('%s\n   XB>%g: P=%g',explanation,xmid,p(end));
end

warning(message('stats:glmfit:PerfectSeparation', explanation));


