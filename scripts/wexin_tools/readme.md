### 功能说明
按照配置文件依次发送微信消息，支持文本和文件。需要配合message.xlsx模板一块使用

### 配置文件
可以将以下配置直接放到/data/scripts.json下，也可以参照，在软件内配置
```json
{
    "id": 1756691547798,
    "title": "微信批量发送消息",
    "file": "E:\\fengxing_tools\\scripts\\wexin_tools\\send.py",
    "description": "",
    "params": [
      {
        "name": "message_file",
        "label": "消息配置文件",
        "type": "file",
        "value": "E:\\fengxing_tools\\scripts\\wexin_tools\\message.xlsx"
      }
    ]
  }
```

### 脚本调用
> python send.py -message_file E:\\fengxing_tools\\scripts\\wexin_tools\\message.xlsx
