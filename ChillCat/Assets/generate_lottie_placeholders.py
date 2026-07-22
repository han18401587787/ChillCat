#!/usr/bin/env python3
"""
绪安 v3.0 — 24 款 Lottie 占位动画生成器

生成 24 个极简 Lottie JSON 占位文件到 EmotionAnimations/ 目录。
每款表情一个 .json 文件，命名：emotion_{type}_{intensity}.json
"""

import json
import os
import math

# ── 配置 ──

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "EmotionAnimations")
FRAMERATE = 30
WIDTH = 60
HEIGHT = 60
DURATION_FRAMES = 60  # 2s @ 30fps

EMOTIONS = {
    "joy":      {"color": [0.961, 0.651, 0.137]},  # #F5A623
    "sadness":  {"color": [0.478, 0.604, 0.667]},  # #7A9AAA
    "anger":    {"color": [0.910, 0.518, 0.431]},  # #E8846E
    "fear":     {"color": [0.627, 0.522, 0.776]},  # #A085C6
    "disgust":  {"color": [0.486, 0.722, 0.529]},  # #7CB887
    "surprise": {"color": [0.831, 0.659, 0.361]},  # #D4A85C
}

INTENSITY_CONFIG = {
    1: {  # mild
        "scale_min": 1.0, "scale_max": 1.03,
        "opacity_min": 0.6, "opacity_max": 1.0,
        "bounce_y": -1.5,
        "shake": False,
    },
    2: {  # moderate
        "scale_min": 1.0, "scale_max": 1.06,
        "opacity_min": 0.7, "opacity_max": 1.0,
        "bounce_y": -2.0,
        "shake": False,
    },
    3: {  # strong
        "scale_min": 1.0, "scale_max": 1.10,
        "opacity_min": 0.85, "opacity_max": 1.0,
        "bounce_y": -2.5,
        "shake": False,
    },
    4: {  # extreme
        "scale_min": 1.0, "scale_max": 1.15,
        "opacity_min": 1.0, "opacity_max": 1.0,
        "bounce_y": -3.0,
        "shake": True,
    },
}


def lerp(a, b, t):
    """线性插值"""
    return a + (b - a) * t


def ease_in_out(t):
    """ease-in-out 缓动函数 (cubic)"""
    if t < 0.5:
        return 4.0 * t * t * t
    else:
        return 1.0 - (-2.0 * t + 2.0) ** 3 / 2.0


def ease_out_elastic(t):
    """弹性缓出"""
    if t == 0 or t == 1:
        return t
    c4 = (2.0 * math.pi) / 3.0
    return math.pow(2.0, -10.0 * t) * math.sin((t * 10.0 - 0.75) * c4) + 1.0


def ease_out_back(t):
    """回弹缓出"""
    c1 = 1.70158
    c3 = c1 + 1.0
    return 1.0 + c3 * math.pow(t - 1.0, 3) + c1 * math.pow(t - 1.0, 2)


def build_scale_keyframes(scale_min, scale_max):
    """
    生成底层圆形的呼吸缩放关键帧。
    使用 ease-in-out 缓动，2s 循环。
    """
    kf = []
    step = 5  # 每 5 帧一个关键帧

    for frame in range(0, DURATION_FRAMES + 1, step):
        # 一个周期内的进度 (0→1→0)
        progress = frame / DURATION_FRAMES  # 0..1
        eased = ease_in_out(progress)
        # 映射: 0→scale_min, 0.5→scale_max, 1→scale_min
        scale_val = lerp(scale_min, scale_max, math.sin(progress * math.pi))
        kf.append({
            "t": frame,
            "s": [round(scale_val, 4)],
            "i": {"x": [0.42], "y": [1]},
            "o": {"x": [0.58], "y": [0]},
        })

    return kf


