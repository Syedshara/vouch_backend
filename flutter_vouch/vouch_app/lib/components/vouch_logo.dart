import 'package:flutter/material.dart';

class VouchLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const VouchLogo({
    super.key,
    this.size = 120,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: VouchLogoPainter(),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.1),
          Text(
            'VOUCH',
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C63FF),
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}

class VouchLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final circlePaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, circlePaint);

    // Draw shield shape
    final shieldPath = Path();
    final shieldWidth = size.width * 0.5;
    final shieldHeight = size.height * 0.6;
    final shieldLeft = (size.width - shieldWidth) / 2;
    final shieldTop = size.height * 0.15;

    shieldPath.moveTo(size.width / 2, shieldTop);
    shieldPath.lineTo(shieldLeft + shieldWidth, shieldTop + shieldHeight * 0.2);
    shieldPath.lineTo(shieldLeft + shieldWidth, shieldTop + shieldHeight * 0.55);
    shieldPath.quadraticBezierTo(
      shieldLeft + shieldWidth,
      shieldTop + shieldHeight * 0.8,
      size.width / 2,
      shieldTop + shieldHeight,
    );
    shieldPath.quadraticBezierTo(
      shieldLeft,
      shieldTop + shieldHeight * 0.8,
      shieldLeft,
      shieldTop + shieldHeight * 0.55,
    );
    shieldPath.lineTo(shieldLeft, shieldTop + shieldHeight * 0.2);
    shieldPath.close();

    final shieldPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(shieldPath, shieldPaint);

    // Draw inner shield
    final innerShieldPath = Path();
    final innerShieldWidth = shieldWidth * 0.8;
    final innerShieldHeight = shieldHeight * 0.8;
    final innerShieldLeft = (size.width - innerShieldWidth) / 2;
    final innerShieldTop = shieldTop + shieldHeight * 0.1;

    innerShieldPath.moveTo(size.width / 2, innerShieldTop);
    innerShieldPath.lineTo(innerShieldLeft + innerShieldWidth, innerShieldTop + innerShieldHeight * 0.2);
    innerShieldPath.lineTo(innerShieldLeft + innerShieldWidth, innerShieldTop + innerShieldHeight * 0.55);
    innerShieldPath.quadraticBezierTo(
      innerShieldLeft + innerShieldWidth,
      innerShieldTop + innerShieldHeight * 0.8,
      size.width / 2,
      innerShieldTop + innerShieldHeight,
    );
    innerShieldPath.quadraticBezierTo(
      innerShieldLeft,
      innerShieldTop + innerShieldHeight * 0.8,
      innerShieldLeft,
      innerShieldTop + innerShieldHeight * 0.55,
    );
    innerShieldPath.lineTo(innerShieldLeft, innerShieldTop + innerShieldHeight * 0.2);
    innerShieldPath.close();

    final innerShieldPaint = Paint()
      ..color = const Color(0xFF6C63FF).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawPath(innerShieldPath, innerShieldPaint);

    // Draw checkmark
    final checkPath = Path();
    final checkCenterY = size.height / 2;
    final checkSize = size.width * 0.15;

    checkPath.moveTo(size.width * 0.38, checkCenterY);
    checkPath.lineTo(size.width * 0.45, checkCenterY + checkSize * 0.5);
    checkPath.lineTo(size.width * 0.62, checkCenterY - checkSize * 0.3);

    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(checkPath, checkPaint);

    // Add outer circle border
    final borderPaint = Paint()
      ..color = const Color(0xFF5A54E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius - 1.5, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

