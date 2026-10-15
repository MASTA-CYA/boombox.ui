import 'package:flutter/material.dart';

class EqualizerTextFieldWidget extends StatefulWidget {
  final void Function(bool hasFocus)? onFocusStatusChanged;

  const EqualizerTextFieldWidget({
    super.key,
    this.onFocusStatusChanged,
  });

  @override
  State<StatefulWidget> createState() => _EqualizerTextfieldWidget();
}

class _EqualizerTextfieldWidget extends State<EqualizerTextFieldWidget>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode()
      ..addListener(
        () => onFocusedChanged(),
      );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        // _focusNode.requestFocus();
        // setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.unfocus();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8,),
      child: buildTextField(),
    );
  }

  Widget buildTextField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      showCursor: false,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Profile',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        suffixIcon: buildSuffixIcon(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
        ),
      ),
      onChanged: (text) => setState(() {}),
    );
  }

  Widget? buildSuffixIcon() {
    return _controller.value.text.isNotEmpty
        ? IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.red,
            ),
            onPressed: () {
              _controller.clear();
              setState(
                () {},
              );
            },
          )
        : _focusNode.hasFocus
            ? IconButton(
                icon: Icon(
                  Icons.arrow_upward,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async => onSearchStateChanged(),
              )
            : const SizedBox.shrink();
  }

  void onSearchStateChanged() async {
    _focusNode.unfocus();
    onFocusedChanged();
  }

  void onFocusedChanged() {
    if (widget.onFocusStatusChanged != null) {
      widget.onFocusStatusChanged!(_focusNode.hasFocus);
    }
    setState(() {});
  }
}