def build_opacity_keyframes(opacity_min, opacity_max):
    """
    生成顶层表情的淡入关键帧。
    0→1 在 0.5s (15帧) 内完成。
    """
    kf = []
    # 起始
    kf.append({"t": 0, "s": [0]})
    # 0.5s 淡入完成
    for frame in range(3, 16, 3):
        t = frame / 15.0  # 0..1
        eased = ease_out_back(t)
        opacity_val = lerp(0, opacity_max, eased)
        kf.append({
            "t": frame,
            "s": [round(opacity_val, 4)],
            "i": {"x": [0.42], "y": [1]},
            "o": {"x": [0.58], "y": [0]},
        })
    # 保持
    kf.append({"t": 15, "s": [opacity_max]})
    kf.append({"t": 60, "s": [opacity_max]})
    return kf


def build_translate_y_keyframes(bounce_y):
    """
    生成顶层表情的微弹跳位移关键帧。
    -3→0 弹性缓出，约 0.5s 完成。
    """
    kf = []
    # 起始
    kf.append({"t": 0, "s": [bounce_y]})
    # 弹性回弹
    for frame in range(3, 16, 3):
        t = frame / 15.0
        eased = ease_out_elastic(t)
        y_val = lerp(bounce_y, 0, eased)
        kf.append({
            "t": frame,
            "s": [round(y_val, 4)],
            "i": {"x": [0.25], "y": [1]},
            "o": {"x": [0.75], "y": [0]},
        })
    kf.append({"t": 15, "s": [0]})
    kf.append({"t": 60, "s": [0]})
    return kf


def build_shake_keyframes():
    """
    极端强度抖动效果关键帧（旋转 + 位移）。
    """
    rotation_kf = [
        {"t": 0, "s": [0]},
        {"t": 10, "s": [3], "i": {"x": [0.42], "y": [1]}, "o": {"x": [0.58], "y": [0]}},
        {"t": 20, "s": [-3], "i": {"x": [0.42], "y": [1]}, "o": {"x": [0.58], "y": [0]}},
        {"t": 30, "s": [2], "i": {"x": [0.42], "y": [1]}, "o": {"x": [0.58], "y": [0]}},
        {"t": 40, "s": [-2], "i": {"x": [0.42], "y": [1]}, "o": {"x": [0.58], "y": [0]}},
        {"t": 50, "s": [0], "i": {"x": [0.42], "y": [1]}, "o": {"x": [0.58], "y": [0]}},
        {"t": 60, "s": [0]},
    ]
    return rotation_kf


def build_layer_circle(name, color, scale_min, scale_max):
    """底层圆形 — 呼吸缩放"""
    scale_kf = build_scale_keyframes(scale_min, scale_max)

    return {
        "ddd": 0,
        "ind": 1,
        "ty": 4,  # shape layer
        "nm": name,
        "sr": 1,
        "ks": {
            "o": {"a": 0, "k": 100},
            "r": {"a": 0, "k": 0},
            "p": {"a": 0, "k": [WIDTH / 2, HEIGHT / 2]},
            "a": {"a": 0, "k": [0, 0]},
            "s": {
                "a": 1,
                "k": scale_kf,
            },
        },
        "shapes": [
            {
                "ty": "el",  # ellipse
                "nm": "Circle",
                "p": {"a": 0, "k": [0, 0]},
                "s": {"a": 0, "k": [30, 30]},  # radius 15 → size 30
                "d": 1,  # direction clockwise
            },
            {
                "ty": "st",  # stroke
                "nm": "Stroke",
                "c": {"a": 0, "k": color},
                "w": {"a": 0, "k": 2},
                "o": {"a": 0, "k": 100},
                "lc": 1,  # butt cap
                "lj": 1,  # miter join
            },
            {
                "ty": "fl",  # fill
                "nm": "Fill",
                "c": {"a": 0, "k": [color[0], color[1], color[2], 0.15]},
                "o": {"a": 0, "k": 100},
                "r": 1,  # fill rule nonzero
            },
        ],
    }


