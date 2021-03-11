import errno
import math
import os
import struct
import sys
import time

SCREEN_WIDTH, SCREEN_HEIGHT  = 960, 720
RADIUS = SCREEN_HEIGHT / 3
CENTER = SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2
VELOCITY = -0.05


def calc_pos(angle):
    return [
        CENTER[0] + RADIUS * math.cos(angle),
        CENTER[1] - RADIUS * math.sin(angle),
    ]


def calc_vel(angle):
    return [
        RADIUS * VELOCITY * math.cos(angle + math.pi / 2),
        - RADIUS * VELOCITY * math.sin(angle + math.pi / 2),
    ]


angle = 0

sys.stdout.buffer.write(struct.pack('I', 2))
while True:
    pos_a = calc_pos(angle)
    pos_b = calc_pos(angle + math.pi)
    vel_a = calc_vel(angle)
    vel_b = calc_vel(angle + math.pi)

    try:
        sys.stdout.buffer.write(struct.pack('ff', *pos_a))
        sys.stdout.buffer.write(struct.pack('ff', *vel_a))

        sys.stdout.buffer.write(struct.pack('ff', *pos_b))
        sys.stdout.buffer.write(struct.pack('ff', *vel_b))
        sys.stdout.buffer.flush()
    except BrokenPipeError as exc:
        devnull = os.open(os.devnull, os.O_WRONLY)
        os.dup2(devnull, sys.stdout.fileno())
        break

    angle += VELOCITY
    if angle > 2 * math.pi:
        angle -= 2 * math.pi

    # True gamers get 60fps
    time.sleep(1/60)
