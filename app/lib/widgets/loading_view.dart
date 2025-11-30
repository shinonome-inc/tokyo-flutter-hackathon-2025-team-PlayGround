import 'package:flutter/material.dart';

class LoadingView extends StatefulWidget {

  const LoadingView({
    super.key,
    this.size = 50.0,
    this.duration = const Duration(seconds: 1),
  });
  final double size;
  final Duration duration;

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<String> _imagePaths = [
    'assets/images/loading_1.png',
    'assets/images/loading_2.png',
    'assets/images/loading_3.png',
    'assets/images/loading_4.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          var currentIndex = (_controller.value * _imagePaths.length).floor();

          // ちょうど1.0になった瞬間に範囲外になるのを防ぐ
          if (currentIndex >= _imagePaths.length) {
            currentIndex = _imagePaths.length - 1;
          }

          return Image.asset(
            _imagePaths[currentIndex],
            fit: BoxFit.contain,
            gaplessPlayback: true,
          );
        },
      ),
    );
  }
}
