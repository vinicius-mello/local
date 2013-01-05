#ifndef MYTL_ARRAY_OPERATORS_HPP
#define MYTL_ARRAY_OPERATORS_HPP

/*! \file
 * \brief Array operators
 */

#include <mytl/array.hpp>

namespace mytl {

    using std::size_t;

    /*! \addtogroup utl
     * @{
     */

    template <class Data, size_t k>
        inline
        array<Data,k>& operator+=(array<Data,k>& a, const array<Data,k>& b) {
            for(size_t i=0;i<k;++i) a[i]+=b[i];
            return a;
        }

    template <class Data, size_t k>
        inline
        array<Data,k> operator+(const array<Data,k>& a, const array<Data,k>& b) {
            array<Data,k> t=a;
            t+=b;
            return t;
        }

    template <class Data, size_t k>
        inline
        Data sum(const array<Data,k>& a) {
            Data s=0;
            for(size_t i=0;i<k;++i) s+=a[i];
            return s;
        }

    /*! @} */

}

#endif //MYTL_ARRAY_OPERATORS_HPP
