#include <random>

#include "scene.h"

Scene::Scene(int num_boids)
{
    std::default_random_engine generator;
    std::uniform_int_distribution<> distr_pos_x(0, screen_width);
    std::uniform_int_distribution<> distr_pos_y(0, screen_height);
    std::uniform_real_distribution<> distr_vel(-0.5, 0.5);

    for (int i = 0; i < num_boids; i++)
    {
        auto boid_position = Vector2D(distr_pos_x(generator), distr_pos_y(generator));
        auto boid_velocity = Vector2D(distr_vel(generator), distr_vel(generator));
        this->add_boid(i, boid_position, boid_velocity);
        boid_centre = boid_centre + boid_position;
    }
}

void Scene::add_boid(int id, Vector2D start_pos, Vector2D start_velocity)
{
    auto boid = Boid(id);
    boid.set_position(start_pos);
    boid.set_velocity(start_velocity);
    boid_list.push_back(boid);
}

Vector2D Scene::centre_of_mass(Boid boid)
{
    auto perceived_pos = boid_centre/(get_boid_no()-1);
    auto out_velocity = (perceived_pos - boid.position)/100;

    return out_velocity;
}

Vector2D Scene::no_collision(Boid boid)
{
    Vector2D c;
    for(auto it_boid : boid_list)
    {
        if (boid.id != it_boid.id)
        {
            auto diff_vector = it_boid.get_position() - boid.get_position();
            if (diff_vector.magnitude() < 50)
            {
                c = c - diff_vector;
            }
        }
    } 
    return c;
}

Vector2D Scene::match_velocity(Boid boid)
{
    Vector2D v;
    for(auto it_boid : boid_list)
    {
        if (boid.id != it_boid.id)
        {
            v = v + it_boid.get_velocity();
        }
    } 
    v = v/(get_boid_no()-1);
    return (v - boid.get_velocity())/8;
}

Vector2D Scene::bound_position(Boid boid)
{
    Vector2D v;
    int nudge_unit = 20;

    auto boid_pos = boid.get_position();
    if (boid_pos.x < 50) {v.x = nudge_unit;}
    else if (boid_pos.x > screen_height - 50) {v.x = -nudge_unit;}

    if (boid_pos.y < 50) {v.y = nudge_unit;}
    else if (boid_pos.y > screen_width - 50) {v.y = -nudge_unit;}

    return v;
}

void Scene::recalc_scene()
{
    for(auto boid = std::begin(boid_list); boid != std::end(boid_list); ++boid)
    {
        boid_centre = boid_centre - boid->get_position();

        // rule one
        auto v1 = centre_of_mass(*boid);
        // rule two
        auto v2 = no_collision(*boid);
        // rule three
        auto v3 = match_velocity(*boid);
        // rule four
        auto v4 = bound_position(*boid);

        auto new_velocity = boid->get_velocity() + v1 + v2 + v3 + v4;

        // velocity limiting happens when the velocity is set
        boid->set_velocity(new_velocity);

        boid->set_position(boid->get_position() + boid->get_velocity());

        boid_centre = boid_centre + boid->get_position();
    }
}