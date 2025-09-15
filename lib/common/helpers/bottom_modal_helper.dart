import 'package:boombox/common/helpers/color_helper.dart';
import 'package:boombox/common/widgets/bottom_sheet_modal.dart';
import 'package:flutter/material.dart';

class BottomSheetModalHelper {
  static Future showModal(
    BuildContext context, {
    AnimationController? transitionController,
    required Widget child,
  }) async {
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 1.4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        side: BorderSide(
          width: 3.8,
          color: Theme.of(context).brightness == Brightness.dark
              ? ColorHelper.fromHex('#505050')
              : Colors.black,
        ),
      ),
      transitionAnimationController: transitionController,
      builder: (context) => BottomSheetModalWidget(child: child),
    );
  }
}
