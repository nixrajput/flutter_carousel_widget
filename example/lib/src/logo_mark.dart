import 'package:flutter/widgets.dart';

/// The package logo, drawn on the same 32 x 32 grid as `assets/logo.svg`, so
/// the example needs no SVG dependency.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'flutter_carousel_widget logo',
    image: true,
    child: SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: _LogoPainter()),
    ),
  );
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  static const _tile = Color(0xFF141118);
  static const _grey = Color(0xFF6B6478);
  static const _amber = Color(0xFFF0A868);
  static const _violet = Color(0xFF9B8CFF);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32);
    void slide(double x, double y, double w, double h, double r, Color color) =>
        canvas.drawRRect(
          RRect.fromLTRBR(x, y, x + w, y + h, Radius.circular(r)),
          Paint()..color = color,
        );
    slide(0, 0, 32, 32, 7, _tile);
    slide(3.5, 10, 5.5, 11, 1.6, _grey);
    slide(23, 10, 5.5, 11, 1.6, _grey);
    slide(10.5, 7, 11, 17, 2.2, _violet);
    for (final (x, color) in [(12.8, _grey), (16.0, _amber), (19.2, _grey)]) {
      canvas.drawCircle(Offset(x, 27.4), 1.25, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
