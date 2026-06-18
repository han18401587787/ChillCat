#!/usr/bin/env python3
"""
绪安 v3.0 — 24 款情绪表情占位 PNG 生成器

生成规则：
- 6 种基础情绪 × 4 级强度 = 24 款表情
- 每款 3 种分辨率：@1x (60×60), @2x (120×120), @3x (180×180)
- 圆形裁剪 + 情绪色背景（透明度随强度递增）
- 外圈同色描边（强度决定线宽，extreme 级带虚线警示）
- 中心显示简化的情绪符号（Unicode）
- 输出到 EmotionAssets/ 源图目录，同时复制到 .xcassets imageset
"""

import os
import json
import math
from PIL import Image, ImageDraw, ImageFont

# ── 情绪元数据（来自 CCEmotionSet.swift） ──
EMOTIONS = [
    {"type": "joy",      "name_cn": "快乐", "color": "#F5A623", "symbol": "☺"},
    {"type": "sadness",  "name_cn": "悲伤", "color": "#7A9AAA", "symbol": "☹"},
    {"type": "anger",    "name_cn": "愤怒", "color": "#E8846E", "symbol": "⚡"},
    {"type": "fear",     "name_cn": "恐惧", "color": "#A085C6", "symbol": "❢"},
    {"type": "disgust",  "name_cn": "厌恶", "color": "#7CB887", "symbol": "✕"},
    {"type": "surprise", "name_cn": "惊喜", "color": "#D4A85C", "symbol": "!"},
]

# 强度级别: (名称, 中文, 背景透明度, 环宽比例, extreme_dashed)
INTENSITIES = [
    ("mild",     "平静/低落/不悦/紧张/不适/好奇", 0.20, 1.0, False),
    ("moderate", "愉悦/难过/生气/害怕/讨厌/惊讶",   0.35, 2.0, False),
    ("strong",   "开心/悲伤/愤怒/恐惧/厌恶/惊喜",   0.50, 3.0, False),
    ("extreme",  "狂喜/悲痛/暴怒/惊恐/憎恶/震撼",   0.70, 4.0, True),
]

# 分辨率配置
SCALES = [
    ("@1x", 60),
    ("@2x", 120),
    ("@3x", 180),
]

# 输出路径
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(BASE_DIR, "EmotionAssets")
XCASSETS_DIR = os.path.join(BASE_DIR, "EmotionAssets.xcassets")


def hex_to_rgba(hex_color, alpha=1.0):
    """将 #RRGGBB 转换为 (R, G, B, A) 0-255"""
    hex_color = hex_color.lstrip("#")
    r = int(hex_color[0:2], 16)
    g = int(hex_color[2:4], 16)
    b = int(hex_color[4:6], 16)
    return (r, g, b, int(alpha * 255))


