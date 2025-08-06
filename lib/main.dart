import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';
import 'detail.dart';
import 'edit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    // 设置窗口标题
    windowManager.setTitle('峰行工具箱'); 
    // 设置窗口初始大小，例如宽1200高800
    await windowManager.setSize(const Size(1560, 860));
    // 可选：设置窗口最小尺寸
    await windowManager.setMinimumSize(const Size(900, 600));
    // 可选：居中显示
    await windowManager.center();
    // windowManager.setIcon('assets/icon.ico'); // 设置窗口图标（见下方）
  }
  // 初始化日志
  _initLogging();
  runApp(const MyApp());
}

void _initLogging() {
  Logger.root.level = Level.ALL; // 打印所有级别日志
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

final Logger log = Logger('MainLogger'); // 全局log对象

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '峰行工具箱',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> scriptList = [];
  int? selectedIndex; // 当前选中的脚本索引

  // 新增：新增或编辑脚本方法
  Future<void> addOrUpdateScript([Map<String, dynamic>? script]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: FractionallySizedBox(
            widthFactor: 0.6,
            heightFactor: 0.9,
            child: Material(
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: EditScriptPage(script: script),
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        if (script == null) {
          // 新增
          scriptList.add(result);
        } else {
          // 编辑
          final idx = scriptList.indexOf(script);
          if (idx != -1) {
            scriptList[idx] = result;
          }
        }
      });
    }
  }

  @override
  void initState() {
    log.info("61 ==== 开始");
    super.initState();
    loadScripts();
  }

  Future<void> loadScripts() async {
    final String jsonStr = await rootBundle.loadString('data/scripts.json');
    final List<dynamic> data = json.decode(jsonStr);
    log.info('Loaded scripts: $data'); // 使用log打印
    setState(() {
      scriptList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧固定宽度60
          Container(
            width: 60,
            color: const Color.fromARGB(255, 41, 41, 41),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 上部分：脚本按钮和新增按钮
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    children: [
                      Tooltip(
                        message: '脚本',
                        child: IconButton(
                          icon: const Icon(Icons.code),
                          iconSize: 32,
                          color: Colors.white,
                          focusColor: Color.fromARGB(255, 28, 252, 121),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 8),
                      Tooltip(
                        message: '新增脚本',
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          iconSize: 28,
                          color: Colors.white,
                          focusColor: Color.fromARGB(255, 28, 252, 121),
                          onPressed: () => addOrUpdateScript(),
                        ),
                      ),
                    ],
                  ),
                ),
                // 下部分：设置和更多按钮
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: '设置',
                        child: IconButton(
                          icon: const Icon(Icons.settings),
                          iconSize: 28,
                          color: Colors.white,
                          focusColor: Color.fromARGB(255, 28, 252, 121),
                          onPressed: () {},
                        ),
                      ),
                      SizedBox(height: 12),
                      Tooltip(
                        message: '更多',
                        child: IconButton(
                          icon: const Icon(Icons.more_vert),
                          iconSize: 28,
                          color: Colors.white,
                          focusColor: Color.fromARGB(255, 28, 252, 121),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 中间固定宽度360
          Container(
            width: 360,
            color: Colors.grey[300],
            child: scriptList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: scriptList.length,
                    itemBuilder: (context, index) {
                      final item = scriptList[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedIndex == index
                                ? Colors.white
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: selectedIndex == index
                                ? Border.all(color: Colors.deepPurple, width: 2)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // title 第一行，超出...显示
                              Text(
                                item['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // file 第二行，超出...显示
                              Text(
                                item['file'] ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // 右侧占满剩余空间
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: selectedIndex == null
                  ? const Center(child: Text('请选择一个脚本'))
                  : DetailWidget(
                      script: scriptList[selectedIndex!],
                      onEdit: () => addOrUpdateScript(
                        scriptList[selectedIndex!],
                      ), // 传递编辑方法
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
