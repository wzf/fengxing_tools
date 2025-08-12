### 功能说明
将某个文件夹下的文件重新命名，保持后缀名不变

### 配置文件
可以将以下配置直接放到/data/scripts.json下，也可以参照，在软件内配置
```json
{
    "id": 1755003859420,
    "title": "文件夹重命名",
    "file": "D:\\2025IP\\fengxing_tools\\scripts\\file_rename\\rename.py",
    "description": "",
    "params": [
        {
            "name": "directory",
            "label": "文件夹",
            "type": "folder"
        },
        {
            "name": "prefix",
            "label": "文件前缀",
            "type": "text"
        },
        {
            "name": "start_num",
            "label": "起始数字",
            "type": "text"
        }
    ]
}
```

### 脚本调用
> python rename.py -directory xxx文件夹 -prefix 新文件名前缀 -start_num 1
