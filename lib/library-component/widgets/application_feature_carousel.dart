import 'package:boombox/library-component/models/application_feature_model.dart';
import 'package:boombox/library-component/widgets/application_feature.dart';
import 'package:carousel_slider/carousel_slider.dart' as slider;
import 'package:flutter/material.dart';

class ApplicationFeatureCarouselWidget extends StatefulWidget {
  final List<ApplicationFeature> features;

  const ApplicationFeatureCarouselWidget({
    super.key,
    required this.features,
  });

  @override
  State<StatefulWidget> createState() => _ApplicationFeatureCarouselWidget();
}

class _ApplicationFeatureCarouselWidget
    extends State<ApplicationFeatureCarouselWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late slider.CarouselSliderController _carouselController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _carouselController = slider.CarouselSliderController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _animation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: slider.CarouselSlider(
        carouselController: _carouselController,
        options: slider.CarouselOptions(
          height: 190,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 6),
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
        ),
        items: widget.features
            .map(
              (feature) => ApplicationFeatureWidget(feature: feature),
            )
            .toList(),
      ),
    );
  }
}
