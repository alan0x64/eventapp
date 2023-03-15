import 'package:EventLink/widgets/status_filter.dart';
import 'package:EventLink/widgets/type_filter.dart';
import 'package:flutter/material.dart';

import '../utilities/shared.dart';

class Search extends SearchDelegate {
  final Widget Function(String query, int selectedCategory,int selectedStatus,int selectedType) body;
  final List<String> categories;
  VoidCallback? setState;

  int selectedCategory;
  int selectedStatus = -1;
  int selectedType = -1;

  Search({
    required this.body,
    this.setState,
    this.categories = const [],
    this.selectedCategory = 0,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () {}, icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Column(
      children: [
        body(query, selectedCategory,selectedStatus,selectedType),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          getTheme(context) != 0 ? Colors.white : Colors.black),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        selectedCategory == index
                            ? Colors.blue
                            : getTheme(context) == 0
                                ? const Color.fromARGB(255, 199, 197, 197)
                                : const Color.fromARGB(228, 26, 25, 25),
                      ),
                    ),
                    onPressed: () {
                      setState(
                        () {
                          selectedCategory = index;
                        },
                      );
                    },
                    child: Text(categories[index]
                        // ,style: TextStyle(color: Colors.white)
                        ),
                  ),
                );
              },
            ),
          ),
           StatusFilter(
            selectedbutton: selectedStatus,
            state: (selectbutton) {
              selectedStatus = selectbutton;
              setState(
                () {},
              );
            },
          ),
          TypeFilter(
            selectedbutton: selectedType,
            state: (selectbutton) {
              selectedType = selectbutton;
              setState(
                () {},
              );
            },
          ),
          Expanded(
            flex: 2,
            child: body(query, selectedCategory,selectedStatus,selectedType),
          ),
        ],
      ),
    );
  }
}
