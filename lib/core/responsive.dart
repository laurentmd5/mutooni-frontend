import 'package:flutter/material.dart';
import 'constants.dart';

/// Extensions & utilitaires pour simplifier le responsive design
extension ScreenSizeX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isMobile   => screenSize.width < Constants.tablet;
  bool get isTablet   =>
      screenSize.width >= Constants.tablet && screenSize.width < Constants.desktop;
  bool get isDesktop  =>
      screenSize.width >= Constants.desktop && screenSize.width < Constants.large4K;
  bool get is4K       => screenSize.width >= Constants.large4K;
}

/// Widget helper (cache la vue si la condition n’est pas remplie)
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleMobile;
  final bool visibleTablet;
  final bool visibleDesktop;
  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleMobile = true,
    this.visibleTablet = true,
    this.visibleDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile  = context.isMobile;
    final isTablet  = context.isTablet;
    final isDesktop = context.isDesktop || context.is4K;
    if ((isMobile && visibleMobile) ||
        (isTablet && visibleTablet) ||
        (isDesktop && visibleDesktop)) {
      return child;
    }
    return const SizedBox.shrink();
  }
}
