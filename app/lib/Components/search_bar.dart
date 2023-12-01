import 'package:flutter/cupertino.dart';
import 'package:FoodHood/cupertino_chip_widget.dart';

class SearchBar extends StatefulWidget {
  final List<String> itemList;

  const SearchBar({required this.itemList, Key? key}) : super(key: key);

  @override
  createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late FocusNode searchFocusNode;
  List<String> filteredList = [];
  List<String> selectedItems = [];
  bool isSearchBarClicked = false;

  @override
  void initState() {
    super.initState();
    searchFocusNode = FocusNode();
    searchFocusNode.addListener(() {
      setState(() {
        isSearchBarClicked = searchFocusNode.hasFocus;
      });
    });
  }

  void filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredList = [];
      } else {
        filteredList = widget.itemList
            .where((item) =>
                item.toLowerCase().contains(query.toLowerCase()) &&
                !selectedItems.contains(item))
            .toList();
      }
    });
  }

  void _onItemClicked(String item) {
    setState(() {
      selectedItems.add(item);
      filteredList = [];
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 17.0, top: 10.0, right: 17.0, bottom: 10.0),
          child: CupertinoSearchTextField(
            onChanged: (value) {
              filterList(value);
            },
            onSubmitted: (value) {
              // Handle submission if needed
            },
            placeholder: 'Search',
            backgroundColor: CupertinoColors.secondarySystemGroupedBackground,
            focusNode: searchFocusNode,
          ),
        ),
        
        // Conditionally show the list based on search bar interaction
        if (isSearchBarClicked && filteredList.isNotEmpty)
          Column(
            children: filteredList.map((item) {
              return GestureDetector(
                onTap: () => _onItemClicked(item),
                child: CupertinoListTile(
                  title: Text(item),
                  // Add more customization as needed
                ),
              );
            }).toList(),
          ),

        // Horizontal list of selected items
        if (selectedItems.isNotEmpty)
          Container(
            height: 50.0, // Adjust the height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: CupertinoChipWidget(
                    label: selectedItems[index],
                    onDeleted: () {
                      setState(() {
                        // Remove the selected item when the chip is deleted
                        selectedItems.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
