"""Check legacy-compatible on-disk assets and five-point outline/fill states."""
import importlib.util
from pathlib import Path
import struct
import unittest

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('star_assets', ROOT / 'tools/generate_star_textures.py')
assets = importlib.util.module_from_spec(spec)
spec.loader.exec_module(assets)


class StarTextureTests(unittest.TestCase):
    def test_committed_assets_are_exact_bgra_tga_and_have_distinct_states(self):
        for filled, name in [(False, 'StarOutline.tga'), (True, 'StarFilled.tga')]:
            body = (ROOT / name).read_bytes()
            self.assertEqual(body, assets.texture(filled))
            self.assertEqual(struct.unpack('<BBBHHBHHHHBB', body[:18]),
                             (0, 0, 2, 0, 0, 0, 0, 0, 32, 32, 32, 0x28))
            self.assertEqual(len(body), 18 + 32 * 32 * 4)
            alpha = lambda x, y: body[18 + 4 * (32 * y + x) + 3]
            self.assertEqual(alpha(16, 16), 255 if filled else 0)
            for point in [(16, 5), (26, 12), (22, 24), (9, 24), (5, 12)]:
                self.assertGreater(alpha(*point), 0, 'missing star point')
            for point in [(0, 0), (31, 31), (0, 31), (31, 0), (16, 29)]:
                self.assertEqual(alpha(*point), 0, 'background must stay transparent')
