import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final String? trend;
  final bool? trendUp;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D2617),
                )),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
            if (trend != null && trend!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (trendUp == true ? AppTheme.primary : AppTheme.destructive).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${trendUp == true ? '↑' : '↓'} $trend',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: trendUp == true ? AppTheme.primary : AppTheme.destructive,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text('son 30 gün',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PlatformBadge extends StatelessWidget {
  final String platform;
  const PlatformBadge({super.key, required this.platform});

  Color get color {
    switch (platform) {
      case 'trendyol': return const Color(0xFFEC4899);
      case 'amazon': return const Color(0xFFD4A017);
      case 'hepsiburada': return const Color(0xFFEA580C);
      case 'n11': return const Color(0xFF2563EB);
      case 'etsy': return AppTheme.primary;
      default: return AppTheme.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        platform,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  String get label {
    switch (status) {
      case 'pending': return 'Beklemede';
      case 'approved': return 'Onaylandı';
      case 'rejected': return 'Reddedildi';
      case 'disbursed': return 'Ödendi';
      case 'repaid': return 'Geri Ödendi';
      default: return status;
    }
  }

  Color get color {
    switch (status) {
      case 'pending': return AppTheme.accent;
      case 'approved': return AppTheme.primary;
      case 'rejected': return AppTheme.destructive;
      case 'disbursed': return AppTheme.chart3;
      default: return AppTheme.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class GreenScoreGauge extends StatelessWidget {
  final double score;
  final double size;
  const GreenScoreGauge({super.key, required this.score, this.size = 120});

  Color get scoreColor {
    if (score >= 80) return AppTheme.primary;
    if (score >= 60) return AppTheme.accent;
    if (score >= 40) return AppTheme.chart3;
    return AppTheme.destructive;
  }

  String get scoreLabel {
    if (score >= 80) return 'Mükemmel';
    if (score >= 60) return 'İyi';
    if (score >= 40) return 'Orta';
    return 'Düşük';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: size * 0.08,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toInt().toString(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
              Text(
                scoreLabel,
                style: TextStyle(
                  fontSize: size * 0.1,
                  color: AppTheme.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({super.key, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null)
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        if (action != null) action!,
      ],
    );
  }
}