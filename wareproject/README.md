# WareProject - 项目管理模块

## 概述

WareProject 是一个完整的项目管理模块，为 libeditor 工程提供分层数据架构和项目管理功能。

## 架构设计

### 分层结构

```
wareproject/
├── ProgramModel.qml      # 核心数据模型
├── ProjectManager.qml    # 项目管理界面
├── ProjectConfig.qml     # 项目配置界面
├── ProjectStats.qml      # 项目统计界面
├── ProjectWorkspace.qml  # 主工作空间
└── README.md            # 说明文档
```

### 数据流向

```
上层: ProjectWorkspace (主界面)
  ↓
中层: ProjectManager/ProjectConfig/ProjectStats (功能模块)
  ↓
下层: ProgramModel (数据模型)
  ↓
底层: projects/ 目录 (文件存储)
```

## 组件说明

### 1. ProgramModel.qml
**核心数据模型**
- 项目数据管理（创建、加载、保存、删除）
- 模块、点位、回路数据模型
- 配置管理和历史记录
- 数据导入导出功能

**主要功能：**
- `loadProject(projectName)` - 加载项目
- `saveProject()` - 保存项目
- `createProject(name, desc, template)` - 创建项目
- `deleteProject(projectName)` - 删除项目
- `addModule(moduleData)` - 添加模块
- `addPoint(pointData)` - 添加点位
- `addLoop(loopData)` - 添加回路

### 2. ProjectManager.qml
**项目管理界面**
- 项目列表显示和搜索
- 项目创建、删除操作
- 项目信息展示
- 操作历史记录

**主要特性：**
- 支持多种项目文件格式（JSON、INI、TXT）
- 项目搜索和过滤
- 可视化项目状态
- 批量操作支持

### 3. ProjectConfig.qml
**项目配置界面**
- 基本信息配置（名称、描述、版本）
- 系统配置（自动保存、备份设置）
- 模块配置（默认类型、编号规则）
- 通信配置（协议、波特率、超时）

**配置项：**
- 自动保存间隔
- 最大备份数量
- 历史记录限制
- 模块编号前缀
- 默认通信协议

### 4. ProjectStats.qml
**项目统计界面**
- 基本统计信息（模块、点位、回路数量）
- 项目信息展示
- 模块类型分布图表
- 操作历史记录
- 数据导出功能

**统计功能：**
- 实时数据统计
- 图表可视化
- 历史记录管理
- 多格式导出（JSON、CSV）

### 5. ProjectWorkspace.qml
**主工作空间**
- 整合所有功能模块
- 标签页切换界面
- 工具栏和状态栏
- 项目状态指示

## 使用方法

### 1. 基本使用

```qml
import QtQuick 2.14
import "./wareproject"

ApplicationWindow {
    ProjectWorkspace {
        anchors.fill: parent
    }
}
```

### 2. 单独使用数据模型

```qml
import QtQuick 2.14
import "./wareproject"

Item {
    ProgramModel {
        id: programModel
        
        onProjectLoaded: function(projectName) {
            console.log("项目已加载:", projectName);
        }
    }
    
    Component.onCompleted: {
        // 加载项目
        programModel.loadProject("项目A.json");
        
        // 添加模块
        programModel.addModule({
            name: "新模块",
            type: "sensor",
            code: "SENSOR_001"
        });
        
        // 保存项目
        programModel.saveProject();
    }
}
```

### 3. 与现有系统集成

在 `warelayout/Libraries.qml` 中已经集成了项目选择功能：

```qml
// 选择项目时自动加载到 programModel
function selectProject(projectName) {
    if (typeof programModel !== "undefined") {
        programModel.loadProject(projectName);
    }
}
```

## 数据格式

### 项目文件格式（JSON）

```json
{
    "projectName": "项目名称",
    "description": "项目描述",
    "version": "1.0.0",
    "createTime": "2024-01-01 10:00:00",
    "updateTime": "2024-01-01 12:00:00",
    "modules": [
        {
            "id": "module_001",
            "name": "模块1",
            "type": "sensor",
            "code": "SENSOR_001",
            "description": "传感器模块",
            "config": {}
        }
    ],
    "points": [
        {
            "id": "point_001",
            "name": "点位1",
            "address": "1-1-1",
            "type": "input",
            "moduleId": "module_001"
        }
    ],
    "loops": [
        {
            "id": "loop_001",
            "name": "回路1",
            "description": "主回路",
            "points": [
                {"index": 0, "seek": "1-1-1"},
                {"index": 1, "seek": "2-2-2"}
            ]
        }
    ],
    "config": {
        "autoSave": true,
        "autoSaveInterval": 5,
        "backupEnabled": true,
        "maxBackup": 5,
        "maxHistory": 50,
        "module": {
            "defaultType": "sensor",
            "codePrefix": "MOD",
            "autoGenerateCode": true
        },
        "communication": {
            "defaultProtocol": "Modbus RTU",
            "defaultBaudRate": "115200",
            "timeout": 1000
        }
    }
}
```

## 扩展开发

### 添加新的数据类型

1. 在 `ProgramModel.qml` 中添加新的 ListModel
2. 实现相应的增删改查方法
3. 在保存和加载函数中处理新数据类型
4. 在界面组件中添加相应的显示和编辑功能

### 添加新的配置项

1. 在 `ProjectConfig.qml` 中添加新的配置界面
2. 在 `ProgramModel.qml` 的配置处理函数中添加新字段
3. 更新默认配置模板

### 自定义项目模板

在 `createProjectTemplate` 函数中添加新的模板类型：

```javascript
case "custom":
    baseTemplate.modules.push({
        "id": "custom_001",
        "name": "自定义模块",
        "type": "custom",
        "code": "CUSTOM_001"
    });
    break;
```

## 注意事项

1. **文件路径**: 所有项目文件存储在 `projects/` 目录下
2. **数据同步**: 修改数据后需要调用 `saveProject()` 保存
3. **错误处理**: 监听 `projectError` 信号处理错误情况
4. **性能优化**: 大量数据时建议使用分页加载
5. **备份机制**: 启用自动备份以防数据丢失

## 版本历史

- v1.0.0: 初始版本，包含基本的项目管理功能
- 支持项目创建、编辑、删除
- 支持模块、点位、回路管理
- 支持配置管理和统计功能
- 支持数据导入导出 