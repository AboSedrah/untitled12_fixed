import 'package:flutter/material.dart';

class EasyContainer extends StatelessWidget {
  final double? borderRadius;
  final Color? color;
  final Color? borderColor;
  final bool showBorder;
  final double? height;
  final double? width;
  final double? padding;
  final double? margin;
  final Widget? child;
  final VoidCallback? onTap;

  const EasyContainer({
    super.key,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.showBorder = false,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: padding != null ? EdgeInsets.all(padding!) : null,
        margin: margin != null ? EdgeInsets.all(margin!) : null,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius != null
              ? BorderRadius.circular(borderRadius!)
              : null,
          border: showBorder
              ? Border.all(
                  color: borderColor ?? Colors.transparent,
                )
              : null,
        ),
        child: child,
      ),
    );
  }
}
