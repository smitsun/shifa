import 'dart:math' as math;
import 'package:flutter/material.dart';

class WavyButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double width;
  final List<Color>? gradientColors;
  final Widget? icon;
  final bool isLoading;

  const WavyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 54.0,
    this.width = double.infinity,
    this.gradientColors,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<WavyButton> createState() => _WavyButtonState();
}

class _WavyButtonState extends State<WavyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.onPressed != null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant WavyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed != null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.onPressed == null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultGradients = widget.gradientColors ?? [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
    ];

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: widget.onPressed == null ? null : [
          BoxShadow(
            color: defaultGradients.first.withOpacity(isDark ? 0.35 : 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background waves
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _WavePainter(
                    progress: _controller.value,
                    gradientColors: defaultGradients,
                    isEnabled: widget.onPressed != null,
                  ),
                );
              },
            ),
            
            // Text and Icon layout
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                splashColor: Colors.white.withOpacity(0.15),
                highlightColor: Colors.white.withOpacity(0.08),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              widget.icon!,
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;
  final bool isEnabled;

  _WavePainter({
    required this.progress,
    required this.gradientColors,
    required this.isEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw base background gradient
    final baseRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final baseGradient = LinearGradient(
      colors: isEnabled 
          ? gradientColors 
          : [Colors.grey.shade600, Colors.grey.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    paint.shader = baseGradient.createShader(baseRect);
    canvas.drawRect(baseRect, paint);

    if (!isEnabled) return;

    // Draw Wave 1 (Subtle lighter wave overlay)
    final wave1Paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.02),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(baseRect);
      
    final path1 = Path();
    final double waveHeight1 = size.height * 0.25;
    final double baseHeight1 = size.height * 0.5;
    path1.moveTo(0, size.height);
    
    for (double i = 0.0; i <= size.width; i += 1.0) {
      final double relativeX = i / size.width;
      final double angle = (relativeX * 2 * math.pi) + (progress * 2 * math.pi);
      final double y = math.sin(angle) * waveHeight1 + baseHeight1;
      path1.lineTo(i, y);
    }
    path1.lineTo(size.width, size.height);
    path1.close();
    canvas.drawPath(path1, wave1Paint);

    // Draw Wave 2 (Deeper glow wave overlay)
    final wave2Paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          gradientColors.last.withOpacity(0.25),
          gradientColors.first.withOpacity(0.05),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(baseRect);

    final path2 = Path();
    final double waveHeight2 = size.height * 0.3;
    final double baseHeight2 = size.height * 0.6;
    path2.moveTo(0, size.height);
    
    for (double i = 0.0; i <= size.width; i += 1.0) {
      final double relativeX = i / size.width;
      // Reverse phase movement for contrast
      final double angle = (relativeX * 1.5 * math.pi) - (progress * 2 * math.pi) + (math.pi / 2);
      final double y = math.cos(angle) * waveHeight2 + baseHeight2;
      path2.lineTo(i, y);
    }
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(path2, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isEnabled != isEnabled ||
        oldDelegate.gradientColors != gradientColors;
  }
}
