import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
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
  int menuIndex = 0; // 当前选中的菜单索引，0=脚本

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
      loadScripts(); // 刷新脚本列表
    }
  }

  @override
  void initState() {
    log.info("61 ==== 开始");
    super.initState();
    loadScripts();
  }

  String getDataFilePath() {
    final docDir = Directory('${Directory.current.path}/config');
    if (!docDir.existsSync()) {
      docDir.createSync(recursive: true);
    }
    return p.join(docDir.path, 'scripts.json');
  }

  Future<void> loadScripts() async {
    final filePath = getDataFilePath();
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('[]');
    }
    String jsonStr = await file.readAsString();
    List<dynamic> data = json.decode(jsonStr);
    log.info('Loaded scripts: $data'); // 使用log打印
    int? iSelectedIndex = selectedIndex;
    if (iSelectedIndex != null && iSelectedIndex >= data.length) {
      iSelectedIndex = null; // 如果之前的索引超出范围，重置为null
    }
    setState(() {
      scriptList = data;
      selectedIndex = iSelectedIndex;
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: menuIndex == 0
                                ? Colors.white24
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.code_outlined,
                              color: menuIndex == 0
                                  ? const Color.fromARGB(255, 28, 252, 121)
                                  : Colors.white,
                            ),
                            iconSize: 28,
                            highlightColor: Colors.white54,
                            isSelected: menuIndex == 0,
                            onPressed: () {
                              setState(() {
                                menuIndex = 0;
                                selectedIndex = null;
                              });
                              loadScripts(); // 刷新脚本列表
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Tooltip(
                        message: '新增脚本',
                        child: IconButton(
                          icon: const Icon(Icons.add_outlined),
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
                          icon: const Icon(Icons.settings_outlined),
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
                          icon: const Icon(Icons.more_vert_outlined),
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
                ? const Center(
                    child: Text(
                      '当前没有配置任何脚本，\n点击左侧+号，创建脚本',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
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
                            horizontal: 8,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedIndex == index
                                ? Colors.white
                                : Colors.grey[50],
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
                      onRefresh: loadScripts, // 刷新脚本列表
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
