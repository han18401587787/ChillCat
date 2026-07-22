# 绪安 Lottie 动效规格

> 所有互动奖励动效均使用 Lottie JSON 实现，矢量无损、跨平台一致。
> 以下为动效设计师/Lottie 制作的完整参数参考。

---

## 1. 点赞 / Like

**使用场景**：共鸣墙 · 树洞 · 治愈空间
**总时长**：600ms
**缓动**：easeOutBack
**触觉反馈**：UIImpactFeedbackGenerator(.light)

### 图层结构

| 图层名 | 时间区间 | 动画属性 | 参数 |
|--------|---------|---------|------|
| heart_outline | 0-80ms | scale, opacity | 1→0, 1→0（淡出消失） |
| heart_fill | 0-500ms | scale, opacity | 0→1.3→1, 0→1 |
| | | easing | cubic-bezier(0.34, 1.56, 0.64, 1) 回弹 |
| particle_1~8 | 200-600ms | translateY, opacity | 0→-40pt, 0→1→0 |
| | | stagger | 依次错开 40ms |

### 时间线

```
0ms ─────── 80ms ──── 200ms ──── 400ms ──── 600ms
│ 空心淡出 │  实心弹入  │  粒子迸发上飘  │  消散定格 │
```

### 设计要点
- 实心爱心颜色：暖杏主色 #E8C4A3
- 粒子为缩小版爱心形状，opacity 渐变 0.8→0
- 触发后立即播放，不可中断

---

## 2. 收藏 / Collect

**使用场景**：治愈空间内容收藏
**总时长**：500ms
**缓动**：easeOutBack
**触觉反馈**：UIImpactFeedbackGenerator(.medium)

### 图层结构

| 图层名 | 时间区间 | 动画属性 | 参数 |
|--------|---------|---------|------|
| star_outline | 0-100ms | scale, rotate | 1→0, 0→360°（旋转消失） |
| star_fill | 80-400ms | scale, opacity | 0→1.2→1, 0→1 |
| | | easing | cubic-bezier(0.34, 1.56, 0.64, 1) 回弹 |
| | | fill | 薄荷绿 #8DD9A8 |
| spark_1~4 | 200-500ms | translate, scale, opacity | 对角扩散, 0→1→0, 0→1→0 |
| glow_ring | 300-500ms | scale, opacity | 0.5→2.5, 0.8→0 |

### 时间线

```
0ms ──── 100ms ──── 250ms ──── 400ms ──── 500ms
│ 旋转消失│   弹入填充  │   闪耀光点  │   定格   │
```

### 设计要点
- 填充星形使用薄荷绿，与 Chip selected 态呼应
- 光点为菱形/圆形混合，四角 45° 分布
- glow_ring 光晕圆环为薄荷绿 opacity 0.3

---

## 3. 共鸣 / Resonance

**使用场景**：共鸣墙专用
**总时长**：800ms
**缓动**：easeOut
**触觉反馈**：UIImpactFeedbackGenerator(.heavy) + CHHapticEngine 波纹模式

### 图层结构

| 图层名 | 时间区间 | 动画属性 | 参数 |
|--------|---------|---------|------|
| ripple_1 | 0-400ms | scale, opacity | 0→3, 0.7→0 |
| ripple_2 | 150-550ms | scale, opacity | 0→3, 0.5→0（延迟 150ms） |
| ripple_3 | 300-700ms | scale, opacity | 0→2.5, 0.3→0（延迟 300ms） |
| heart_1~6 | 200-800ms | translateY, scale, opacity | 0→-72pt, 0→1, 0→1→0 |
| | | stagger | 依次错开 60ms |
| | | translateX | 终点 ±30pt 水平随机偏移 |

### 时间线

```
0ms ── 150ms ── 300ms ── 450ms ── 600ms ── 800ms
│ 波纹1 │ 波纹2 │ 波纹3 │  爱心上浮  │  消散  │
```

### 设计要点
- 波纹为暖杏色填充圆环，stroke-only，逐层淡化
- 爱心粒子颜色渐变：底部 #E8C4A3 → 顶部 #F2DBC9（从暖杏到浅暖杏）
- 三层波纹营造「声波共鸣」物理感
- 爱心粒子终点随机分散，象征情感传递的多向性

---

## 4. 全局微动效规范

| 场景 | 时长 | 缓动 | 备注 |
|------|------|------|------|
| Tab 切换 | 200ms | ease-out | 图标颜色渐变 |
| 卡片按下 | 150ms | ease-out | 背景色过渡 + scale(0.97) |
| Chip 选中 | 200ms | ease-out | 描边→填充切换 |
| 按钮 Pressed | 100ms | ease-in | scale(0.97) + 阴影切换 |
| 按钮 Loading | loop | linear | 旋转 spinner，暖杏色 |
| 输入框 Focus | 200ms | ease-out | 描边色变化 + 外发光渐现 |
| 页面 Push | 350ms | ease-in-out | iOS 原生右滑入 |
| 下拉刷新 | - | spring | 弹性回弹 |

---

## 技术实施建议

1. **Lottie 文件尺寸**：控制在 50KB 以内，确保首次加载流畅
2. **播放模式**：点赞/收藏/共鸣 → `playOnce`；Loading → `loop`
3. **iOS 集成**：使用 `lottie-ios` (Airbnb) 或 `DotLottie`
4. **触觉同步**：在关键帧 callback 中触发 haptic feedback
5. **性能**：预加载常用动效 JSON，避免按需加载延迟
6. **适配**：Lottie 画布尺寸建议 120×120pt @1x，实际显示时缩放到按钮大小
