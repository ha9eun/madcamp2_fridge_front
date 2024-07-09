import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../view_model/community_view_model.dart';
import '../model/board_model.dart';
import '../view_model/user_view_model.dart';

class AddPostPage extends StatefulWidget {
  final String writerId;

  AddPostPage({required this.writerId});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  String _selectedCategory = '자유';

  void _addPost() {
    final title = titleController.text;
    final content = contentController.text;
    if (title.isEmpty || content.isEmpty) {
      Fluttertoast.showToast(msg: '내용이 부족합니다');
      return;
    }

    final post = Board(
      boardId: 0,
      title: title,
      writerId: widget.writerId,
      content: content,
      createdAt: DateTime.now().toString(),
      category: _selectedCategory,
    );

    Provider.of<CommunityViewModel>(context, listen: false)
        .addPost(post)
        .then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('글 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '제목',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('분류', style: TextStyle(fontSize: 16)),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    items: <String>['자유', '질문', '공유']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    dropdownColor: Colors.grey[200], // 드롭다운 배경색 변경
                    style: TextStyle(color: Colors.black), // 드롭다운 텍스트 색상 변경
                  ),
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      labelText: '글 내용',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addPost,
              child: Text('글 등록'),
            ),
          ],
        ),
      ),
    );
  }
}
