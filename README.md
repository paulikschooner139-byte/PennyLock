# PennyLock

一款本地记账工具:iOS 上的记账 + 月度预算目标 + 「惩罚锁」。

超支就要付出代价——设一个月度预算上限,月底如果超支,下个月记账会被锁住,必须完成你自己设定的惩罚(比如"存 1000 块"、"跑 20 公里")才能解锁继续用。

## 功能

- 记账:收入/支出,分类、金额、日期、备注
- 月结余:自动算本月收入 - 支出
- 消费分析:本月 vs 上月环比、分类占比饼图、每日支出趋势
- 月度预算目标:设一个支出上限
- 惩罚锁:月底超支 → 下月锁定 → 完成惩罚后解锁

## 技术栈

- Swift + SwiftUI,纯代码(无 Storyboard)
- iOS 17+
- 数据全部存本机(UserDefaults + JSON),无账号、无云、不上传
- 双语:英文为主,简体中文跟随系统语言
- 零第三方依赖(Swift Charts 是系统框架)

## 目录结构

```
PennyLock/
├── codemagic.yaml            # Codemagic 云端构建配置
├── gen_icon.py               # App 图标生成脚本(已生成占位图标)
├── PennyLock.xcodeproj/      # Xcode 工程(可直接打开)
└── PennyLock/
    ├── PennyLockApp.swift    # @main 入口
    ├── Models/               # 数据模型 + 数据仓库
    │   ├── Transaction.swift
    │   ├── BudgetGoal.swift
    │   ├── MonthResult.swift
    │   └── AppStore.swift    # 核心:持久化、结算、惩罚锁逻辑
    ├── Views/                # 7 个视图
    ├── Support/              # 分类、月份、货币格式化
    └── Resources/            # 双语 strings + 图标资源
```

## 上架前必须改的 3 件事

1. **Bundle ID**:现在是占位的 `com.example.PennyLock`,必须改成你自己的唯一 ID(建议用反向域名,如 `com.你的品牌.pennylock`)。发布后不可更改。改法:Xcode 打开工程 → 选中 Target → Signing & Capabilities → Bundle Identifier;或直接改 `project.pbxproj` 里两处 `PRODUCT_BUNDLE_IDENTIFIER`。
2. **Team**:Xcode 里 Signing & Capabilities 的 Team 选你的 Apple 开发者账号(英国账号即可)。
3. **App 图标**:我已生成一个占位图标(渐变 + 锁形)。想换,直接替换 `PennyLock/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`(1024x1024 PNG)。

## 方式 A:Codemagic 云端构建(零设备,推荐)

你不需要 Mac。全程云端编译、签名、上传。

1. 注册 GitHub(免费),新建一个私有仓库,把整个 `PennyLock` 目录 push 上去。
2. 注册 Codemagic,连接你的 GitHub 仓库。
3. 在 Codemagic 的 App 设置里,连接你的 Apple 开发者账号(Codemagic 会帮你自动管理证书和签名)。
4. 把 `codemagic.yaml` 里的 `user@example.com` 改成你的邮箱(可选)。
5. 点 "Start new build" → 云端跑 Xcode 编译 → 产出 ipa。
6. 在 Codemagic 的 publishing 里配置 App Store Connect 自动上传(用 App Store Connect API key),或者手动把 ipa 上传到 App Store Connect。

> 免费额度:GitHub 私有仓库免费;Codemagic 免费 500 分钟/月,一次 iOS 构建约 15~30 分钟,足够你上架。

## 方式 B:本地 Mac 构建(如果你之后买了/借了 Mac)

1. 装最新版 Xcode。
2. 双击 `PennyLock.xcodeproj` 打开。
3. Signing & Capabilities 里选你的 Team,改好 Bundle ID。
4. 顶部设备选 "Any iOS Device (arm64)"。
5. 菜单 Product → Archive。
6. Organizer 里选刚生成的 Archive → Distribute App → App Store Connect → Upload。
7. 构建版本出现在 App Store Connect(处理延迟 10~30 分钟)。

## App Store Connect 上架步骤(两种方式都适用)

1. 登录 App Store Connect → 「我的 App」→ 新建 App:名称(PennyLock)、主要语言(英文)、Bundle ID(和工程一致)、SKU。
2. 截图:至少 6.7" + 5.5" 各一张(在模拟器或真机截图)。
3. App 隐私(App Privacy):本 App 数据只存本机、不上传,如实声明「不收集数据」。
4. 定价与销售范围:选免费;地区勾选海外地区即可,**不要勾中国大陆**(否则要办 App 备案)。
5. 隐私政策 URL:必填,必须是能打开的网页。
6. 选构建版本 → 提交审核。周期 1~3 天,新账号首次可能更久。

## 隐私政策

这个 App 不联网、不上传任何数据,所有记录只存在你自己的手机里。隐私政策里写清楚这一点即可(示例):「PennyLock 不收集、不存储、不传输任何个人数据。所有记账数据仅保存在您的设备本地,卸载即删除。」

## 惩罚锁机制说明(产品逻辑)

- 你在「目标」页设定月度支出上限 + 一段惩罚内容。
- 每个月跨月后,App 自动结算上月:上月支出 ≤ 上限 = 达成;支出 > 上限 = 未达成。
- 未达成 → 本月一打开 App 就弹出「锁定页」,大字显示超支金额和你的惩罚,必须点「我已完成惩罚」才能解锁。
- 解锁靠自我确认(自己对自己承诺),本地工具不做虚假验证。
- 上限设为 0 = 不启用目标追踪(不会锁)。

## 常见问题

- **打开工程报错?** 确认 Xcode 是 15 或更新版本(iOS 17 SDK)。
- **Swift Charts 找不到?** Charts 是 iOS 16+ 系统框架,确认部署目标 ≥ 17。
- **签名报错?** 检查 Signing & Capabilities 的 Team 和 Bundle ID 是否已设置。

## 改代码

任何功能想改(加分类、改惩罚逻辑、加导出),改对应 `.swift` 文件即可。改完按上面方式 A 或 B 重新构建。遇到编译报错,把完整报错信息发给你的开发助手(agent),远程帮你修。
