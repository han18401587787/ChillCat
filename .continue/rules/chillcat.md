---
globs: "**/*.swift"
description: ChillCat 工程中所有新增类必须使用 CC 前缀命名
alwaysApply: true
---

ChillCat 工程中所有新增的自定义类必须使用 `CC` 前缀命名。

## 命名规则

1. **所有新增自定义类**必须加 `CC` 前缀
2. **系统类/系统协议**的继承/遵循，类名格式为 `CC{功能描述}{类型}`

## 命名示例

| 类型 | 命名格式 | 示例 |
|------|----------|------|
| ViewController | `CC{功能}ViewController` | `CCHomeViewController`, `CCLoginViewController` |
| View | `CC{功能}View` | `CCHeaderView`, `CCMusicCell` |
| Model | `CC{功能}Model` | `CCUserModel`, `CCSongModel` |
| Manager | `CC{功能}Manager` | `CCNetworkManager`, `CCCacheManager` |
| Service | `CC{功能}Service` | `CCAuthService`, `CCPayService` |
| Helper/Util | `CC{功能}Helper` | `CCDateHelper`, `CCFormatHelper` |
| Protocol | `CC{功能}Protocol` | `CCLoginProtocol`, `CCCacheProtocol` |
| Delegate | `CC{功能}Delegate` | `CCPlayerDelegate` |
| Coordinator | `CC{功能}Coordinator` | `CCAppCoordinator` |
| ViewModel | `CC{功能}ViewModel` | `CCLoginViewModel` |

## 例外情况

以下情况不需要加 `CC` 前缀：
- AppDelegate、SceneDelegate（系统入口，保持原名）
- 纯扩展（extension）文件
- 枚举、结构体等值类型建议也加 `CC` 前缀，保持一致性

## 文件头注释

所有新建类文件头使用：
```
//
//  {文件名}.swift
//  ChillCat
//
//  Created by doudou.han on {真实日期}
//  
//
```