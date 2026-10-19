#!/usr/bin/env python3
"""生成 PennyLock 的 App 图标(1024x1024):渐变背景 + 白色锁形。"""
from PIL import Image, ImageDraw

SIZE = 1024
img = Image.new("RGB", (SIZE, SIZE))
draw = ImageDraw.Draw(img)

# 垂直渐变背景:青色 -> 天蓝
top = (45, 212, 191)      # #2DD4BF
bottom = (14, 165, 233)   # #0EA5E9
for y in range(SIZE):
    t = y / (SIZE - 1)
    r = int(top[0] + (bottom[0] - top[0]) * t)
    g = int(top[1] + (bottom[1] - top[1]) * t)
    b = int(top[2] + (bottom[2] - top[2]) * t)
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b))

cx = SIZE // 2

# 锁梁(倒 U 形圆弧),两端接锁体顶部
draw.arc([cx - 130, 430, cx + 130, 690], start=180, end=360, fill="white", width=72)

# 锁体(白色圆角矩形)
draw.rounded_rectangle([cx - 210, 540, cx + 210, 820], radius=70, fill="white")

# 钥匙孔
kh_y = 660
draw.ellipse([cx - 34, kh_y - 34, cx + 34, kh_y + 34], fill=(14, 165, 233))
draw.rectangle([cx - 20, kh_y + 4, cx + 20, kh_y + 90], fill=(14, 165, 233))

img.save("/mnt/c/Users/xykj1/Desktop/PennyLock/PennyLock/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
print("icon saved")
