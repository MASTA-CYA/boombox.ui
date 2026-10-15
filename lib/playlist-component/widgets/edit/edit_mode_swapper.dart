import 'package:boombox/playlist-component/models/edit_mode_enum.dart';
import 'package:flutter/material.dart';

class EditModeSwapperWidget extends StatefulWidget {
  final void Function(EditMode mode) onEditModeChanged;

  const EditModeSwapperWidget({
    super.key,
    required this.onEditModeChanged,
  });

  @override
  State<EditModeSwapperWidget> createState() => _EditModeSwapperWidgetState();
}

class _EditModeSwapperWidgetState extends State<EditModeSwapperWidget>
    with TickerProviderStateMixin {
  late AnimationController _reorderController;
  late Animation _reorderAnimation;
  late AnimationController _deleteController;
  late Animation _deleteAnimation;

  void alignAnimation() {
    // Reorder
    _reorderAnimation = ColorTween(
      begin: Theme.of(context).iconTheme.color,
      end: Theme.of(context).colorScheme.primary,
    ).animate(_reorderController);

    // Delete
    _deleteAnimation = ColorTween(
      begin: Theme.of(context).iconTheme.color,
      end: Theme.of(context).colorScheme.primary,
    ).animate(_deleteController);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Reorder
    _reorderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _reorderAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.black,
    ).animate(_reorderController);

    // Delete
    _deleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _deleteAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.black,
    ).animate(_reorderController);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        alignAnimation();
        _onModeSwapPressed(EditMode.reorder);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    alignAnimation();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: _buildReorderMode()),
        const SizedBox(width: 10),
        Expanded(child: _buildDeleteMode()),
      ],
    );
  }

  Widget _buildReorderMode() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onModeSwapPressed(EditMode.reorder),
      child: Container(
        // padding: const EdgeInsets.all(1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIcon(
              const ResizeImage(
                AssetImage('assets/images/reorder.png'),
                width: 1000,
                height: 1000,
              ),
              color: _reorderAnimation.value,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              EditMode.reorder.mode,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                    TextStyle(
                      color: _reorderAnimation.value,
                      fontWeight: _reorderController.isCompleted
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteMode() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onModeSwapPressed(EditMode.delete),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: _deleteAnimation.value,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              EditMode.delete.mode,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                    TextStyle(
                      color: _deleteAnimation.value,
                      fontWeight: _deleteController.isCompleted
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _onModeSwapPressed(EditMode mode) async {
    widget.onEditModeChanged(mode);

    switch (mode) {
      case EditMode.reorder:
        if (_deleteController.isCompleted) {
          await _deleteController.reverse();
        }
        if (!_reorderController.isCompleted) {
          await _reorderController.forward();
        }
        break;
      case EditMode.delete:
        if (_reorderController.isCompleted) {
          await _reorderController.reverse();
        }
        if (!_deleteController.isCompleted) {
          await _deleteController.forward();
        }
        break;
    }
    setState(() {});
  }
}
