classdef TreeBagger < classreg.learning.internal.DisallowVectorOps


    properties(SetAccess=protected,GetAccess=public,Dependent)
        
        X;
    end
        
    properties(SetAccess=protected,GetAccess=public)
       
        Y = [];
        
        
        W = [];
        
       
        SampleWithReplacement = true;
        
        
        ComputeOOBPrediction = false;
        
       
        Prune = false;
        
        MergeLeaves = false;
        
        
        OOBIndices = [];
    end
    
    properties(SetAccess=public,GetAccess=public,Dependent=true,Hidden=true)
        DefaultScore;
    end
    
    properties(SetAccess=protected,GetAccess=public,Hidden=true)
        InBagIndices = [];
    end
    
    properties(SetAccess=protected,GetAccess=protected)
        Compact = [];
        PrivOOBPermutedVarDeltaError = [];
        PrivOOBPermutedVarDeltaMeanMargin = [];
        PrivOOBPermutedVarCountRaiseMargin = [];
        PrivProx = [];
        DataSummary = [];
        ClassSummary = [];
        ModelParams = [];
        PrivateX = [];
        Version = 1; 
    end
    
    properties(SetAccess=protected,GetAccess=public,Dependent=true)
        
        InBagFraction;
        
        
        TreeArguments;
        
        
        ComputeOOBPredictorImportance;
        
       
        NumPredictorsToSample;
       
        MinLeafSize;
        
       
        Trees;
       
        NumTrees;
        
        
        ClassNames;
        
       
        Prior = [];
        
       
        Cost = [];
        
       
        PredictorNames;
       
        Method;
        
        
        OOBInstanceWeight;
       
        OOBPermutedPredictorDeltaError;
        
        OOBPermutedPredictorDeltaMeanMargin;
        
        OOBPermutedPredictorCountRaiseMargin;
        
       
        DeltaCriterionDecisionSplit;
        
       
        NumPredictorSplit;

       
        SurrogateAssociation ;

      
        Proximity;
        
        OutlierMeasure;
    end

        
    properties(SetAccess=public,GetAccess=public,Dependent=true)
        
        DefaultYfit;
    end
    
    properties(SetAccess=protected,GetAccess=public,Hidden=true)        
        FBoot = 1;
        TreeArgs = {};
        ComputeOOBVarImp = false;
        NVarToSample = [];
        MinLeaf = [];
    end
    
    properties(SetAccess=protected,GetAccess=public,Dependent=true,Hidden=true)
        NTrees;
        VarNames;
        OOBPermutedVarDeltaError;
        OOBPermutedVarDeltaMeanMargin;
        OOBPermutedVarCountRaiseMargin;
        DeltaCritDecisionSplit;
        NVarSplit
        VarAssoc;
    end

  
    properties(Dependent=true,GetAccess=public,SetAccess=public,Hidden=true)
        VariableRange = {};
        TableInput = false;
    end

    methods
        function vr = get.VariableRange(this)
            try
                vr = this.DataSummary.VariableRange;
            catch
                vr = {};
            end
        end
        function this = set.VariableRange(this,vr)
            this.DataSummary.VariableRange = vr;
        end
        function ti = get.TableInput(this)
            try
                ti = this.DataSummary.TableInput;
            catch
                ti = false; 
            end
        end
        function this = set.TableInput(this,t)
            this.DataSummary.TableInput = t;
        end
    end


    methods
        function bagger = TreeBagger(NumTrees,X,Y,varargin)
           
            growTreeArgs = {{'nprint','numprint'}             'options'};
            growTreeDefs = {                    0 statset('TreeBagger')};
            [nprint,parallelOptions,~,makeArgs] ...
                = internal.stats.parseArgs(growTreeArgs,growTreeDefs,varargin{:});

            bagger = init(bagger,X,Y,makeArgs{:});
            
          
            bagger = growTrees(bagger,NumTrees,'Options', parallelOptions, 'nprint', nprint);
   
            bagger.Version = 3;
        end
        
        function bagger = growTrees(bagger,NumTrees,varargin)
            
            baggerArgs = {{'nprint','numprint'}         'options'};
            baggerDefs = {       0                statset('TreeBagger')};
            [nprint,parallelOptions] ...
                = internal.stats.parseArgs(baggerArgs,baggerDefs,varargin{:});
  
            if isempty(nprint) || ~isnumeric(nprint) || numel(nprint)~=1 || nprint<0
                warning(message('stats:TreeBagger:growTrees:BadPrintoutFreq'));
            end
     
            if ~isnumeric(NumTrees) || NumTrees<0
                error(message('stats:TreeBagger:growTrees:BadTreeNum'));
            end
            if NumTrees==0
                return;
            end

            [useParallel, RNGscheme, poolsz] = ...
                internal.stats.parallel.processParallelAndStreamOptions(parallelOptions,true);
            usePool = useParallel && poolsz>0;
            
    
            [N,Nvars] = size(bagger.PrivateX);
            

            NTreesBefore = bagger.NTrees;
       
            doclassregtree = false;
            if NTreesBefore>0 && isa(bagger.Trees{1},'classregtree')
                doclassregtree = true;
            end
            
       
            if bagger.ComputeOOBPrediction
            
                if isempty(bagger.OOBIndices)
                    bagger.OOBIndices = false(N,NumTrees);
                else
                    bagger.OOBIndices(1:N,end+1:end+NumTrees) = false;
                end
                
      
                if bagger.ComputeOOBVarImp
                    bagger.PrivOOBPermutedVarDeltaError(end+1:end+NumTrees,1:Nvars) ...
                        = zeros(NumTrees,Nvars);
                    if bagger.Method(1)=='c'
                        bagger.PrivOOBPermutedVarDeltaMeanMargin(end+1:end+NumTrees,1:Nvars) ...
                            = zeros(NumTrees,Nvars);
                        bagger.PrivOOBPermutedVarCountRaiseMargin(end+1:end+NumTrees,1:Nvars) ...
                            = zeros(NumTrees,Nvars);
                    end
                end
            end
            
            if bagger.Method(1)=='r'
                fsample = bagger.InBagFraction;
                Nsample = ceil(N*fsample);
                if isempty(bagger.InBagIndices)
                    bagger.InBagIndices = zeros(Nsample,NumTrees);
                else
                    bagger.InBagIndices(1:Nsample,end+1:end+NumTrees) = zeros(Nsample,NumTrees);
                end
            end
                        

            fboot = bagger.FBoot;
            sampleWithReplacement = bagger.SampleWithReplacement;
            x = bagger.PrivateX;
            y = bagger.Y;
            w = bagger.W;
            method = bagger.Method;
            ds = bagger.DataSummary;
            cs = bagger.ClassSummary;
            mp = bagger.ModelParams;
            computeOOBPrediction = bagger.ComputeOOBPrediction;
            computeOOBVarImp = bagger.ComputeOOBVarImp;
            if computeOOBVarImp
                xorig = bagger.X;
            else
                xorig = [];
            end
            args = {doclassregtree fboot sampleWithReplacement x y w method ...
                ds cs mp computeOOBPrediction computeOOBVarImp nprint usePool xorig};

   
            if nprint>0
                if usePool
                    
                    parfor i=1:internal.stats.parallel.getParallelPoolSize
                        internal.stats.parallel.statParallelStore('mylabindex', i);
                        internal.stats.parallel.statParallelStore('ntreesGrown',0);
                    end
                else
                   
                    internal.stats.parallel.statParallelStore('mylabindex', 1);
                    internal.stats.parallel.statParallelStore('ntreesGrown',0);
                end
            end
            
           
            [trees, ...
                slicedOOBIndices, ...
                slicedInBagIndices, ...
                slicedPrivOOBPermutedVarDeltaError, ...
                slicedPrivOOBPermutedVarDeltaMeanMargin, ...
                slicedPrivOOBPermutedVarCountRaiseMargin] = ...
                localGrowTrees(NumTrees, useParallel, RNGscheme, args);
                            
         
            if computeOOBPrediction
                bagger.OOBIndices(:,NTreesBefore+1:NTreesBefore+NumTrees) = slicedOOBIndices;
                
                if computeOOBVarImp
                    bagger.PrivOOBPermutedVarDeltaError(NTreesBefore+1:NTreesBefore+NumTrees,:) = ...
                        slicedPrivOOBPermutedVarDeltaError;
                    if bagger.Method(1)=='c'
                        bagger.PrivOOBPermutedVarDeltaMeanMargin(NTreesBefore+1:NTreesBefore+NumTrees,:) = ...
                            slicedPrivOOBPermutedVarDeltaMeanMargin;
                        bagger.PrivOOBPermutedVarCountRaiseMargin(NTreesBefore+1:NTreesBefore+NumTrees,:) = ...
                            slicedPrivOOBPermutedVarCountRaiseMargin;
                    end
                end
            end
            
            if bagger.Method(1)=='r'
                bagger.InBagIndices(:,NTreesBefore+1:NTreesBefore+NumTrees) = slicedInBagIndices;
            end
            
          
            bagger.Compact = addTrees(bagger.Compact,trees);                        
        end 

        function cmp = compact(bagger)
         

            cmp = bagger.Compact;
        end
        
        function bagger = fillprox(bagger,varargin)
           
            bagger = fillProximities(bagger,varargin{:});
        end
        
        function bagger = append(bagger,other)
           
            if ~isequaln(bagger.PrivateX,other.PrivateX)
                error(message('stats:TreeBagger:append:IncompatibleX'));
            end
            
          
            if ~isequaln(bagger.Y,other.Y)
                error(message('stats:TreeBagger:append:IncompatibleY'));
            end
            
         
            if ~strcmpi(bagger.Method,other.Method)
                error(message('stats:TreeBagger:append:IncompatibleMethod'));
            end
            
      
            if bagger.ComputeOOBPrediction~=other.ComputeOOBPrediction ...
                    || bagger.ComputeOOBVarImp~=other.ComputeOOBVarImp
                error(message('stats:TreeBagger:append:IncompatibleOOB'));
            end
     
            bagger.Compact = combine(bagger.Compact,other.Compact);
            
   
            nTrees = other.NTrees;
            if nTrees>0 && other.ComputeOOBPrediction
                if size(other.OOBIndices,1)~=size(bagger.OOBIndices,1) || ...
                        size(other.OOBIndices,2)~=nTrees
                    error(message('stats:TreeBagger:append:BadOOBIndices'));
                end
                bagger.OOBIndices(:,end+1:end+nTrees) = other.OOBIndices;
            end
            
        
            nTrees = other.NTrees;
            if nTrees>0 && bagger.Method(1)=='r'
                if size(other.InBagIndices,1)~=size(bagger.InBagIndices,1) || ...
                        size(other.InBagIndices,2)~=nTrees
                    error(message('stats:TreeBagger:append:BadInBagIndices'));
                end
                bagger.InBagIndices(:,end+1:end+nTrees) = other.InBagIndices;
            end
            
      
            if nTrees>0 && other.ComputeOOBVarImp
            
                if size(bagger.PrivOOBPermutedVarDeltaError,2) ...
                        ~=size(other.PrivOOBPermutedVarDeltaError,2) || ...
                        size(other.PrivOOBPermutedVarDeltaError,1)~=nTrees
                    error(message('stats:TreeBagger:append:BadOOBError'));
                end
                bagger.PrivOOBPermutedVarDeltaError(end+1:end+nTrees,:) = ...
                    other.PrivOOBPermutedVarDeltaError;

      
                if size(bagger.PrivOOBPermutedVarDeltaMeanMargin,2) ...
                        ~=size(other.PrivOOBPermutedVarDeltaMeanMargin,2) || ...
                        size(other.PrivOOBPermutedVarDeltaMeanMargin,1)~=nTrees
                    error(message('stats:TreeBagger:append:BadOOBMargin'));
                end
                bagger.PrivOOBPermutedVarDeltaMeanMargin(end+1:end+nTrees,:) = ...
                    other.PrivOOBPermutedVarDeltaMeanMargin;

          
                if size(bagger.PrivOOBPermutedVarCountRaiseMargin,2) ...
                        ~=size(other.PrivOOBPermutedVarCountRaiseMargin,2) || ...
                        size(other.PrivOOBPermutedVarCountRaiseMargin,1)~=nTrees
                    error(message('stats:TreeBagger:append:BadOOBCountMargin'));
                end
                bagger.PrivOOBPermutedVarCountRaiseMargin(end+1:end+nTrees,:) = ...
                    other.PrivOOBPermutedVarCountRaiseMargin;
            end
          
            if isempty(other.PrivProx)
                bagger.PrivProx = [];
            else
                if ~isempty(bagger.PrivProx)
                    if numel(bagger.PrivProx)~=numel(other.PrivProx)
                        error(message('stats:TreeBagger:append:BadProx'));
                    end
                    bagger.PrivProx = ...
                        (bagger.NTrees*bagger.PrivProx + nTrees*other.PrivProx) / ...
                        (bagger.NTrees + nTrees);
                end
            end
        end
    end
    
    methods(Static)
        function this = loadobj(obj)
            if ~isstruct(obj) && obj.Version>=2
           
                this = obj;
            elseif ~isempty(obj.Compact.Trees) ...
                    && isa(obj.Compact.Trees{1},'classreg.learning.Predictor')
             
                this = obj;
                this.PrivateX = this.X;
            else 
                sampleWithReplacement = 'off';
                if obj.SampleWithReplacement
                    sampleWithReplacement = 'on';
                end
                computeOOBPrediction = 'off';
                if obj.ComputeOOBPrediction
                    computeOOBPrediction = 'on';
                end
                computeOOBVarImp = 'off';
                if obj.ComputeOOBVarImp
                    computeOOBVarImp = 'on';
                end
                prune = 'off';
                if obj.Prune
                    prune = 'on';
                end
                mergeLeaves = 'off';
                if obj.MergeLeaves
                    mergeLeaves = 'on';
                end
                
                weightsSet = false;
                w = ones(size(obj.X,1),1);
                if isfield(obj,'W')
                    w = obj.W;
                    weightsSet = true;
                end
                
                this = TreeBagger(0,obj.X,obj.Y,...
                    'fboot',obj.FBoot,'samplewithreplacement',sampleWithReplacement,...
                    'oobpred',computeOOBPrediction,'oobvarimp',computeOOBVarImp,...
                    'prune',prune,'mergeleaves',mergeLeaves,...
                    'nvartosample',obj.NVarToSample,'minleaf',obj.MinLeaf,...
                    'weights',w,obj.TreeArgs{:});
                this.Compact = obj.Compact;
                this.OOBIndices = obj.OOBIndices;
                this.PrivOOBPermutedVarDeltaError = obj.PrivOOBPermutedVarDeltaError;
                this.PrivOOBPermutedVarDeltaMeanMargin = obj.PrivOOBPermutedVarDeltaMeanMargin;
                this.PrivOOBPermutedVarCountRaiseMargin = obj.PrivOOBPermutedVarCountRaiseMargin;
                
                if ~isempty(obj.PriorStruct)
                    newgrp = cellstr(this.ClassSummary.NonzeroProbClasses);
                    oldgrp = obj.PriorStruct.group;
                    [~,loc] = ismember(newgrp,oldgrp);
                    this.ClassSummary.Prior = obj.PriorStruct.prob(loc);
                end
                
                if ~isempty(obj.CostStruct)
                    newgrp = cellstr(this.ClassSummary.NonzeroProbClasses);
                    oldgrp = obj.CostStruct.group;
                    [~,loc] = ismember(newgrp,oldgrp);
                    this.ClassSummary.Cost = obj.CostStruct.cost(loc,loc);
                end

       
                if ~weightsSet && (~isempty(obj.PriorStruct) || ~isempty(obj.CostStruct))
                    [~,this.W] = classreg.learning.internal.adjustPrior(...
                        this.ClassSummary,classreg.learning.internal.ClassLabel(this.Y),w);
                end
            end
        end
    end

    
    methods(Hidden=true,Static=true)
        function a = empty(varargin),      throwUndefinedError(); end 
    end
    
    
    methods(Hidden=true)
        function disp(obj)
            internal.stats.displayClassName(obj);

            fprintf(1,'%s\n',getString(message('stats:TreeBagger:DispHeader',obj.NTrees)));
            sx = ['[' num2str(size(obj.PrivateX,1)) 'x' num2str(size(obj.PrivateX,2)) ']'];
            sy = ['[' num2str(size(obj.Y,1)) 'x' num2str(size(obj.Y,2)) ']'];
            fprintf(1,'%30s: %20s\n','Training X',sx);
            fprintf(1,'%30s: %20s\n','Training Y',sy);
            fprintf(1,'%30s: %20s\n','Method',obj.Method);
            fprintf(1,'%30s: %20i\n','NumPredictors',length(obj.VarNames));
            fprintf(1,'%30s: %20s\n','NumPredictorsToSample',num2str(obj.NVarToSample));
            fprintf(1,'%30s: %20i\n','MinLeafSize',obj.MinLeaf);
            fprintf(1,'%30s: %20g\n','InBagFraction',obj.FBoot);
            fprintf(1,'%30s: %20i\n','SampleWithReplacement',obj.SampleWithReplacement);
            fprintf(1,'%30s: %20i\n','ComputeOOBPrediction',obj.ComputeOOBPrediction);
            fprintf(1,'%30s: %20i\n','ComputeOOBPredictorImportance',obj.ComputeOOBVarImp);
            if ~isempty(obj.PrivProx)
                sprox = ['[' num2str(size(obj.PrivateX,1)) 'x' num2str(size(obj.PrivateX,1)) ']'];
            else
                sprox = '[]';
            end
            fprintf(1,'%30s: %20s\n','Proximity',sprox);
            if obj.Method(1)=='c'
                sform = ' %s';
                if ~isempty(obj.Prior) || ~isempty(obj.Cost)
                    sform = ' %15s';
                end
                fprintf(1,'%30s:','ClassNames');
                for i=1:length(obj.ClassNames)
                    fprintf(1,sform,['''' obj.ClassNames{i} '''']);
                end
                fprintf(1,'\n');
            end
            
            internal.stats.displayMethodsProperties(obj);
        end
    end
    
    
    methods
        function x = get.X(bagger)
            x = bagger.PrivateX;
        
            if bagger.TableInput
                t = array2table(x,'VariableNames',bagger.PredictorNames);
                for j=1:size(x,2)
                    vrj = bagger.VariableRange{j};
                    newx = decodeX(x(:,j),vrj);
                    t.(bagger.PredictorNames{j}) = newx;
                end
                x = t;
            end
        end
        function bagger = set.X(bagger,x)
            bagger.PrivateX = x;
        end
        
        function fboot = get.InBagFraction(bagger)
            fboot = bagger.FBoot;
        end
        
        function treeargs = get.TreeArguments(bagger)
            treeargs = bagger.TreeArgs;
        end
        
        function computeOOBVarImp = get.ComputeOOBPredictorImportance(bagger)
            computeOOBVarImp = bagger.ComputeOOBVarImp;
        end
        
        function nvartosample = get.NumPredictorsToSample(bagger)
            nvartosample = bagger.NVarToSample;
        end
        
        function minleaf = get.MinLeafSize(bagger)
            minleaf = bagger.MinLeaf;
        end
        
        function trees = get.Trees(bagger)
            trees = bagger.Compact.Trees;
        end
        
        function n = get.NTrees(bagger)
            n = length(bagger.Trees);
        end
        
        function n = get.NumTrees(bagger)
            n = bagger.NTrees;
        end
        
        function cnames = get.ClassNames(bagger)
            cnames = bagger.Compact.ClassNames;
        end

        function prior = get.Prior(this)
            K = length(this.ClassSummary.ClassNames);
            prior = zeros(1,K);
            [~,pos] = ismember(this.ClassSummary.NonzeroProbClasses,...
                this.ClassSummary.ClassNames);
            prior(pos) = this.ClassSummary.Prior;            
        end
        
        function cost = get.Cost(this)
            K = length(this.ClassSummary.ClassNames);
            if isempty(this.ClassSummary.Cost)
                cost = ones(K) - eye(K);
            else
                cost = zeros(K);
                [~,pos] = ismember(this.ClassSummary.NonzeroProbClasses,...
                    this.ClassSummary.ClassNames);
                cost(pos,pos) = this.ClassSummary.Cost;
                unmatched = 1:K;
                unmatched(pos) = [];
                cost(:,unmatched) = NaN;
                cost(1:K+1:end) = 0;
            end
        end
        
        function vnames = get.VarNames(bagger)
            vnames = bagger.Compact.VarNames;
        end
        
        function vnames = get.PredictorNames(bagger)
            vnames = bagger.VarNames;
        end
        
        function meth = get.Method(bagger)
            meth = bagger.Compact.Method;
        end
        
        function weights = get.OOBInstanceWeight(bagger)
   
            if ~bagger.ComputeOOBPrediction
                error(message('stats:TreeBagger:OOBInstanceWeight:InvalidProperty'));
            end
            
      
            weights = sum(bagger.OOBIndices,2);
        end
               
        function deltacrit = get.DeltaCritDecisionSplit(bagger)
            deltacrit = bagger.Compact.DeltaCritDecisionSplit;
        end
        
        function deltacrit = get.DeltaCriterionDecisionSplit(bagger)
            deltacrit = bagger.DeltaCritDecisionSplit;
        end
         
        function nsplit = get.NVarSplit(bagger)
            nsplit = bagger.Compact.NVarSplit;
        end
        
        function nsplit = get.NumPredictorSplit(bagger)
            nsplit = bagger.NVarSplit;
        end
        
        function assoc = get.VarAssoc(bagger)
            assoc = bagger.Compact.VarAssoc;
        end
        
        function assoc = get.SurrogateAssociation(bagger)
            assoc = bagger.VarAssoc;
        end

        function delta = get.OOBPermutedVarDeltaError(bagger)
       
            if ~bagger.ComputeOOBVarImp
                error(message('stats:TreeBagger:OOBPermutedVarDeltaError:InvalidProperty'));
            end
         
            delta = normalizeMean1(bagger.PrivOOBPermutedVarDeltaError);
        end
        
        function delta = get.OOBPermutedPredictorDeltaError(bagger)
            delta = bagger.OOBPermutedVarDeltaError;
        end
        
        function delta = get.OOBPermutedVarDeltaMeanMargin(bagger)
     
            if ~bagger.ComputeOOBVarImp
                error(message('stats:TreeBagger:OOBPermutedVarDeltaMeanMargin:InvalidProperty'));
            end
            
       
            delta = normalizeMean1(bagger.PrivOOBPermutedVarDeltaMeanMargin);
        end
        
        function delta = get.OOBPermutedPredictorDeltaMeanMargin(bagger)
            delta = bagger.OOBPermutedVarDeltaMeanMargin;
        end
        
        function delta = get.OOBPermutedVarCountRaiseMargin(bagger)
           
            if ~bagger.ComputeOOBVarImp
                error(message('stats:TreeBagger:OOBPermutedVarCountRaiseMargin:InvalidProperty'));
            end
            
        
            delta = normalizeMean1(bagger.PrivOOBPermutedVarCountRaiseMargin);
        end
        
        function delta = get.OOBPermutedPredictorCountRaiseMargin(bagger)
            delta = bagger.OOBPermutedVarCountRaiseMargin;
        end
        
        function prox = get.Proximity(bagger)
      
            if isempty(bagger.PrivProx)
                error(message('stats:TreeBagger:Proximity:InvalidProperty'));
            end
            
       
            prox = squareform(bagger.PrivProx);
            N = size(bagger.PrivateX,1);
            prox(1:N+1:end) = 1;
        end
        
        function outlier = get.OutlierMeasure(bagger)
 
            if isempty(bagger.PrivProx)
                error(message('stats:TreeBagger:OutlierMeasure:InvalidProperty'));
            end
        
            if bagger.Method(1)=='c'
                outlier = outlierMeasure(bagger.Compact,bagger.Proximity,...
                    'data','proximity','labels',bagger.Y);
            else
                outlier = outlierMeasure(bagger.Compact,bagger.Proximity,...
                    'data','proximity');
            end
        end
        
        function yfit = get.DefaultYfit(bagger)
            yfit = bagger.Compact.DefaultYfit;
        end
        
        function bagger = set.DefaultYfit(bagger,yfit)
            bagger.Compact = setDefaultYfit(bagger.Compact,yfit);
        end
        
        function sc = get.DefaultScore(bagger)
            sc = bagger.Compact.DefaultScore;
        end
        
        function bagger = set.DefaultScore(bagger,score)
            bagger.Compact.DefaultScore = score;
        end
    end
   
    methods(Access=protected)
        function bagger = init(bagger,x,y,varargin)
     
            baggerArgs = {{'fboot','inbagfraction'} 'samplewithreplacement' ...
                          {'oobpred','oobprediction'} {'oobvarimp','oobpredictorimportance'} ...
                          'method' 'names' 'splitmin'};
            baggerDefs = {      1                    'on' ...
                              'off'       'off' ...
                  'classification'     {}          []};
            [bagger.FBoot,...
                samplemethod,oobpred,oobvarimp, ...
                method,varnames,splitmin,~,bagger.TreeArgs] ...
                = internal.stats.parseArgs(baggerArgs,baggerDefs,varargin{:});
            
     
            checkOnOff = ...
                @(x) ischar(x) && (strcmpi(x,'off') || strcmpi(x,'on'));

            if ~isnumeric(bagger.FBoot) ...
                    || bagger.FBoot<=0 || bagger.FBoot>1
                error(message('stats:TreeBagger:init:BadFBoot'));
            end
                        
            if ~checkOnOff(samplemethod)
                error(message('stats:TreeBagger:init:BadSampleWithReplacement'));
            end
            bagger.SampleWithReplacement = strcmpi(samplemethod,'on');
            
            if ~checkOnOff(oobpred)
                error(message('stats:TreeBagger:init:BadOOBPred'));
            end
            bagger.ComputeOOBPrediction = strcmpi(oobpred,'on');

            if ~checkOnOff(oobvarimp)
                error(message('stats:TreeBagger:init:BadOOBVarImp'));
            end
            bagger.ComputeOOBVarImp = strcmpi(oobvarimp,'on');

            allowedVals = {'classification' 'regression'};
            tf = strncmpi(method,allowedVals,length(method));
            if isempty(method) || ~ischar(method) || ~any(tf)
                error(message('stats:TreeBagger:init:BadMethod'));
            end
            method = allowedVals{tf};
            
            [bagger.ModelParams,extraArgs] = classreg.learning.modelparams.TreeParams.make(...
                method,bagger.TreeArgs{:});

            if islogical(y)
                y = double(y);
            end
            
            if strcmp(method(1),'c')
          
                [bagger.PrivateX,y,bagger.W,bagger.DataSummary,classSummary] = ...
                    ClassificationTree.prepareData(x,y,...
                    'predictornames',varnames,'ResponseString',true,extraArgs{:});
                bagger.Y = cellstr(y);
                [classSummary,bagger.W] = ...
                    classreg.learning.internal.adjustPrior(classSummary,y,bagger.W);
                bagger.ClassSummary = classSummary;
            else
                [bagger.PrivateX,bagger.Y,bagger.W,bagger.DataSummary] = ...
                    classreg.learning.regr.FullRegressionModel.prepareData(...
                    x,y,'predictornames',varnames,extraArgs{:});
            end
            
            if isempty(bagger.ModelParams.Prune)
                bagger.ModelParams.Prune = 'off';
            end
            bagger.Prune = strcmpi(bagger.ModelParams.Prune,'on');
            if bagger.Prune
                warning(message('stats:TreeBagger:init:BadPruneValue'));
            end
            
            if isempty(bagger.ModelParams.MergeLeaves)
                bagger.ModelParams.MergeLeaves = 'off';
            end
            bagger.MergeLeaves = strcmpi(bagger.ModelParams.MergeLeaves,'on');
            if bagger.MergeLeaves
                warning(message('stats:TreeBagger:init:BadMergeLeavesValue'));
            end
                                    
         
            bagger.ComputeOOBPrediction = ...
                bagger.ComputeOOBPrediction || bagger.ComputeOOBVarImp;

     
            N = size(bagger.PrivateX,1);
            if bagger.ComputeOOBPrediction && ~bagger.SampleWithReplacement ...
                    && N*(1-bagger.FBoot)<1
                error(message('stats:TreeBagger:init:NotEnoughOOBobservations'));
            end
        
            if strcmp(method(1),'c')
                classnames = cellstr(bagger.ClassSummary.ClassNames);
            else
                classnames = {};
            end
            varnames = bagger.DataSummary.PredictorNames;
            if isnumeric(varnames)
                varnames = classreg.learning.internal.defaultPredictorNames(varnames);
            end
            bagger.Compact = CompactTreeBagger({},classnames,varnames);

      
            nvartosample = bagger.ModelParams.NVarToSample;
            if isempty(nvartosample)
                if     method(1)=='c'
                    nvartosample = ceil(sqrt(length(varnames)));
                elseif method(1)=='r'
                    nvartosample = ceil(length(varnames)/3);
                end
            end
            bagger.NVarToSample = nvartosample;
            bagger.ModelParams.NVarToSample = nvartosample;
       
            minleaf = bagger.ModelParams.MinLeaf;
            if isempty(minleaf)
                if     method(1)=='c'
                    minleaf = 1;
                elseif method(1)=='r'
                    minleaf = 5;
                end
            end
            bagger.MinLeaf = minleaf;
            bagger.ModelParams.MinLeaf = minleaf;
       
            minparent = bagger.ModelParams.MinParent;
            if ~isempty(minparent) || ~isempty(splitmin)
                error(message('stats:TreeBagger:init:MinparentSplitminNotAllowed'));
            end
            
            bagger.ModelParams = fillDefaultParams(bagger.ModelParams,...
                bagger.PrivateX,bagger.Y,bagger.W,bagger.DataSummary,bagger.ClassSummary);
 
         
            if method(1)=='c'
                bagger.Compact.ClassProb = bagger.Prior;
                bagger.DefaultYfit = 'mostpopular';
            else
                bagger.DefaultYfit = dot(bagger.W,bagger.Y)/sum(bagger.W);
            end
        end

        function x = getXForPrediction(bagger,x)
            vrange = bagger.DataSummary.VariableRange;
            x = classreg.learning.internal.table2PredictMatrix(x,[],[],...
                vrange,bagger.DataSummary.CategoricalPredictors,bagger.PredictorNames);
        end
    end    
    
    
    methods
        function [varargout] = predict(bagger,X,varargin)
            
            [varargout{1:nargout}] = predict(bagger.Compact,X,varargin{:});
        end
        
        
        function [varargout] = quantilePredict(bagger,X,varargin)
           

            [varargout{1:nargout}] = quantilePredictCompact(bagger.Compact,X,...
                bagger.X,bagger.Y,bagger.W,...
                'inbagindices',bagger.InBagIndices,varargin{:});
        end
        
        function [varargout] = oobPredict(bagger,varargin)
           
            if ~bagger.ComputeOOBPrediction
                error(message('stats:TreeBagger:oobPredict:InvalidOperation'));
            end
            
          
            [varargout{1:nargout}] = predict(bagger.Compact,bagger.X,...
                'useifort',bagger.OOBIndices,varargin{:});
        end
                
        function [varargout] = oobQuantilePredict(bagger,varargin)
           
            if ~bagger.ComputeOOBPrediction
                error(message('stats:TreeBagger:oobPredict:InvalidOperation'));
            end
            
       
            [varargout{1:nargout}] = quantilePredict(bagger,bagger.X,...
                'useifort',bagger.OOBIndices,varargin{:});
        end        
        
        function err = oobError(bagger,varargin)
           
            if ~bagger.ComputeOOBPrediction
                error(message('stats:TreeBagger:oobError:InvalidOperation'));
            end

        
            err = error(bagger.Compact,bagger.X,bagger.Y,...
                'weights',bagger.W,'useifort',bagger.OOBIndices,varargin{:});
        end
        
        function err = oobQuantileError(bagger,varargin)
           
            if ~bagger.ComputeOOBPrediction
                error(message('stats:TreeBagger:oobError:InvalidOperation'));
            end
            
      
            err = quantileError(bagger,bagger.X,bagger.Y,...
                'weights',bagger.W,'useifort',bagger.OOBIndices,...
                varargin{:});           
        end
        
        function mar = oobMargin(bagger,varargin)
           
            if ~bagger.ComputeOOBPrediction
                error(message('stats:TreeBagger:oobMargin:InvalidOperation'));
            end
            
           
            mar = margin(bagger.Compact,bagger.X,bagger.Y,...
                'useifort',bagger.OOBIndices,varargin{:});
        end
        
        function mar = oobMeanMargin(bagger,varargin)
            
            if ~bagger.ComputeOOBPrediction
                error(message('stats:TreeBagger:oobMeanMargin:InvalidOperation'));
            end
            
            
            mar = meanMargin(bagger.Compact,bagger.X,bagger.Y,...
                'weights',bagger.W,'useifort',bagger.OOBIndices,varargin{:});
        end
        
        function err = error(bagger,X,varargin)
           
            [y,varargin] = inferResponse(bagger.Compact,X,varargin{:});
            
            
            err = error(bagger.Compact,X,y,varargin{:});
        end
        
        function err = quantileError(bagger,X,varargin)
           
            [y,varargin] = inferResponse(bagger.Compact,X,varargin{:});

            err = quantileErrorCompact(bagger.Compact,X,y,...
                bagger.X,bagger.Y,bagger.W,...
                'inbagindices',bagger.InBagIndices,varargin{:});
        end

         function mar = margin(bagger,X,varargin)
            
            [y,varargin] = inferResponse(bagger.Compact,X,varargin{:});
            
          
            mar = margin(bagger.Compact,X,y,varargin{:});
        end
        
        function [varargout] = meanMargin(bagger,X,varargin)
           
            [y,varargin] = inferResponse(bagger.Compact,X,varargin{:});
            
            [varargout{1:nargout}] = meanMargin(bagger.Compact,X,y,varargin{:});
        end
        
        function [varargout] = mdsprox(bagger,varargin)
          
            
            [varargout{1:nargout}] = mdsProx(bagger,varargin{:});
        end
        
        function [AX] = plotPartialDependence(bagger,features,varargin)
        
        narginchk(2,13);
        
        
        p = inputParser;        
        addRequired(p,'Model');
        addRequired(p,'Var');
        addOptional(p,'Data',bagger.X); 
        addParameter(p,'Conditional',{'none','absolute','centered'});
        addParameter(p,'NumObservationsToSample',0);
        addParameter(p,'ParentAxisHandle',[]);
        addParameter(p,'QueryPoints',[]);
        addParameter(p,'UseParallel',false);
        parse(p,bagger,features,varargin{:});
        data = p.Results.Data;
        
       
        if(nargin>2 && ~ischar(varargin{1}))
            
            varargin = varargin(2:end);
        end
        
      
        ax = plotPartialDependence(bagger.Compact,...
            features,data,varargin{:});
        if(nargout > 0)
            AX = ax;
        end
        end
    end
    
    methods(Hidden=true)
        function [varargout] = mdsProx(bagger,varargin)
            
            if isempty(bagger.PrivProx)
                error(message('stats:TreeBagger:mdsProx:InvalidProperty'));
            end
            
          
            args = {'keep'};
            defs = { 'all'};
            [keep,~,compactArgs] = ...
                internal.stats.parseArgs(args,defs,varargin{:});
            
           
            N = size(bagger.PrivateX,1);
            if strcmpi(keep,'all')
                keep = 1:N;
            end
            if ~isnumeric(keep) && (~islogical(keep) || length(keep)~=N)
                error(message('stats:TreeBagger:mdsProx:InvalidInput'));
            end
            
          
            [varargout{1:nargout}] = mdsProx(bagger.Compact,...
                bagger.Proximity(keep,keep),'labels',bagger.Y(keep),...
                'data','proximity',compactArgs{:});
        end
        
        function bagger = fillProximities(bagger,varargin)
            bagger.PrivProx = flatprox(bagger.Compact,bagger.X,varargin{:});
        end
    end
end

function throwUndefinedError()
error(message('stats:TreeBagger:UndefinedFunction'));
end

function nm = normalizeMean1(A)

nm = zeros(1,size(A,2));


m = mean(A,1);
s = std(A,1,1);


above0 = s>0 | m>0;
nm(above0) = m(above0)./s(above0);
end



function idx = weightedSample(s,w,fsample,replace)

N = numel(w);
Nsample = ceil(N*fsample);



if isempty(s)
    idx = datasample((1:N)',Nsample,'replace',replace,'weights',w);
else
    idx = datasample(s,(1:N)',Nsample,'replace',replace,'weights',w);
end
end

function [trees, ...
    slicedOOBIndices, ...
    slicedInBagIndices, ...
    slicedPrivOOBPermutedVarDeltaError, ...
    slicedPrivOOBPermutedVarDeltaMeanMargin, ...
    slicedPrivOOBPermutedVarCountRaiseMargin] = ...
    localGrowTrees(NTrees, useParallel, RNGscheme, args)

doclassregtree            = args{1};            
fboot                     = args{2};
sampleWithReplacement     = args{3};
x                         = args{4};
y                         = args{5};
w                         = args{6};
method                    = args{7};
dataSummary               = args{8};
classSummary              = args{9};
modelParams               = args{10};
computeOOBPrediction      = args{11};
computeOOBVarImp          = args{12};
nprint                    = args{13};
usePool                   = args{14};
xorig                     = args{15};


prune = modelParams.Prune;
nvartosample = modelParams.NVarToSample;
minleaf = modelParams.MinLeaf;
maxsplits = modelParams.MaxSplits;
mergeleaves = modelParams.MergeLeaves;
nsurrogate = modelParams.NSurrogate;
qetoler = modelParams.QEToler;
splitcrit = modelParams.SplitCriterion;
catpred = dataSummary.CategoricalPredictors;
maxcat = modelParams.MaxCat;
algcat = modelParams.AlgCat;
prunecrit = modelParams.PruneCriterion;
predictorsel = modelParams.PredictorSelection;
usechisq = modelParams.UseChisqTest;


N = size(x,1);


slicedOOBIndices                              = [];
slicedInBagIndices                            = [];
slicedPrivOOBPermutedVarDeltaError            = [];
slicedPrivOOBPermutedVarDeltaMeanMargin       = [];
slicedPrivOOBPermutedVarCountRaiseMargin      = [];


if computeOOBPrediction
    if computeOOBVarImp
        if method(1)=='c'
            [trees, ...
                slicedOOBIndices, ...
                slicedInBagIndices, ...
                slicedPrivOOBPermutedVarDeltaError, ...
                slicedPrivOOBPermutedVarDeltaMeanMargin, ...
                slicedPrivOOBPermutedVarCountRaiseMargin] = ...
                internal.stats.parallel.smartForSliceout(NTrees, @loopBody, useParallel, RNGscheme);
        else
            [trees, ...
                slicedOOBIndices, ...
                slicedInBagIndices, ...
                slicedPrivOOBPermutedVarDeltaError] = ...
                internal.stats.parallel.smartForSliceout(NTrees, @loopBody, useParallel, RNGscheme);
        end
    else
        if method(1)=='r'
            [trees, slicedOOBIndices, slicedInBagIndices] = ...
                internal.stats.parallel.smartForSliceout(NTrees, @loopBody, useParallel, RNGscheme);
        else
            [trees, slicedOOBIndices] = ...
                internal.stats.parallel.smartForSliceout(NTrees, @loopBody, useParallel, RNGscheme);
        end
    end    
elseif method(1)=='r'
    [trees, ~, slicedInBagIndices] = ...
        internal.stats.parallel.smartForSliceout(NTrees, @loopBody, useParallel, RNGscheme);
else
    trees = internal.stats.parallel.smartForSliceout(NTrees, @loopBody, useParallel, RNGscheme);
end


if N==1
    slicedOOBIndices = slicedOOBIndices(:)';
end

if NTrees==1
    slicedPrivOOBPermutedVarDeltaError = slicedPrivOOBPermutedVarDeltaError(:)';
    slicedPrivOOBPermutedVarDeltaMeanMargin = slicedPrivOOBPermutedVarDeltaMeanMargin(:)';
    slicedPrivOOBPermutedVarCountRaiseMargin = slicedPrivOOBPermutedVarCountRaiseMargin(:)';
end


    
    function [slicedTree, ...
            slicedOOBIndices, ...
            slicedInBagIndices, ...
            slicedPrivOOBPermutedVarDeltaError, ...
            slicedPrivOOBPermutedVarDeltaMeanMargin, ...
            slicedPrivOOBPermutedVarCountRaiseMargin] = loopBody(~,s)
        
        slicedOOBIndices                              = [];
        slicedInBagIndices                            = [];
        slicedPrivOOBPermutedVarDeltaError            = [];
        slicedPrivOOBPermutedVarDeltaMeanMargin       = [];
        slicedPrivOOBPermutedVarCountRaiseMargin      = [];
        
        if isempty(s)
            s = RandStream.getGlobalStream;
        end
     
        idxtrain = weightedSample(s,w,fboot,sampleWithReplacement);
        
        if isempty(classSummary)
            cost = [];
            classNames = {};
        else
          
            cost = classSummary.Cost;
            classNames = cellstr(classSummary.ClassNames);
        end
        
        varnames = dataSummary.PredictorNames;
        if isnumeric(varnames)
            varnames = classreg.learning.internal.defaultPredictorNames(varnames);
        end

       
        if doclassregtree
            surrogate = 'off';
            if nsurrogate>0
                surrogate = 'on';
            end
          
            tree = ...
                classregtree(x(idxtrain,:),y(idxtrain),...
                'weights',ones(N,1),...
                'method',method,'prune',prune,...
                'cost',cost,'priorprob','empirical',...
                'nvartosample',nvartosample,...
                'minparent',2*minleaf,'minleaf',minleaf,...
                'mergeleaves',mergeleaves, ...
                'stream',s,'surrogate',surrogate,...
                'qetoler',qetoler,'splitcrit',splitcrit,...
                'categorical',catpred); 
        else
             if strcmp(method(1),'c')
                 localY = grp2idx(classreg.learning.internal.ClassLabel(y));
                 impl = classreg.learning.impl.TreeImpl.makeFromData(...
                     x,localY,ones(N,1)/N,idxtrain,true,...
                     catpred,splitcrit,minleaf,2*minleaf,maxsplits,nvartosample,...
                     nsurrogate,maxcat,algcat,cost,0,...
                     predictorsel,usechisq,s);
                 if strcmp(prune,'on')
                     impl = impl.prune('cost',cost,'criterion',prunecrit);
                 end
                 if strcmp(mergeleaves,'on')
                     impl = impl.prune('cost',cost,'criterion',prunecrit,'level',0);
                 end
                 tree = classreg.learning.classif.CompactClassificationTree(...
                     dataSummary,classSummary,...
                     @classreg.learning.transform.identity,'probability');
                 tree.Impl = impl;
             else
                 impl = classreg.learning.impl.TreeImpl.makeFromData(...
                     x,y,ones(N,1)/N,idxtrain,false,...
                     catpred,splitcrit,minleaf,2*minleaf,maxsplits,nvartosample,...
                     nsurrogate,0,'',[],qetoler,...
                     predictorsel,usechisq,s);
                 if strcmp(prune,'on')
                     
                     impl = impl.prune();
                 end
                 if strcmp(mergeleaves,'on')
                     impl = impl.prune('level',0);
                 end
                 tree = classreg.learning.regr.CompactRegressionTree(...
                     dataSummary,@classreg.learning.transform.identity);
                 tree.Impl = impl;
            end
        end
        
       
        if computeOOBPrediction
           
            oobtf = true(N,1);
            oobtf(idxtrain) = false;
            slicedOOBIndices = oobtf;  
           
         
            localcompact = CompactTreeBagger({tree},classNames,varnames);
            
            
            if computeOOBVarImp
                
                if method(1)=='c'
                    [slicedPrivOOBPermutedVarDeltaError, ...
                        slicedPrivOOBPermutedVarDeltaMeanMargin, ...
                        slicedPrivOOBPermutedVarCountRaiseMargin ] = ...
                        oobPermVarUpdate(xorig,y,w,classNames,...
                        localcompact,1,oobtf,doclassregtree,s);
                else
                    slicedPrivOOBPermutedVarDeltaError = ...
                        oobPermVarUpdate(xorig,y,w,classNames,...
                        localcompact,1,oobtf,doclassregtree,s);
                end
            end
        end
        
        if method(1)=='r'
            slicedInBagIndices = idxtrain;
        end
        
    
        if nprint>0
            ntreesGrown = internal.stats.parallel.statParallelStore('ntreesGrown') + 1;
            internal.stats.parallel.statParallelStore('ntreesGrown',ntreesGrown);
            if floor(ntreesGrown/nprint)*nprint==ntreesGrown
                if usePool
                    fprintf(1,'%s\n',getString(message('stats:TreeBagger:TreesDoneOnWorker', ...
                        ntreesGrown, ...
                        internal.stats.parallel.statParallelStore('mylabindex'))));
                else
                    fprintf(1,'%s\n',getString(message('stats:TreeBagger:TreesDone',ntreesGrown)));
                end
            end
        end
        
        slicedTree{1} = tree;
        
    end 
end


function [slicedPrivOOBPermutedVarDeltaError, ...
    slicedPrivOOBPermutedVarDeltaMeanMargin, ...
    slicedPrivOOBPermutedVarCountRaiseMargin] = ...
    oobPermVarUpdate(x,y,w,classNames,compact,treeInd,oobtf,doclassregtree,s)


Nvars = size(x,2);


slicedPrivOOBPermutedVarDeltaError = zeros(1,Nvars);
slicedPrivOOBPermutedVarDeltaMeanMargin = zeros(1,Nvars);
slicedPrivOOBPermutedVarCountRaiseMargin = zeros(1,Nvars);

Xoob = x(oobtf,:);


Noob = size(Xoob,1);
if Noob<=1
    return;
end


Woob = w(oobtf);
Wtot = sum(Woob);
if Wtot<=0
    return;
end

[sfit,~,yfit] = treeEval(compact,treeInd,Xoob,doclassregtree);


doclass = ~isempty(classNames);
    if iscategorical(yfit)
        yfit = cellstr(yfit);
    end
if doclass
    err = dot(Woob,~strcmp(y(oobtf),yfit))/Wtot;
else
    err = dot(Woob,(y(oobtf)-yfit).^2)/Wtot;
end


if doclass
    C = classreg.learning.internal.classCount(classNames,y(oobtf));
    margin = classreg.learning.loss.classifmargin(C,sfit);
end

if doclassregtree
    usedVars = varimportance(compact.Trees{treeInd}) > 0;
else
    usedVars = predictorImportance(compact.Trees{treeInd}) > 0;
end

for ivar=1:Nvars

    if ~usedVars(ivar) 
        continue;
    end
    
    permuted = randsample(s,Noob,Noob);
    xperm = Xoob;
    xperm(:,ivar) = xperm(permuted,ivar);
    wperm = Woob(permuted);
    [sfitvar,~,yfitvar] = ...
        treeEval(compact,treeInd,xperm,doclassregtree);
    

    if iscategorical(yfitvar)
        yfitvar = cellstr(yfitvar);
    end
    if doclass
        permErr = dot(wperm,~strcmp(y(oobtf),yfitvar))/Wtot;
    else
        permErr = dot(wperm,(y(oobtf)-yfitvar).^2)/Wtot;
    end
    slicedPrivOOBPermutedVarDeltaError(ivar) = permErr-err;
    
  
    if doclass
        permMargin = classreg.learning.loss.classifmargin(C,sfitvar);
        deltaMargin = margin-permMargin;
        slicedPrivOOBPermutedVarDeltaMeanMargin(ivar) = ...
            dot(wperm,deltaMargin)/Wtot;
        slicedPrivOOBPermutedVarCountRaiseMargin(ivar) = ...
            sum(deltaMargin>0) - sum(deltaMargin<0);
    end
end
end

function newx = decodeX(oldx,vr)

if isempty(vr)
    newx = oldx;
else
    ok = oldx>0 & ~isnan(oldx);
    if all(ok) 
        newx = vr(oldx);
    else
        newx = vr(ones(length(ok),1));
        newx(ok,:) = vr(oldx(ok));
        if iscategorical(newx)
            missing = '<undefined>';
        elseif isfloat(newx)
            missing = NaN;
        elseif iscell(newx) 
            missing = {''};
        elseif ischar(newx)
            missing = ' ';
        end
        newx(~ok,:) = missing;
    end
end
end
 