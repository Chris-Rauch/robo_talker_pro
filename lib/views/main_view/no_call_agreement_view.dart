import 'package:flutter/material.dart';

class NoCallAgreementView extends StatefulWidget {
  const NoCallAgreementView({super.key});

  @override
  State<StatefulWidget> createState() => _NoCallAgreementView();
}

class _NoCallAgreementView extends State<NoCallAgreementView> {
  List<String> items = [];
  int? selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Scaffold(
      body: Column(
        children: [
          const Text(
            'NCA List',
            style: TextStyle(
              fontSize: 36,
            ),
          ),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText:
                  "Provide the name of companies you DON'T want to send calls to",
              labelText: "Company Name",
            ),
            onSubmitted: (value) {
              items.insert(0, value);
              controller.clear();
              setState(() {});
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                  tileColor: selectedIndex == index ? Colors.blue : null,
                  onTap: () {
                    selectedIndex = index;
                    setState(() {});
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.file_copy_rounded),
              ),
              const Spacer(),
              FloatingActionButton(
                onPressed: () {
                  try {
                    items.removeAt(selectedIndex!);
                  } catch (e) {
                    print(e);
                  }
                  setState(() {});
                },
                child: const Icon(Icons.remove),
              ),
              FloatingActionButton(
                onPressed: () {
                  items.clear();
                  selectedIndex = 0;
                  setState(() {});
                },
                child: const Icon(Icons.clear),
              ),
              FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.save),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
