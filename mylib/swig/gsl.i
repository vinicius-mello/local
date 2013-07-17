%module gsl
%{
#include <wrappers/gsl.hpp>
%}

typedef unsigned int uint;

#define M_E        2.71828182845904523536028747135      /* e */
#define M_LOG2E    1.44269504088896340735992468100      /* log_2 (e) */
#define M_LOG10E   0.43429448190325182765112891892      /* log_10 (e) */
#define M_SQRT2    1.41421356237309504880168872421      /* sqrt(2) */
#define M_SQRT1_2  0.70710678118654752440084436210      /* sqrt(1/2) */
#define M_SQRT3    1.73205080756887729352744634151      /* sqrt(3) */
#define M_PI       3.14159265358979323846264338328      /* pi */
#define M_PI_2     1.57079632679489661923132169164      /* pi/2 */
#define M_PI_4     0.78539816339744830961566084582     /* pi/4 */
#define M_SQRTPI   1.77245385090551602729816748334      /* sqrt(pi) */
#define M_1_PI     0.31830988618379067153776752675      /* 1/pi */
#define M_2_PI     0.63661977236758134307553505349      /* 2/pi */
#define M_LN10     2.30258509299404568401799145468      /* ln(10) */
#define M_LN2      0.69314718055994530941723212146      /* ln(2) */
#define M_LNPI     1.14472988584940017414342735135      /* ln(pi) */
#define M_EULER    0.57721566490153286060651209008      /* Euler constant */


namespace gsl {

    bool isNaN (const double x);
    bool finite (const double x);
    int isInf (const double x);
    double log1p(const double x);
    double expm1(const double x);
    double hypot(const double x, const double y);
    double hypot3(const double x, const double y, const double z);
    double pow2(const double x);
    double pow3(const double x);
    double pow4(const double x);
    double pow5(const double x);
    double pow6(const double x);
    double pow7(const double x);
    double pow8(const double x);
    double pow9(const double x);
    double poly_eval(const array<double>& d, const double x);
    int poly_eval_derivs(const array<double>& d, const double x, array<double>& res);
    double erf(const double x);
    double Ei(const double x);
    double Ci(const double x);
    double Si(const double x);
    double gamma(const double x);
    double fact(const int n);
    double choose(const unsigned int n, const unsigned int m);
    double taylorcoeff(const int n, const double x);
    double zeta(const double x);
    void permutation_init(array<size_t>& a);
    bool permutation_swap(array<size_t>& a, uint i, uint j);
    bool permutation_valid(array<size_t>& a);
    void permutation_reverse(array<size_t>& a);
    bool permutation_inverse(array<size_t>& ai, array<size_t>& a);
    bool permutation_next(array<size_t>& a);
    bool permutation_prev(array<size_t>& a);
    void matrix_set_zero(array<double>& a);
    void matrix_set_identity(array<double>& a);
    void matrix_set_all(array<double>& a, double x);
    void matrix_swap_rows(array<double>& a, uint i, uint j);
    void matrix_swap_columns(array<double>& a, uint i, uint j);
    void matrix_transpose(array<double>& a);
    void matrix_transpose(array<double>& a, array<double>& b);
    bool matrix_mul(array<double>& a, array<double>& b, array<double>& c);
    bool matrix_add(array<double>& a, array<double>& b);
    bool matrix_sub(array<double>& a, array<double>& b);
    bool matrix_mul_elements(array<double>& a, array<double>& b);
    bool matrix_div_elements(array<double>& a, array<double>& b);
    bool matrix_scale(array<double>& a, double x);
    bool matrix_add_constant(array<double>& a, double x);
    bool matrix_add_diagonal(array<double>& a, double x);
    int LU_decomp(array<double>& a, array<size_t>& p);
    bool LU_solve(array<double>& a, array<size_t>& p, array<double>& b, array<double>& x);
    bool LU_solve(array<double>& a, array<size_t>& p, array<double>& bx);
    bool LU_invert(array<double>& a, array<size_t>& p, array<double>& inv);
    bool LU_refine(array<double>& a, array<double>& lu, array<size_t>& p, array<double>& b, array<double>& x, array<double>& r);
    double LU_det(array<double>& a, int sig);
    bool QR_decomp(array<double>& a, array<double>& tau);
    bool QR_solve(array<double>& qr, array<double>& tau, array<double>& b, array<double>& x);
    bool QR_solve(array<double>& a, array<double>& tau, array<double>& bx);
    bool QR_lssolve(array<double>& qr, array<double>& tau, array<double>& b, array<double>& x, array<double>& r);
    bool cholesky_decomp(array<double>& a);
    bool cholesky_solve(array<double>& chol, array<double>& b, array<double>& x);
    bool cholesky_solve(array<double>& chol, array<double>& bx);
    bool eigen_symm(array<double>& a, array<double>& eval);
    bool eigen_symm(array<double>& a, array<double>& eval, array<double>& evec);

    enum wavelet_type {
        daubechies,
        daubechies_centered,
        haar,
        haar_centered,
        bspline,
        bspline_centered
    };

    class dwt {
        public:
            dwt(wavelet_type t, size_t k);
            ~dwt();
            int forward(array<double>& a);
            int inverse(array<double>& a);
            int forward2d(array<double>& a);
            int inverse2d(array<double>& a);
    };

    class dct {
        public:
            dct(size_t l);
            ~dct();
            int forward(const array<double>& input,
                array<double>& output);
            int inverse(const array<double>& input,
                array<double>& output);
            int forward2d(const array<double>& input,
                array<double>& output);
            int inverse2d(const array<double>& input,
                array<double>& output);
    };
}

