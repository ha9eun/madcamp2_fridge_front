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
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('히스토리'),
      ),
      body: Consumer<HistoryViewModel>(
        builder: (context, historyViewModel, child) {
          if (historyViewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: historyViewModel.histories.length,
            itemBuilder: (context, index) {
              final reversedIndex = historyViewModel.histories.length - 1 - index;
              final history = historyViewModel.histories[reversedIndex];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(
                    history.recipeName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...history.ingredients.map((ingredient) => Text(
                        '${ingredient.foodName}: ${ingredient.amount}${ingredient.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      )),
                      Text(
                        '시간: ${_formatDate(history.time)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
