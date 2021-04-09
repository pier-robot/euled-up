#include <vector>

#include "boid.h"
#include "vector.h"

void Boid::set_position(Vector2D new_pos)
{
   position = new_pos;
}

void Boid::set_velocity(Vector2D new_vel)
{
   float velocity_limit = 15;
   if (new_vel.magnitude() > velocity_limit)
   {
      new_vel = (new_vel / new_vel.magnitude()) * velocity_limit;
   }

   velocity = new_vel;
}

