import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class EditScriptPage extends StatefulWidget {
  final Map<String, dynamic>? script; // 传入为null表示新增，否则为编辑

  const EditScriptPage({super.key, this.script});

  @override
  State<EditScriptPage> createState() => _EditScriptPageState();
}

class _EditScriptPageState extends State<EditScriptPage> {
  late TextEditingController titleController;
  late TextEditingController fileController;
  late TextEditingController descController;
  late List<Map<String, String>> params;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
      text: widget.script?['title'] ?? '',
    );
    fileController = TextEditingController(text: widget.script?['file'] ?? '');
    descController = TextEditingController(
      text: widget.script?['description'] ?? '',
    );
    params =
        (widget.script?['params'] as List?)
            ?.map<Map<String, String>>(
              (e) => {
                'name': e['name'] ?? '',
                'label': e['label'] ?? '',
                'type': e['type'] ?? '',
              },
            )
            .toList() ??
        [];
  }

  @override
  void dispose() {
    titleController.dispose();
    fileController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> saveToJsonFile(Map<String, dynamic> script) async {
    final filePath = 'data/scripts.json';
    // 1. 读取原有数据
    List<dynamic> scripts = [];
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        scripts = json.decode(content);
      } else {
        // 如果文件不存在，尝试从assets读取初始内容
        final assetContent = await rootBundle.loadString(filePath);
        scripts = json.decode(assetContent);
      }
    } catch (e) {
      scripts = [];
    }

    // 2. 判断是新增还是编辑
    int idx = -1;
    if (widget.script != null) {
      idx = scripts.indexWhere(
        (item) =>
            item['title'] == widget.script!['title'] &&
            item['file'] == widget.script!['file'],
      );
    }
    if (idx != -1) {
      scripts[idx] = script; // 编辑
    } else {
      scripts.add(script); // 新增
    }

    // 3. 写回文件
    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(scripts),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.script != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? '编辑脚本' : '新增脚本')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          24.0,
          8.0,
          24.0,
          16.0,
        ), // 左上右下(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1.2 标题输入框
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '输入一个方便自己记忆的名称',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            // 1.3 文件选择框
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fileController,
                    decoration: const InputDecoration(
                      labelText: '选择脚本文件路径（支持Python）',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['py'],
                        );
                    if (result != null && result.files.single.path != null) {
                      setState(() {
                        fileController.text = result.files.single.path!;
                      });
                    }
                  },
                  child: const Text('选择文件'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 1.4 描述输入框
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: '描述脚本实现的功能，注意点',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            // 1.5 参数配置区
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '参数配置',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      params.add({'name': '', 'label': '', 'type': 'text'});
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('新增参数'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 表头
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: const [
                  Expanded(child: Text('变量')),
                  Expanded(child: Text('显示')),
                  Expanded(child: Text('类型')),
                  SizedBox(width: 40), // 删除按钮占位
                ],
              ),
            ),
            // 表格内容
            Expanded(
              child: ListView.builder(
                itemCount: params.length,
                itemBuilder: (context, idx) {
                  return Row(
                    children: [
                      // name
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            controller:
                                TextEditingController(text: params[idx]['name'])
                                  ..selection = TextSelection.collapsed(
                                    offset: params[idx]['name']?.length ?? 0,
                                  ),
                            onChanged: (v) => params[idx]['name'] = v,
                          ),
                        ),
                      ),
                      // label
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            controller:
                                TextEditingController(
                                    text: params[idx]['label'],
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: params[idx]['label']?.length ?? 0,
                                  ),
                            onChanged: (v) => params[idx]['label'] = v,
                          ),
                        ),
                      ),
                      // type
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: DropdownButtonFormField<String>(
                            value: params[idx]['type'] == 'folder'
                                ? 'folder'
                                : 'text',
                            items: const [
                              DropdownMenuItem(
                                value: 'text',
                                child: Text('text'),
                              ),
                              DropdownMenuItem(
                                value: 'folder',
                                child: Text('folder'),
                              ),
                            ],
                            onChanged: (v) => setState(
                              () => params[idx]['type'] = v ?? 'text',
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      // 删除按钮
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 128, 128, 128),
                        ),
                        onPressed: () {
                          setState(() {
                            params.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            // 1.6 按钮区域
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final script = {
                      'id': widget.script?['id'] ?? DateTime.now().millisecondsSinceEpoch, // 新增ID
                      'title': titleController.text,
                      'file': fileController.text,
                      'description': descController.text,
                      'params': params,
                    };
                    await saveToJsonFile(script); // 写回json文件
                    if (!mounted) return; // 关键：判断当前widget是否还在树上
                    Navigator.of(context).pop(script); // 返回数据
                  },
                  child: Text(isEdit ? '修改' : '新增'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
