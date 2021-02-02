import collections

import OpenImageIO as oiio


def is_empty(buf):
    return oiio.ImageBufAlgo.isConstantChannel(buf, buf.spec().alpha_channel, 0)


def find_move(buf, tiles):
    for i, tile in enumerate(tiles):
        if oiio.ImageBufAlgo.isConstantChannel(tile, tile.spec().channelindex("R"), 1.0):
            return i

    import pdb; pdb.set_trace()
    raise RuntimeError(f"Could not find move in {buf.roi}")


def third_tiles(buf):
    third_x = buf.roi.width // 3
    third_y = buf.roi.height // 3

    for yoffset in range(3):
        ybegin = buf.roi.ybegin + yoffset * third_y
        yend = ybegin + third_y
        for xoffset in range(3):
            xbegin = buf.roi.xbegin + xoffset * third_x
            xend = xbegin + third_x

            tile_roi = oiio.ROI(xbegin, xend, ybegin, yend)
            yield oiio.ImageBufAlgo.crop(buf, tile_roi)


def _generate_x(buf, next_id):
    move_sequences = [None for _ in range(9)]

    node_id = next_id
    next_id += 1
    tiles = list(third_tiles(buf))
    move = find_move(buf, tiles)
    is_last_move = any(is_empty(tile) for tile in tiles)
    if is_last_move:
        return (node_id, move, move_sequences), next_id

    for i, tile in enumerate(tiles):
        if i == move or oiio.ImageBufAlgo.isConstantColor(tile):
            continue

        move_sequences[i], next_id = _generate_x(tile, next_id)

    return (node_id, move, move_sequences), next_id


def generate_x(buf):
    return _generate_x(buf, 0)[0]


def generate_o(buf):
    move_sequences = [None for _ in range(9)]

    for i, tile in enumerate(third_tiles(buf)):
        move = tiles.index(min(tiles, key=num_transparent))

        move_sequences[i] = []


def output(node, out_f):
    node_id, value, children = node
    for child in children:
        if child:
            output(child, out_f)

    print(f"{node_id},{value},{','.join(str(child[0]) if child else '' for child in children)}", file=out_f)


def main():
    image = "Tictactoe-X.png"
    buf = oiio.ImageBuf(image)
    if buf.spec().alpha_channel < 0:
        raise RuntimeError(f"{image} does not have an identifiable alpha channel")

    root = generate_x(buf)
    with open("x-tree.csv", "w") as out_f:
        output(root, out_f)


if __name__ == "__main__":
    main()
