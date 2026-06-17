import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Loading com a identidade da Glicare: um anel com gradiente girando em volta
/// da gota d'água, que pulsa suavemente. Opcionalmente exibe uma mensagem.
///
/// Uso simples:
/// ```dart
/// const Center(child: GlicareLoading())
/// ```
///
/// Tela cheia (ex.: rotas, splash, overlays):
/// ```dart
/// const GlicareLoading.fullscreen(message: 'Carregando seus dados...')
/// ```
class GlicareLoading extends StatefulWidget {
  const GlicareLoading({
    super.key,
    this.size = 64,
    this.message,
    this.onPrimary = false,
  })  : _fullscreen = false,
        _backgroundColor = null;

  /// Variante que ocupa a tela inteira, centralizada, sobre um fundo sólido.
  const GlicareLoading.fullscreen({
    super.key,
    this.size = 88,
    this.message,
    this.onPrimary = true,
    Color? backgroundColor,
  })  : _fullscreen = true,
        _backgroundColor = backgroundColor;

  /// Diâmetro do anel.
  final double size;

  /// Texto opcional exibido abaixo do loader.
  final String? message;

  /// Quando `true`, usa cores claras (para fundos escuros/coloridos).
  final bool onPrimary;

  final bool _fullscreen;
  final Color? _backgroundColor;

  @override
  State<GlicareLoading> createState() => _GlicareLoadingState();
}

class _GlicareLoadingState extends State<GlicareLoading>
    with TickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = widget.onPrimary ? Colors.white : AppColors.primary;
    final accentColor =
        widget.onPrimary ? AppColors.secondaryContainer : AppColors.secondary;
    final dropColor = widget.onPrimary ? Colors.white : AppColors.primary;
    final checkColor = widget.onPrimary ? AppColors.secondaryContainer : AppColors.secondary;
    final textColor = widget.onPrimary
        ? Colors.white.withValues(alpha: 0.9)
        : AppColors.onSurfaceVariant;

    final loader = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anel com gradiente girando.
              RotationTransition(
                turns: _spin,
                child: CustomPaint(
                  size: Size.square(widget.size),
                  painter: _RingPainter(
                    color: ringColor,
                    accent: accentColor,
                    strokeWidth: widget.size * 0.07,
                  ),
                ),
              ),
              // Gota pulsando no centro.
              ScaleTransition(
                scale: Tween<double>(begin: 0.82, end: 1.0).animate(
                  CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                ),
                child: _DropMark(
                  size: widget.size * 0.46,
                  dropColor: dropColor,
                  checkColor: checkColor,
                ),
              ),
            ],
          ),
        ),
        if (widget.message != null) ...[
          SizedBox(height: widget.size * 0.28),
          Text(
            widget.message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );

    if (!widget._fullscreen) return loader;

    return ColoredBox(
      color: widget._backgroundColor ??
          (widget.onPrimary ? AppColors.primary : AppColors.background),
      child: Center(child: loader),
    );
  }
}

/// Gota d'água com o "check" da marca — versão leve do GlicareLogo.
class _DropMark extends StatelessWidget {
  const _DropMark({
    required this.size,
    required this.dropColor,
    required this.checkColor,
  });

  final double size;
  final Color dropColor;
  final Color checkColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.water_drop, color: dropColor, size: size),
          Positioned(
            top: size * 0.5,
            child: Icon(Icons.check, color: checkColor, size: size * 0.42),
          ),
        ],
      ),
    );
  }
}

/// Desenha um arco com gradiente varrido (sweep) e pontas arredondadas,
/// criando o efeito de anel girando com cauda que some.
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.color,
    required this.accent,
    required this.strokeWidth,
  });

  final Color color;
  final Color accent;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - strokeWidth) / 2;

    // Trilho de fundo bem sutil.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius, track);

    // Arco principal com gradiente que vai do transparente ao sólido.
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [
        color.withValues(alpha: 0.0),
        accent,
        color,
      ],
      stops: const [0.0, 0.6, 1.0],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(rect);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = shader;

    // Varre ~80% do círculo, deixando uma "cauda" aberta.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * 0.8,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.accent != accent ||
      oldDelegate.strokeWidth != strokeWidth;
}
