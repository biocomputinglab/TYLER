function this = fitcdiscr(X,Y,varargin)

[IsOptimizing, RemainingArgs] = classreg.learning.paramoptim.parseOptimizationArgs(varargin);
if IsOptimizing
    this = classreg.learning.paramoptim.fitoptimizing('fitcdiscr',X,Y,varargin{:});
else
    this = ClassificationDiscriminant.fit(X,Y,RemainingArgs{:});
end
end
