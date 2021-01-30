fn draw_line(line: ((i32, i32), (i32, i32)), buffer: &mut Vec<Vec<bool>>) {
    let (line0, line1) = line;
    let (x0, y0) = line0;
    let (x1, y1) = line1;

    let dx = (x1 - x0).abs();
    let dy = (y1 - y0).abs();

    let mut x = x0;
    let mut y = y0;
    let sx = if x0 > x1 { -1 } else { 1 };
    let sy = if y0 > y1 { -1 } else { 1 };

    if dx > dy {
        let mut err = (dx as f64) / 2.0;
        while x != x1 {
            buffer[y as usize][x as usize] = true;
            err -= dy as f64;
            if err < 0.0 {
                y += sy;
                err += dx as f64;
            }
            x += sx;
        }
    } else {
        let mut err = (dy as f64) / 2.0;
        while y != y1 {
            buffer[y as usize][x as usize] = true;
            err -= dx as f64;
            if err < 0.0 {
                x += sx;
                err += dy as f64;
            }
            y += sy;
        }
    }
    buffer[y as usize][x as usize] = true;
}

fn output_buffer(buffer: &Vec<Vec<bool>>) {
    for row in buffer {
        for pixel in row {
            print!("{}", if *pixel { "█" } else {" "});
        }
        println!("");
    }
}

fn main() {
    let image_size: (usize, usize) = (100, 100);

    let lines = vec![
        ((10, 10), (90, 10)),
        ((90, 90), (10, 90)),
        ((10, 10), (10, 90)),
        ((90, 90), (90, 10)),
        ((20, 20), (80, 80)),
        ((80, 20), (20, 80)),
        ((50, 20), (50, 80)),
    ];

    let mut buffer: Vec<Vec<bool>> = Vec::with_capacity(image_size.0 * image_size.1);
    for _ in 0..image_size.0 {
        buffer.push(vec![false; image_size.1]);
    }

    for line in lines {
        draw_line(line, &mut buffer);
    }

    output_buffer(&buffer);
}
