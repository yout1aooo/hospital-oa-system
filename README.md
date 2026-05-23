# 河口医院智能协同办公平台

> 基于 RuoYi-Cloud 3.6.7 二次开发的医院行政协同办公系统。项目采用 Spring Cloud 微服务架构与 Vue 2 前后端分离模式，面向医院内部办公、跨科室协同、通知文档、会议任务、通讯录、患者信息查询等场景。

## 目录

- [项目概览](#项目概览)
- [核心能力](#核心能力)
- [功能模块](#功能模块)
- [技术栈](#技术栈)
- [系统架构](#系统架构)
- [模块结构](#模块结构)
- [端口清单](#端口清单)
- [环境要求](#环境要求)
- [快速开始](#快速开始)
- [Docker 部署](#docker-部署)
- [数据库脚本](#数据库脚本)
- [关键配置](#关键配置)
- [常用命令](#常用命令)
- [常见问题](#常见问题)
- [开发说明](#开发说明)
- [License](#license)

## 项目概览

`hospital-oa-system` 是一个医院 OA 微服务项目，保留了 RuoYi-Cloud 的网关、认证、权限、日志、代码生成、定时任务、监控等基础能力，并扩展了医院协同办公业务。

项目主要覆盖以下角色和场景：

- 医院行政人员：处理审批、通知、制度文档、会议室预约、任务督办。
- 科室负责人：查看待办、跟进跨科室任务、维护科室通讯录。
- 普通员工：提交申请、查看通知、确认文档阅读、管理个人日程。
- 授权医护人员：按权限查询患者、病例及访问审计记录。

## 核心能力

- 微服务分层：Gateway 统一入口，Auth 统一认证，System 承载系统管理与 OA 核心业务，File/Job/Gen/Monitor 独立服务化。
- 权限体系：支持 RBAC 菜单权限、按钮权限、数据权限、登录日志、操作日志和接口鉴权。
- 医院 OA 业务：覆盖审批中心、通知文档、会议管理、任务督办、日程提醒、院内通讯录、患者服务。
- 文件能力：提供独立文件服务，默认支持本地存储，并保留 MinIO、GridFS 相关兼容能力。
- 配置中心：通过 Nacos 管理公共配置、网关路由、数据源、文件服务、接口文档等配置。
- 初始化脚本：`sql/hospital_cloud_init.sql` 提供主业务库的一站式初始化脚本，包含核心系统表、Quartz 表、OA 表和演示数据。
- 前后端分离：前端基于 Vue 2 + Element UI，开发环境通过 `/dev-api` 代理到网关。

## 功能模块

| 模块 | 说明 |
| --- | --- |
| 工作台 | 聚合待办事项、近期日程、通知公告、文档和业务概览。 |
| 审批中心 | 支持我的申请、我的待办、我的已办；当前覆盖请假、报销等轻量审批流。 |
| 通知文档 | 通知中心、制度文档管理、文档发布、归档、阅读确认、附件上传下载。 |
| 会议任务 | 会议室查询、会议预约、会议完成、任务督办、任务跟进记录、日程提醒。 |
| 通讯录 | 院内人员查询、科室查询、联系人分组。 |
| 患者服务 | 患者查询、病例查询、患者访问审计，支持手机号、身份证等敏感信息脱敏。 |
| 系统管理 | 用户、角色、菜单、部门、岗位、字典、参数、日志、代码生成、定时任务、服务监控。 |

## 技术栈

### 后端

| 技术 | 版本/说明 |
| --- | --- |
| Java | 1.8 |
| Maven | 3.6+ |
| Spring Boot | 2.7.18 |
| Spring Cloud | 2021.0.8 |
| Spring Cloud Alibaba | 2021.0.5.0 |
| Nacos | 注册中心、配置中心；Docker 默认镜像 `nacos/nacos-server:v3.0.2` |
| Sentinel | 网关限流、熔断降级 |
| OpenFeign | 微服务间调用 |
| MyBatis | 2.3.2 |
| Druid | 1.2.28 |
| Dynamic Datasource | 3.6.1 |
| PageHelper | 1.4.7 |
| MySQL | Docker 默认 `mysql:5.7` |
| Redis | 缓存、验证码、令牌存储 |
| Quartz | 定时任务 |
| Spring Boot Admin | 服务监控 |
| Springdoc OpenAPI | 1.7.0 |
| MinIO | 可选对象存储，文件服务已引入依赖 |
| MongoDB/GridFS | 可选，`hospital-system` 默认保留 `MONGODB_URI` 配置用于历史兼容 |

### 前端

| 技术 | 版本/说明 |
| --- | --- |
| Vue | 2.6.12 |
| Vue Router | 3.4.9 |
| Vuex | 3.6.0 |
| Element UI | 2.15.14 |
| Axios | 0.28.1 |
| ECharts | 5.4.0 |
| Quill | 2.0.2 |
| Sass | 1.32.13 |
| Vue CLI | 4.4.6 |

## 系统架构

```text
Browser / hospital-ui
        |
        | /dev-api 或 /prod-api
        v
hospital-gateway :8080
        |
        +-- hospital-auth    :9200  登录、认证、令牌
        +-- hospital-system  :9201  系统管理、OA 核心业务、患者服务
        +-- hospital-file    :9300  文件上传、下载、存储
        +-- hospital-gen     :9202  代码生成
        +-- hospital-job     :9203  定时任务
        +-- hospital-monitor :9100  服务监控

基础设施：
Nacos :8848 / MySQL :3306 / Redis :6379 / 可选 MongoDB / 可选 MinIO
```

网关路由来自 Nacos 配置 `hospital-gateway-dev.yml`：

| 入口路径 | 目标服务 |
| --- | --- |
| `/auth/**` | `hospital-auth` |
| `/system/**` | `hospital-system` |
| `/file/**` | `hospital-file` |
| `/code/**` | `hospital-gen` |
| `/schedule/**` | `hospital-job` |

## 模块结构

```text
hospital-oa-system
├── hospital-gateway                 # API 网关 [8080]
├── hospital-auth                    # 认证中心 [9200]
├── hospital-api
│   └── hospital-api-system          # Feign API 定义
├── hospital-common                  # 公共能力模块
│   ├── hospital-common-core         # 核心工具、基础实体、通用返回
│   ├── hospital-common-security     # 鉴权、安全上下文、Feign 拦截
│   ├── hospital-common-redis        # Redis 封装
│   ├── hospital-common-datascope    # 数据权限
│   ├── hospital-common-datasource   # 多数据源
│   ├── hospital-common-log          # 操作日志
│   ├── hospital-common-seata        # 分布式事务预留
│   ├── hospital-common-sensitive    # 敏感数据处理
│   └── hospital-common-swagger      # Springdoc/OpenAPI 配置
├── hospital-modules
│   ├── hospital-system              # 系统管理 + OA 核心业务 [9201]
│   ├── hospital-file                # 文件服务 [9300]
│   ├── hospital-gen                 # 代码生成 [9202]
│   ├── hospital-job                 # 定时任务 [9203]
│   └── hospital-oa-collab           # 协同扩展实验模块，当前未加入父工程构建
├── hospital-visual
│   └── hospital-monitor             # Spring Boot Admin 监控中心 [9100]
├── hospital-ui                      # Vue 2 + Element UI 前端
├── sql                              # 数据库初始化、演进和兼容脚本
├── docker                           # Docker Compose 与镜像构建配置
└── bin                              # Windows 打包、启动脚本
```

当前真实 OA 业务代码主要位于：

```text
hospital-modules/hospital-system/src/main/java/com/hospitaloa/oa
hospital-modules/hospital-system/src/main/java/com/hospitaloa/system/controller/OaDocumentController.java
hospital-ui/src/views/oa
hospital-ui/src/api/oa
```

## 端口清单

| 服务 | 默认端口 | 说明 |
| --- | --- | --- |
| hospital-ui | 80 | 前端开发服务或 Nginx 访问端口 |
| hospital-gateway | 8080 | API 网关 |
| hospital-auth | 9200 | 认证中心 |
| hospital-system | 9201 | 系统管理与 OA 核心服务 |
| hospital-gen | 9202 | 代码生成服务 |
| hospital-job | 9203 | 定时任务服务 |
| hospital-file | 9300 | 文件服务 |
| hospital-monitor | 9100 | 服务监控中心 |
| Nacos | 8848 / 9848 / 9849 | 注册中心、配置中心 |
| Redis | 6379 | 缓存服务 |
| MySQL | 3306 | 数据库服务 |
| MinIO | 9000 | 可选对象存储 |

## 环境要求

| 环境 | 要求 |
| --- | --- |
| JDK | 1.8+ |
| Maven | 3.6+ |
| Node.js | 8.9+；建议使用 Node 14 或 16 以匹配 Vue CLI 4 生态 |
| npm | 3.0+ |
| MySQL | 5.7+ |
| Redis | 5+ |
| Nacos | 2.x/3.x |
| Docker | 可选，用于快速启动基础设施或容器化部署 |
| MongoDB | 可选，启用 GridFS 兼容能力时需要 |
| MinIO | 可选，启用对象存储模式时需要 |

## 快速开始

以下流程适合本地开发。默认以 Windows + PowerShell 为例，Linux/macOS 可按等价命令执行。

### 1. 启动基础设施

仓库内的 Docker Compose 已提供 MySQL、Redis、Nacos 等基础服务：

```bash
cd docker
docker compose up -d hospital-mysql hospital-redis hospital-nacos
```

如果你的 Docker Compose 版本较旧，也可以使用：

```bash
docker-compose up -d hospital-mysql hospital-redis hospital-nacos
```

说明：

- MySQL 默认账号：`root / 123456`
- MySQL 默认业务库：`hospital-cloud`
- Nacos 配置库：`hospital-config`
- 当前 `docker-compose.yml` 未内置 MongoDB 和 MinIO；如启用相关能力，请单独启动。

### 2. 初始化数据库

推荐导入一站式业务库脚本和 Nacos 配置脚本：

```bash
mysql -uroot -p123456 < sql/hospital_cloud_init.sql
mysql -uroot -p123456 < sql/hospital-config_20260311.sql
```

注意：以上脚本会执行 `DROP DATABASE IF EXISTS`，会重建 `hospital-cloud` 和 `hospital-config`，请不要在生产库或有价值数据的库上直接执行。

如需启用 Seata 预留库，再额外执行：

```bashnv
mysql -uroot -p123456 < sql/hospital-seata_20210128.sql
```

### 3. 启动后端服务

开发阶段可以使用 IDE 分别启动以下 Application 类：

| 启动类 | 服务 |
| --- | --- |
| `com.hospitaloa.gateway.HospitalGatewayApplication` | 网关 |
| `com.hospitaloa.auth.HospitalAuthApplication` | 认证中心 |
| `com.hospitaloa.system.HospitalSystemApplication` | 系统/OA 核心 |
| `com.hospitaloa.file.HospitalFileApplication` | 文件服务 |
| `com.hospitaloa.gen.HospitalGenApplication` | 代码生成 |
| `com.hospitaloa.job.HospitalJobApplication` | 定时任务 |
| `com.hospitaloa.modules.monitor.HospitalMonitorApplication` | 监控中心 |

最小可用组合：

```text
hospital-auth
hospital-system
hospital-file
hospital-gateway
```

启动顺序建议：

```text
Nacos / MySQL / Redis
        ↓
hospital-auth / hospital-system / hospital-file
        ↓
hospital-gateway
        ↓
hospital-ui
```

也可以先打包，再用 `bin` 目录下的 Windows 脚本启动：

```bash
mvn clean package -DskipTests
```

```text
bin/run-auth.bat
bin/run-modules-system.bat
bin/run-modules-file.bat
bin/run-gateway.bat
```

### 4. 启动前端

```bash
cd hospital-ui
npm install
npm run dev
```

前端开发服务默认端口为 `80`，开发环境接口前缀为 `/dev-api`，并在 `hospital-ui/vue.config.js` 中代理到 `http://localhost:8080`。

如果 `80` 端口被占用，可以指定端口：

```powershell
$env:port=8081
npm run dev
```

浏览器访问：

```text
http://localhost
```

如果改用了 `8081`：

```text
http://localhost:8081
```

### 5. 默认账号

| 账号 | 密码 | 说明 |
| --- | --- | --- |
| `admin` | `admin123` | 系统管理员 |
| `staff` | `admin123` | 测试员工账号 |

## Docker 部署

完整容器化部署依赖已构建好的后端 jar 和前端 `dist`。

```bash
# 1. 后端打包
mvn clean package -DskipTests

# 2. 前端构建
cd hospital-ui
npm install
npm run build:prod

# 3. 复制产物并启动容器
cd ../docker
sh copy.sh
sh deploy.sh base
sh deploy.sh modules
```

`deploy.sh` 参数说明：

| 命令 | 说明 |
| --- | --- |
| `sh deploy.sh port` | 在 Linux 防火墙中放行项目端口 |
| `sh deploy.sh base` | 启动 MySQL、Redis、Nacos |
| `sh deploy.sh modules` | 启动 Nginx、Gateway、Auth、System 等核心服务 |
| `sh deploy.sh stop` | 停止全部容器 |
| `sh deploy.sh rm` | 删除全部容器 |

说明：

- Windows 环境建议通过 WSL 或 Git Bash 执行 `sh` 脚本。
- `copy.sh` 会复制 SQL、前端构建产物和后端 jar 到 `docker` 目录下对应镜像上下文。
- 当前 `deploy.sh modules` 只启动核心模块；如需启动 `job`、`gen`、`file`、`monitor`，可按需调整 `docker/docker-compose.yml` 或手动执行 `docker compose up -d <service>`。

## 数据库脚本

| 脚本 | 说明 |
| --- | --- |
| `sql/hospital_cloud_init.sql` | 推荐的一站式主业务库初始化脚本，包含 `hospital-cloud`、核心系统表、Quartz 表、OA 表和演示数据。 |
| `sql/00_core_schema.sql` | 系统核心表结构和基础种子数据。 |
| `sql/10_quartz_schema.sql` | Quartz 调度表。 |
| `sql/20_oa_runtime_schema.sql` | 当前启用的 OA 业务表。 |
| `sql/21_oa_seed_demo.sql` | OA 演示数据。 |
| `sql/90_oa_future_schema.sql` | 未来预留的 OA 扩展表。 |
| `sql/hospital-config_20260311.sql` | Nacos 配置中心库 `hospital-config`。 |
| `sql/hospital-seata_20210128.sql` | Seata 事务库 `hospital-seata`。 |
| `sql/hospital_20250523.sql` | 旧版兼容脚本，保留用于对照。 |
| `sql/hospital_oa_phase1.sql` | 旧版/阶段性 OA 脚本，保留用于对照。 |
| `sql/quartz.sql` | 旧版 Quartz 拆分脚本，保留用于对照。 |

推荐本地初始化顺序：

```sql
source sql/hospital_cloud_init.sql;
source sql/hospital-config_20260311.sql;
-- 如需启用 Seata，再执行：
source sql/hospital-seata_20210128.sql;
```

## 关键配置

### Nacos

后端服务会从 Nacos 加载公共配置和服务私有配置：

```text
application-dev.yml
hospital-gateway-dev.yml
hospital-auth-dev.yml
hospital-system-dev.yml
hospital-file-dev.yml
hospital-gen-dev.yml
hospital-job-dev.yml
hospital-monitor-dev.yml
```

服务本地 `bootstrap.yml` 默认读取：

```text
NACOS_SERVER_ADDR=127.0.0.1:8848
```

如 Nacos 不在本机，可设置环境变量：

```powershell
$env:NACOS_SERVER_ADDR="192.168.1.10:8848"
```

### 数据源

默认数据源配置在 Nacos 的 `hospital-system-dev.yml`、`hospital-gen-dev.yml`、`hospital-job-dev.yml` 中：

```text
jdbc:mysql://localhost:3306/hospital-cloud
root / 123456
```

如果后端服务运行在 Docker 网络内，需要把 `localhost` 调整为对应容器名，例如 `hospital-mysql`。

### Redis

默认 Redis 配置：

```text
host: localhost
port: 6379
```

Docker 网络内同样需要调整为 `hospital-redis`。

### 文件服务

Nacos 中 `hospital-file-dev.yml` 默认配置：

```text
file.domain = http://127.0.0.1:9300
file.path   = D:/hospital/uploadPath
file.prefix = /statics
```

MinIO 配置已预留：

```text
minio.url        = http://127.0.0.1:9000
minio.accessKey  = minioadmin
minio.secretKey  = minioadmin
minio.bucketName = test
```

### MongoDB

`hospital-system` 默认保留 MongoDB URI：

```text
MONGODB_URI=mongodb://127.0.0.1:27017/hospital_oa
```

如不使用 GridFS 相关能力，通常不需要单独处理；如使用文档历史附件兼容能力，请启动 MongoDB 并按环境修改该变量。

### 前端接口前缀

| 环境文件 | 接口前缀 |
| --- | --- |
| `hospital-ui/.env.development` | `/dev-api` |
| `hospital-ui/.env.production` | `/prod-api` |
| `hospital-ui/.env.staging` | `/stage-api` |

生产环境 Nginx 会将 `/prod-api/` 转发到网关：

```text
http://hospital-gateway:8080/
```

## 常用命令

```bash
# 后端打包
mvn clean package -DskipTests

# 后端打包，跳过 Maven 测试执行
mvn clean package -Dmaven.test.skip=true

# 前端开发
cd hospital-ui
npm run dev

# 前端生产构建
cd hospital-ui
npm run build:prod

# 启动基础 Docker 服务
cd docker
docker compose up -d hospital-mysql hospital-redis hospital-nacos

# 查看 Docker 服务状态
docker compose ps

# 停止 Docker 服务
docker compose stop
```

## 常见问题

### 1. 前端 80 端口被占用

指定其他端口启动：

```powershell
$env:port=8081
npm run dev
```

### 2. 后端启动时报 Nacos 配置不存在

确认已导入：

```bash
mysql -uroot -p123456 < sql/hospital-config_20260311.sql
```

然后打开 Nacos 控制台检查配置是否存在：

```text
http://localhost:8848
```

### 3. 服务注册了但前端接口 404

优先检查：

- `hospital-gateway` 是否启动。
- Nacos 中 `hospital-gateway-dev.yml` 是否存在路由配置。
- 前端接口前缀是否为 `/dev-api`。
- `hospital-ui/vue.config.js` 是否代理到 `http://localhost:8080`。

### 4. Docker 环境服务连不上 MySQL 或 Redis

Nacos 配置中默认使用 `localhost`。如果服务运行在容器内，需要把地址调整为 Docker Compose 服务名：

```text
MySQL: hospital-mysql
Redis: hospital-redis
Nacos: hospital-nacos:8848
```

### 5. 文档附件上传路径不存在

默认本地上传目录是：

```text
D:/hospital/uploadPath
```

请先创建目录，或在 Nacos 的 `hospital-file-dev.yml` 中改为当前机器可写路径。

## 开发说明

- 后端包名统一使用 `com.hospitaloa`。
- 新增通用能力优先放入 `hospital-common-*`，业务能力优先放入对应业务模块。
- 当前 OA 业务主要集中在 `hospital-system`，不要误以为 `hospital-oa-collab` 已参与主构建。
- 前端 OA 页面集中在 `hospital-ui/src/views/oa`，接口封装集中在 `hospital-ui/src/api/oa`。
- 菜单、权限标识和初始数据主要来自 `sql/00_core_schema.sql` 或合并后的 `sql/hospital_cloud_init.sql`。
- 网关路由、数据源、Redis、文件服务配置优先在 Nacos 中维护。
- 变更数据库结构时，建议同步维护拆分脚本和 `hospital_cloud_init.sql`，避免初始化脚本与演进脚本不一致。

## License

本项目沿用仓库根目录 [LICENSE](LICENSE)。
