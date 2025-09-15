import 'package:boombox/common/constants.dart';
import 'package:flutter/material.dart';

class NoNetworkConnectivityWidget extends StatelessWidget {
  const NoNetworkConnectivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        const SizedBox(height: 130),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 150,
          child: const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/no-network.png'),
              width: 1000,
              height: 1000,
              allowUpscaling: false,
            ),
            size: 150,
            color: Colors.red,
          ),
        ),
        Text(
          'You\'re currently offline',
          style: Theme.of(context).textTheme.titleLarge?.merge(
                const TextStyle(fontFamily: FontFamily.PRIMARY),
              ),
        ),
      ],
    );
  }
}
