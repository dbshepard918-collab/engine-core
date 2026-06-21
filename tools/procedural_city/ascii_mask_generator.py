
"""
Simple deterministic ASCII layout generator for top-down cyberpunk ARPG test maps.
This does not call AI. Use it to turn prompt/design intent into a playable mask scaffold.
"""
import random
from pathlib import Path

WALL = '#'; FLOOR = '.'; DOOR = 'D'; HAZARD = 'H'; LANDMARK = 'L'; START = 'S'; EXIT = 'X'

def carve_room(grid, x, y, w, h):
    for yy in range(y, y+h):
        for xx in range(x, x+w):
            if 0 < xx < len(grid[0])-1 and 0 < yy < len(grid)-1:
                grid[yy][xx] = FLOOR

def generate(width=32, height=20, seed=1234):
    random.seed(seed)
    grid = [[WALL for _ in range(width)] for _ in range(height)]
    rooms = []
    x = 2
    while x < width - 8:
        y = random.randint(3, height-8)
        w = random.randint(5, 8); h = random.randint(4, 6)
        carve_room(grid, x, y, w, h)
        rooms.append((x,y,w,h))
        if len(rooms) > 1:
            px,py,pw,ph = rooms[-2]
            cx,cy = x+w//2, y+h//2
            pcx,pcy = px+pw//2, py+ph//2
            for xx in range(min(pcx,cx), max(pcx,cx)+1): grid[pcy][xx] = FLOOR
            for yy in range(min(pcy,cy), max(pcy,cy)+1): grid[yy][cx] = FLOOR
        x += random.randint(6, 9)
    if rooms:
        sx,sy,sw,sh = rooms[0]; grid[sy+sh//2][sx+sw//2] = START
        ex,ey,ew,eh = rooms[-1]; grid[ey+eh//2][ex+ew//2] = EXIT
        lx,ly,lw,lh = rooms[len(rooms)//2]; grid[ly+lh//2][lx+lw//2] = LANDMARK
    for _ in range(max(2, len(rooms))):
        rx,ry,rw,rh = random.choice(rooms)
        grid[random.randint(ry, ry+rh-1)][random.randint(rx, rx+rw-1)] = HAZARD
    return [''.join(row) for row in grid]

if __name__ == '__main__':
    mask = generate()
    out = Path('generated_city_mask.txt')
    out.write_text('\n'.join(mask), encoding='utf-8')
    print(out.read_text())
