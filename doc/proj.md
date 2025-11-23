# 项目说明

## 项目简介
GitHub Follow Contributions 用于汇总你关注的 GitHub 用户近期贡献，按仓库与事件类型聚合，并生成简洁的文字摘要与可浏览页面，支持 Web 与 Android。

## 架构与数据流
- Python 脚本抓取与分析 → 生成 `public/events.json`
- 前端展示：Vue 站点或 Flutter Web/Android 读取并渲染事件与摘要

## 核心模块与目录
- `main.py`：获取关注用户、拉取事件、过滤与排序、生成 `events.json`
- `event_analysis.py`：事件分类与话题总结，调用 LLM 生成不超过 60 字摘要
- `frontend/`：Vue3+Vite 前端页面
- `ghfc_app/`：Flutter 应用（Web/Android），`provider` 管理状态
- `public/events.json`：前端数据源

## 技术栈
- Python、OpenAI API、YAML/JSON
- Vue3 + Vite
- Flutter（Material 3、provider）
- GitHub Pages 部署

## 使用与构建
- 数据生成：配置 `.env`（如 `OPENAI_API_KEY`、`GITHUB_TOKEN`），运行 `python main.py`
- Vue 本地预览：`npm install`、`npm run dev`
- Flutter Web 构建：`flutter build web` 或使用提供的构建脚本

## 配置与过滤
- 关注列表：`all.yaml` 全量；可复制成 `special.yaml` 做定向关注
- 事件类型过滤：工作/讨论/观察三类，前端支持按类型显示

## 近期变更要点
- 推进 Flutter 迁移与 Web/Android 构建
- 重构事件分析与摘要逻辑并增加单测
- 完善构建与环境检测脚本