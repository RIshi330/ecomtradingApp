import 'package:flutter/material.dart';

class HoverableCard extends StatefulWidget {
  final Widget child;
  final Color borderColor;
  final double borderRadius;
  final Color backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const HoverableCard({
    super.key,
    required this.child,
    this.borderColor = const Color(0xff006565),
    this.borderRadius = 24.0,
    this.backgroundColor = Colors.white,
    this.gradient,
    this.onTap,
  });

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _isHovered ? -6.0 : 0.0, 0.0),
      decoration: BoxDecoration(
        color: widget.gradient != null ? null : widget.backgroundColor,
        gradient: widget.gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _isHovered
              ? widget.borderColor.withOpacity(0.3)
              : Colors.black.withOpacity(0.04),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.03),
            blurRadius: _isHovered ? 24 : 12,
            offset: Offset(0, _isHovered ? 12 : 6),
          ),
          if (_isHovered)
            BoxShadow(
              color: widget.borderColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: cardContent,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: cardContent,
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String value;
  final String? growth;
  final bool positive;
  final Gradient? gradient;
  final Color borderColor;
  final double borderRadius;
  final Color backgroundColor;
  final Color? iconColor;
  final Color? bgHighlightColor;
  final Color? valueColor;
  final Color? titleColor;
  final Color? leftIndicatorColor;
  final Widget? footer;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    this.icon,
    required this.title,
    required this.value,
    this.growth,
    this.positive = true,
    this.gradient,
    this.borderColor = const Color(0xff006565),
    this.borderRadius = 20.0,
    this.backgroundColor = Colors.white,
    this.iconColor,
    this.bgHighlightColor,
    this.valueColor,
    this.titleColor,
    this.leftIndicatorColor,
    this.footer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStatusColor = positive ? const Color(0xff006565) : Colors.redAccent;
    final defaultBgHighlightColor = positive ? const Color(0xffe5f7f7) : const Color(0xffffebee);

    final actualStatusColor = iconColor ?? (gradient != null ? Colors.white : defaultStatusColor);
    final actualBgHighlightColor = bgHighlightColor ?? (gradient != null ? Colors.white.withOpacity(0.15) : defaultBgHighlightColor);

    return HoverableCard(
      borderColor: borderColor,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      gradient: gradient,
      onTap: onTap,
      child: Stack(
        children: [
          if (leftIndicatorColor != null)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: leftIndicatorColor,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(borderRadius),
                  ),
                ),
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 150;
              final padding = isNarrow ? 12.0 : 18.0;
              final iconPadding = isNarrow ? 8.0 : 12.0;
              final iconSize = isNarrow ? 18.0 : 22.0;
              final titleSize = isNarrow ? 11.0 : 13.0;
              final valueSize = isNarrow ? 16.0 : 22.0;
              final showTopRow = icon != null || (growth != null && growth!.isNotEmpty);

              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: constraints.hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    if (showTopRow) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (icon != null)
                            Container(
                              padding: EdgeInsets.all(iconPadding),
                              decoration: BoxDecoration(
                                color: actualBgHighlightColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                icon,
                                color: actualStatusColor,
                                size: iconSize,
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          if (growth != null && growth!.isNotEmpty && (!isNarrow || constraints.maxWidth > 100))
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isNarrow ? 6 : 10,
                                vertical: isNarrow ? 4 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: positive
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                growth!,
                                style: TextStyle(
                                  color: positive
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isNarrow ? 9 : 11,
                                ),
                              ),
                            )
                        ],
                      ),
                      if (constraints.hasBoundedHeight) const Spacer() else const SizedBox(height: 16),
                    ],
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor ?? (gradient != null ? Colors.white70 : Colors.grey.shade500),
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.w800,
                        color: valueColor ?? (gradient != null ? Colors.white : Colors.black87),
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (footer != null) ...[
                      const SizedBox(height: 8),
                      footer!,
                    ]
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
