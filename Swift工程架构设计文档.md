# Swift 工程架构设计文档

> **版本：** v1.0  
> **作者：** doudou.han  
> **日期：** 2025-07-16  
> **状态：** 初稿

---

## 目录

1. [工程概述](#1-工程概述)
2. [工程架构设计](#2-工程架构设计)
3. [模块化设计](#3-模块化设计)
4. [开发规范](#4-开发规范)
5. [三方库集成策略](#5-三方库集成策略)
6. [UI 架构](#6-ui-架构)
7. [网络层设计](#7-网络层设计)
8. [数据持久化](#8-数据持久化)
9. [依赖注入与容器](#9-依赖注入与容器)
10. [错误处理与日志](#10-错误处理与日志)
11. [测试策略](#11-测试策略)
12. [CI/CD 与自动化](#12-cicd-与自动化)
13. [可维护性与可扩展性](#13-可维护性与可扩展性)
14. [附录](#14-附录)

---

## 1. 工程概述

### 1.1 项目定位

本文档旨在为新建 Swift 工程提供一套完整、可落地的架构设计指南。涵盖从项目初始化、模块划分、编码规范到持续集成的全生命周期管理，确保工程具备 **高内聚、低耦合、易测试、可扩展** 的特性。

### 1.2 设计原则

| 原则 | 说明 |
|------|------|
| **单一职责** | 每个模块/类只负责一个明确的职责 |
| **依赖反转** | 依赖抽象而非具体实现，通过协议解耦 |
| **接口隔离** | 协议应小而专，避免胖协议 |
| **开闭原则** | 对扩展开放，对修改封闭 |
| **最少知识** | 模块间通过明确的接口通信，减少直接依赖 |

### 1.3 技术栈选型

| 类别 | 选型 | 说明 |
|------|------|------|
| 语言 | Swift 5.9+ | 使用最新 Swift 特性（Macro、Concurrency） |
| 最低部署 | iOS 15.0+ | 覆盖主流设备 |
| UI 框架 | SwiftUI + UIKit 混编 | SwiftUI 主导，UIKit 处理复杂交互 |
| 架构模式 | MVVM + Coordinator | 视图与逻辑分离，路由统一管理 |
| 依赖管理 | Swift Package Manager (SPM) | 官方推荐，原生支持 |
| 构建工具 | XcodeGen / Tuist | 工程文件自动化生成 |
| 包管理 | SPM | 统一管理内部和外部依赖 |

---

## 2. 工程架构设计

### 2.1 整体架构分层

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │  Views /  │  │ViewModels│  │   Coordinators /     │  │
│  │ SwiftUI   │  │          │  │    Routers           │  │
│  └──────────┘  └──────────┘  └──────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                     Domain Layer                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │  UseCases │  │ Entities │  │   RepositoryProtocols│  │
│  └──────────┘  └──────────┘  └──────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                      Data Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │Repositories│  │  DTOs   │  │  DataSources         │  │
│  │           │  │          │  │  (API/Local/Cloud)   │  │
│  └──────────┘  └──────────┘  └──────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                   Core / Foundation Layer                │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │ Networking│  │ Storage  │  │  Extensions / Utils  │  │
│  └──────────┘  └──────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

#### 2.1.1 分层职责

**Core / Foundation Layer（核心基础层）**
- 网络请求封装（URLSession + async/await）
- 本地存储封装（UserDefaults / Keychain / CoreData / SwiftData）
- 通用工具类与扩展（Date、String、Color 等）
- 日志系统
- 第三方 SDK 封装层

**Data Layer（数据层）**
- Repository 实现（实现 Domain 层定义的协议）
- DTO（Data Transfer Object）与 Entity 的映射转换
- 数据源管理（RemoteDataSource / LocalDataSource）
- 缓存策略

**Domain Layer（领域层）**
- UseCases（业务用例）
- Entities（核心业务实体）
- RepositoryProtocols（数据仓库协议）
- 纯业务逻辑，不依赖任何 UIKit/SwiftUI

**Presentation Layer（展示层）**
- Views（SwiftUI View / UIKit ViewController）
- ViewModels（状态管理，@Observable / ObservableObject）
- Coordinators / Routers（页面路由与导航）
- 仅依赖 Domain 层

### 2.2 目录结构

```
ProjectName/
├── App/
│   ├── App.swift                    # App 入口
│   ├── AppDelegate.swift            # AppDelegate（如需）
│   ├── SceneDelegate.swift          # SceneDelegate（如需）
│   └── AppDependencyContainer.swift # 全局依赖容器
│
├── Core/
│   ├── Networking/
│   │   ├── APIClient.swift          # 网络请求客户端
│   │   ├── APIEndpoint.swift        # API 端点协议
│   │   ├── APIError.swift           # 网络错误定义
│   │   ├── RequestInterceptor.swift # 请求拦截器（鉴权、重试）
│   │   └── NetworkLogger.swift      # 网络日志
│   │
│   ├── Storage/
│   │   ├── KeychainManager.swift    # 钥匙串管理
│   │   ├── UserDefaultsManager.swift
│   │   ├── CacheManager.swift       # 缓存管理
│   │   └── Database/
│   │       ├── DatabaseManager.swift
│   │       └── Models/
│   │
│   ├── Logging/
│   │   ├── Logger.swift             # 日志系统
│   │   └── LogFormatter.swift
│   │
│   ├── Extensions/
│   │   ├── Foundation+Extensions.swift
│   │   ├── SwiftUI+Extensions.swift
│   │   └── UIKit+Extensions.swift
│   │
│   └── Helpers/
│       ├── Constants.swift
│       ├── Environment.swift        # 环境配置
│       └── ReachabilityManager.swift
│
├── Domain/
│   ├── Entities/
│   │   ├── User.swift
│   │   └── ... (业务实体)
│   │
│   ├── UseCases/
│   │   ├── LoginUseCase.swift
│   │   └── ... (业务用例)
│   │
│   └── RepositoryProtocols/
│       ├── UserRepositoryProtocol.swift
│       └── ... (仓库协议)
│
├── Data/
│   ├── Repositories/
│   │   ├── UserRepository.swift
│   │   └── ... (仓库实现)
│   │
│   ├── DataSources/
│   │   ├── Remote/
│   │   │   ├── UserRemoteDataSource.swift
│   │   │   └── ... (远程数据源)
│   │   └── Local/
│   │       ├── UserLocalDataSource.swift
│   │       └── ... (本地数据源)
│   │
│   └── DTOs/
│       ├── UserDTO.swift
│       ├── DTOMapper.swift          # DTO 转 Entity 映射
│       └── ... (数据传输对象)
│
├── Presentation/
│   ├── Common/
│   │   ├── Components/              # 公共 UI 组件
│   │   │   ├── LoadingView.swift
│   │   │   ├── ErrorView.swift
│   │   │   ├── EmptyStateView.swift
│   │   │   └── ...
│   │   ├── Modifiers/               # ViewModifier
│   │   └── Styles/                  # 样式定义
│   │       ├── AppColors.swift
│   │       ├── AppFonts.swift
│   │       └── AppTheme.swift
│   │
│   ├── Modules/                     # 按功能模块划分
│   │   ├── Auth/
│   │   │   ├── Views/
│   │   │   │   ├── LoginView.swift
│   │   │   │   └── RegisterView.swift
│   │   │   ├── ViewModels/
│   │   │   │   ├── LoginViewModel.swift
│   │   │   │   └── RegisterViewModel.swift
│   │   │   └── Coordinators/
│   │   │       └── AuthCoordinator.swift
│   │   │
│   │   ├── Home/
│   │   │   ├── Views/
│   │   │   ├── ViewModels/
│   │   │   └── Coordinators/
│   │   │
│   │   └── Profile/
│   │       ├── Views/
│   │       ├── ViewModels/
│   │       └── Coordinators/
│   │
│   └── Navigation/
│       ├── AppCoordinator.swift      # 根协调器
│       ├── DeepLinkHandler.swift     # 深度链接处理
│       └── NavigationRoute.swift     # 路由定义
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Colors.xcassets
│   ├── Fonts/
│   ├── Localization/
│   │   ├── en.lproj/
│   │   └── zh-Hans.lproj/
│   ├── LaunchScreen.storyboard
│   └── Info.plist
│
├── Tests/
│   ├── UnitTests/
│   │   ├── Domain/
│   │   ├── Data/
│   │   └── Presentation/
│   │
│   ├── IntegrationTests/
│   │   └── ...
│   │
│   └── UITests/
│       └── ...
│
├── Mocks/
│   ├── Domain/
│   └── Data/
│
├── Scripts/
│   ├── generate_module.sh
│   ├── lint.sh
│   └── build.sh
│
├── Package.swift                     # SPM 本地包（可选）
├── Project.swift                     # Tuist 配置（如使用）
├── project.yml                       # XcodeGen 配置（如使用）
├── .swiftlint.yml                    # SwiftLint 配置
├── .swiftformat                     # SwiftFormat 配置
└── README.md
```

---

## 3. 模块化设计

### 3.1 模块化策略

采用 **Feature Module（功能模块）** 模式，每个功能模块是一个独立的 SPM 包，包含自己的 Presentation、Domain、Data 三层。

#### 3.1.1 模块划分示例

```
App（主工程）
├── CoreModule          # 基础能力：网络、存储、日志
├── CommonUIModule      # 公共 UI 组件、主题、样式
├── AuthModule          # 登录/注册模块
├── HomeModule          # 首页模块
├── ProfileModule       # 个人中心模块
├── SearchModule        # 搜索模块
└── ...                 # 其他功能模块
```

#### 3.1.2 模块间依赖规则

```
App → CoreModule
App → CommonUIModule
App → AuthModule
App → HomeModule
App → ProfileModule

AuthModule → CoreModule
HomeModule → CoreModule
HomeModule → CommonUIModule
ProfileModule → CoreModule
ProfileModule → CommonUIModule
```

**禁止：**
- 模块间循环依赖
- 业务模块之间直接依赖（如 HomeModule → ProfileModule）
- 跨模块直接引用内部类型

**模块间通信方式：**
- **协议/接口**：模块定义协议，通过依赖注入传递实现
- **事件总线**：用于松耦合的跨模块事件通知
- **Coordinator**：模块间的页面跳转由上层 Coordinator 编排

### 3.2 模块模板

每个 Feature Module 的标准结构：

```
FeatureModule/
├── Sources/
│   ├── Domain/
│   │   ├── Entities/
│   │   ├── UseCases/
│   │   └── RepositoryProtocols/
│   ├── Data/
│   │   ├── Repositories/
│   │   ├── DataSources/
│   │   └── DTOs/
│   └── Presentation/
│       ├── Views/
│       ├── ViewModels/
│       └── Coordinators/
├── Tests/
├── Package.swift
└── README.md
```

---

## 4. 开发规范

### 4.1 Swift 编码规范

#### 4.1.1 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 类/结构体/枚举 | PascalCase | `UserManager`, `LoginView` |
| 协议 | PascalCase | `UserRepositoryProtocol` |
| 方法/属性/变量 | camelCase | `fetchUser()`, `userName` |
| 枚举 case | camelCase | `.success`, `.networkError` |
| 静态常量 | camelCase | `static let defaultTimeout = 30.0` |
| 泛型参数 | 大写单字母/描述性 | `T`, `Element`, `RequestType` |

#### 4.1.2 代码组织

```swift
// MARK: - 文件头注释
//
//  LoginViewModel.swift
//  ProjectName
//
//  Created by doudou.han on 2025-07-16.
//

import Foundation

// MARK: - Protocol
protocol LoginViewModelProtocol: AnyObject {
    var state: LoginState { get }
    func login(username: String, password: String) async
}

// MARK: - State
struct LoginState {
    var isLoading = false
    var error: Error?
    var isLoggedIn = false
}

// MARK: - Class
final class LoginViewModel: LoginViewModelProtocol {
    // MARK: - Dependencies
    private let loginUseCase: LoginUseCaseProtocol

    // MARK: - Properties
    @Published private(set) var state = LoginState()

    // MARK: - Initialization
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    // MARK: - Public Methods
    func login(username: String, password: String) async {
        state.isLoading = true
        defer { state.isLoading = false }

        do {
            try await loginUseCase.execute(username: username, password: password)
            state.isLoggedIn = true
        } catch {
            state.error = error
        }
    }

    // MARK: - Private Methods
    private func validateInput(_ username: String, _ password: String) -> Bool {
        !username.isEmpty && !password.isEmpty
    }
}
```

#### 4.1.3 SwiftLint 规则

```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
  - identifier_name
  - force_cast

opt_in_rules:
  - empty_count
  - explicit_init
  - closure_spacing
  - overridden_super_call
  - redundant_nil_coalescing
  - sorted_imports
  - yoda_condition

line_length: 120
file_length:
  warning: 400
  error: 600
type_body_length:
  warning: 300
  error: 500
function_body_length:
  warning: 50
  error: 100
```

### 4.2 Git 规范

#### 4.2.1 分支策略

```
main          # 生产分支
├── develop   # 开发主分支
│   ├── feature/xxx    # 功能分支
│   ├── bugfix/xxx     # Bug 修复分支
│   └── refactor/xxx   # 重构分支
├── release/x.y.z      # 发布分支
└── hotfix/xxx         # 紧急修复分支
```

#### 4.2.2 Commit Message 规范

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型：**
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试
- `chore`: 构建/工具
- `ci`: CI 配置

**示例：**
```
feat(auth): 添加手机号登录功能

- 支持手机号+验证码登录
- 支持手机号+密码登录
- 添加登录状态持久化

Closes #123
```

### 4.3 代码审查 Checklist

- [ ] 代码符合命名规范和代码组织规范
- [ ] 没有强制解包（force unwrap）
- [ ] 没有循环引用（weak/unowned 使用正确）
- [ ] 异步操作有正确的错误处理
- [ ] 协议定义合理，没有胖协议
- [ ] 单元测试覆盖了核心逻辑
- [ ] 没有硬编码的字符串/数字（使用常量或枚举）
- [ ] 没有遗留的 TODO/FIXME 未处理
- [ ] 公共 API 有文档注释
- [ ] 没有引入不必要的依赖

---

## 5. 三方库集成策略

### 5.1 集成原则

1. **必要性**：优先使用系统 API，确需三方库时再引入
2. **稳定性**：选择活跃维护、社区广泛使用的库
3. **抽象隔离**：三方库通过封装层隔离，便于替换
4. **版本锁定**：锁定主版本号，避免破坏性更新
5. **最小引入**：只引入需要的子模块

### 5.2 推荐三方库清单

| 类别 | 库名 | 用途 | 替代方案 |
|------|------|------|----------|
| **网络** | Alamofire | HTTP 请求封装 | 系统 URLSession |
| **图片加载** | Kingfisher | 异步图片加载/缓存 | Nuke, SDWebImage |
| **JSON 解析** | SwiftyJSON / Codable | JSON 序列化 | 系统 Codable |
| **数据库** | SwiftData / CoreData | 本地持久化 | GRDB, Realm |
| **响应式** | Combine（系统） | 响应式编程 | RxSwift |
| **日志** | SwiftyBeaver / OSLog | 日志系统 | 系统 OSLog |
| **路由** | SwiftUI Navigation（系统） | 页面路由 | Coordinator |
| **依赖注入** | Factory / Swinject | DI 容器 | 手动注入 |
| **UI 组件** | SwiftUI（系统） | UI 构建 | UIKit |
| **测试** | XCTest（系统） | 单元测试 | Quick/Nimble |
| **快照测试** | SnapshotTesting | UI 快照测试 | - |
| **代码规范** | SwiftLint | 代码规范检查 | - |
| **代码格式化** | SwiftFormat | 代码格式化 | - |
| **HUD** | ProgressHUD | 加载提示 | SVProgressHUD |
| **Toast** | ToastUI / 自实现 | 轻提示 | - |
| **WebView** | WKWebView（系统） | 网页加载 | - |

### 5.3 三方库封装示例

#### 网络层封装

```swift
// Core/Networking/APIClient.swift

import Foundation

/// 网络请求客户端协议
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func request(_ endpoint: APIEndpoint) async throws -> Data
}

/// API 端点协议
protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Encodable? { get }
    var queryParameters: [String: String]? { get }
    var timeout: TimeInterval { get }
}

extension APIEndpoint {
    var timeout: TimeInterval { 30 }
    var headers: [String: String]? { nil }
    var body: Encodable? { nil }
    var queryParameters: [String: String]? { nil }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// 网络客户端实现
final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let interceptor: RequestInterceptor?
    private let logger: NetworkLogger?

    init(
        session: URLSession = .shared,
        interceptor: RequestInterceptor? = nil,
        logger: NetworkLogger? = NetworkLogger()
    ) {
        self.session = session
        self.interceptor = interceptor
        self.logger = logger
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await request(endpoint)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    func request(_ endpoint: APIEndpoint) async throws -> Data {
        var request = try buildRequest(from: endpoint)

        // 拦截器处理
        if let interceptor = interceptor {
            request = try await interceptor.intercept(request)
        }

        logger?.log(request: request)

        let (data, response) = try await session.data(for: request)

        logger?.log(response: response, data: data)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        try validateResponse(httpResponse)

        // 拦截器后处理
        if let interceptor = interceptor {
            try await interceptor.handle(response: httpResponse, data: data)
        }

        return data
    }

    private func buildRequest(from endpoint: APIEndpoint) throws -> URLRequest {
        var components = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path),
                                        resolvingAgainstBaseURL: false)
        if let queryParameters = endpoint.queryParameters {
            components?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = endpoint.timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        endpoint.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        return request
    }

    private func validateResponse(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError(response.statusCode)
        default:
            throw APIError.unexpectedStatusCode(response.statusCode)
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case networkFailure(Error)
    case decodingFailure(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "无效的响应"
        case .unauthorized:
            return "未授权，请重新登录"
        case .forbidden:
            return "无权限访问"
        case .notFound:
            return "资源不存在"
        case .serverError(let code):
            return "服务器错误 (\(code))"
        case .unexpectedStatusCode(let code):
            return "意外的状态码 (\(code))"
        case .networkFailure(let error):
            return "网络错误: \(error.localizedDescription)"
        case .decodingFailure(let error):
            return "数据解析失败: \(error.localizedDescription)"
        }
    }
}
```

#### 图片加载封装

```swift
// Core/ImageLoader.swift

import SwiftUI

/// 图片加载器协议
protocol ImageLoaderProtocol {
    func loadImage(from url: URL) async throws -> UIImage
    func prefetchImages(urls: [URL]) async
    func clearCache()
}

/// 图片加载器实现（使用 Kingfisher 或系统 URLSession）
final class ImageLoader: ImageLoaderProtocol {
    private let cache = NSCache<NSURL, UIImage>()

    func loadImage(from url: URL) async throws -> UIImage {
        // 先查缓存
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        // 网络加载
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageLoaderError.invalidData
        }

        // 写入缓存
        cache.setObject(image, forKey: url as NSURL)
        return image
    }

    func prefetchImages(urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    _ = try? await self.loadImage(from: url)
                }
            }
        }
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}

enum ImageLoaderError: Error {
    case invalidData
}
```

---

## 6. UI 架构

### 6.1 SwiftUI + MVVM 模式

#### 6.1.1 状态管理

```swift
// 使用 @Observable（iOS 17+）
@Observable
final class HomeViewModel {
    var items: [Item] = []
    var isLoading = false
    var error: Error?

    private let fetchItemsUseCase: FetchItemsUseCaseProtocol

    init(fetchItemsUseCase: FetchItemsUseCaseProtocol) {
        self.fetchItemsUseCase = fetchItemsUseCase
    }

    @MainActor
    func loadItems() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await fetchItemsUseCase.execute()
        } catch {
            self.error = error
        }
    }
}

// View 层
struct HomeView: View {
    @State private var viewModel: HomeViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if let error = viewModel.error {
                ErrorView(error: error, retryAction: {
                    await viewModel.loadItems()
                })
            } else {
                List(viewModel.items) { item in
                    ItemRow(item: item)
                }
            }
        }
        .task {
            await viewModel.loadItems()
        }
    }
}
```

#### 6.1.2 页面路由（Coordinator）

```swift
// Presentation/Navigation/AppCoordinator.swift

import SwiftUI

/// 路由定义
enum AppRoute: Hashable {
    case login
    case home
    case profile
    case detail(id: String)
    case settings
}

/// 根协调器
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var presentedRoute: AppRoute?

    private let diContainer: DIContainerProtocol

    init(diContainer: DIContainerProtocol) {
        self.diContainer = diContainer
    }

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func present(_ route: AppRoute) {
        presentedRoute = route
    }

    func dismiss() {
        presentedRoute = nil
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    @ViewBuilder
    func buildView(for route: AppRoute) -> some View {
        switch route {
        case .login:
            let vm = LoginViewModel(loginUseCase: diContainer.resolve())
            LoginView(viewModel: vm, coordinator: self)
        case .home:
            let vm = HomeViewModel(fetchItemsUseCase: diContainer.resolve())
            HomeView(viewModel: vm, coordinator: self)
        case .profile:
            let vm = ProfileViewModel(userRepository: diContainer.resolve())
            ProfileView(viewModel: vm, coordinator: self)
        case .detail(let id):
            let vm = DetailViewModel(itemId: id, fetchDetailUseCase: diContainer.resolve())
            DetailView(viewModel: vm, coordinator: self)
        case .settings:
            SettingsView(coordinator: self)
        }
    }
}

// App 入口
struct ProjectApp: App {
    @StateObject private var coordinator: AppCoordinator

    init() {
        let diContainer = AppDependencyContainer()
        _coordinator = StateObject(wrappedValue: AppCoordinator(diContainer: diContainer))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                coordinator.buildView(for: .home)
                    .navigationDestination(for: AppRoute.self) { route in
                        coordinator.buildView(for: route)
                    }
                    .sheet(item: $coordinator.presentedRoute) { route in
                        coordinator.buildView(for: route)
                    }
            }
            .environmentObject(coordinator)
        }
    }
}
```

### 6.2 主题与样式系统

```swift
// Presentation/Common/Styles/AppTheme.swift

import SwiftUI

/// 应用主题协议
protocol AppThemeProtocol {
    // 颜色
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var backgroundColor: Color { get }
    var surfaceColor: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var errorColor: Color { get }

    // 字体
    var titleFont: Font { get }
    var bodyFont: Font { get }
    var captionFont: Font { get }

    // 间距
    var smallSpacing: CGFloat { get }
    var mediumSpacing: CGFloat { get }
    var largeSpacing: CGFloat { get }

    // 圆角
    var smallCornerRadius: CGFloat { get }
    var mediumCornerRadius: CGFloat { get }
    var largeCornerRadius: CGFloat { get }
}

/// 亮色主题
struct LightTheme: AppThemeProtocol {
    let primaryColor = Color.blue
    let secondaryColor = Color.orange
    let backgroundColor = Color(.systemBackground)
    let surfaceColor = Color(.secondarySystemBackground)
    let textPrimary = Color(.label)
    let textSecondary = Color(.secondaryLabel)
    let errorColor = Color.red

    let titleFont = Font.title
    let bodyFont = Font.body
    let captionFont = Font.caption

    let smallSpacing: CGFloat = 8
    let mediumSpacing: CGFloat = 16
    let largeSpacing: CGFloat = 24

    let smallCornerRadius: CGFloat = 4
    let mediumCornerRadius: CGFloat = 8
    let largeCornerRadius: CGFloat = 16
}

/// 暗色主题
struct DarkTheme: AppThemeProtocol {
    // ... 暗色配置
}

/// 主题环境值
struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppThemeProtocol = LightTheme()
}

extension EnvironmentValues {
    var appTheme: AppThemeProtocol {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// 使用示例
struct SomeView: View {
    @Environment(\.appTheme) var theme

    var body: some View {
        VStack(spacing: theme.mediumSpacing) {
            Text("标题")
                .font(theme.titleFont)
                .foregroundColor(theme.textPrimary)
            Text("内容")
                .font(theme.bodyFont)
                .foregroundColor(theme.textSecondary)
        }
        .padding(theme.largeSpacing)
        .background(theme.surfaceColor)
        .cornerRadius(theme.mediumCornerRadius)
    }
}
```

---

## 7. 网络层设计

### 7.1 网络架构

```
┌──────────────────────────────────────────────────┐
│                   ViewModel                       │
│         (调用 UseCase，不直接调用网络)              │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│                   UseCase                         │
│           (业务逻辑编排，调用 Repository)           │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│                  Repository                       │
│       (数据源选择：Remote / Local / Cache)         │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│              RemoteDataSource                     │
│         (调用 APIClient，DTO 转换)                 │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│                  APIClient                        │
│   (URLSession + async/await，请求/响应处理)        │
└──────────────────────────────────────────────────┘
```

### 7.2 API 端点定义

```swift
// Core/Networking/APIEndpoint.swift

enum UserAPI {
    case login(username: String, password: String)
    case profile
    case updateProfile(name: String, avatar: Data?)
    case logout
}

extension UserAPI: APIEndpoint {
    var baseURL: URL {
        // 根据环境返回不同 baseURL
        return Environment.current.baseURL
    }

    var path: String {
        switch self {
        case .login: return "/v1/auth/login"
        case .profile: return "/v1/user/profile"
        case .updateProfile: return "/v1/user/profile"
        case .logout: return "/v1/auth/logout"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .updateProfile: return .post
        case .profile, .logout: return .get
        }
    }

    var body: Encodable? {
        switch self {
        case .login(let username, let password):
            return ["username": username, "password": password]
        case .updateProfile(let name, _):
            return ["name": name]
        default:
            return nil
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        default: return nil
        }
    }
}
```

### 7.3 请求拦截器

```swift
// Core/Networking/RequestInterceptor.swift

protocol RequestInterceptor {
    /// 请求发送前拦截（如添加 Token）
    func intercept(_ request: URLRequest) async throws -> URLRequest
    /// 响应处理（如 Token 刷新）
    func handle(response: HTTPURLResponse, data: Data) async throws
}

/// Token 拦截器
final class TokenInterceptor: RequestInterceptor {
    private let tokenProvider: TokenProviderProtocol

    init(tokenProvider: TokenProviderProtocol) {
        self.tokenProvider = tokenProvider
    }

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        guard let token = await tokenProvider.getAccessToken() else {
            return request
        }
        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return modifiedRequest
    }

    func handle(response: HTTPURLResponse, data: Data) async throws {
        if response.statusCode == 401 {
            // Token 过期，尝试刷新
            try await tokenProvider.refreshToken()
        }
    }
}
```

### 7.4 环境配置

```swift
// Core/Helpers/Environment.swift

enum Environment {
    case development
    case staging
    case production

    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://dev-api.example.com")!
        case .staging:
            return URL(string: "https://staging-api.example.com")!
        case .production:
            return URL(string: "https://api.example.com")!
        }
    }

    var logLevel: LogLevel {
        switch self {
        case .development: return .debug
        case .staging: return .info
        case .production: return .error
        }
    }

    var isDebugMode: Bool {
        switch self {
        case .development: return true
        case .staging, .production: return false
        }
    }
}
```

---

## 8. 数据持久化

### 8.1 持久化策略

| 数据类型 | 存储方式 | 说明 |
|----------|----------|------|
| 用户 Token | Keychain | 安全存储敏感数据 |
| 用户偏好 | UserDefaults / @AppStorage | 简单配置项 |
| 业务数据 | SwiftData / CoreData | 结构化数据持久化 |
| 缓存数据 | NSCache / 文件缓存 | 临时缓存 |
| 大文件 | FileManager | 图片、视频等 |

### 8.2 Keychain 封装

```swift
// Core/Storage/KeychainManager.swift

import Foundation
import Security

protocol KeychainManagerProtocol {
    func set(_ value: String, for key: String) throws
    func get(_ key: String) throws -> String?
    func delete(_ key: String) throws
    func clear() throws
}

final class KeychainManager: KeychainManagerProtocol {
    private let service: String

    init(service: String = Bundle.main.bundleIdentifier ?? "com.example.app") {
        self.service = service
    }

    func set(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        // 先删除已有项
        try? delete(key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func get(_ key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.readFailed(status)
        }

        return String(data: data, encoding: .utf8)
    }

    func delete(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

enum KeychainError: LocalizedError {
    case encodingFailed
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "数据编码失败"
        case .saveFailed(let status): return "Keychain 保存失败: \(status)"
        case .readFailed(let status): return "Keychain 读取失败: \(status)"
        case .deleteFailed(let status): return "Keychain 删除失败: \(status)"
        }
    }
}
```

### 8.3 缓存策略

```swift
// Core/Storage/CacheManager.swift

import Foundation

protocol CacheManagerProtocol {
    func object<T: Codable>(for key: String) throws -> T?
    func set<T: Codable>(_ object: T, for key: String, expiry: CacheExpiry) throws
    func remove(for key: String)
    func clear()
}

enum CacheExpiry {
    case never
    case seconds(TimeInterval)
    case minutes(TimeInterval)
    case hours(TimeInterval)
    case days(TimeInterval)

    var timeInterval: TimeInterval {
        switch self {
        case .never: return .infinity
        case .seconds(let s): return s
        case .minutes(let m): return m * 60
        case .hours(let h): return h * 3600
        case .days(let d): return d * 86400
        }
    }
}

final class CacheManager: CacheManagerProtocol {
    private let cache = NSCache<NSString, CacheEntry>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    init(cacheName: String = "default") {
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(cacheName, isDirectory: true)

        try? fileManager.createDirectory(at: cacheDirectory,
                                         withIntermediateDirectories: true)

        // 内存缓存配置
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    func object<T: Codable>(for key: String) throws -> T? {
        let sanitizedKey = sanitize(key)

        // 检查内存缓存
        if let entry = cache.object(forKey: sanitizedKey as NSString) {
            if entry.isExpired {
                cache.removeObject(forKey: sanitizedKey as NSString)
                return nil
            }
            return entry.value as? T
        }

        // 检查磁盘缓存
        let fileURL = cacheDirectory.appendingPathComponent(sanitizedKey)
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let entry = try decoder.decode(CacheEntry.self, from: data)

        if entry.isExpired {
            try? fileManager.removeItem(at: fileURL)
            return nil
        }

        // 写回内存缓存
        cache.setObject(entry, forKey: sanitizedKey as NSString)

        return entry.value as? T
    }

    func set<T: Codable>(_ object: T, for key: String, expiry: CacheExpiry) throws {
        let sanitizedKey = sanitize(key)
        let entry = CacheEntry(value: object, expiryDate: Date().addingTimeInterval(expiry.timeInterval))

        // 写入内存缓存
        cache.setObject(entry, forKey: sanitizedKey as NSString)

        // 写入磁盘缓存
        let fileURL = cacheDirectory.appendingPathComponent(sanitizedKey)
        let encoder = JSONEncoder()
        let data = try encoder.encode(entry)
        try data.write(to: fileURL, options: .atomic)
    }

    func remove(for key: String) {
        let sanitizedKey = sanitize(key)
        cache.removeObject(forKey: sanitizedKey as NSString)

        let fileURL = cacheDirectory.appendingPathComponent(sanitizedKey)
        try? fileManager.removeItem(at: fileURL)
    }

    func clear() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory,
                                         withIntermediateDirectories: true)
    }

    private func sanitize(_ key: String) -> String {
        key.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
    }
}

// MARK: - Cache Entry

final class CacheEntry: NSObject, Codable {
    let data: Data
    let expiryDate: Date

    var isExpired: Bool {
        Date() > expiryDate
    }

    var value: Any? {
        try? JSONSerialization.jsonObject(with: data, options: [])
    }

    init<T: Codable>(value: T, expiryDate: Date) {
        self.data = (try? JSONEncoder().encode(value)) ?? Data()
        self.expiryDate = expiryDate
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(Data.self, forKey: .data)
        expiryDate = try container.decode(Date.self, forKey: .expiryDate)
    }

    enum CodingKeys: String, CodingKey {
        case data, expiryDate
    }
}
```

---

## 9. 依赖注入与容器

### 9.1 依赖注入容器

```swift
// App/AppDependencyContainer.swift

import Foundation

/// 依赖容器协议
protocol DIContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func register<T>(_ type: T.Type, name: String, factory: @escaping () -> T)
    func resolve<T>() -> T
    func resolve<T>(_ name: String) -> T?
}

/// 依赖容器实现
final class DIContainer: DIContainerProtocol {
    private var factories: [String: () -> Any] = [:]
    private var singletons: [String: Any] = [:]
    private let lock = NSLock()

    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        lock.withLock {
            factories[key] = factory
        }
    }

    func register<T>(_ type: T.Type, name: String, factory: @escaping () -> T) {
        let key = "\(String(describing: type))_\(name)"
        lock.withLock {
            factories[key] = factory
        }
    }

    func registerSingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = "singleton_\(String(describing: type))"
        lock.withLock {
            singletons[key] = factory()
        }
    }

    func resolve<T>() -> T {
        let key = String(describing: T.self)

        // 先查单例
        let singletonKey = "singleton_\(key)"
        if let instance = lock.withLock({ singletons[singletonKey] }) as? T {
            return instance
        }

        // 再查工厂
        guard let factory = lock.withLock({ factories[key] }),
              let instance = factory() as? T else {
            fatalError("Dependency \(key) not registered")
        }
        return instance
    }

    func resolve<T>(_ name: String) -> T? {
        let key = "\(String(describing: T.self))_\(name)"
        return lock.withLock { factories[key]?() } as? T
    }
}

// MARK: - 容器组装

final class AppDependencyContainer {
    let container: DIContainer

    init() {
        container = DIContainer()
        registerDependencies()
    }

    private func registerDependencies() {
        // Core Services
        container.registerSingleton(APIClientProtocol.self) {
            APIClient(interceptor: TokenInterceptor(
                tokenProvider: self.container.resolve()
            ))
        }

        container.registerSingleton(TokenProviderProtocol.self) {
            TokenProvider(keychainManager: self.container.resolve())
        }

        container.registerSingleton(KeychainManagerProtocol.self) {
            KeychainManager()
        }

        container.registerSingleton(CacheManagerProtocol.self) {
            CacheManager(cacheName: "app_cache")
        }

        container.registerSingleton(LoggerProtocol.self) {
            Logger()
        }

        // Repositories
        container.register(UserRepositoryProtocol.self) {
            UserRepository(
                remoteDataSource: UserRemoteDataSource(
                    apiClient: self.container.resolve()
                ),
                localDataSource: UserLocalDataSource(
                    keychainManager: self.container.resolve()
                )
            )
        }

        // UseCases
        container.register(LoginUseCaseProtocol.self) {
            LoginUseCase(userRepository: self.container.resolve())
        }

        container.register(FetchItemsUseCaseProtocol.self) {
            FetchItemsUseCase(itemRepository: self.container.resolve())
        }
    }
}
```

---

## 10. 错误处理与日志

### 10.1 统一错误处理

```swift
// Core/Helpers/AppError.swift

import Foundation

/// 应用级错误
enum AppError: LocalizedError {
    // 网络错误
    case network(APIError)
    // 业务错误
    case business(code: Int, message: String)
    // 数据错误
    case data(Error)
    // 认证错误
    case authentication
    // 未知错误
    case unknown(Error?)

    var errorDescription: String? {
        switch self {
        case .network(let apiError):
            return apiError.errorDescription
        case .business(_, let message):
            return message
        case .data(let error):
            return "数据处理错误: \(error.localizedDescription)"
        case .authentication:
            return "请先登录"
        case .unknown(let error):
            return error?.localizedDescription ?? "未知错误"
        }
    }

    var errorCode: Int {
        switch self {
        case .network(let apiError):
            switch apiError {
            case .unauthorized: return 401
            case .serverError(let code): return code
            default: return -1
            }
        case .business(let code, _): return code
        case .authentication: return 401
        default: return -9999
        }
    }
}

/// Result 类型别名
typealias AppResult<T> = Result<T, AppError>

/// 异步抛出扩展
extension AppError {
    static func from(_ error: Error) -> AppError {
        switch error {
        case let appError as AppError:
            return appError
        case let apiError as APIError:
            return .network(apiError)
        default:
            return .unknown(error)
        }
    }
}
```

### 10.2 日志系统

```swift
// Core/Logging/Logger.swift

import Foundation
import OSLog

/// 日志级别
enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3

    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var label: String {
        switch self {
        case .debug: return "🔍 DEBUG"
        case .info: return "ℹ️ INFO"
        case .warning: return "⚠️ WARNING"
        case .error: return "❌ ERROR"
        }
    }
}

/// 日志协议
protocol LoggerProtocol {
    func debug(_ message: String, file: String, function: String, line: Int)
    func info(_ message: String, file: String, function: String, line: Int)
    func warning(_ message: String, file: String, function: String, line: Int)
    func error(_ message: String, file: String, function: String, line: Int)
}

/// 日志实现
final class Logger: LoggerProtocol {
    private let osLog: OSLog
    private let minLevel: LogLevel
    private let dateFormatter: DateFormatter
    private let queue = DispatchQueue(label: "com.app.logger", qos: .utility)

    init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.app",
         category: String = "default",
         minLevel: LogLevel = Environment.current.logLevel) {
        self.osLog = OSLog(subsystem: subsystem, category: category)
        self.minLevel = minLevel
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }

    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }

    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }

    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }

    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }

    private func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        guard level >= minLevel else { return }

        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        let formattedMessage = "\(timestamp) \(level.label) [\(fileName):\(line)] \(function) > \(message)"

        queue.async {
            os_log("%{public}@", log: self.osLog, type: level.osLogType, formattedMessage)
        }
    }
}

extension LogLevel {
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}
```

---

## 11. 测试策略

### 11.1 测试金字塔

```
        ╱╲
       ╱  ╲        UI Tests (E2E)
      ╱    ╲       - 关键用户流程
     ╱──────╲
    ╱        ╲     Integration Tests
   ╱          ╲    - 模块间交互
  ╱────────────╲   - Repository + DataSource
 ╱              ╲
╱────────────────╲ Unit Tests (最多)
╱                  ╲ - UseCases
╱                    ╲ - ViewModels
╱                      ╲ - Entities
╱                        ╲ - Utils
```

### 11.2 单元测试

```swift
// Tests/UnitTests/Domain/UseCases/LoginUseCaseTests.swift

import XCTest
@testable import ProjectName

final class LoginUseCaseTests: XCTestCase {
    private var useCase: LoginUseCase!
    private var mockRepository: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockUserRepository()
        useCase = LoginUseCase(userRepository: mockRepository)
    }

    override func tearDown() {
        useCase = nil
        mockRepository = nil
        super.tearDown()
    }

    func test_login_success() async {
        // Given
        let expectedUser = User(id: "1", name: "Test User")
        mockRepository.loginResult = .success(expectedUser)

        // When
        let result = try? await useCase.execute(username: "test", password: "123456")

        // Then
        XCTAssertEqual(result?.id, expectedUser.id)
        XCTAssertEqual(result?.name, expectedUser.name)
        XCTAssertTrue(mockRepository.loginCalled)
    }

    func test_login_failure_invalidCredentials() async {
        // Given
        mockRepository.loginResult = .failure(.business(code: 1001, message: "账号或密码错误"))

        // When/Then
        do {
            _ = try await useCase.execute(username: "test", password: "wrong")
            XCTFail("Expected error to be thrown")
        } catch {
            guard let appError = error as? AppError else {
                XCTFail("Expected AppError")
                return
            }
            if case .business(let code, _) = appError {
                XCTAssertEqual(code, 1001)
            } else {
                XCTFail("Expected business error")
            }
        }
    }

    func test_login_emptyUsername() async {
        // Given
        let emptyUsername = ""

        // When/Then
        do {
            _ = try await useCase.execute(username: emptyUsername, password: "123456")
            XCTFail("Expected validation error")
        } catch {
            XCTAssertEqual(error as? ValidationError, .emptyUsername)
        }
    }
}

// MARK: - Mock

final class MockUserRepository: UserRepositoryProtocol {
    var loginCalled = false
    var loginResult: Result<User, AppError>?

    func login(username: String, password: String) async throws -> User {
        loginCalled = true
        switch loginResult {
        case .success(let user):
            return user
        case .failure(let error):
            throw error
        case nil:
            throw AppError.unknown(nil)
        }
    }
}
```

### 11.3 ViewModel 测试

```swift
// Tests/UnitTests/Presentation/ViewModels/LoginViewModelTests.swift

import XCTest
import Combine
@testable import ProjectName

@MainActor
final class LoginViewModelTests: XCTestCase {
    private var viewModel: LoginViewModel!
    private var mockUseCase: MockLoginUseCase!

    override func setUp() {
        super.setUp()
        mockUseCase = MockLoginUseCase()
        viewModel = LoginViewModel(loginUseCase: mockUseCase)
    }

    func test_login_success_updatesState() async {
        // Given
        mockUseCase.result = .success(User(id: "1", name: "Test"))

        // When
        await viewModel.login(username: "test", password: "123456")

        // Then
        XCTAssertTrue(viewModel.state.isLoggedIn)
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertNil(viewModel.state.error)
    }

    func test_login_failure_updatesErrorState() async {
        // Given
        mockUseCase.result = .failure(.business(code: 1001, message: "登录失败"))

        // When
        await viewModel.login(username: "test", password: "wrong")

        // Then
        XCTAssertFalse(viewModel.state.isLoggedIn)
        XCTAssertFalse(viewModel.state.isLoading)
        XCTAssertNotNil(viewModel.state.error)
    }
}
```

### 11.4 UI 测试

```swift
// Tests/UITests/LoginUITests.swift

import XCTest

final class LoginUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    func test_login_success() {
        // Given
        let usernameField = app.textFields["username"]
        let passwordField = app.secureTextFields["password"]
        let loginButton = app.buttons["login"]

        // When
        usernameField.tap()
        usernameField.typeText("testuser")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Then
        let homeTitle = app.staticTexts["home_title"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5))
    }

    func test_login_emptyFields_showsError() {
        // Given
        let loginButton = app.buttons["login"]

        // When
        loginButton.tap()

        // Then
        let errorLabel = app.staticTexts["error_message"]
        XCTAssertTrue(errorLabel.exists)
        XCTAssertEqual(errorLabel.label, "请输入用户名和密码")
    }
}
```

---

## 12. CI/CD 与自动化

### 12.1 CI 流程

```yaml
# .github/workflows/ci.yml

name: CI

on:
  pull_request:
    branches: [develop, main]
  push:
    branches: [develop]

jobs:
  lint:
    name: Lint
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: SwiftLint
        run: swiftlint --strict

  test:
    name: Test
    runs-on: macos-14
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '16.0'
      - name: Run Tests
        run: |
          xcodebuild test \
            -scheme ProjectName \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.0' \
            -resultBundlePath TestResults \
            | xcpretty

      - name: Upload Test Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: test-results
          path: TestResults.xcresult

  build:
    name: Build
    runs-on: macos-14
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '16.0'
      - name: Build
        run: |
          xcodebuild build \
            -scheme ProjectName \
            -sdk iphonesimulator \
            -destination 'generic/platform=iOS Simulator' \
            | xcpretty
```

### 12.2 自动化脚本

```bash
#!/bin/bash
# Scripts/setup.sh - 项目初始化脚本

echo "🚀 项目初始化开始..."

# 安装依赖
echo "📦 安装依赖..."
brew list swiftlint &>/dev/null || brew install swiftlint
brew list swiftformat &>/dev/null || brew install swiftformat

# 安装 Git Hooks
echo "🔗 安装 Git Hooks..."
cp Scripts/git-hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# 生成 Xcode 项目（如使用 XcodeGen）
if [ -f project.yml ]; then
    echo "🛠 生成 Xcode 项目..."
    xcodegen generate
fi

echo "✅ 初始化完成！"
```

### 12.3 Git Hooks

```bash
#!/bin/sh
# Scripts/git-hooks/pre-commit

echo "🔍 运行 pre-commit 检查..."

# SwiftLint
echo "  • SwiftLint..."
swiftlint --strict
if [ $? -ne 0 ]; then
    echo "❌ SwiftLint 检查失败，请修复后重新提交"
    exit 1
fi

# SwiftFormat
echo "  • SwiftFormat..."
swiftformat --lint .
if [ $? -ne 0 ]; then
    echo "❌ SwiftFormat 检查失败，请运行 swiftformat . 修复"
    exit 1
fi

echo "✅ pre-commit 检查通过！"
```

---

## 13. 可维护性与可扩展性

### 13.1 可维护性策略

| 维度 | 策略 | 实践 |
|------|------|------|
| **代码可读性** | 命名规范 + 注释 | 所有公共 API 必须有文档注释 |
| **代码质量** | 静态分析 | SwiftLint + SwiftFormat 强制检查 |
| **模块化** | 高内聚低耦合 | 模块间通过协议通信，禁止循环依赖 |
| **测试覆盖** | 核心逻辑全覆盖 | UseCase + ViewModel 单元测试覆盖率 ≥ 80% |
| **文档** | 代码即文档 | README + 架构文档 + API 文档 |
| **重构** | 持续重构 | 技术债务跟踪，定期重构周 |

### 13.2 可扩展性策略

| 场景 | 策略 |
|------|------|
| **新增功能模块** | 按 Feature Module 模板创建，注册到 DI 容器 |
| **新增页面** | 在对应模块下添加 View + ViewModel，注册路由 |
| **替换三方库** | 通过封装层隔离，仅修改 Core 层 |
| **新增 API** | 在对应 API 枚举中添加 case |
| **多主题** | 通过 ThemeProtocol 扩展 |
| **插件化** | 通过协议定义插件接口，运行时注册 |
| **A/B 测试** | 通过 FeatureFlag 系统控制 |

### 13.3 Feature Flag 系统

```swift
// Core/Helpers/FeatureFlag.swift

/// 功能开关
enum FeatureFlag: String, CaseIterable {
    case newHomePage = "new_home_page"
    case darkMode = "dark_mode"
    case experimentalPlayer = "experimental_player"

    var isEnabled: Bool {
        // 从远程配置或本地配置读取
        RemoteConfig.shared.bool(forKey: rawValue) ?? defaultEnabled
    }

    var defaultEnabled: Bool {
        switch self {
        case .newHomePage: return false
        case .darkMode: return true
        case .experimentalPlayer: return false
        }
    }
}

// 使用示例
if FeatureFlag.newHomePage.isEnabled {
    NewHomeView()
} else {
    LegacyHomeView()
}
```

### 13.4 性能优化策略

| 关注点 | 措施 |
|--------|------|
| **启动速度** | 懒加载、异步初始化、减少 +load 方法 |
| **内存** | 图片缓存、复用 cell、避免大对象持有 |
| **UI 流畅度** | 主线程避免耗时操作、使用 async/await |
| **网络** | 请求合并、缓存策略、预加载 |
| **包体积** | SPM 按需引入、资源压缩、Asset Catalog |
| **编译速度** | 模块化编译、减少全局 import |

### 13.5 安全策略

| 关注点 | 措施 |
|--------|------|
| **敏感数据** | Keychain 存储 Token、密码 |
| **网络传输** | HTTPS + SSL Pinning |
| **输入校验** | 所有用户输入需校验 |
| **日志安全** | 生产环境不输出敏感信息 |
| **代码混淆** | 关键逻辑代码混淆 |
| **越狱检测** | 可选的安全检测 |

---

## 14. 附录

### 14.1 参考资源

- [Swift 官方文档](https://docs.swift.org/swift-book/)
- [SwiftUI 教程](https://developer.apple.com/tutorials/swiftui)
- [SwiftLint 规则](https://realm.github.io/SwiftLint/)
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)
- [Tuist 文档](https://docs.tuist.io/)
- [XcodeGen 文档](https://github.com/yonaskolb/XcodeGen)

### 14.2 版本记录

| 版本 | 日期 | 作者 | 变更说明 |
|------|------|------|----------|
| v1.0 | 2025-07-16 | doudou.han | 初稿 |

### 14.3 快速开始

```bash
# 1. 克隆项目
git clone git@github.com:example/ProjectName.git
cd ProjectName

# 2. 运行初始化脚本
./Scripts/setup.sh

# 3. 打开项目
open ProjectName.xcodeproj

# 4. 运行测试
xcodebuild test -scheme ProjectName -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

> **本文档将随项目演进持续更新，建议每季度评审一次。**
