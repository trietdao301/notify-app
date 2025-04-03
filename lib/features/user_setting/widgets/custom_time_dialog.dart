import 'package:flutter/material.dart';
import 'package:notifyapp/features/user_setting/screens/user_setting_screen.dart';

class CustomTimeDialog extends StatelessWidget {
  final String initialSelection;
  final ValueChanged<String?> onSelected;
  final List<MenuEntry> items;

  const CustomTimeDialog({
    Key? key,
    required this.initialSelection,
    required this.onSelected,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder:
              (context) => Dialog(
                child: SizedBox(
                  width: 200,
                  height: 300,
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.label),
                        onTap: () => Navigator.pop(context, item.value),
                      );
                    },
                  ),
                ),
              ),
        );
        onSelected(selected);
      },
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(initialSelection), const Icon(Icons.arrow_drop_down)],
        ),
      ),
    );
  }
}
