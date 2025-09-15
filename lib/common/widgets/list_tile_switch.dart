import 'package:flutter/material.dart';

class ListTileSwitchWidget extends StatefulWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final bool? isActive;
  final void Function(bool isActive) onValueChanged;

  const ListTileSwitchWidget({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle = '',
    this.isActive = false,
    required this.onValueChanged,
  });

  @override
  State<ListTileSwitchWidget> createState() => _ListTileSwitchWidgetState();
}

class _ListTileSwitchWidgetState extends State<ListTileSwitchWidget> {
  late ValueNotifier<bool> _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = ValueNotifier<bool>(false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _isActive.value = widget.isActive!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: widget.subtitle!.isNotEmpty
          ? Text(
              widget.subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
            )
          : null,
      leading: widget.leading,
      trailing: ValueListenableBuilder(
        valueListenable: _isActive,
        builder: (context, isActive, child) => Switch(
          thumbIcon: _buildThumbnailIcon(context),
          value: isActive,
          onChanged: (bool value) => _onValueChanged(value),
        ),
      ),
    );
  }

  MaterialStateProperty<Icon?> _buildThumbnailIcon(BuildContext context) {
    return MaterialStateProperty.resolveWith<Icon?>(
      (Set<MaterialState> states) {
        // Thumb icon when the switch is selected.
        if (states.contains(MaterialState.selected)) {
          return const Icon(Icons.check);
        }
        return const Icon(Icons.close);
      },
    );
  }

  void _onValueChanged(bool value) {
    // _isActive.value = value;
    widget.onValueChanged(value);
  }
}
