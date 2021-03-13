use raylib::prelude::*;

const NUM_BOIDS: u32 = 5;
const SCREEN_WIDTH: i32 = 960;
const SCREEN_HEIGHT: i32 = 720;
const CENTRE: (i32, i32) = (SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
const RADIUS: f32 = (SCREEN_HEIGHT as f32) / 3.0;
const VELOCITY: f32 = -0.05;

#[derive(Debug)]
struct Boid {
    position: Vector2,
    velocity: Vector2,
}

fn init_position(angle: f32) -> Vector2 {
    Vector2 {
        x: (CENTRE.0 as f32) + RADIUS * angle.cos(),
        y: (CENTRE.1 as f32) - RADIUS * angle.sin(),
    }
}

fn init_velocity(angle: f32) -> Vector2 {
    let tangent_angle = angle + PI as f32 / 2.0;
    Vector2 {
        x: RADIUS * VELOCITY * tangent_angle.cos(),
        y: -RADIUS * VELOCITY * tangent_angle.sin(),
    }
}

fn initialise_positions() -> Vec<Boid> {
    let mut boids: Vec<Boid> = Vec::with_capacity(NUM_BOIDS as usize);

    let increment = (2.0 * PI as f32) / (NUM_BOIDS as f32);
    for i in 0..NUM_BOIDS {
        let angle = (i as f32) * increment;
        let boid = Boid {
            position: init_position(angle),
            velocity: init_velocity(angle),
        };
        boids.push(boid);
    }

    boids
}

fn boid_triangle(boid: &Boid) -> (Vector2, Vector2, Vector2) {
    let length = 18;
    let width = 12;

    let bound_offset = boid.velocity.normalized() * (length / 2) as f32;
    let tip = boid.position + bound_offset;
    let tail = boid.position - bound_offset;

    let perpendicular = Vector2 {
        x: boid.velocity.y,
        y: -boid.velocity.x,
    }
    .normalized()
        * (width / 2) as f32;
    let bottom_a = tail + perpendicular;
    let bottom_b = tail - perpendicular;

    (tip, bottom_a, bottom_b)
}

fn draw_boids(boids: &[Boid], d: &mut RaylibDrawHandle) {
    for boid in boids {
        let triangle = boid_triangle(boid);
        d.draw_triangle_lines(triangle.0, triangle.1, triangle.2, Color::WHITE);
    }
}

fn move_all_boids_to_new_positions(boids: &[Boid]) -> Vec<Boid> {
    let mut new_boids = Vec::with_capacity(boids.len());

    for boid in boids {
        let v1 = rule1(boid, boids);
        let v2 = rule2(boid, boids);
        let v3 = rule3(boid, boids);

        let velocity = boid.velocity + v1 + v2 + v3;
        let position = boid.position + velocity;
        let new_boid = Boid { position, velocity };
        new_boids.push(new_boid);
    }

    new_boids
}

fn rule1(boid: &Boid, boids: &[Boid]) -> Vector2 {
    let mut perceived_center = Vector2::zero();

    for boid_ in boids {
        if boid_ as *const _ != boid as *const _ {
            perceived_center += boid_.position;
        }
    }

    perceived_center /= (boids.len() - 1) as f32;

    (perceived_center - boid.position) / 100.0
}

fn rule2(boid: &Boid, boids: &[Boid]) -> Vector2 {
    let mut displacement = Vector2::zero();

    for boid_ in boids {
        if boid_ as *const _ != boid as *const _ {
            if boid.position.distance_to(boid_.position) < 10.0 {
                displacement -= boid.position - boid_.position;
            }
        }
    }

    displacement
}

fn rule3(boid: &Boid, boids: &[Boid]) -> Vector2 {
    let mut perceived_velocity = Vector2::zero();

    for boid_ in boids {
        if boid_ as *const _ != boid as *const _ {
            perceived_velocity += boid.velocity;
        }
    }

    perceived_velocity /= (boids.len() - 1) as f32;

    (boid.velocity - perceived_velocity) / 8.0
}

fn main() {
    let mut boids = initialise_positions();
    let (mut rl, thread) = raylib::init()
        .size(SCREEN_WIDTH as i32, SCREEN_HEIGHT as i32)
        .title("Boid Simulation")
        .build();
    rl.set_target_fps(60);

    while !rl.window_should_close() {
        let mut d = rl.begin_drawing(&thread);
        d.clear_background(Color::BLACK);
        d.draw_fps(11 * SCREEN_WIDTH / 12, SCREEN_HEIGHT / 2 / 9);
        draw_boids(&boids, &mut d);

        boids = move_all_boids_to_new_positions(&boids);
    }
}
