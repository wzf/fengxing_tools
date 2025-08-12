### 功能说明
将某个图片缩放到指定尺寸，并且进行质量压缩，比如原来的图片a.jpg是1024x1024的，我希望压缩以后，成为108x108，压缩质量是0.9，得到新文件a_s.jpg

### 配置文件
可以将以下配置直接放到/data/scripts.json下，也可以参照，在软件内配置
```json
{
    "id": 1755006159413,
    "title": "图片缩放",
    "file": "D:\\2025IP\\fengxing_tools\\scripts\\image_resize\\resize.py",
    "description": "",
    "params": [
      {
        "name": "input_path",
        "label": "图片",
        "type": "file",
        "value": "C:\\Users\\admin\\Downloads\\1111.png"
      },
      {
        "name": "width",
        "label": "宽度",
        "type": "text",
        "value": "108"
      },
      {
        "name": "height",
        "label": "高度",
        "type": "text",
        "value": "108"
      },
      {
        "name": "quality",
        "label": "压缩质量",
        "type": "text",
        "value": "0.9"
      },
      {
        "name": "output_suffix",
        "label": "新文件后缀名",
        "type": "text",
        "value": "_s"
      }
    ]
  }
```

### 脚本调用
> python resize.py -input_path 图片路径 -width 128 -height 128 -quality 0.85 -output_suffix _s