def build_layer_emoji(name, color, opacity_min, opacity_max, bounce_y, shake):
    """顶层表情 — 淡入 + 微弹跳"""
    opacity_kf = build_opacity_keyframes(opacity_min, opacity_max)
    translate_y_kf = build_translate_y_keyframes(bounce_y)

    # 变换属性
    transform = {
        "o": {
            "a": 1,
            "k": opacity_kf,
        },
        "r": {"a": 0, "k": 0},
        "p": {
            "a": 1,
            "k": [
                {
                    "t": 0,
                    "s": [WIDTH / 2, HEIGHT / 2 + bounce_y],
                    "i": {"x": [0.42], "y": [1]},
                    "o": {"x": [0.58], "y": [0]},
                },
                {"t": 15, "s": [WIDTH / 2, HEIGHT / 2]},
                {"t": 60, "s": [WIDTH / 2, HEIGHT / 2]},
            ],
        },
        "a": {"a": 0, "k": [0, 0]},
        "s": {"a": 0, "k": [100, 100]},
    }

    # 极端强度添加抖动
    if shake:
        shake_kf = build_shake_keyframes()
        transform["r"] = {
            "a": 1,
            "k": shake_kf,
        }

    # 表情符号（简化为小型圆形 + 眼睛形状）
    shapes = [
        {
            "ty": "el",
            "nm": "Face",
            "p": {"a": 0, "k": [0, 0]},
            "s": {"a": 0, "k": [16, 16]},  # 小圆脸
            "d": 1,
        },
        {
            "ty": "fl",
            "nm": "Face Fill",
            "c": {"a": 0, "k": color},
            "o": {"a": 0, "k": 80},
            "r": 1,
        },
        # 左眼
        {
            "ty": "el",
            "nm": "Left Eye",
            "p": {"a": 0, "k": [-3.5, -2]},
            "s": {"a": 0, "k": [3, 3]},
            "d": 1,
        },
        {
            "ty": "fl",
            "nm": "Left Eye Fill",
            "c": {"a": 0, "k": [1, 1, 1]},
            "o": {"a": 0, "k": 100},
            "r": 1,
        },
        # 右眼
        {
            "ty": "el",
            "nm": "Right Eye",
            "p": {"a": 0, "k": [3.5, -2]},
            "s": {"a": 0, "k": [3, 3]},
            "d": 1,
        },
        {
            "ty": "fl",
            "nm": "Right Eye Fill",
            "c": {"a": 0, "k": [1, 1, 1]},
            "o": {"a": 0, "k": 100},
            "r": 1,
        },
    ]

    return {
        "ddd": 0,
        "ind": 2,
        "ty": 4,
        "nm": name,
        "sr": 1,
        "ks": transform,
        "shapes": shapes,
    }


def generate_lottie(emotion_type, intensity_num, config):
    """生成单个 Lottie JSON"""
    emotion_cfg = EMOTIONS[emotion_type]
    color = emotion_cfg["color"]

    name = f"emotion_{emotion_type}_{intensity_num}"
    display_name = f"{emotion_type.capitalize()} Lv.{intensity_num}"

    # 构建图层
    circle_layer = build_layer_circle(
        f"{name}_circle",
        color,
        config["scale_min"],
        config["scale_max"],
    )

    emoji_layer = build_layer_emoji(
        f"{name}_emoji",
        color,
        config["opacity_min"],
        config["opacity_max"],
        config["bounce_y"],
        config["shake"],
    )

    lottie_json = {
        "v": "5.9.0",
        "fr": FRAMERATE,
        "ip": 0,
        "op": DURATION_FRAMES,
        "w": WIDTH,
        "h": HEIGHT,
        "nm": display_name,
        "ddd": 0,
        "assets": [],
        "layers": [circle_layer, emoji_layer],
        "markers": [],
    }

    return lottie_json


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    total = 0
    for emotion_type in EMOTIONS:
        for intensity_num, config in INTENSITY_CONFIG.items():
            lottie = generate_lottie(emotion_type, intensity_num, config)
            filename = f"emotion_{emotion_type}_{intensity_num}.json"
            filepath = os.path.join(OUTPUT_DIR, filename)

            with open(filepath, "w", encoding="utf-8") as f:
                json.dump(lottie, f, separators=(",", ":"), ensure_ascii=False)

            file_size = os.path.getsize(filepath)
            print(f"  ✓ {filename} ({file_size} bytes)")
            total += 1

    print(f"\n生成完成：{total} 个 Lottie 占位动画 → {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
