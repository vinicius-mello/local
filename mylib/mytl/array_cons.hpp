#ifndef MYTL_ARRAY_CONS_HPP
#define MYTL_ARRAY_CONS_HPP

/*! \file
 * \brief Array constructors
 */

#include <iostream>
#include <mytl/array.hpp>

namespace mytl {

    using std::ostream;
    using std::istream;

    /*! \addtogroup utl
     * @{
     */

    /*! \name Array constructors
     * Constructs arrays of many sizes
     */
    //@{
    template <class T>
        array<T,1> _(T a0) {
            array<T,1> a;
            a[0]=a0;
            return a;
        }

    template <class T>
        array<T,2> _(T a0, T a1) {
            array<T,2> a;
            a[0]=a0;
            a[1]=a1;
            return a;
        }

    template <class T>
        array<T,3> _(T a0, T a1, T a2) {
            array<T,3> a;
            a[0]=a0;
            a[1]=a1;
            a[2]=a2;
            return a;
        }

    template <class T>
        array<T,4> _(T a0, T a1, T a2, T a3) {
            array<T,4> a;
            a[0]=a0;
            a[1]=a1;
            a[2]=a2;
            a[3]=a3;
            return a;
        }

    template <class T>
        array<T,5> _(T a0, T a1, T a2, T a3, T a4) {
            array<T,5> a;
            a[0]=a0;
            a[1]=a1;
            a[2]=a2;
            a[3]=a3;
            a[4]=a4;
            return a;
        }

    template <class T>
        array<T,6> _(T a0, T a1, T a2, T a3, T a4, T a5) {
            array<T,6> a;
            a[0]=a0;
            a[1]=a1;
            a[2]=a2;
            a[3]=a3;
            a[4]=a4;
            a[5]=a5;
            return a;
        }
    //@}

    //! Simple array output
    template <class T, std::size_t k>
        ostream& operator<<(ostream& o, const array<T,k>& a) {
            for(size_t i=0; i<(k-1); ++i) o<<a[i]<<" ";
            o<<a[k-1];
            return o;
        }

    //! Simple array input
    template <class T, std::size_t k>
        istream& operator>>(istream& in, array<T,k>& a) {
            for(size_t i=0; i<k; ++i) in>>a[i];
            return in;
        }

    /*! @} */

}

#endif //MYTL_ARRAY_CONS_HPP
