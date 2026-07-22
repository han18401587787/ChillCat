# Swift Testing Expert — ChillCat 项目测试约束

> 基于 Antoine van der Lee 的 Swift Testing Agent Skill 模式，为 ChillCat 项目定制的测试编写约束规则。

## Agent Behavior Contract

当为 ChillCat 项目编写 Swift 测试时，AI **必须**遵守以下规则：

### 规则 1：禁止不必要的 @MainActor

- **默认不加 @MainActor**。只有测试真正需要主线程隔离的 UI 绑定代码（如 `@Published` 属性更新、`@Observable` 类在主线程的断言）时，才加 `@MainActor`。
- 网络层、数据处理、UseCase、Repository、纯逻辑 ViewModel 方法 → **不加 @MainActor**。
- 违反此规则会直接废掉 Swift Testing 的并行执行能力，测试套件耗时增加 3-5 倍。

```swift
// ❌ AI 常见错误
@MainActor
@Test func networkParserWorks() { ... }

// ✅ 正确：非 UI 逻辑不需要
@Test func networkParserWorks() { ... }

// ✅ 正确：UI 绑定逻辑才需要
@MainActor
@Test func viewModelUpdatesPublishedProperty() { ... }
```

### 规则 2：.serialized 是临时妥协，不是默认架构

- **禁止**用 `.serialized` 作为解决 flaky test 的第一手段。
- 遇到 flaky test，必须先排查共享可变状态，隔离每个测试的实例/数据。
- 只有在迁移旧 XCTest（已存在共享状态且短期无法重构）时，才临时使用 `.serialized`，且必须加 `// TODO: 隔离状态后移除 .serialized` 注释。

```swift
// ❌ AI 的"修复"
@Suite(.serialized)
struct DatabaseTests { ... }

// ✅ 正确：隔离状态
struct DatabaseTests {
    @Test func migration() {
        let db = InMemoryDatabase()  // 每个测试独立实例
    }
}

// ✅ 可接受：迁移旧测试时临时使用
@Suite(.serialized)  // TODO: 隔离状态后移除 .serialized
struct LegacyDatabaseTests { ... }
```

### 规则 3：优先参数化测试

- 当多个测试共享相同逻辑、仅输入不同时，**必须**使用 `@Test(arguments:)` 参数化测试。
- 禁止写 `testFooCaseA`、`testFooCaseB`、`testFooCaseC` 这种重复方法。

```swift
// ❌ AI 常见错误
@Test func validPort80() { #expect(isValidPort(80)) }
@Test func validPort443() { #expect(isValidPort(443)) }

// ✅ 正确：参数化
@Test(arguments: [80, 443, 8080, 65535])
func validPorts(_ port: Int) {
    #expect(isValidPort(port))
}
```

### 规则 4：网络层必须 Mock，禁止连真实服务器

- **绝对禁止**在单元测试中调用 `CCXuanAPI` 的真实方法。
- 使用 `URLProtocol` 子类 mock 网络响应，或使用协议抽象注入 mock 实现。
- UI 测试（XCUITest）可以连真实服务器，但单元测试（ChillCatTests）不行。

```swift
// ✅ 正确：Mock 网络层
final class MockURLProtocol: URLProtocol {
    static var responseHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    override func startLoading() { ... }
}
```

### 规则 5：确定性优先

- 优先使用同步验证，除非真的需要异步等待。
- 禁止 `try await Task.sleep(nanoseconds:)` 作为等待手段。使用 `wait(for:timeout:)` 或 `withCheckedContinuation`。
- 测试结果必须 100% 可重现。

### 规则 6：日志验证

- 测试中可以注入 mock logger，验证关键路径是否输出了预期日志。
- ChillCat 的 `CCLogger.shared` 是单例，在测试中可通过 `setLevel(.off, for: .default)` 关闭日志输出以减少噪音。

---

## 测试目录结构

```
ChillCatTests/
├── Core/
│   ├── Networking/
│   │   ├── CCXuanAPITests.swift        # API 客户端测试
│   │   ├── XuanAuthInterceptorTests.swift
│   │   └── CCNetworkConfigTests.swift
│   ├── Logging/
│   │   └── CCLoggerTests.swift
│   └── Storage/
│       └── CCTokenProviderTests.swift
├── Domain/
│   └── UseCases/
│       ├── CCLoginUseCaseTests.swift
│       ├── CCFetchMemberInfoUseCaseTests.swift
│       └── CCUserProfileUseCaseTests.swift
├── Presentation/
│   └── ViewModels/
│       ├── CCLoginViewModelTests.swift
│       ├── CCEmotionViewModelTests.swift
│       └── ...
└── Helpers/
    ├── MockURLProtocol.swift
    ├── MockLogger.swift
    └── TestHelpers.swift
```

---

## ChillCat 项目特有的注意事项

1. **CCXuanAPI 是 enum**：不能实例化，所有方法都是 `static`。测试时 mock Alamofire 的 `URLProtocol`。
2. **Keychain 依赖**：`XuanAuthInterceptor` 依赖 `Keychain(service: "app.xuanpeace.token")`，测试中需要 mock 或使用测试专用 service。
3. **@MainActor ViewModel**：大部分 ViewModel 标记了 `@MainActor`，测试这些 ViewModel 的方法时**需要**加 `@MainActor`，但仅限这些情况。
4. **CCLogger 全局函数**：`LogD/LogI/LogW/LogE` 是全局函数（非类方法），测试中注入 mock 需要通过 `CCLogger.shared` 单例。
