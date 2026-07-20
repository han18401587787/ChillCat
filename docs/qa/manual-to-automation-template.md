# Skill 4: 手工链路 → 自动化链路工程化拆解模板

> 将手工测试步骤转化为可执行、可维护的自动化测试链路

## 拆解原则

1. **粗 → 细**：手工的"搜索商品"在自动化中要拆成 5-7 步
2. **每步有等待**：不用 `sleep()`，用 `waitForExistence` 或显式等待
3. **每步有断言**：不只验证"点过去了"，要验证"到了正确的页面/状态"
4. **失败有截图**：关键步骤失败自动截图
5. **数据可复位**：测试前后数据状态一致

## 拆解模板

### 输入：手工测试描述

```
{手工描述，例如：打开 App → 匿名登录 → 选择"焦虑"情绪 → 写一段话 → 打卡 → 验证打卡成功}
```

### 输出：自动化链路

```swift
// === 链路：{链路名称} ===
// 优先级：P0/P1/P2
// 预计耗时：{N}秒

func test_{链路简称}() {
    let app = XCUIApplication()

    // Step 1: {步骤描述}
    // 等待条件：{等待什么元素出现}
    // 定位方式：accessibilityIdentifier "{identifier}"
    // 断言：{验证什么}
    XCTAssertTrue(app.buttons["{identifier}"].waitForExistence(timeout: {N}))
    app.buttons["{identifier}"].tap()

    // Step 2: ...
    // ...
}
```

## 实际示例：情绪打卡完整链路

### 手工描述
> 打开 App，匿名登录，在首页选择"焦虑"情绪，输入一段感受，点击打卡，验证打卡成功提示出现。

### 自动化拆解

```
Step 1: 等待欢迎页加载
  ├─ 等待条件：welcome_anonymous_entry 出现（timeout: 10s）
  ├─ 定位：app.buttons["welcome_anonymous_entry"]
  ├─ 断言：按钮存在且 enabled
  └─ 操作：tap

Step 2: 等待首页加载
  ├─ 等待条件：home_checkin_button 出现（timeout: 15s）
  ├─ 定位：app.buttons["home_checkin_button"]
  ├─ 断言：首页打卡按钮存在
  └─ 操作：选择情绪按钮 app.buttons["emotion_anxious"]

Step 3: 输入感受
  ├─ 等待条件：checkin_note_field 出现
  ├─ 定位：app.textViews["checkin_note_field"]
  ├─ 断言：输入框可编辑
  └─ 操作：tap → typeText("今天感到有些焦虑...")

Step 4: 点击打卡
  ├─ 等待条件：按钮 enabled（非 disabled）
  ├─ 定位：app.buttons["home_checkin_button"]
  ├─ 断言：按钮存在且 enabled
  └─ 操作：tap

Step 5: 验证打卡成功
  ├─ 等待条件：checkin_success_toast 出现（timeout: 5s）
  ├─ 定位：app.staticTexts["checkin_success_toast"]
  ├─ 断言：成功提示包含"打卡成功"
  └─ 截图：保存成功状态截图
```

### 异常分支处理

| 异常 | 处理方式 |
|------|----------|
| 网络超时 | 等待 30s，失败截图 + 标记 SKIP |
| 已打卡（按钮 disabled） | 断言 disabled 状态，跳过打卡步骤 |
| 情绪按钮不可点击 | 截图当前页面，报告元素状态 |
| 打卡接口返回错误 | 等待 toast 出现，验证错误信息 |

## 链路模板库

### 模板 A：简单导航链路

```
Step 1: 等待起始页加载
Step 2: 点击目标入口
Step 3: 等待目标页加载
Step 4: 断言目标页关键元素存在
```

### 模板 B：表单提交流程

```
Step 1: 等待表单页加载
Step 2: 逐字段输入/选择
Step 3: 验证提交按钮从 disabled → enabled
Step 4: 点击提交
Step 5: 等待成功/失败反馈
Step 6: 验证反馈内容
```

### 模板 C：列表交互流程

```
Step 1: 等待列表页加载
Step 2: 验证列表非空（至少 N 条）
Step 3: 点击第 N 条
Step 4: 等待详情页加载
Step 5: 验证详情内容与列表一致
Step 6: 返回列表
Step 7: 验证列表仍在原位
```

### 模板 D：多步骤向导流程（CBT/BodyScan）

```
Step 1: 等待步骤 1 加载
Step 2: 执行步骤 1 操作
Step 3: 点击"下一步"
Step 4: 等待步骤 2 加载
Step 5: 重复...
Step N: 验证最终结果
```

## 使用方式

1. 复制对应模板
2. 填入具体的 identifier（从 `docs/xctest-identifier-validation.md` 查找）
3. 填入具体的等待时间和断言内容
4. 运行一次确认链路通畅
5. 加入回归测试套件
