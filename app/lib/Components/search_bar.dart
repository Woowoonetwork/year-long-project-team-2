import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/cupertino_chip_widget.dart';

class SearchBar extends StatefulWidget {
  final List<String> itemList;
  final Function(List<String>) onItemsSelected;

  const SearchBar(
      {required this.itemList, required this.onItemsSelected, Key? key})
      : super(key: key);

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
      widget.onItemsSelected(
          selectedItems); // Callback to notify parent about selected items
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
          padding: EdgeInsets.only(left: 17.0, top: 10.0, right: 17.0),
          child: CupertinoSearchTextField(
            onChanged: (value) {
              filterList(value);
            },
            onSubmitted: (value) {
              // Handle submission if needed
            },
            placeholder: 'Search',
            backgroundColor: CupertinoColors.tertiarySystemBackground,
            focusNode: searchFocusNode,
          ),
        ),
        if (isSearchBarClicked && filteredList.isNotEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 17.0, vertical: 10.0),
            decoration: BoxDecoration(
              color:
                  CupertinoColors.tertiarySystemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 20,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: filteredList.map((item) {
                  return GestureDetector(
                    onTap: () => _onItemClicked(item),
                    child: CupertinoListTile(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        if (selectedItems.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 10.0),
            height: 34.0, // Adjust the height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedItems.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(
                      left: index == 0 ? 17 : 4), // Conditional left margin
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
        SizedBox(height: 4.0)
      ],
    );
  }
}
