#!/usr/bin/env python3
"""Deterministic 32-bit, power-of-two TGA stars for the legacy texture API."""
import argparse
import math
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]
SIZE = 32


def polygon(scale):
    return [(16 + scale * (13 if i % 2 == 0 else 5.7) * math.sin(i * math.pi / 5),
             16 - scale * (13 if i % 2 == 0 else 5.7) * math.cos(i * math.pi / 5))
            for i in range(10)]


def inside(x, y, points):
    result = False
    for (ax, ay), (bx, by) in zip(points, points[1:] + points[:1]):
        if (ay > y) != (by > y) and x < (bx - ax) * (y - ay) / (by - ay) + ax:
            result = not result
    return result


def texture(filled):
    outer, inner = polygon(1), polygon(.68)
    # Uncompressed BGRA, top-left origin, 8 alpha bits; no atlas/font dependency.
    body = bytearray(struct.pack('<BBBHHBHHHHBB', 0, 0, 2, 0, 0, 0, 0, 0, SIZE, SIZE, 32, 0x28))
    for y in range(SIZE):
        for x in range(SIZE):
            samples = sum(inside(x + (sx + .5) / 4, y + (sy + .5) / 4, outer)
                          and (filled or not inside(x + (sx + .5) / 4, y + (sy + .5) / 4, inner))
                          for sy in range(4) for sx in range(4))
            body.extend((*((70, 201, 255) if filled else (203, 185, 166)), round(255 * samples / 16)))
    return bytes(body)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    for filled, name in [(False, 'StarOutline.tga'), (True, 'StarFilled.tga')]:
        path = ROOT / name
        expected = texture(filled)
        if args.check:
            assert path.read_bytes() == expected, name
        else:
            path.write_bytes(expected)
    print('PASS deterministic outline/filled five-point TGA assets')


if __name__ == '__main__':
    main()
