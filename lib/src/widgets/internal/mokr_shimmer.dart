import 'package:flutter/material.dart';

/// Animated shimmer placeholder. Internal — not exported.
///
/// Wraps [child] with a sweeping gradient that mimics a loading skeleton.
/// The child defines the size and shape of the placeholder — apply clipping
/// (e.g. [ClipOval], [ClipRRect]) on the outside as needed.
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

/// Grey rectangle placeholder shown when an image fails to load.
/// Internal — not exported.
class MokrImageError extends StatelessWidget {
  const MokrImageError({super.key, this.width, this.height = 200.0});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(
        color: Color(0xFFEEEEEE),
        child: Center(
          child: Icon(Icons.broken_image_outlined,
              color: Color(0xFFBBBBBB), size: 28),
        ),
      ),
    );
  }
}

/// Grey circle/square placeholder shown when an avatar fails to load.
/// Internal — not exported.
class MokrAvatarError extends StatelessWidget {
  const MokrAvatarError({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const ColoredBox(
        color: Color(0xFFE0E0E0),
        child: Center(
          child: Icon(Icons.person_outline, color: Color(0xFFBBBBBB), size: 20),
        ),
      ),
    );
  }
}
