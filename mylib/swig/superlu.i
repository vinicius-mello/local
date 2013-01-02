%module superlu
%{
#include <wrappers/superlu.hpp>
%}

enum yes_no_t {NO, YES};
enum fact_t {DOFACT, SamePattern, SamePattern_SameRowPerm, FACTORED};
enum rowperm_t {NOROWPERM, LargeDiag, MY_PERMR};
enum colperm_t {NATURAL, MMD_ATA, MMD_AT_PLUS_A, COLAMD, METIS_AT_PLUS_A, PARMETIS, ZOLTAN, MY_PERMC};
enum trans_t {NOTRANS, TRANS, CONJ};
enum IterRefine_t {NOREFINE, SINGLE=1, DOUBLE, EXTRA};
enum norm_t {ONE_NORM, TWO_NORM, INF_NORM};
enum milu_t {SILU, SMILU_1, SMILU_2, SMILU_3};

struct superlu_options_t {
    fact_t        Fact;
    yes_no_t      Equil;
    colperm_t     ColPerm;
    trans_t       Trans;
    IterRefine_t  IterRefine;
    double        DiagPivotThresh;
    yes_no_t      SymmetricMode;
    yes_no_t      PivotGrowth;
    yes_no_t      ConditionNumber;
    rowperm_t     RowPerm;
    int           ILU_DropRule;
    double        ILU_DropTol;    /* threshold for dropping */
    double        ILU_FillFactor; /* gamma in the secondary dropping */
    norm_t        ILU_Norm;       /* infinity-norm, 1-norm, or 2-norm */
    double        ILU_FillTol;    /* threshold for zero pivot perturbation */
    milu_t        ILU_MILU_DimU;
    double        ILU_MILU_Dim;   /* Dimension of PDE (if available) */
    yes_no_t      ParSymbFact;
    yes_no_t      ReplaceTinyPivot; /* used in SuperLU_DIST */
    yes_no_t      SolveInitialized;
    yes_no_t      RefineInitialized;
    yes_no_t      PrintStat;
};

extern void set_default_options(superlu_options_t& opt);

class superlu {
    public:
        superlu(const sparse& _S);
        ~superlu();
        void set_options(const superlu_options_t& opt);
        void factor();
        void solve(const array<double>& b, array<double>& x) const;
};

