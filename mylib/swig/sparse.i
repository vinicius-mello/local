%module sparse

%{
#include <wrappers/sparse.hpp>
%}

class sparse {
public:
	sparse(int _m, int _n, int _nz, bool _sym=false);
	sparse();
	sparse(const sparse& b);
  sparse& operator=(const sparse& b);
	void ijv_col(array<int> ai, array<int> aj, array<double> av);
	~sparse();
  void report() const;
	double get(int i, int j) const;
	double set(int i, int j, double v);
	void diag(array<int>& d) const;
	void shift(double sigma, const array<int>& diag);
  void shift(double sigma, const array<int>& diag, const array<double>& d);
	void shift_same(double sigma, const sparse& s);
	void times(const array<double>& x, array<double>& y) const;
	void copy(const sparse& s);
	int n() const;
	int m() const;
	int nz() const;
	bool sym() const;
	array<int> col_ptr();
	array<int> row_ind();
	array<double> val();
};

