import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/ingredient_view_model.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:flutter/services.dart';

import '../model/ingredient.dart';
import '../model/ingredient_service.dart';

class EditIngredientDialog extends StatefulWidget {
  final Ingredient ingredient;

  EditIngredientDialog({required this.ingredient});

  @override
  _EditIngredientDialogState createState() => _EditIngredientDialogState();
}

class _EditIngredientDialogState extends State<EditIngredientDialog> {
  final TextEditingController amountController = TextEditingController();
  int? selectedYear;
  int? selectedMonth;
  int? selectedDay;

  @override
  void initState() {
    super.initState();
    amountController.text = widget.ingredient.amount.toString();
    final expirationDateParts = widget.ingredient.expirationDate.split('-');
    selectedYear = int.tryParse(expirationDateParts[0]);
    selectedMonth = int.tryParse(expirationDateParts[1]);
    selectedDay = int.tryParse(expirationDateParts[2]);
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  List<int> _getDaysInMonth(int year, int month) {
    return List<int>.generate(DateUtils.getDaysInMonth(year, month), (i) => i + 1);
  }

  @override
  Widget build(BuildContext context) {
    final ingredientViewModel = Provider.of<IngredientViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return AlertDialog(
      title: Text('재료 수정'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: '양'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    hint: Text('년'),
                    value: selectedYear,
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value;
                        if (selectedMonth != null) {
                          selectedDay = null;
                        }
                      });
                    },
                    items: List.generate(11, (index) => DateTime.now().year + index)
                        .map((year) => DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    hint: Text('월'),
                    value: selectedMonth,
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                        selectedDay = null;
                      });
                    },
                    items: List.generate(12, (index) => index + 1)
                        .map((month) => DropdownMenuItem<int>(
                      value: month,
                      child: Text(month.toString()),
                    ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    hint: Text('일'),
                    value: selectedDay,
                    onChanged: (value) {
                      setState(() {
                        selectedDay = value;
                      });
                    },
                    items: selectedYear != null && selectedMonth != null
                        ? _getDaysInMonth(selectedYear!, selectedMonth!)
                        .map((day) => DropdownMenuItem<int>(
                      value: day,
                      child: Text(day.toString()),
                    ))
                        .toList()
                        : [],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (selectedYear != null && selectedMonth != null && selectedDay != null) {
              final int amount = int.parse(amountController.text);
              final String expirationDate = '${selectedYear!}-${selectedMonth!.toString().padLeft(2, '0')}-${selectedDay!.toString().padLeft(2, '0')}';
              await ingredientViewModel.updateIngredient(
                userViewModel.kakaoId,
                widget.ingredient.foodId,
                amount,
                expirationDate,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text('수정'),
        ),
      ],
    );
  }
}
