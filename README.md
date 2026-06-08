# ChillCat 🐱

音乐流媒体 iOS 应用，采用 SwiftUI + Go 全栈架构。

> 🔧 服务端独立仓库：[ChillCat-Server](https://github.com/han18401587787/ChillCat-Server)

## 项目结构

```
ChillCat/
├── ChillCat.xcodeproj          # Xcode 工程
├── ChillCat/                   # iOS 客户端 (Swift/SwiftUI)
│   ├── App/                    # 入口 + DI 容器
│   ├── Core/                   # 基础层 (网络/存储/日志/DI)
│   ├── Domain/                 # 领域层 (实体/用例/仓库协议)
│   ├── Data/                   # 数据层 (DTO/数据源/仓库实现)
│   └── Presentation/           # 展示层 (MVVM + Coordinator)
│       ├── Common/             # 公共组件/主题
│       ├── Modules/            # 功能模块
│       │   ├── Auth/           # 登录/注册
│       │   ├── Home/           # 首页内容流
│       │   ├── Search/         # 搜索
│       │   ├── Message/        # 消息中心
│       │   ├── VIP/            # 会员中心
│       │   ├── Profile/        # 个人中心
│       │   └── Settings/       # 设置
│       └── Navigation/         # 路由协调器
├── server/                     # Go 服务端
│   ├── cmd/server/             # 入口
│   ├── cmd/seed/               # 种子数据
│   ├── internal/
│   │   ├── config/             # 配置管理
│   │   ├── handler/            # HTTP 处理器
│   │   ├── middleware/         # 中间件
│   │   ├── model/              # 数据模型
│   │   ├── repository/         # 数据访问层
│   │   ├── router/             # 路由注册
│   │   └── service/            # 业务逻辑
│   ├── pkg/                    # 公共包
│   │   ├── jwt/                # JWT 工具
│   │   ├── logger/             # 日志
│   │   ├── response/           # 统一响应
│   │   └── validator/          # 参数校验
│   ├── configs/                # 配置文件
│   ├── migrations/             # SQL 迁移
│   └── docs/                   # API 文档
└── Swift工程架构设计/           # 架构设计文档
```

## 技术栈

| 层 | iOS | 服务端 |
|:--|:--|:--|
| 语言 | Swift 5.9+ | Go 1.25 |
| UI | SwiftUI + UIKit | — |
| 架构 | MVVM + Coordinator + Clean Architecture | Handler → Service → Repository |
| 网络 | URLSession + async/await | Gin |
| 存储 | Keychain / UserDefaults / Cache | PostgreSQL + GORM |
| 认证 | JWT Token 拦截器 | bcrypt + JWT |
| 部署 | Xcode Archive | Docker + Docker Compose |

## 快速开始

### 服务端

```bash
cd server

# 启动 PostgreSQL + 服务
docker-compose up -d

# 或本地运行
cp configs/config.yaml configs/config.local.yaml  # 修改数据库连接
go run ./cmd/server

# 填充测试数据
make seed
# 测试账号: test / 123456

# 运行测试
make test
```

### iOS

1. 用 Xcode 打开 `ChillCat.xcodeproj`
2. 选择 `ChillCat` scheme
3. ⌘R 运行

开发环境默认连接 `http://localhost:8080`。

## API 概览

| 端点 | 方法 | 认证 | 说明 |
|:--|:--|:--|:--|
| `/health` | GET | — | 健康检查 |
| `/api/v1/auth/register` | POST | — | 注册 |
| `/api/v1/auth/login` | POST | — | 登录 |
| `/api/v1/auth/refresh` | POST | — | 刷新Token |
| `/api/v1/user/profile` | GET | ✅ | 用户信息 |
| `/api/v1/member/info` | GET | ✅ | 会员信息 |
| `/api/v1/member/products` | GET | ✅ | 商品列表 |
| `/api/v1/member/privileges` | GET | ✅ | 权益列表 |
| `/api/v1/member/purchase` | POST | ✅ | 购买 |
| `/api/v1/member/history` | GET | ✅ | 购买历史 |
| `/api/v1/feeds` | GET | ✅ | 内容流 |
| `/api/v1/feeds/:id` | GET | ✅ | 内容详情 |
| `/api/v1/search` | GET | ✅ | 搜索 |
| `/api/v1/messages` | GET | ✅ | 消息列表 |
| `/api/v1/messages/unread` | GET | ✅ | 未读数 |
| `/api/v1/messages/:id/read` | POST | ✅ | 标记已读 |

详细文档见 `server/docs/api.md`。

## CI/CD

GitHub Actions 自动执行：build → test (race) → lint → docker build

触发条件：push/PR 到 main/develop 分支。
