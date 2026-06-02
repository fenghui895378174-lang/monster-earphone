# 魔音控制台 — Monster Cyber Console

暗黑科技风蓝牙耳机管理 App，基于 Flutter 开发，支持 Android。

## 功能一览

### 仪表盘
- 🔋 三路独立电量显示（左耳/右耳/充电盒）
- 📶 实时信号强度雷达图
- 🎵 音频编码格式显示
- 🌊 EQ 实时波形可视化

### 均衡器
- 10 段专业 EQ 调节（32Hz - 16KHz）
- 10 种预设场景：流行/古典/摇滚/人声/电子/嘻哈/原声/电影/低音增强/平坦
- 3D 环绕音效开关
- Bass Boost 低音增强

### 查找耳机
- 📡 RSSI 信号强度雷达
- 🔊 蜂鸣定位（让耳机发出声音）
- 📍 自动记录断开时的 GPS 位置
- 📏 距离估算（很近/较近/中等/较远）

### 听力健康
- 📊 每日听音时长统计柱状图
- 📈 周/月趋势分析
- 🏥 WHO 听力安全标准对比
- 💡 健康建议（60/60 法则等）

### 声景白噪音
- 🌧️ 12 种白噪音：雨声/海浪/森林/雷雨/风声/篝火/咖啡馆/图书馆/火车/白噪音/粉红噪音/棕色噪音
- ⏰ 定时关闭（30分钟/1小时/2小时/不限）
- 🎚️ 独立音量控制

### 煲机助手
- 📡 白噪音热身 → 🌸 粉红噪音 → 📊 频率扫描 → 🎵 音乐播放 → ❄️ 自然冷却
- ⏱️ 约 13 小时全自动流程
- 📊 实时进度显示

### 设置
- 自动连接 / 低电量提醒 / 听力保护 / 最大音量限制 / 语言切换 / 清除缓存 / 恢复出厂

## 技术栈

| 层面 | 选择 |
|------|------|
| 框架 | Flutter 3.x |
| 蓝牙 | flutter_blue_plus |
| 状态管理 | Riverpod |
| 本地存储 | Hive |
| 图表 | fl_chart |
| 音频 | just_audio |
| 定位 | geolocator |

## 构建 APK

### 前提条件
1. 安装 Flutter SDK (>=3.0.0)
2. 安装 Android Studio 和 Android SDK
3. 配置好 Android 开发环境

### 步骤

```bash
# 1. 进入项目目录
cd monster_earphone

# 2. 安装依赖
flutter pub get

# 3. 运行代码生成（如果需要）
flutter pub run build_runner build --delete-conflicting-outputs

# 4. 构建 debug APK
flutter build apk --debug

# 5. 构建 release APK
flutter build apk --release

# APK 输出位置:
# build/app/outputs/flutter-apk/app-release.apk
```

### 安装到手机

```bash
# USB 连接手机后
flutter install

# 或手动安装 APK
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## 项目结构

```
lib/
├── main.dart              # 入口
├── app.dart               # App 配置
├── models/                # 数据模型 (Hive)
│   ├── device_model.dart
│   ├── eq_preset.dart
│   ├── listening_report.dart
│   └── soundscape.dart
├── services/              # 业务服务
│   ├── bluetooth_service.dart
│   ├── audio_service.dart
│   └── health_service.dart
├── screens/               # 页面
│   ├── home_screen.dart       # 仪表盘主页
│   ├── scan_screen.dart       # 蓝牙扫描
│   ├── eq_screen.dart         # 均衡器
│   ├── find_screen.dart       # 查找耳机
│   ├── health_screen.dart     # 听力健康
│   ├── soundscape_screen.dart # 白噪音
│   ├── burnin_screen.dart     # 煲机助手
│   └── settings_screen.dart   # 设置
├── widgets/               # 可复用组件
│   ├── cyber_card.dart
│   ├── battery_indicator.dart
│   ├── signal_radar.dart
│   ├── eq_visualizer.dart
│   └── cyber_button.dart
└── theme/                 # 暗黑科技风主题
    ├── app_theme.dart
    ├── app_colors.dart
    └── app_text_styles.dart
```

## 权限说明

- 蓝牙：扫描和连接耳机
- 位置：蓝牙扫描必需 + 记录耳机断开位置
- 存储：缓存数据
- 音频设置：系统音量控制
