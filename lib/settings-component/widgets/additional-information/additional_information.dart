import 'package:boombox/settings-component/widgets/additional-information/news_additional_information.dart';
import 'package:boombox/settings-component/widgets/additional-information/text_additional_information.dart';
import 'package:flutter/material.dart';

class AdditionalInformationWidget<T> extends StatelessWidget {
  final String text;

  AdditionalInformationWidget({
    super.key,
    required this.text,
  });

  final ValueNotifier _isExpanded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[300],
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextAdditionalInformationWidget(text: text),
                ),
              ),
              _buildExpander(),
            ],
          ),
          _buildAdditionalChild()
        ],
      ),
    );
  }

  Widget _buildExpander() {
    if (T != TextAdditionalInformationWidget) {
      return ValueListenableBuilder(
        valueListenable: _isExpanded,
        builder: (context, isExpanded, child) => GestureDetector(
          onTap: () => _onIsExpandedPressed(),
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              child: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: isExpanded
                    ? Theme.of(context).iconTheme.color
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildAdditionalChild() {
    return ValueListenableBuilder(
      valueListenable: _isExpanded,
      builder: (context, isExpanded, child) {
        Widget widget = SizedBox.shrink(key: UniqueKey());

        if (isExpanded) {
          switch (T) {
            case NewsAdditionalInformationWidget:
              widget = NewsAdditionalInformationWidget(key: UniqueKey());
              break;
            default:
              break;
          }
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          child: widget,
        );
      },
    );
  }

  void _onIsExpandedPressed() {
    _isExpanded.value = !_isExpanded.value;
  }
}
