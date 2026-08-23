import 'package:flutter/material.dart';

class ProfileDropdownWidget extends StatefulWidget {
  final String label;
  final Map<String, Widget> profiles;
  final void Function(String profile) onProfileChanged;

  const ProfileDropdownWidget({
    super.key,
    required this.label,
    required this.profiles,
    required this.onProfileChanged,
  });

  @override
  State<StatefulWidget> createState() => _ProfileDropdownWidget();
}

class _ProfileDropdownWidget extends State<ProfileDropdownWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildProfileDropdown();
  }

  Widget _buildProfileDropdown() {
    List<String> list = widget.profiles.keys.toList();

    return DropdownButtonFormField(
      isDense: true,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1),
        ),
      ),
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getIcon(value),
              const SizedBox(width: 10),
              Container(
                margin: const EdgeInsets.only(top: 3),
                child: Text(value),
              ),
            ],
          ),
        );
      }).toList(),
      value: list.first,
      // disabledHint: const Text(
      //     'Category cannot be changed because an accident is being reported'),
      onChanged: (String? value) {
        widget.onProfileChanged(value ?? list.first);
      },
    );
  }

  Widget _getIcon(String profile) {
    return widget.profiles.containsKey(profile)
        ? widget.profiles[profile] ?? const SizedBox.shrink()
        : widget.profiles['Custom'] ?? const SizedBox.shrink();
  }
}
