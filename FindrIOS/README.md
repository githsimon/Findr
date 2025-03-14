# Findr iOS App

Findr是一个物品管理应用，帮助用户记录和查找家中物品的存放位置。

## 功能特点

- 添加和管理存放位置
- 记录物品信息及其存放位置
- 按类别快速查找物品
- 查看最近添加的物品
- 统计物品和位置数量
- 个人中心管理

## 项目结构

```
FindrIOS/
├── Models/             # 数据模型
│   ├── Location.swift  # 位置模型
│   ├── LocationStore.swift  # 位置数据管理
│   ├── Item.swift      # 物品模型
│   └── ItemStore.swift # 物品数据管理
├── Views/              # 视图组件
│   ├── HomeView.swift  # 首页视图
│   ├── LocationsView.swift  # 位置管理视图
│   ├── AddItemView.swift    # 添加物品视图
│   └── ProfileView.swift    # 个人中心视图
├── ContentView.swift   # 主内容视图（包含标签栏导航）
└── FindrApp.swift      # 应用入口
```

## 数据存储

应用使用本地JSON文件存储数据：
- `locations.json`: 存储位置信息
- `items.json`: 存储物品信息

## 开发进度

- [x] 创建基本项目结构
- [x] 实现位置管理功能
- [x] 实现首页UI
- [x] 实现个人中心UI
- [x] 实现添加物品功能
- [ ] 实现搜索功能
- [ ] 实现设置页面
- [ ] 实现数据导入/导出功能

## 运行要求

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## 下一步计划

1. 完善搜索功能
2. 添加物品编辑功能
3. 实现标签管理系统
4. 添加提醒功能
5. 优化UI/UX体验
