import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../view_model/history_view_model.dart';
import '../view_model/user_view_model.dart';

class HistoryListView extends StatefulWidget {
  @override
  _HistoryListViewState createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final historyViewModel = Provider.of<HistoryViewModel>(context, listen: false);
    await historyViewModel.fetchHistory(userViewModel.kakaoId);
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy년 MM월 dd일 HH시 mm분');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Consumer<HistoryViewModel>(
        builder: (context, historyViewModel, child) {
          if (historyViewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 0.0),
                  child: Text(
                    '나의 식사 히스토리',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(
                  color: Theme.of(context).primaryColor,
                  thickness: 2,
                  endIndent: 16,
                  indent: 16,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: historyViewModel.histories.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = historyViewModel.histories.length - 1 - index;
                    final history = historyViewModel.histories[reversedIndex];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.restaurant_menu, color: Theme.of(context).primaryColor),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    history.recipeName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ...history.ingredients.map((ingredient) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                '${ingredient.foodName}: ${ingredient.amount}${ingredient.unit}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            )),
                            SizedBox(height: 8),
                            Text(
                              _formatDate(history.time),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
