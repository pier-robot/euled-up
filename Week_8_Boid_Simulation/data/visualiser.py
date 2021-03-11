# python -m venv .venv
# .venv/bin/pip/install pygame
# /path/to/boid/sim | .venv/bin/python visualiser.py
import math
from time import time
import pathlib
import struct
import sys

import numpy as np
import pygame
import pygame.freetype

SCREEN_WIDTH, SCREEN_HEIGHT  = 960, 720
SCREEN_SIZE = (SCREEN_WIDTH, SCREEN_HEIGHT)
SCREEN_CENTER = (SCREEN_WIDTH // 2, SCREEN_HEIGHT // 2)
CAPTION = "Boid Simulation Visualiser"
SIMULATION_BACKGROUND = pygame.Color('black')


def freetype_font(file, size=20):
    file_path = str(pathlib.Path(__file__).parent / file)
    if not pygame.freetype.was_init():
        pygame.freetype.init()
    return pygame.freetype.Font(file_path, size)


def image(file):
    file_path = str(pathlib.Path(__file__).parent / file)
    image_ = pygame.image.load(file_path)
    alpha = image_.get_alpha() is not None
    if alpha:
        image_ = image_.convert_alpha()
    else:
        image_ = image_.convert()
    return image_


class FPSCounter(pygame.sprite.Sprite):
    def __init__(self):
        self._text = "FPS: ..."
        self.font = freetype_font('hallo-sans.otf')
        self.font_color = pygame.Color('white')
        self.image, self.rect = self.render_font()
        self.rect.center = 11 * SCREEN_WIDTH // 12, 0.5 * SCREEN_HEIGHT // 9
        self.refresh_every = 30
        self.counter = 0
        self.time = 0

    def render_font(self):
        return self.font.render(self._text, fgcolor=self.font_color, size=17)

    def update(self, time):
        self.counter += 1
        self.time += time
        if self.counter == self.refresh_every or self.time > 1:
            self.time /= self.counter
            self.text = "FPS: {}".format(round(1 / self.time, 1))
            self.counter = 0
            self.time = 0

    @property
    def text(self):
        return self._text

    @text.setter
    def text(self, text):
        self._text = text
        self.image, rect = self.render_font()
        rect.topleft = self.rect.topleft
        self.rect = rect

    def display(self, screen):
        screen.blit(self.image, self.rect)


class Boid(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()
        self.base_image = image("boid.png")
        self.rect = self.base_image.get_rect()
        self.image = self.base_image
        self.pos = np.zeros(2)
        self.vel = np.zeros(2)

    @property
    def pos(self):
        return self._pos

    @pos.setter
    def pos(self, pos):
        self._pos = pos
        self.rect.center = tuple(int(x) for x in pos)

    @property
    def vel(self):
        return self._vel

    @vel.setter
    def vel(self, vel):
        self._vel = vel
        self._rotate_image()

    def _rotate_image(self):
        angle = -np.rad2deg(np.angle(self.vel[0] + 1j * self.vel[1]))
        self.image = pygame.transform.rotate(self.base_image, angle)
        self.rect = self.image.get_rect(center=self.rect.center)

    def display(self, screen):
        screen.blit(self.image, self.rect)


class Simulation:

    def __init__(self):
        pygame.init()
        self.running = True
        self.screen = pygame.display.set_mode(SCREEN_SIZE)
        pygame.display.set_caption(CAPTION)
        self.boids = []
        self.to_display = pygame.sprite.Group()
        self.fps_counter = FPSCounter()

    def update(self):
        for boid in self.boids:
            pos = sys.stdin.buffer.read(4 * 2)
            boid.pos = np.frombuffer(pos, dtype='f4', count=2)
            vel = sys.stdin.buffer.read(4 * 2)
            boid.vel = np.frombuffer(vel, dtype='f4', count=2)

    def display(self):
        for sprite in self.to_display:
            sprite.display(self.screen)

    def init_run(self):
        num_boids = struct.unpack('<I', sys.stdin.buffer.read(4))[0]
        for _ in range(num_boids):
            boid = Boid()
            self.to_display.add(boid)
            self.boids.append(boid)

    def handle_events(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return True

        return False

    def run(self):
        self.init_run()
        dt = 0
        while self.running:
            t = time()

            self.display()
            self.fps_counter.display(self.screen)
            pygame.display.flip()

            self.screen.fill(SIMULATION_BACKGROUND)
            if self.handle_events():
                break
            self.update()
            self.fps_counter.update(dt)

            dt = time() - t
        pygame.quit()


if __name__ == '__main__':
    Simulation().run()
