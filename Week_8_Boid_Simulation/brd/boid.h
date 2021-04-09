#ifndef __BOID_H_INCLUDED__
#define __BOID_H_INCLUDED__

#include "vector.h"

class Boid {

    public:
        Boid(int a) {id=a;};
        int id;
        Vector2D position;
        Vector2D velocity;
        void set_position(float, float);
        void set_position(Vector2D);
        Vector2D get_position() { return position;};
        void set_velocity(float, float);
        void set_velocity(Vector2D);
        Vector2D get_velocity() { return velocity;};

};

#endif