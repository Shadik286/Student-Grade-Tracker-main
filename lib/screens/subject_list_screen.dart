import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../providers/subject_filter_provider.dart';
import '../widgets/subject_tile.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Consumer<SubjectProvider>(
          builder: (context, provider, _) {
            if (provider.subjects.isEmpty) {
              return const _EmptyState();
            }

            final filterProvider = context.watch<SubjectFilterProvider>();
            final filtered = filterProvider.apply(provider.subjects);
            final activeFilterCount = filtered.length;
            final query = filterProvider.query;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _SummaryHeader(
                      total: provider.totalSubjects,
                      passing: provider.passingSubjects.length,
                      failing: provider.failingSubjects.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  sliver: SliverToBoxAdapter(
                    child: _SearchField(
                      controller: _searchCtrl,
                      onChanged: (v) =>
                          context.read<SubjectFilterProvider>().setQuery(v),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _FilterRow(
                      filter: filterProvider.filter,
                      onChanged: (f) =>
                          context.read<SubjectFilterProvider>().setFilter(f),
                      visible: activeFilterCount,
                      total: provider.totalSubjects,
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NoMatches(query: query),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 24),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final subject = filtered[index];
                        return Dismissible(
                          key: ValueKey(
                            '${subject.name}_${subject.mark}_$index',
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            final originalIndex = provider.subjects
                                .indexWhere((s) =>
                                    s.name == subject.name &&
                                    s.mark == subject.mark);
                            if (originalIndex != -1) {
                              provider.removeSubject(originalIndex);
                            }
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('"${subject.name}" removed'),
                              ),
                            );
                          },
                          background: _SwipeBackground(),
                          child: SubjectTile(subject: subject),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Header strip: stat tiles + subtle progress ─────────────────────────────

class _SummaryHeader extends StatelessWidget {
  final int total;
  final int passing;
  final int failing;

  const _SummaryHeader({
    required this.total,
    required this.passing,
    required this.failing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final passRatio = total == 0 ? 0.0 : passing / total;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your subjects',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onPrimary.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$total recorded',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cs.onPrimary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: cs.onPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(passRatio * 100).toStringAsFixed(0)}% pass',
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  icon: Icons.check_circle_rounded,
                  label: 'Pass',
                  value: '$passing',
                ),
              ),
              Container(
                height: 32,
                width: 1,
                color: cs.onPrimary.withOpacity(0.25),
              ),
              Expanded(
                child: _HeaderStat(
                  icon: Icons.cancel_rounded,
                  label: 'Fail',
                  value: '$failing',
                ),
              ),
              Container(
                height: 32,
                width: 1,
                color: cs.onPrimary.withOpacity(0.25),
              ),
              Expanded(
                child: _HeaderStat(
                  icon: Icons.trending_up_rounded,
                  label: 'Pass rate',
                  value: total == 0
                      ? '—'
                      : '${(passRatio * 100).toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cs.onPrimary.withOpacity(0.85), size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              color: cs.onPrimary.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search field ───────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search subjects',
            hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.5)),
            prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
            isDense: true,
            filled: true,
            fillColor: cs.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: cs.onSurface.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: cs.onSurface.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
          ),
        );
      },
    );
  }
}

// ─── Filter row ─────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final SubjectFilter filter;
  final ValueChanged<SubjectFilter> onChanged;
  final int visible;
  final int total;

  const _FilterRow({
    required this.filter,
    required this.onChanged,
    required this.visible,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Row(
      children: [
        _Chip(
          label: 'All',
          icon: Icons.apps_rounded,
          selected: filter == SubjectFilter.all,
          onTap: () => onChanged(SubjectFilter.all),
          selectedColor: cs.primary,
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Pass',
          icon: Icons.check_circle_rounded,
          selected: filter == SubjectFilter.pass,
          onTap: () => onChanged(SubjectFilter.pass),
          selectedColor: cs.primary,
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'Fail',
          icon: Icons.cancel_rounded,
          selected: filter == SubjectFilter.fail,
          onTap: () => onChanged(SubjectFilter.fail),
          selectedColor: cs.error,
        ),
        const Spacer(),
        Text(
          '$visible of $total',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const _Chip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.onPrimary : cs.onSurface.withOpacity(0.75);
    final bg = selected ? selectedColor : cs.surface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? selectedColor
                  : cs.onSurface.withOpacity(0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Swipe-to-delete background ─────────────────────────────────────────────

class _SwipeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: cs.error,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      child: Icon(Icons.delete_rounded, color: cs.onError),
    );
  }
}

// ─── Empty states ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 44,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No subjects yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Switch to the Add Subject tab to record your first mark.',
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

class _NoMatches extends StatelessWidget {
  final String query;
  const _NoMatches({required this.query});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.onSurface.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36,
                color: cs.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              query.isEmpty
                  ? 'Nothing matches the current filter'
                  : 'No matches for "$query"',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different search term or change the filter.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
