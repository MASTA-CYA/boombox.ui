// import 'package:boombox/common/navigator/page_route_helper.dart';
// import 'package:boombox/settings-component/services/user_settings_service.dart';
// import 'package:flutter/material.dart';
// import 'package:animated_splash_screen/animated_splash_screen.dart';
// // ignore: depend_on_referenced_packages
// import 'package:page_transition/page_transition.dart';

// class SplashWidget extends StatelessWidget {
//   const SplashWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     bool isDarkMode = UserSettingsService.isDarkTheme == Brightness.dark;

//     return AnimatedSplashScreen(
//       curve: Curves.easeInOut,
//       duration: 8000,
//       splash: 'assets/images/${isDarkMode ? 'logo-dark' : 'logo-light'}.png',
//       splashIconSize: MediaQuery.of(context).size.width * 0.55,
//       backgroundColor: isDarkMode ? Colors.black : Colors.white,
//       nextRoute: PageRouteHelper.getHomeRoutePath(), 
//       nextScreen: PageRouteHelper.getHomeRouteWidget(),
//       splashTransition: SplashTransition.fadeTransition,
//       pageTransitionType: PageTransitionType.leftToRight,
//     );
//   }
// }
