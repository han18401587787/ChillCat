# 绪安 App 设计标注资源包

> 本资源包从设计稿直接导出，供 iOS Swift/SwiftUI 开发团队使用。

---

## 资源包结构

```
绪安设计标注资源包/
├── DesignTokens.swift          # Swift 可直接引用的颜色/字体/间距/阴影定义
├── icons/                       # SVG 矢量图标（27个）
│   ├── tab-home-active-homepage.svg
│   ├── tab-tree-inactive-homepage.svg
│   ├── tab-resonance-active-resonance.svg
│   ├── nav-back.svg
│   └── ... (共27个)
├── lottie/
│   └── 动效规格说明.md           # Lottie 动效制作参考（图层结构+关键帧+缓动）
└── 设计标注总览.md              # 本文件
```

---

## 一、颜色系统速查

### 主色板

| Token 名 | 色值 | Swift 变量 | 用途 |
|----------|------|-----------|------|
| 暖杏主色 | #E8C4A3 | `.xuanApricot` | 主按钮、Tab active、品牌色 |
| 深暖杏 | #D4A882 | `.xuanApricotDark` | 次按钮文字、强调 |
| 浅暖杏 | #F2DBC9 | `.xuanApricotLight` | 次按钮背景、轻触 |
| 杏白背景 | #FAF3ED | `.xuanApricotBg` | 页面底色 |
| 薄荷绿 | #A8D9BA | `.xuanMint` | AI 标识、标签 Chip |
| 深薄荷 | #7ABF9E | `.xuanMintDark` | AI 发送按钮 |
| 樱花粉 | #F5A6BA | `.xuanPink` | 情绪强调（愤怒维度）|
| 危机红 | #E67373 | `.xuanDanger` | 错误/危机提示 |

### 交互状态色

| 状态 | 色值 | Swift 变量 |
|------|------|-----------|
| 按钮 Pressed | #C49E7D | `.xuanApricotPressed` |
| 按钮 Disabled | #E8C4A3 @ 40% | `.xuanApricotDisabled` |
| 输入框 Focus 描边 | #E8C4A3 | `.xuanInputFocusBorder` |
| 输入框 Error 描边 | #E67373 | `.xuanInputErrorBorder` |
| 卡片 Pressed 底色 | #F5F0EB | `.xuanCardPressed` |

---

## 二、字体规范

| 级别 | 字号 | 字重 | 字体族 | 用��� |
|------|------|------|--------|------|
| H1 | 28pt | Bold | PingFang SC | 大标题 |
| H2 | 22pt | Semibold | PingFang SC | 页面标题 |
| H3 | 18pt | Medium | PingFang SC | 区块标题 |
| Body-L | 16pt | Regular | PingFang SC | 正文主要内容 |
| Body-M | 14pt | Regular | PingFang SC | 次要正文、描述 |
| Body-S | 12pt | Regular | PingFang SC | 辅助说明 |
| Caption | 11pt | Regular | PingFang SC | 时间戳、标签 |

---

## 三、间距系统

| Token | 值 | 使用场景 |
|-------|-----|---------|
| xs | 4pt | 图标与文字间 |
| sm | 8pt | 紧凑元素间距 |
| md | 12pt | 列表行间距 |
| lg | 16pt | 卡片内边距、区块间 |
| xl | 20pt | 区块内部大间隔 |
| 2xl | 24pt | 卡片与屏幕边距 |
| 3xl | 32pt | 大区块间隔 |

---

## 四、圆角系统

| Token | 值 | 使用场景 |
|-------|-----|---------|
| sm | 8pt | 输入框、小按钮 |
| md | 12pt | 标签、选择器 |
| lg | 16pt | 卡片 |
| xl | 20pt | 弹窗、大容器 |
| full | capsule | 主按钮、Tab 胶囊 |

---

## 五、阴影系统

| 名称 | 参数 | Swift 方法 | 使用场景 |
|------|------|-----------|---------|
| card | 0 2px 12px rgba(44,36,22,0.06) | `.xuanCardShadow()` | 卡片默认状态 |
| float | 0 4px 24px rgba(44,36,22,0.10) | `.xuanFloatShadow()` | 弹窗/浮层 |
| press | 0 1px 4px rgba(44,36,22,0.08) | `.xuanPressShadow()` | 按压态 |

---

## 六、图标资源清单

### Tab Bar 图标（5个 Tab × 5种页面状态）

命名规则：`tab-{功能}-{active/inactive}-{所在页面}.svg`

| 功能 | Active 页面 | 尺寸 |
|------|------------|------|
| home | 首页 | 24×24pt |
| tree | 树洞 | 24×24pt |
| resonance | 共鸣墙 | 24×24pt |
| healing | 治愈空间 | 24×24pt |
| profile | 个人中心 | 24×24pt |

### 导航图标

| 文件名 | 用途 | 尺寸 |
|--------|------|------|
| nav-back.svg | 通用返回按钮 | 28×28pt |
| nav-back-report.svg | 情绪报告返回 | 28×28pt |

---

## 七、页面布局参考

### 全局结构

```
┌─────────────────────────┐
│   状态栏 44pt            │
├─────────────────────────┤
│   导航栏 44pt            │
├─────────────────────────┤
│                          │
│   内容区域               │
│   左右 padding: 16pt     │
│   卡片间距: 16pt          │
│                          │
├─────────────────────────┤
│   底部 Tab 栏 83pt       │
│   Tab 胶囊 50pt          │
│   安全区 bottom: 34pt    │
└─────────────────────────┘
```

### 屏幕尺寸基准
- 设计基准：375 × 812pt（iPhone 13 mini 逻辑尺寸）
- 所有元素使用 Auto Layout / SwiftUI 自适应布局

---

## 八、交互状态速查

| 控件 | Default | Pressed | Disabled | 其他 |
|------|---------|---------|----------|------|
| 主按钮 | 暖杏填充 #E8C4A3 | 深暖杏 #C49E7D + press阴影 | 40% opacity | Loading: spinner |
| 次按钮 | 浅暖杏 #F2DBC9 | 深暖杏填充+白字 | 40% opacity | Outline 变体 |
| 输入框 | 暖灰描边 | - | 灰底+40% 文字 | Focused: 暖杏描边+发光, Error: 红描边 |
| Tab 项 | 灰棕图标+浅棕文字 | - | - | Active: 暖杏底色+白色图标 |
| 卡片 | 白底+card阴影 | 暖白底+press阴影 | - | 过渡 150ms |
| Chip 标签 | 白底+薄荷绿描边 | - | - | Selected: 薄荷绿填充+白字 |

---

## 九、动效规格

详见 `lottie/动效规格说明.md`，包含三个互动奖励动效（点赞/收藏/共鸣）的完整 Lottie 图层结构、关键帧时间轴和缓动参数。

---

## 使用说明

1. **DesignTokens.swift** — 直接拖入 Xcode 项目，所有颜色/字体/阴影即可通过 `Color.xuanApricot`、`XuanFont.h1`、`.xuanCardShadow()` 等方式调用
2. **icons/** — SVG 文件导入 Xcode Asset Catalog，建议开启 "Preserve Vector Data" 以支持多分辨率
3. **lottie/** — 将规格交给动效设计师制作 Lottie JSON 文件，或使用 LottieFiles 在线编辑器
