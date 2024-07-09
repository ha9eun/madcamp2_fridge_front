import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../view_model/community_view_model.dart';
import '../model/board_model.dart';

class EditPostPage extends StatefulWidget {
  final Board post;

  EditPostPage({required this.post});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  String _selectedCategory = '자유';

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.post.title);
    contentController = TextEditingController(text: widget.post.content);
    _selectedCategory = widget.post.category;
  }

  void _editPost() {
    final title = titleController.text;
    final content = contentController.text;
    if (title.isEmpty || content.isEmpty) {
      Fluttertoast.showToast(msg: '내용이 부족합니다');
      return;
    }

    final updatedPost = Board(
      boardId: widget.post.boardId,
      title: title,
      writerId: widget.post.writerId,
      content: content,
      createdAt: widget.post.createdAt,
      category: _selectedCategory,
      writerNickname: widget.post.writerNickname,
    );

    Provider.of<CommunityViewModel>(context, listen: false)
        .editPost(updatedPost)
        .then((_) {
      Fluttertoast.showToast(msg: '수정되었습니다');
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('글 수정')),
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
              onPressed: _editPost,
              child: Text('글 수정'),
            ),
          ],
        ),
      ),
    );
  }
}
