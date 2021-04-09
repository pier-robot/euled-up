#ifndef __SCENE_H_INCLUDED__
#define __SCENE_H_INCLUDED__

#include <vector>
#include "boid.h"
#include "vector.h"

class Scene
{
    int screen_width = 960;
    int screen_height  = 720;
    float radius = screen_height / 3.0;
    Vector2D centre = {screen_width / 2.0f, screen_height / 2.0f};
    Vector2D boid_centre;

    Vector2D centre_of_mass(Boid);
    Vector2D no_collision(Boid);
    Vector2D match_velocity(Boid);
    Vector2D bound_position(Boid);
    void limit_speed(Boid);
    void add_boid(int, Vector2D, Vector2D);

    public:
        std::vector<Boid> boid_list;
        int get_boid_no() {return boid_list.size();};
        void recalc_scene();
        Scene(int);
};

#endif