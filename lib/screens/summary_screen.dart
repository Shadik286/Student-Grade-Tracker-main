import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/subject_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  Color _gradeColor(BuildContext context, String grade) {
    final cs = Theme.of(context).colorScheme;
    switch (grade) {
      case 'A':
        return cs.primary;
      case 'B':
        return cs.secondary;
      case 'C':
        return cs.tertiary;
      case 'F':
        return cs.error;
      default:
        return cs.onSurface;
    }
  }

  IconData _gradeIcon(String grade) {
    switch (grade) {
      case 'A':
        return Icons.emoji_events_rounded;
      case 'B':
        return Icons.thumb_up_rounded;
      case 'C':
        return Icons.menu_book_rounded;
      case 'F':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _gradeHeadline(String grade) {
    switch (grade) {
      case 'A':
        return 'Outstanding work';
      case 'B':
        return 'Solid performance';
      case 'C':
        return 'Room to grow';
      case 'F':
        return 'Needs attention';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: Consumer<SubjectProvider>(
        builder: (context, provider, _) {
          if (provider.subjects.isEmpty) {
            return const _EmptyState();
          }

          final overallGrade = provider.overallGrade;
          final gradeColor = _gradeColor(context, overallGrade);
          final average = provider.averageMark;
          final passing = provider.passingSubjects.length;
          final failing = provider.failingSubjects.length;
          final total = provider.totalSubjects;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OverallBanner(
                  grade: overallGrade,
                  gradeColor: gradeColor,
                  icon: _gradeIcon(overallGrade),
                  headline: _gradeHeadline(overallGrade),
                  average: average,
                ),
                const SizedBox(height: 16),
                _SummaryBar(
                  total: total,
                  passing: passing,
                  failing: failing,
                ),
                const SizedBox(height: 16),
                _SectionTitle(
                  'Performance',
                  trailing: '${average.toStringAsFixed(1)}% avg',
                ),
                const SizedBox(height: 10),
                _ProgressCard(
                  average: average,
                  gradeColor: gradeColor,
                ),
                const SizedBox(height: 20),
                _SectionTitle('Pass vs Fail'),
                const SizedBox(height: 10),
                _DistributionCard(
                  passing: passing,
                  failing: failing,
                  total: total,
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  'Subject Breakdown',
                  trailing: '$total total',
                ),
                const SizedBox(height: 10),
                if (provider.subjects.isEmpty)
                  const _SmallEmpty()
                else
                  ...provider.subjects.map(
                    (s) => _BreakdownRow(
                      subject: s,
                      gradeColor: _gradeColor(context, s.grade),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Overall Result Banner ──────────────────────────────────────────────────

class _OverallBanner extends StatelessWidget {
  final String grade;
  final Color gradeColor;
  final IconData icon;
  final String headline;
  final double average;

  const _OverallBanner({
    required this.grade,
    required this.gradeColor,
    required this.icon,
    required this.headline,
    required this.average,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradeColor.withOpacity(0.85), gradeColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.onPrimary.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cs.onPrimary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall result',
                      style: TextStyle(
                        color: cs.onPrimary.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      headline,
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                grade,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: cs.onPrimary.withOpacity(0.85),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Average mark',
                style: TextStyle(
                  color: cs.onPrimary.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${average.toStringAsFixed(1)} / 100',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Summary Bar (Total / Pass / Fail) ──────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final int total;
  final int passing;
  final int failing;

  const _SummaryBar({
    required this.total,
    required this.passing,
    required this.failing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCell(
              icon: Icons.library_books_rounded,
              label: 'Total',
              value: '$total',
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: cs.onPrimary.withOpacity(0.25),
          ),
          Expanded(
            child: _SummaryCell(
              icon: Icons.check_circle_rounded,
              label: 'Pass',
              value: '$passing',
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: cs.onPrimary.withOpacity(0.25),
          ),
          Expanded(
            child: _SummaryCell(
              icon: Icons.cancel_rounded,
              label: 'Fail',
              value: '$failing',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: cs.onPrimary.withOpacity(0.85), size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: cs.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: cs.onPrimary.withOpacity(0.85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Section Title ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  final String? trailing;

  const _SectionTitle(this.text, {this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

// ─── Progress Card ──────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final double average;
  final Color gradeColor;

  const _ProgressCard({
    required this.average,
    required this.gradeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final percent = (average / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Average mark progress',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              Text(
                '${average.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: gradeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: cs.onSurface.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ScaleTick(label: '0', cs: cs),
              _ScaleTick(label: '50', cs: cs),
              _ScaleTick(label: '100', cs: cs, alignEnd: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScaleTick extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  final bool alignEnd;

  const _ScaleTick({
    required this.label,
    required this.cs,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: cs.onSurface.withOpacity(0.45),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    if (alignEnd) {
      return Text(label, style: style);
    }
    return Expanded(
      child: Text(label, style: style, textAlign: TextAlign.start),
    );
  }
}

// ─── Distribution Card ──────────────────────────────────────────────────────

class _DistributionCard extends StatelessWidget {
  final int passing;
  final int failing;
  final int total;

  const _DistributionCard({
    required this.passing,
    required this.failing,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final passingRatio = total == 0 ? 0.0 : passing / total;
    final failingRatio = total == 0 ? 0.0 : failing / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 18,
                    child: Row(
                      children: [
                        Expanded(
                          flex:
                              (passingRatio * 1000).round().clamp(0, 1000),
                          child: Container(color: cs.primary),
                        ),
                        Expanded(
                          flex:
                              (failingRatio * 1000).round().clamp(0, 1000),
                          child: Container(color: cs.error),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                total == 0 ? '—' : '${(passingRatio * 100).toStringAsFixed(0)}% pass',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LegendDot(
                  label: 'Pass',
                  value: passing,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LegendDot(
                  label: 'Fail',
                  value: failing,
                  color: cs.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _LegendDot({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          '$value',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Breakdown Row ──────────────────────────────────────────────────────────

class _BreakdownRow extends StatelessWidget {
  final Subject subject;
  final Color gradeColor;

  const _BreakdownRow({
    required this.subject,
    required this.gradeColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.onSurface.withOpacity(0.06)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: gradeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${subject.mark} / 100',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: gradeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subject.grade,
                        style: TextStyle(
                          color: gradeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty States ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights_rounded,
                size: 48,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Nothing to summarize yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a subject to see your overall result, average, and pass/fail breakdown here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallEmpty extends StatelessWidget {
  const _SmallEmpty();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      alignment: Alignment.center,
      child: Text(
        'No subjects added',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}