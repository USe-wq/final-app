import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CategoryPage(),
    );
  }
}

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // 定義分類群
  List<String> categories = [
    '生活',
    '運動',
    '身體健康',
    '支出',
    '重要事項',
  ];

  // 用於存儲每個分類的項目
  final Map<String, List<Map<String, dynamic>>> categoryItems = {
    '生活': [],
    '運動': [],
    '身體健康': [],
    '支出': [],
    '重要事項': [],
  };

  // 釘選分類列表
  final List<String> pinnedCategories = [];

  final TextEditingController _categoryController = TextEditingController();

  void _addCategory() {
    String newCategory = _categoryController.text;
    if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
      setState(() {
        categories.add(newCategory);
        categoryItems[newCategory] = []; // 新增對應的項目列表
      });
      _categoryController.clear();
    }
  }

  void _deleteCategory(String category) {
    setState(() {
      categories.remove(category);
      pinnedCategories.remove(category); // 從釘選中移除
      categoryItems.remove(category); // 刪除對應的項目列表
    });
  }

  void _togglePin(String category) {
    setState(() {
      if (pinnedCategories.contains(category)) {
        pinnedCategories.remove(category);
      } else {
        pinnedCategories.add(category);
      }
    });
  }

  List<String> _getDisplayCategories() {
    // 釘選的分類置頂，其餘分類按原順序排列
    return [
      ...pinnedCategories,
      ...categories.where((category) => !pinnedCategories.contains(category))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('分類群管理'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      hintText: '新增分類',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: Text('新增分類'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getDisplayCategories().length,
              itemBuilder: (context, index) {
                String category = _getDisplayCategories()[index];
                bool isPinned = pinnedCategories.contains(category);

                return Card(
                  margin: EdgeInsets.all(8),
                  color: isPinned ? Colors.yellow[100] : Colors.white, // 釘選時背景變黃色
                  child: ListTile(
                    title: Text(
                      category,
                      style: TextStyle(
                        color: isPinned ? Colors.orange : Colors.black, // 釘選時文字變橙色
                      ),
                    ),
                    leading: IconButton(
                      icon: Icon(
                        isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      ),
                      onPressed: () => _togglePin(category),
                    ),
                    trailing: category != '支出'
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () {
                            // 點擊進入對應分類的項目頁面
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteApp(
                                  category: category,
                                  categoryItems: categoryItems,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(category),
                        ),
                      ],
                    )
                        : IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteApp(
                              category: category,
                              categoryItems: categoryItems,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NoteApp extends StatefulWidget {
  final String category; // 接收分類名稱
  final Map<String, List<Map<String, dynamic>>> categoryItems;

  NoteApp({required this.category, required this.categoryItems});

  @override
  _NoteAppState createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  late List<Map<String, dynamic>> _items; // 保存當前分類的項目列表
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化時從全局數據中獲取對應分類的項目列表
    _items = widget.categoryItems[widget.category]!;
  }

  void _addItem() {
    if (_nameController.text.isNotEmpty &&
        (widget.category == '支出'
            ? (_amountController.text.isNotEmpty &&
            double.tryParse(_amountController.text) != null)
            : _noteController.text.isNotEmpty)) {
      setState(() {
        if (widget.category == '支出') {
          _items.add({
            'name': _nameController.text,
            'amount': double.parse(_amountController.text),
          });
        } else {
          _items.add({
            'name': _nameController.text,
            'note': _noteController.text,
          });
        }
      });
      widget.categoryItems[widget.category] = _items; // 更新全局的分類項目
      _nameController.clear();
      _amountController.clear();
      _noteController.clear(); // 清空輸入框
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index); // 刪除指定索引的項目
    });
    widget.categoryItems[widget.category] = _items; // 更新全局的分類項目
  }

  double _calculateTotal() {
    return widget.category == '支出'
        ? _items.fold(0, (sum, item) => sum + item['amount'])
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} 分類'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: '輸入名稱',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                if (widget.category == '支出')
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '輸入金額',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                if (widget.category != '支出')
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: '輸入備註',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  child: Text('新增'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('名稱: ${_items[index]['name']}'),
                    subtitle: widget.category == '支出'
                        ? Text('金額: \$${_items[index]['amount'].toStringAsFixed(2)}')
                        : Text('備註: ${_items[index]['note']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(index), // 點擊刪除按鈕
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.category == '支出')
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.blueGrey[50],
              child: Text(
                '總金額: \$${_calculateTotal().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
