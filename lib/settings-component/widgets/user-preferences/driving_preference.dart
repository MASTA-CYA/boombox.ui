import 'preferences_barrel.dart';

class DrivingPreferenceWidget extends StatelessWidget {
  const DrivingPreferenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTileSwitchWidget(
      key: UniqueKey(),
      leading: const ImageIcon(
        ResizeImage(
          AssetImage('assets/images/driving.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
      ),
      title: 'Driving Mode',
      subtitle: 'Enable driving modes features',
      isActive: false,
      onValueChanged: (isActive) => _onDrivingModeChanged(context, isActive),
    );
  }

  Future<void> _onDrivingModeChanged(
    BuildContext context,
    bool isActive,
  ) async {}
}
