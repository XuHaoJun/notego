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
  String? selectedDrawer;

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
                  onAcceptWithDetails: (target) {
                    setState(() {
                      selectedDrawer = drawers[index].title;
                      var draggingNote = target.data;
                      // 將筆記添加到選定的抽屜中
                      drawers[index].notes.add(draggingNote);
                      // 更新抽屜的 updatedAt
                      drawers[index].updatedAt = DateTime.now();
                      // 從原始列表中移除筆記（使用 id 比較）
                      notes.removeWhere((n) => n.id == draggingNote.id);
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return ListTile(
                      tileColor: selectedDrawer == drawers[index].title 
                          ? Colors.blue.withOpacity(0.1) 
                          : null,
                      leading: Icon(Icons.folder),
                      title: Text(drawers[index].title),
                      subtitle: Text('${drawers[index].notes.length} notes'),
                      onTap: () {
                        // TODO: 實現查看抽屜內容的邏輯
                      },
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
