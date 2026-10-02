from PIL import Image
import numpy as np

REPO = '/Users/skyline/PROJECTS/Games/g1/'
SRC = REPO + 'game/content/onepiece/characters/luffy/sprites/base/idle.png'
OUT = '/private/tmp/claude-501/-Users-skyline-PROJECTS-Games-g1/df12427a-9512-4496-956a-d47b7d816b23/scratchpad/'

idle = np.array(Image.open(SRC).convert('RGBA'))[:, :64].copy()
Y0, X0 = 41, 26
HIP = (X0 + 6, Y0 + 16)          # hip joint (x, y) when bob = 0
GROUND = 63


def C(h):
    return np.array([int(h[i:i + 2], 16) for i in (1, 3, 5)] + [255], dtype=np.uint8)


NEAR = {'thigh': C('#5571A3'), 'thigh_edge': C('#3F5C8B'), 'cuff': C('#CED0E2'),
        'shin': C('#EADAC0'), 'foot': C('#AC906A'), 'arm': C('#EADAC0')}
FAR = {'thigh': C('#224C6E'), 'thigh_edge': C('#224C6E'), 'cuff': C('#B7B9C8'),
       'shin': C('#CEC09C'), 'foot': C('#927755'), 'arm': C('#CEC09C')}

# Leg poses as joint offsets from the hip: (knee, ankle, foot direction).
LEGS = {
    'reach':    ((3, 2), (5, 6), 1),     # front leg forward, knee bent, heel down ahead
    'trail_hi': ((-2, 3), (-6, 1), -1),  # rear leg stretched back, foot kicked high
    'support':  ((1, 3), (0, 6), 1),
    'fold':     ((4, 2), (-2, 1), -1),
    'spread':   ((3, 2), (5, 5), 1),     # front leg in flight, knee bent
}
ARMS = {
    'fwd':  ["..A..", "..A.A", "..AAA"],   # elbow bent 90 degrees, fist up in front of the chest
    'back': ["..A..", ".AA..", "A...."],   # elbow pulled back behind the body
    'mid':  ["..A..", "..A..", "..AA."],
}
# (bob, near leg, far leg, near arm, far arm)
FRAMES = [
    (0, 'reach', 'trail_hi', 'back', 'fwd'),
    (1, 'support', 'fold', 'mid', 'mid'),
    (-2, 'trail_hi', 'spread', 'fwd', 'back'),
    (0, 'trail_hi', 'reach', 'fwd', 'back'),
    (1, 'fold', 'support', 'mid', 'mid'),
    (-2, 'spread', 'trail_hi', 'back', 'fwd'),
]
LEAN = [(0, 10, 2), (10, 13, 1), (13, 16, 0)]   # (row from, row to, x shift): head +2, chest +1, hips 0
NEAR_SHOULDER, FAR_SHOULDER = (11, 3), (11, 10)
ARM_PIXELS = [(r, c) for r in range(11, 16) for c in range(0, 4)] + [(r, c) for r in range(12, 16) for c in range(10, 13)]


def put(frame, x, y, color):
    if 0 <= x < 64 and 0 <= y < 64:
        frame[y, x] = color


def segment(frame, a, b, width, color, edge=None):
    steps = max(abs(b[0] - a[0]), abs(b[1] - a[1]), 1) * 2
    for t in np.linspace(0, 1, steps + 1):
        x = int(round(a[0] + (b[0] - a[0]) * t))
        y = int(round(a[1] + (b[1] - a[1]) * t))
        for w in range(width):
            put(frame, x - width // 2 + w, y, edge if (edge is not None and w == 0) else color)


def leg(frame, pose, bob, pal):
    (kx, ky), (ax, ay), direction = LEGS[pose]
    hip = (HIP[0], HIP[1] + bob)
    knee = (hip[0] + kx, hip[1] + ky)
    ankle = (hip[0] + ax, hip[1] + ay)
    segment(frame, hip, knee, 3, pal['thigh'], pal['thigh_edge'])
    segment(frame, knee, ankle, 2, pal['shin'])
    put(frame, knee[0], knee[1], pal['cuff'])
    put(frame, knee[0] - 1, knee[1], pal['cuff'])
    for i in range(3 if direction > 0 else 2):
        put(frame, ankle[0] + i * direction, ankle[1], pal['foot'])


def torso_and_head(bob):
    body = idle.copy()
    for r, c in ARM_PIXELS:
        body[Y0 + r, X0 + c] = 0
    layer = np.zeros_like(idle)
    for r0, r1, dx in LEAN:
        layer[Y0 + r0 + bob:Y0 + r1 + bob, dx:] = body[Y0 + r0:Y0 + r1, :64 - dx]
    return layer


def arm(frame, pose, shoulder, bob, pal):
    r0, c0 = shoulder
    lean = 1
    for r, line in enumerate(ARMS[pose]):
        for c, ch in enumerate(line):
            if ch != '.':
                put(frame, X0 + c0 + c - 2 + lean, Y0 + r0 + r + bob, pal['arm'])


def overlay(base, layer):
    mask = layer[:, :, 3] > 0
    base[mask] = layer[mask]


def run_frame(bob, near_leg, far_leg, near_arm, far_arm):
    frame = np.zeros_like(idle)
    leg(frame, far_leg, bob, FAR)
    arm(frame, far_arm, FAR_SHOULDER, bob, FAR)
    overlay(frame, torso_and_head(bob))
    leg(frame, near_leg, bob, NEAR)
    arm(frame, near_arm, NEAR_SHOULDER, bob, NEAR)
    return frame


frames = [run_frame(*spec) for spec in FRAMES]
for i, f in enumerate(frames):
    ys = np.nonzero(f[:, :, 3])[0]
    assert ys.max() <= GROUND, f'frame {i + 1} goes below the ground row'
strip = np.concatenate(frames, axis=1)
Image.fromarray(strip, 'RGBA').save(OUT + 'run9.png')
zoom = np.concatenate([f[36:64, 18:48] for f in frames], axis=1)
bg = Image.new('RGBA', (zoom.shape[1], zoom.shape[0]), (252, 245, 234, 255))
bg.alpha_composite(Image.fromarray(zoom, 'RGBA'))
bg.resize((zoom.shape[1] * 12, zoom.shape[0] * 12), Image.NEAREST).save(OUT + 'run9_zoom.png')
print('grounded rows:', [int(np.nonzero(f[:, :, 3])[0].max()) for f in frames])