def create_placeholder(emotion, intensity, scale_suffix, size):
    """
    生成单张占位 PNG
    - 圆形裁剪
    - 情绪色填充背景（透明度由强度决定）
    - 外圈同色描边
    - extreme 级别额外加虚线外圈
    - 中心 Unicode 情绪符号
    """
    etype = emotion["type"]
    hex_color = emotion["color"]
    symbol = emotion["symbol"]
    iname = intensity[0]      # mild / moderate / strong / extreme
    alpha_bg = intensity[2]   # 背景透明度
    ring_ratio = intensity[3] # 环宽比例
    is_extreme = intensity[4]

    # 创建透明画布
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 圆形区域参数
    cx = cy = size / 2
    margin = max(4, size * 0.06)  # 边距
    outer_radius = (size / 2) - margin

    # 描边环宽度
    ring_width = max(1, int(size * 0.03 * ring_ratio))

    # ── 1. 背景圆形填充 ──
    fill_rgba = hex_to_rgba(hex_color, alpha_bg)
    draw.ellipse(
        [cx - outer_radius, cy - outer_radius, cx + outer_radius, cy + outer_radius],
        fill=fill_rgba,
    )

    # ── 2. 外圈描边（60% 不透明度） ──
    stroke_rgba = hex_to_rgba(hex_color, 0.60)
    for i in range(ring_width):
        r = outer_radius - i
        draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            outline=stroke_rgba,
            width=1,
        )

    # ── 3. Extreme 级：额外虚线外圈（警示效果） ──
    if is_extreme:
        dashed_radius = outer_radius + ring_width + max(2, int(size * 0.025))
        dash_len = max(3, int(size * 0.08))
        gap_len = max(2, int(size * 0.04))
        warning_rgba = hex_to_rgba(hex_color, 0.75)

        num_segments = 16
        for seg in range(num_segments):
            angle_start = (seg / num_segments) * 2 * math.pi
            angle_end = angle_start + (2 * math.pi / num_segments) * 0.6

            steps = 8
            for step in range(steps):
                t = step / steps
                angle = angle_start + t * (angle_end - angle_start)
                x1 = cx + dashed_radius * math.cos(angle)
                y1 = cy + dashed_radius * math.sin(angle)
                x2 = cx + dashed_radius * math.cos(angle + 0.01)
                y2 = cy + dashed_radius * math.sin(angle + 0.01)
                draw.line([x1, y1, x2, y2], fill=warning_rgba, width=1)

    # ── 4. 中心情绪符号 ──
    # 尝试使用较大的字号
    font_size = int(size * 0.55)
    try:
        # macOS/Linux 常用字体
        for font_name in [
            "AppleColorEmoji", "Segoe UI Emoji", "NotoColorEmoji",
            "Noto Emoji", "Symbola", "DejaVuSans",
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        ]:
            try:
                font = ImageFont.truetype(font_name, font_size)
                break
            except (IOError, OSError):
                font = None
        if font is None:
            font = ImageFont.load_default()
    except Exception:
        font = ImageFont.load_default()

    # 计算文字位置（居中）
    bbox = draw.textbbox((0, 0), symbol, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = cx - tw / 2
    ty = cy - th / 2 - th * 0.05  # 微调垂直居中

    # 文字颜色：白色 + 80% 不透明度（在彩色背景上可读）
    text_color = (255, 255, 255, 220)
    draw.text((tx, ty), symbol, fill=text_color, font=font)

    # ── 5. 在 extreme 级画面上方加一个小惊叹号标记 ──
    if is_extreme:
        marker_size = int(size * 0.12)
        marker_font_size = int(size * 0.10)
        try:
            mfont = ImageFont.truetype("DejaVuSans", marker_font_size)
        except Exception:
            mfont = ImageFont.load_default()
        mx = size - marker_size - int(size * 0.04)
        my = int(size * 0.04)
        draw.ellipse(
            [mx, my, mx + marker_size, my + marker_size],
            fill=(255, 80, 80, 200),
            outline=(255, 255, 255, 180),
            width=1,
        )
        # 感叹号
        mb = draw.textbbox((0, 0), "!", font=mfont)
        mtw = mb[2] - mb[0]
        mth = mb[3] - mb[1]
        draw.text(
            (mx + marker_size / 2 - mtw / 2, my + marker_size / 2 - mth / 2),
            "!",
            fill=(255, 255, 255, 255),
            font=mfont,
        )

    return img


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(XCASSETS_DIR, exist_ok=True)

    total = 0

    for emotion in EMOTIONS:
        for idx, intensity in enumerate(INTENSITIES):
            etype = emotion["type"]
            iname = intensity[0]
            asset_name = f"emotion_{etype}_{idx + 1}"

            # ── Part A: 生成 3 种分辨率的 PNG ──
            for scale_suffix, size in SCALES:
                filename = f"{asset_name}{scale_suffix}.png"
                filepath = os.path.join(OUTPUT_DIR, filename)

                img = create_placeholder(emotion, intensity, scale_suffix, size)
                img.save(filepath, "PNG")
                total += 1

            # ── Part B: 创建 .xcassets imageset ──
            imageset_dir = os.path.join(XCASSETS_DIR, f"{asset_name}.imageset")
            os.makedirs(imageset_dir, exist_ok=True)

            # Contents.json
            contents = {
                "images": [
                    {
                        "filename": f"{asset_name}@1x.png",
                        "idiom": "universal",
                        "scale": "1x",
                    },
                    {
                        "filename": f"{asset_name}@2x.png",
                        "idiom": "universal",
                        "scale": "2x",
                    },
                    {
                        "filename": f"{asset_name}@3x.png",
                        "idiom": "universal",
                        "scale": "3x",
                    },
                ],
                "info": {"author": "xcode", "version": 1},
            }
            contents_path = os.path.join(imageset_dir, "Contents.json")
            with open(contents_path, "w", encoding="utf-8") as f:
                json.dump(contents, f, indent=2, ensure_ascii=False)

            # 复制 PNG 到 imageset 目录
            for scale_suffix, size in SCALES:
                src_filename = f"{asset_name}{scale_suffix}.png"
                src_path = os.path.join(OUTPUT_DIR, src_filename)
                dst_path = os.path.join(imageset_dir, f"{asset_name}{scale_suffix}.png")
                # 硬链接或复制
                import shutil
                shutil.copy2(src_path, dst_path)

            print(f"  ✓ {asset_name}  ({emotion['name_cn']} / {intensity[1]})")

    print(f"\n✅ 完成！共生成 {total} 张 PNG（24 款 × 3 分辨率）")
    print(f"   源图目录: {OUTPUT_DIR}")
    print(f"   Asset Catalog: {XCASSETS_DIR}")

    # 统计验证
    png_count = len([f for f in os.listdir(OUTPUT_DIR) if f.endswith(".png")])
    imageset_count = len([
        d for d in os.listdir(XCASSETS_DIR)
        if d.endswith(".imageset") and os.path.isdir(os.path.join(XCASSETS_DIR, d))
    ])
    print(f"   验证: {png_count} PNG 文件, {imageset_count} imageset 目录")


if __name__ == "__main__":
    main()
