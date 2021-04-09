#ifndef __VECTOR_H_INCLUDED__
#define __VECTOR_H_INCLUDED__

#include <math.h>

class Vector2D
{
    public:
        float x;
        float y;
        Vector2D() {x = 0; y = 0;};
        Vector2D(float, float);
        Vector2D operator+ (Vector2D);
        Vector2D operator- (Vector2D);
        Vector2D operator/ (Vector2D);
        Vector2D operator/ (float);
        Vector2D operator* (float);
        float magnitude() {return sqrt(pow(x, 2) + pow(y, 2));};

};

#endif