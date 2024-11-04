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
  
  // 處理抽屜動畫的方法
  void _animateDrawer(String drawerId) {
    setState(() {
      _drawerAnimationStates[drawerId] = true;
    });
    
    // 300ms 後重置動畫狀態
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _drawerAnimationStates[drawerId] = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Notes'),
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
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Draggable<Note>(
                    data: notes[index],
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
                                  notes[index].title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  notes[index].content,
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
                      title: Text(notes[index].title),
                      subtitle: Text(
                        notes[index].content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        // TODO: 實現查看/編輯筆記的邏輯
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          
          // 下半部分：抽屜列表
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: drawers.length,
              itemBuilder: (context, index) {
                return DragTarget<Note>(
                  onWillAccept: (data) {
                    // 當筆記懸停在抽屜上時的視覺反饋
                    setState(() {
                      lastNoteDropDrawerId = drawers[index].id;
                    });
                    return true;
                  },
                  onLeave: (data) {
                    // 當筆記離開抽屜區域時
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
                      // 觸發動畫
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
                        color: isSelected
                            ? Colors.blue.withOpacity(0.1)
                            : null,
                        border: Border.all(
                          color: isAnimating 
                              ? Colors.green 
                              : Colors.transparent,
                          width: isAnimating ? 2 : 0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.folder,
                              color: isSelected ? Colors.blue : null,
                            ),
                            title: Text(drawers[index].title),
                            subtitle: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                color: isAnimating 
                                    ? Colors.green 
                                    : Colors.grey,
                                fontWeight: isAnimating 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                              child: Text('${drawers[index].notes.length} notes'),
                            ),
                          ),
                          if (isAnimating)
                            Positioned(
                              right: 16,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 實現添加新筆記的邏輯
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
