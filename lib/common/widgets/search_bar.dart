import 'package:boombox/common/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final void Function(bool hasFocus)? onFocusStatusChanged;
  final void Function(String text)? onTextChanged;

  const SearchBarWidget({
    super.key,
    this.onFocusStatusChanged,
    this.onTextChanged,
  });

  @override
  State<StatefulWidget> createState() => _SearchBarWidget();
}

class _SearchBarWidget extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late final TextEditingController controller;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
    _searchFocusNode = FocusNode()
      ..addListener(
        () => onFocusedChanged(),
      );

    // WidgetsBinding.instance.addPostFrameCallback(
    //   (_) async {
    //     _searchFocusNode.requestFocus();
    //     setState(() {});
    //   },
    // );
  }

  @override
  void dispose() {
    controller.dispose();
    _searchFocusNode.unfocus();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: _buildTextField(),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: controller,
      focusNode: _searchFocusNode,
      showCursor: false,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Search',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        prefixIcon: const Icon(CupertinoIcons.search),
        suffixIcon: _buildSuffixIcon(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
        ),
      ),
      onChanged: (text) => _onSearchTextChanged(text),
    );
  }

  Widget? _buildSuffixIcon() {
    return controller.value.text.isNotEmpty
        ? IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
            onPressed: () {
              controller.clear();
              if (!widget.onTextChanged.isNull) {
                widget.onTextChanged!(controller.text);
              }
              setState(
                () {},
              );
            },
          )
        : IconButton(
            icon: Icon(
              _searchFocusNode.hasFocus
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () async => _onSearchStateChanged(),
          );
  }

  void _onSearchTextChanged(String text) {
    if (widget.onTextChanged != null) {
      widget.onTextChanged!(text);
    }
    setState(() {});
  }

  void _onSearchStateChanged() async {
    _searchFocusNode.hasFocus
        ? _searchFocusNode.unfocus()
        : _searchFocusNode.requestFocus();
    onFocusedChanged();
  }

  void onFocusedChanged() {
    if (widget.onFocusStatusChanged != null) {
      widget.onFocusStatusChanged!(_searchFocusNode.hasFocus);
    }
    setState(() {});
  }
}
