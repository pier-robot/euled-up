import sys

B = "\u001b[0m\u001b[40m  \u001b[0m"
W = "\u001b[0m\u001b[42m  \u001b[0m"
#B = "-"
#W = "X"


class Bitmap(object):
    def __init__(self, width, height, background=B):
        super(Bitmap, self).__init__()
        self.width = width
        self.height = height
        self.background = background

        self.pixels = [[self.background]*width for h in range(height)]

    def set(self, pt, val=W):
        x, y = pt
        self.pixels[y][x] = val

    def draw(self):
        for row in self.pixels:
            print("".join(row))

    def add_line(self, pt0, pt1):
        x0, y0 = pt0
        x1, y1 = pt1
        dx = abs(x1 - x0)
        dy = -abs(y1 - y0)
        sx = -1 if x0 > x1 else 1
        sy = -1 if y0 > y1 else 1

        x = x0
        y = y0
        err = dx + dy
        while True:
            self.set((x, y))
            if x == x1 and y == y1: break
            e2 = 2*err
            if e2 >= dy:
                err += dy
                x += sx
            if e2 <= dx:
                err += dx
                y += sy


def main():
    bitmap = Bitmap(17, 17)
    # bitmap.draw()
    bitmap.add_line((1, 8), (8, 16))
    bitmap.add_line((8, 16), (16, 8))
    bitmap.add_line((16, 8), (8, 1))
    bitmap.add_line((8, 1), (1, 8))

    #bitmap.add_line((1, 1), (5, 9))
    print()
    bitmap.draw()



if __name__ == '__main__':
    main()
