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
                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '제목',
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
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
                      labelStyle: TextStyle(color: Colors.black),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // 버튼을 우측으로 옮김
              children: [
                ElevatedButton(
                  onPressed: _editPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text('글 수정', style: TextStyle(color: Theme.of(context).primaryColor)), // 폰트 색을 primaryColor로 설정
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
