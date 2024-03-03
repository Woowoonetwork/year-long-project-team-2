import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:FoodHood/Components/cupertino_chip_widget.dart';

class SearchBar extends StatefulWidget {
  final List<String> itemList;
  final Function(List<String>) onItemsSelected;

  const SearchBar(
      {required this.itemList, required this.onItemsSelected, Key? key})
      : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final FocusNode searchFocusNode = FocusNode();
  List<String> filteredList = [];
  List<String> selectedItems = [];
  bool isSearchBarClicked = false;

  // Define consistent padding and margin values
  static const EdgeInsets geometryPadding = EdgeInsets.all(8.0);
  static const double searchBarHeight = 40.0;
  static const EdgeInsets suggestionMargin =
      EdgeInsets.symmetric(horizontal: 17.0, vertical: 10.0);
  static const double chipListHeight = 34.0;
  static const EdgeInsets chipMargin = EdgeInsets.only(left: 4.0);

  @override
  void initState() {
    super.initState();
    searchFocusNode.addListener(_updateSearchBarState);
  }

  void _updateSearchBarState() =>
      setState(() => isSearchBarClicked = searchFocusNode.hasFocus);

  void filterList(String query) {
    setState(() {
      filteredList = query.isEmpty
          ? []
          : widget.itemList
              .where((item) =>
                  item.toLowerCase().contains(query.toLowerCase()) &&
                  !selectedItems.contains(item))
              .toList();
    });
  }

  void _onItemClicked(String item) {
    setState(() {
      selectedItems.add(item);
      filteredList = [];
      widget.onItemsSelected(selectedItems); // Notify about selected items
    });
  }

  @override
  void dispose() {
    searchFocusNode.removeListener(_updateSearchBarState);
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchField(),
        if (isSearchBarClicked && filteredList.isNotEmpty)
          _buildSuggestionList(),
        if (selectedItems.isNotEmpty) _buildSelectedItemsList(),
      ],
    );
  }

  Widget _buildSearchField() => Container(
        margin: geometryPadding,
        height: searchBarHeight,
        child: CupertinoSearchTextField(
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 6.0),
            child: Icon(FeatherIcons.search, size: 16.0),
          ),
          onChanged: filterList,
          placeholder: 'Search',
          placeholderStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: CupertinoColors.secondaryLabel.resolveFrom(context)),
          backgroundColor: CupertinoColors.tertiarySystemBackground,
          focusNode: searchFocusNode,
        ),
      );

  Widget _buildSuggestionList() => Container(
        margin: suggestionMargin,
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
            children: filteredList
                .map((item) => _buildSuggestionItem(item))
                .toList()),
      );

  Widget _buildSuggestionItem(String item) => CupertinoButton(
        onPressed: () => _onItemClicked(item),
        padding: EdgeInsets.zero,
        child: CupertinoListTile(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(item,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600)),
        ),
      );

  Widget _buildSelectedItemsList() => Container(
        height: chipListHeight,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: selectedItems.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) => Container(
            margin: index == 0
                ? EdgeInsets.only(left: 0)
                : chipMargin, // Adjust left margin for first item if necessary
            child: CupertinoChipWidget(
              label: selectedItems[index],
              onDeleted: () => setState(() => selectedItems.removeAt(index)),
            ),
          ),
        ),
      );
}
