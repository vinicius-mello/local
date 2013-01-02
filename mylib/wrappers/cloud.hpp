#ifndef WRAP_CLOUD_HPP
#define WRAP_CLOUD_HPP
#include "array.hpp"

void barycenter(array<float> cl, int ra, int rb, array<float> b) {
    b.zero();
    for(int i=ra;i<rb;++i) {
        for(int j=0;j<b.size();++j)
            b.set(j,b.get(j)+cl.get(i,j));
    }
    float s=rb-ra;
    for(int j=0;j<b.size();++j)
        b.set(j,b.get(j)/s);
}

#endif // WRAP_CLOUD_HPP
