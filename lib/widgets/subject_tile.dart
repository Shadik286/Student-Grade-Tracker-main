import 'package:flutter/material.dart';
import '../models/subject.dart';

class SubjectTile extends StatelessWidget {
  final Subject subject;

  const SubjectTile({
    super.key,
    required this.subject,
  });

  Color _gradeColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (subject.grade) {
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
        return Icons.star_rounded;
      case 'B':
        return Icons.thumb_up_rounded;
      case 'C':
        return Icons.menu_book_rounded;
      case 'F':
        return Icons.refresh_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  String _gradeLabel(String grade) {
    switch (grade) {
      case 'A':
        return 'Excellent';
      case 'B':
        return 'Good';
      case 'C':
        return 'Average';
      case 'F':
        return 'Failing';
      default:
        return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final gradeColor = _gradeColor(context);
    final percent = (subject.mark / 100).clamp(0.0, 1.0);
    final passing = subject.isPassing;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: gradeColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: gradeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _gradeIcon(subject.grade),
                            color: gradeColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_gradeLabel(subject.grade)} • '
                                '${subject.mark}/100',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: gradeColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            subject.grade,
                            style: TextStyle(
                              color: gradeColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 6,
                              backgroundColor:
                                  cs.onSurface.withOpacity(0.08),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(gradeColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: passing
                                ? cs.primary.withOpacity(0.12)
                                : cs.error.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            passing ? 'Pass' : 'Fail',
                            style: TextStyle(
                              color: passing ? cs.primary : cs.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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
