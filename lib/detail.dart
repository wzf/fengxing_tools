import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DetailWidget extends StatefulWidget {
  final Map script;
  final VoidCallback? onEdit; // 新增：编辑回调
  final VoidCallback? onRefresh; // 刷新：编辑回调
  const DetailWidget({super.key, required this.script, this.onEdit, this.onRefresh});

  @override
  State<DetailWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  int navIndex = 0; // 0: 参数配置, 1: 运行窗口
  late Map<String, dynamic> paramValues;
  String runOutput = '';
  bool running = false;

  @override
  void initState() {
    super.initState();
    paramValues = {};
    if (widget.script['params'] is List) {
      for (var param in widget.script['params']) {
        paramValues[param['name']] = '';
      }
    }
  }

  @override
  void didUpdateWidget(covariant DetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.script != widget.script) {
      paramValues = {};
      if (widget.script['params'] is List) {
        for (var param in widget.script['params']) {
          paramValues[param['name']] = '';
        }
      }
      runOutput = '';
      navIndex = 0;
    }
  }

  // 删除按钮
  Future<void> _onDeletePressed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('是否删除该脚本？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    // 点击确定后，更新本地存储
    if (confirm == true) {
      final filePath = 'data/scripts.json';
      List<dynamic> scripts = [];
      try {
        final file = File(filePath);
        if (await file.exists()) {
          final content = await file.readAsString();
          scripts = json.decode(content);
        }
      } catch (e) {
        scripts = [];
      }
      scripts.removeWhere((item) =>
        item['id'] == widget.script['id']
      );
      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(scripts),
      );
      if (mounted) {
        widget.onRefresh?.call(); // 调用刷新回调
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final script = widget.script;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：标题和编辑icon
          Row(
            children: [
              Expanded(
                child: Text(
                  script['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: widget.onEdit,
                tooltip: '编辑',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: '删除',
                onPressed: _onDeletePressed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 第二行：简介
          Text(
            script['description'] ?? '',
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // 第三行：文件路径
          Text(
            script['file'] ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // 第四行：导航栏
          Row(
            children: [
              _buildNavItem('参数配置', 0),
              const SizedBox(width: 16),
              _buildNavItem('运行窗口', 1),
            ],
          ),
          const SizedBox(height: 16),
          // 第五行：内容区
          Expanded(child: navIndex == 0 ? _buildParamsArea() : _buildRunArea()),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, int idx) {
    return GestureDetector(
      onTap: () {
        setState(() {
          navIndex = idx;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: navIndex == idx ? Colors.deepPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: navIndex == idx ? Colors.white : Colors.black87,
            fontWeight: navIndex == idx ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildParamsArea() {
    final params = widget.script['params'] as List<dynamic>? ?? [];
    // 用于临时存储输入框的值
    Map<String, TextEditingController> controllers = {};

    // 初始化controllers
    for (var param in params) {
      controllers[param['name']] = TextEditingController(
        text: param['value'] ?? '',
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: params.length,
            itemBuilder: (context, idx) {
              final param = params[idx];
              final name = param['name'] ?? '';
              final label = param['label'] ?? '';
              final type = param['type'] ?? 'text';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(label, style: const TextStyle(fontSize: 15)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: type == 'text'
                          ? TextField(
                              controller: controllers[name],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                              ),
                              onChanged: (v) {},
                            )
                          : GestureDetector(
                              onTap: () async {
                                String? folder = await FilePicker.platform
                                    .getDirectoryPath();
                                if (folder != null) {
                                  controllers[name]?.text = folder;
                                  setState(() {});
                                }
                              },
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  controllers[name]?.text ?? '',
                                  style: const TextStyle(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Footer 操作按钮行
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async {
                // 1. 更新params的value字段
                for (var param in params) {
                  param['value'] = controllers[param['name']]?.text ?? '';
                }
                // 2. 读取原有脚本数据
                final filePath = 'data/scripts.json';
                List<dynamic> scripts = [];
                try {
                  final file = File(filePath);
                  if (await file.exists()) {
                    final content = await file.readAsString();
                    scripts = json.decode(content);
                  }
                } catch (e) {
                  scripts = [];
                }
                // 3. 找到当前脚本并更新
                int idx = scripts.indexWhere(
                  (item) =>
                      item['title'] == widget.script['title'] &&
                      item['file'] == widget.script['file'],
                );
                if (idx != -1) {
                  scripts[idx]['params'] = params;
                  final file = File(filePath);
                  await file.writeAsString(
                    const JsonEncoder.withIndent('  ').convert(scripts),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('参数已保存')));
                  }
                }
              },
              child: const Text('保存'),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {
                // 清空输入框，但不影响data/scripts.json
                for (var ctrl in controllers.values) {
                  ctrl.text = '';
                }
                setState(() {});
              },
              child: const Text('重置'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRunArea() {
    final ScrollController scrollController = ScrollController();

    // 每次runOutput变化时自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('运行'),
          onPressed: running ? null : _runScript,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black,
            width: double.infinity,
            child: Scrollbar(
              thumbVisibility: true,
              controller: scrollController,
              thickness: 8,
              radius: const Radius.circular(6),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Text(
                  runOutput,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _runScript() async {
    setState(() {
      running = true;
      runOutput = '';
    });
    try {
      // 拼接参数
      final scriptFile = widget.script['file'];
      final args = <String>[];
      final params = widget.script['params'] as List<dynamic>? ?? [];
      for (var param in params) {
        final name = param['name'];
        final value = paramValues[name] ?? '';
        args.add(value);
      }
      // 调用python脚本
      final process = await Process.start('python', [
        scriptFile,
        ...args,
      ], runInShell: true);
      process.stdout.transform(SystemEncoding().decoder).listen((data) {
        setState(() {
          runOutput += data;
        });
      });
      process.stderr.transform(SystemEncoding().decoder).listen((data) {
        setState(() {
          runOutput += data;
        });
      });
      await process.exitCode;
    } catch (e) {
      setState(() {
        runOutput += '\n[Error] $e';
      });
    }
    setState(() {
      running = false;
    });
  }
}
