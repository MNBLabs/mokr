import 'package:flutter/material.dart';

/// Animated shimmer placeholder. Internal — not exported.
///
/// Wraps [child] with a sweeping gradient that mimics a loading skeleton.
/// The child defines the size and shape of the placeholder; apply clipping
/// (e.g. [ClipOval], [ClipRRect]) on the outside as needed.
///
/// ```dart
/// ClipOval(
///   child: MokrShimmer(
///     child: SizedBox(width: 48, height: 48),
///   ),
/// )
/// ```
class MokrShimmer extends StatefulWidget {
  const MokrShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<MokrShimmer> createState() => _MokrShimmerState();
}

class _MokrShimmerState extends State<MokrShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(-2.0 + _controller.value * 4.0, 0),
            end: Alignment(-0.5 + _controller.value * 4.0, 0),
            colors: const [
              Color(0xFFD8D8D8),
              Color(0xFFF2F2F2),
              Color(0xFFD8D8D8),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
