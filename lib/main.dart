import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// 新增 Note 模型類
class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;
  
  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
}

// 新增 Drawer 模型類
class Drawer {
  final String id;
  String title;
  List<Note> notes;
  final DateTime createdAt;
  DateTime updatedAt;
  
  Drawer({
    String? id,
    required this.title,
    List<Note>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    notes = notes ?? [],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
}

class _MyHomePageState extends State<MyHomePage> {
  // 更新示例數據
  List<Note> notes = [
    Note(
      title: 'Meeting Notes', 
      content: 'Discuss project timeline'
    ),
    Note(
      title: 'Shopping List', 
      content: 'Buy groceries'
    ),
    Note(
      title: 'Ideas', 
      content: 'New app features'
    ),
  ];
  
  List<Drawer> drawers = [
    Drawer(title: '工作'),
    Drawer(title: '個人'),
    Drawer(title: '購物清單'),
  ];
  String? lastNoteDropDrawerId;
  // 新增一個 Map 來追踪每個抽屜的動畫狀態
  final Map<String, bool> _drawerAnimationStates = {};
  
  // 新增當前選中的抽屜
  Drawer? selectedDrawer;
  
  // 獲取要顯示的筆記列表
  List<Note> get displayedNotes => selectedDrawer?.notes ?? notes;
  
  // 獲取要顯示的標題
  String get displayedTitle => selectedDrawer?.title ?? widget.title;
  
  // 處理抽屜��方法
  void _animateDrawer(String drawerId) {
    setState(() {
      _drawerAnimationStates[drawerId] = true;
    });
    
    // 300ms 後重置動畫狀態和清除 lastNoteDropDrawerId
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _drawerAnimationStates[drawerId] = false;
          lastNoteDropDrawerId = null;
        });
      }
    });
  }

  // 新增方法：獲取不重複的抽屜名稱
  String _getUniqueDrawerTitle(String baseTitle) {
    // 移除尾部的數字和括號（如果有的話）
    final RegExp regex = RegExp(r'(.*?)(?:\s*\(\d+\))?$');
    final match = regex.firstMatch(baseTitle);
    final originalTitle = match?.group(1)?.trim() ?? baseTitle.trim();
    
    // 計算現有相同名稱的數量
    int count = drawers.where((drawer) {
      String existingTitle = drawer.title;
      // 移除現有抽屜名稱的數字後綴
      final existingMatch = regex.firstMatch(existingTitle);
      final existingOriginal = existingMatch?.group(1)?.trim() ?? existingTitle.trim();
      return existingOriginal == originalTitle;
    }).length;
    
    // 如果沒有重複，直接返回原始名稱
    if (count == 0) {
      return originalTitle;
    }
    
    // 有重複則添加數字
    return '$originalTitle (${count + 1})';
  }

  Future<void> _showAddDrawerDialog() async {
    String? drawerName = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        final TextEditingController controller = TextEditingController();
        
        return AlertDialog(
          title: Text('新增抽屜'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: '抽屜名稱',
              hintText: '請輸入抽屜名稱',
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                Navigator.of(dialogContext).pop(value.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
              child: Text('確定'),
            ),
          ],
        );
      },
    );

    // 在對話框關閉後處理結果
    if (drawerName != null && drawerName.isNotEmpty) {
      setState(() {
        // 使用 _getUniqueDrawerTitle 獲取不重複的名稱
        String uniqueTitle = _getUniqueDrawerTitle(drawerName);
        drawers.add(Drawer(title: uniqueTitle));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: selectedDrawer != null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedDrawer = null;
                  });
                },
              )
            : null,
        title: Text(displayedTitle),
      ),
      body: Column(
        children: [
          // 上半部分：筆記列表
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: ListView.builder(
                itemCount: displayedNotes.length,
                itemBuilder: (context, index) {
                  return Draggable<Note>(
                    data: displayedNotes[index],
                    feedback: Material(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.grey.withOpacity(0.5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.drag_indicator),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  displayedNotes[index].title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  displayedNotes[index].content,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.drag_indicator),
                      title: Text(displayedNotes[index].title),
                      subtitle: Text(
                        displayedNotes[index].content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // 下半部分：抽屜列表（只在未選擇抽屜時顯示）
          if (selectedDrawer == null)  // 新增條件
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: drawers.length,
                itemBuilder: (context, index) {
                  return DragTarget<Note>(
                    onWillAccept: (data) {
                      setState(() {
                        lastNoteDropDrawerId = drawers[index].id;
                      });
                      return true;
                    },
                    onLeave: (data) {
                      setState(() {
                        if (lastNoteDropDrawerId == drawers[index].id) {
                          lastNoteDropDrawerId = null;
                        }
                      });
                    },
                    onAccept: (note) {
                      setState(() {
                        lastNoteDropDrawerId = drawers[index].id;
                        drawers[index].notes.add(note);
                        drawers[index].updatedAt = DateTime.now();
                        notes.removeWhere((n) => n.id == note.id);
                        _animateDrawer(drawers[index].id);
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      bool isAnimating = _drawerAnimationStates[drawers[index].id] ?? false;
                      bool isSelected = lastNoteDropDrawerId == drawers[index].id;
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isSelected && candidateData.isNotEmpty
                              ? Colors.blue.withOpacity(0.1)
                              : null,
                          border: Border.all(
                            color: isAnimating ? Colors.green : Colors.transparent,
                            width: isAnimating ? 2 : 0,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.folder,
                            color: isSelected && candidateData.isNotEmpty
                                ? Colors.blue
                                : null,
                          ),
                          title: Text(drawers[index].title),
                          subtitle: Text('${drawers[index].notes.length} notes'),
                          onTap: () {
                            setState(() {
                              selectedDrawer = drawers[index];
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 新增筆記按鈕
            FloatingActionButton(
              heroTag: 'addNote',  // 防止多個 FAB 的 hero animation 衝突
              onPressed: () {
                // TODO: 實現添加新筆記的邏輯
              },
              child: const Icon(Icons.note_add),
              tooltip: '新增筆記',
            ),
            SizedBox(height: 16),  // 按鈕之間的間距
            // 新增抽屜按鈕（只在主視圖顯示）
            if (selectedDrawer == null)
              FloatingActionButton(
                heroTag: 'addDrawer',
                onPressed: () => _showAddDrawerDialog(),
                child: const Icon(Icons.create_new_folder),
                tooltip: '新增抽屜',
              ),
          ],
        ),
      ),
      // 調整 FAB 位置
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
