#include "vector.h"

Vector2D::Vector2D (float a, float b)
{
    x = a;
    y = b;
}

Vector2D Vector2D::operator+(Vector2D param)
{
    Vector2D temp;
    temp.x = x + param.x;
    temp.y = y + param.y;
    return temp;
}

Vector2D Vector2D::operator-(Vector2D param)
{
    Vector2D temp;
    temp.x = x - param.x;
    temp.y = y - param.y;
    return temp;
}

Vector2D Vector2D::operator/(Vector2D param)
{
    Vector2D temp;
    temp.x = x / param.x;
    temp.y = y / param.y;
    return temp;
}

Vector2D Vector2D::operator/(float div)
{
    Vector2D temp;
    temp.x = x / div;
    temp.y = y / div;
    return temp;
}


Vector2D Vector2D::operator*(float mult)
{
    Vector2D temp;
    temp.x = x * mult;
    temp.y = y * mult;
    return temp;
}
