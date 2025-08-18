### 功能说明
将二维码图片解析出来

### 配置文件
可以将以下配置直接放到/data/scripts.json下，也可以参照，在软件内配置
```json
{
    "id": 1755003859420,
    "title": "二维码解码",
    "file": "D:\\2025IP\\fengxing_tools\\scripts\\barcode\\barcode_de.py",
    "description": "",
    "params": [
        {
            "file": "file",
            "label": "二维码图片",
            "type": "file"
        }
    ]
}
```

### 脚本调用
> python barcode_de.py -file xxx/xxx.jpeg

### 依赖
> pip install pyzbar
