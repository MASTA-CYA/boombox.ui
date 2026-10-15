import 'package:boombox/common/constants.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/library-component/models/application_feature_model.dart';
import 'package:flutter/material.dart';

class ApplicationFeatureWidget extends StatelessWidget {
  final ApplicationFeature feature;

  const ApplicationFeatureWidget({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            offset: Offset.zero,
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 40,
      color: Theme.of(context).colorScheme.primary,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ImageIcon(
                  ResizeImage(
                    AssetImage(feature.icon),
                    width: 70,
                    height: 70,
                    allowUpscaling: false,
                  ),
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Text(
                  feature.name,
                  style: Theme.of(context).textTheme.titleMedium?.merge(
                        const TextStyle(
                          fontFamily: FontFamily.PRIMARY,
                          color: Colors.white,
                        ),
                      ),
                ),
              ],
            ),
            if (!feature.isEnabled.isNull) ...{
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              ),
              Text(
                feature.isEnabled! ? 'Enabled' : 'Disabled',
                style: Theme.of(context).textTheme.titleMedium?.merge(
                      const TextStyle(
                        fontFamily: FontFamily.PRIMARY,
                        color: Colors.white,
                      ),
                    ),
              ),
            }
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Text(feature.description),
      ),
    );
  }
}
