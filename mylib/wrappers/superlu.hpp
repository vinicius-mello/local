#ifndef WRAP_SUPERLU_HPP
#define WRAP_SUPERLU_HPP
extern "C" {
#include <slu_ddefs.h>
}
#include "array.hpp"
#include "sparse.hpp"

void set_default_options(superlu_options_t& opt) {
    set_default_options(&opt);
}

class superlu {
    mutable SuperMatrix A;
    mutable SuperMatrix B;
    mutable SuperMatrix * L;
    mutable SuperMatrix * U;
    int * perm_r;
    int * perm_c;
    int * etree;
    mutable superlu_options_t options;
    mutable SuperLUStat_t stat;
    mutable mem_usage_t    mem_usage;
    trans_t trans;
    const sparse& S;
    bool alloc;
    public:
    superlu(const sparse& _S) : S(_S) {
        alloc=false;
        ::set_default_options(options);
    }
    ~superlu() {
        if(alloc) free();
    }
    void set_options(const superlu_options_t& opt) {
        options=opt;
    }
    void free() {
        SUPERLU_FREE(perm_r);
        SUPERLU_FREE(perm_c);
        Destroy_SuperNode_Matrix(L);
        Destroy_CompCol_Matrix(U);
        SUPERLU_FREE (L);
        SUPERLU_FREE (U);
        alloc=false;
    }
    void factor() {
        SuperMatrix AC;
        int i, panel_size, permc_spec, relax;
        trans=NOTRANS;
        int info;
        if(alloc) free();
        /* Initialize the statistics variables. */
        StatInit(&stat);
        dCreate_CompCol_Matrix(&A, S.m(), S.n(), S.nz(), const_cast<double *>(S.val().data()), const_cast<int *>(S.row_ind().data()), const_cast<int *>(S.col_ptr().data()), SLU_NC, SLU_D, SLU_GE);
        L = (SuperMatrix *) SUPERLU_MALLOC( sizeof(SuperMatrix) );
        U = (SuperMatrix *) SUPERLU_MALLOC( sizeof(SuperMatrix) );
        if( !(perm_r = intMalloc(S.m())) ) ABORT("Malloc fails for perm_r[].");
        if( !(perm_c = intMalloc(S.n())) ) ABORT("Malloc fails for perm_c[].");
        if( !(etree = intMalloc(S.n())) ) ABORT("Malloc fails for etree[].");
        /*
         * * Get column permutation vector perm_c[], according to permc_spec:
         * * permc_spec = 0: natural ordering
         * * permc_spec = 1: minimum degree on structure of AÎéÎ÷*A
         * * permc_spec = 2: minimum degree on structure of AÎéÎ÷+A
         * * permc_spec = 3: approximate minimum degree for unsymmetric matrices
         * */
        permc_spec = 3;
        get_perm_c(permc_spec, &A, perm_c);
        sp_preorder(&options, &A, perm_c, etree, &AC);
        panel_size = sp_ienv(1);
        relax = sp_ienv(2);
        dgstrf(&options, &AC, relax, panel_size,
                etree, NULL, 0, perm_c, perm_r, L, U, &stat, &info);
        if ( info == 0 ) {
            /*  SCformat * Lstore = (SCformat *) L->Store;
                NCformat * Ustore = (NCformat *) U->Store;
                printf("No of nonzeros in factor L = %d\n", Lstore->nnz);
                printf("No of nonzeros in factor U = %d\n", Ustore->nnz);
                printf("No of nonzeros in L+U = %d\n", Lstore->nnz + Ustore->nnz);
                dQuerySpace(L, U, &mem_usage);
                printf("L\\U MB %.3f\ttotal MB needed %.3f\n",
                mem_usage.for_lu/1e6, mem_usage.total_needed/1e6);*/
        } else {
            printf("dgstrf() error returns INFO= %d\n", info);
            if ( info <= S.n() ) { /* factorization completes */
                dQuerySpace(L, U, &mem_usage);
                printf("L\\U MB %.3f\ttotal MB needed %.3f\n", mem_usage.for_lu/1e6, mem_usage.total_needed/1e6);
            }
        }
        SUPERLU_FREE(etree);
        Destroy_SuperMatrix_Store(&A);
        Destroy_CompCol_Permuted(&AC);
        StatFree(&stat);
        alloc=true;
    }
    void solve(const array<double>& b, array<double>& x) const {
        int info;
        /* Initialize the statistics variables. */
        StatInit(&stat);
        /* Extract the LU factors in the factors handle */
        x.copy(b);
        dCreate_Dense_Matrix(&B, S.m(), 1, x.data(), S.m(), SLU_DN, SLU_D, SLU_GE);
        /* Solve the system A*X=B, overwriting B with X. */
        dgstrs (trans, L, U, perm_c, perm_r, &B, &stat, &info);
        Destroy_SuperMatrix_Store(&B);
        StatFree(&stat);
    }
};

#endif // WRAP_SUPERLU_HPP
