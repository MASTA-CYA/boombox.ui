import 'package:boombox/common/constants.dart';
import 'package:boombox/theme-component/models/user_theme_model.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ThemeImageCardWidget extends StatefulWidget {
  final bool isActive;
  final UserTheme theme;
  final Function(Color color, bool isInverted) onThemeChanged;

  const ThemeImageCardWidget({
    super.key,
    required this.isActive,
    required this.theme,
    required this.onThemeChanged,
  });

  @override
  State<ThemeImageCardWidget> createState() => _ThemeImageCardWidgetState();
}

class _ThemeImageCardWidgetState extends State<ThemeImageCardWidget> {
  // Color for the picker in a dialog using onChanged.
  late Color _selectedColor;
  bool? _isInverted;

  @override
  void initState() {
    super.initState();

    _selectedColor = Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onThemeChanged(
              _selectedColor,
              _isInverted ?? widget.theme.invertColors,
            ),
            child: Container(
              margin: const EdgeInsets.all(6),
              height: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ResizeImage(
                    AssetImage(widget.theme.path),
                    height: 500,
                    allowUpscaling: true,
                  ),
                  fit: widget.theme.fit,
                  invertColors: _isInverted ?? widget.theme.invertColors,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.theme.name,
                  style: Theme.of(context).textTheme.bodyLarge?.merge(
                        const TextStyle(fontFamily: FontFamily.PRIMARY),
                      ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.secondary,
                        blurRadius: 5,
                        offset: Offset.zero, // Shadow position
                      ),
                    ],
                  ),
                  child: ColorIndicator(
                    color: _selectedColor,
                    onSelectFocus: false,
                    onSelect: () async {
                      if (!widget.theme.isCustom!) return;

                      // Store current color before we open the dialog.
                      final Color colorBeforeDialog = _selectedColor;
                      // Wait for the picker to close, if dialog was dismissed,
                      // then restore the color we had before it was opened.
                      if (!(await _buildColorPickerDialog())) {
                        if (mounted) {
                          setState(() {
                            _selectedColor = colorBeforeDialog;
                          });
                        }
                      }
                    },
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onInvertPressed(),
                  child: SizedBox(
                    width: 17,
                    height: 17,
                    child: ImageIcon(
                      const ResizeImage(
                        AssetImage('assets/images/invert.png'),
                        width: 70,
                        height: 70,
                        allowUpscaling: false,
                      ),
                      color: !widget.theme.isCustom!
                          ? Theme.of(context).colorScheme.secondary
                          : _isInverted ?? widget.theme.invertColors
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onThemeChanged(
                    _selectedColor,
                    _isInverted ?? widget.theme.invertColors,
                  ),
                  child: Text(
                    widget.isActive ? 'Active' : 'Inactive',
                    style: Theme.of(context).textTheme.bodyLarge?.merge(
                          TextStyle(
                            fontFamily: FontFamily.PRIMARY,
                            color: widget.isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _buildColorPickerDialog() async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: _selectedColor,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) => setState(() => _selectedColor = color),
      borderRadius: 0,
      spacing: 5,
      runSpacing: 5,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      // materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      // colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      // colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
      enableShadesSelection: false,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: false,
      },
      actionButtons: const ColorPickerActionButtons(),
      // customColorSwatchesAndNames: colorsNameMap,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        // editFieldCopyButton: false,
        editUsesParsedPaste: false,
      ),
    ).showPickerDialog(
      context,
      // New in version 3.0.0 custom transitions support.
      transitionBuilder: (BuildContext context, Animation<double> a1,
          Animation<double> a2, Widget widget) {
        final double curvedValue =
            Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      constraints: const BoxConstraints(
        minHeight: 250,
        minWidth: 350,
        maxWidth: 350,
      ),
    );
  }

  void _onInvertPressed() {
    if (widget.theme.isCustom!) {
      setState(
        () => _isInverted = !(_isInverted ?? widget.theme.invertColors),
      );
    }
    widget.onThemeChanged(
      _selectedColor,
      _isInverted ?? widget.theme.invertColors,
    );
  }
}
