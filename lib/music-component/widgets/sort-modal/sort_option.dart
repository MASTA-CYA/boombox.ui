import 'package:boombox/music-component/models/enums/sort_option_order_enum.dart';
import 'package:flutter/material.dart';

class SortOptionWidget extends StatefulWidget {
  final String text;
  final bool? isAvailable;
  final SortOptionOrder? previousOrder;
  final void Function(SortOptionOrder order) onOptionChanged;

  const SortOptionWidget({
    super.key,
    required this.text,
    this.isAvailable = false,
    this.previousOrder,
    required this.onOptionChanged,
  });

  @override
  State<SortOptionWidget> createState() => _SortOptionWidgetState();
}

class _SortOptionWidgetState extends State<SortOptionWidget> {
  late ValueNotifier<SortOptionOrder> _order;

  @override
  void initState() {
    super.initState();

    _order = ValueNotifier<SortOptionOrder>(widget.previousOrder ?? SortOptionOrder.none);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.text,
              style: Theme.of(context).textTheme.titleMedium?.merge(
                    TextStyle(
                        color: widget.isAvailable!
                            ? null
                            : Theme.of(context).colorScheme.secondary),
                  ),
            ),
            ValueListenableBuilder(
              valueListenable: _order,
              builder: (context, value, child) => AnimatedSwitcher(
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                duration: const Duration(milliseconds: 400),
                child: IconButton(
                  key: UniqueKey(),
                  icon: _buildOrderIcon(context),
                  onPressed: () =>
                      widget.isAvailable! ? _onOptionChanged() : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onOptionChanged() {
    _order.value = SortOptionOrder.values.elementAt(
      _order.value.index == SortOptionOrder.values.length - 1
          ? 0
          : _order.value.index + 1,
    );
    widget.onOptionChanged(_order.value);
  }

  Widget _buildOrderIcon(BuildContext context) {
    Color selectedColor = Theme.of(context).colorScheme.primary;
    Color unavailableColor = Theme.of(context).colorScheme.secondary;

    switch (_order.value) {
      case SortOptionOrder.asc:
        return Icon(
          Icons.arrow_upward,
          color: selectedColor,
          size: 30,
        );
      case SortOptionOrder.desc:
        return Icon(
          Icons.arrow_downward,
          color: selectedColor,
          size: 30,
        );
      default:
        return ImageIcon(
          const ResizeImage(
            AssetImage('assets/images/dash.png'),
            width: 70,
            height: 70,
            allowUpscaling: false,
          ),
          color: widget.isAvailable! ? null : unavailableColor,
          size: 30,
        );
    }
  }
}
