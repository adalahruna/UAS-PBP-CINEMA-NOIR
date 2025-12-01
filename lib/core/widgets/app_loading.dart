import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cinema_noir/core/constants/app_colors.dart';

class AppLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoading({
    super.key,
    this.size = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.flickr(
      leftDotColor: color ?? AppColors.gold,
      rightDotColor: color ?? Colors.black,
      size: size,
    );
  }
}

class AppLoadingSmall extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoadingSmall({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.flickr(
      leftDotColor: color ?? AppColors.gold,
      rightDotColor: color ?? Colors.black,
      size: size,
    );
  }
}
