import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../providers/subject_provider.dart';
import '../providers/subject_form_provider.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _markController = TextEditingController();
  final _nameFocus = FocusNode();
  final _markFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _markController.dispose();
    _nameFocus.dispose();
    _markFocus.dispose();
    super.dispose();
  }

  void _submitForm() {
    final formProvider = context.read<SubjectFormProvider>();

    // First invalid attempt flips autoValidate on so subsequent edits
    // re-validate live. After a successful submit we turn it back off
    // so the freshly-cleared fields don't immediately show error text.
    if (!_formKey.currentState!.validate()) {
      formProvider.markInteraction();
      return;
    }

    final provider = context.read<SubjectProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final cs = Theme.of(context).colorScheme;

    if (provider.subjectExists(_nameController.text.trim())) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(_buildSnack(
        context: context,
        icon: Icons.error_outline,
        message:
            '"${_nameController.text.trim()}" is already on your list',
        tone: _SnackTone.error,
        fg: cs.onErrorContainer,
        bg: cs.errorContainer,
      ));
      return;
    }

    final subject = Subject(
      name: _nameController.text.trim(),
      mark: int.parse(_markController.text.trim()),
    );

    provider.addSubject(subject);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(_buildSnack(
      context: context,
      icon: Icons.check_circle_rounded,
      message:
          '${subject.name} added · Grade ${subject.grade} · ${subject.mark}/100',
      tone: _SnackTone.success,
      fg: cs.onPrimary,
      bg: cs.primary,
    ));

    // 1) Reset validation mode + bump reload key BEFORE clearing so the
    //    Form's reload doesn't repaint red "cannot be empty" errors onto
    //    the just-emptied fields.
    // 2) Clear the controllers' text.
    formProvider.resetAfterAdd();
    _nameController.clear();
    _markController.clear();

    _nameFocus.requestFocus();
  }

  String? _liveGradePreview(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final mark = int.tryParse(trimmed);
    if (mark == null) return null;
    if (mark < 0 || mark > 100) return null;
    final s = Subject(name: 'preview', mark: mark);
    return s.grade;
  }

  Color _gradeColor(String grade, ColorScheme cs) {
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

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: cs.primary),
      suffixIcon: suffix == null ? null : null,
      suffix: suffix,
      filled: true,
      fillColor: cs.surface,
      labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
      hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.4)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.onSurface.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.onSurface.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final autoValidate =
        context.select<SubjectFormProvider, bool>((p) => p.autoValidate);
    final reloadKey =
        context.select<SubjectFormProvider, Object>((p) => p.reloadKeyValue);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Form(
            key: _formKey,
            // Changing this key forces the Form and its TextFormFields to
            // be rebuilt from scratch — guarantees the inputs clear after
            // a successful add, regardless of any cached Form state.
            child: KeyedSubtree(
              key: ValueKey(reloadKey),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(),
                  const SizedBox(height: 20),
                  _StepCard(
                    index: 1,
                    title: 'Subject name',
                    subtitle: 'e.g. Mathematics, Bangla, Physics',
                    child: TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: autoValidate
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      style: theme.textTheme.titleMedium,
                      decoration: _inputDecoration(
                        context,
                        label: 'Subject',
                        hint: 'e.g. Mathematics',
                        icon: Icons.menu_book_rounded,
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Subject name cannot be empty';
                        }
                        if (trimmed.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _markFocus.requestFocus(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _StepCard(
                    index: 2,
                    title: 'Mark',
                    subtitle: 'Enter a number from 0 to 100',
                    // Drive the live grade preview off the mark controller
                    // directly. No setState needed — the listenable rebuilds
                    // only the mark step card on every keystroke.
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _markController,
                      builder: (context, value, _) {
                        final preview = _liveGradePreview(value.text);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _markController,
                              focusNode: _markFocus,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              autovalidateMode: autoValidate
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              style: theme.textTheme.titleMedium,
                              decoration: _inputDecoration(
                                context,
                                label: 'Mark (0–100)',
                                hint: 'e.g. 75',
                                icon: Icons.star_rate_rounded,
                                suffix: preview != null
                                    ? Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _gradeColor(preview, cs)
                                              .withOpacity(0.14),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          preview,
                                          style: TextStyle(
                                            color: _gradeColor(preview, cs),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                final trimmed = value?.trim() ?? '';
                                if (trimmed.isEmpty) {
                                  return 'Mark cannot be empty';
                                }
                                final mark = int.tryParse(trimmed);
                                if (mark == null) {
                                  return 'Please enter a valid number';
                                }
                                if (mark < 0 || mark > 100) {
                                  return 'Mark must be between 0 and 100';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _submitForm(),
                            ),
                            if (preview != null) ...[
                              const SizedBox(height: 10),
                              _PreviewStrip(grade: preview, cs: cs),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add subject'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _GradeLegend(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.onPrimary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.add_task_rounded, color: cs.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a subject',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in the two steps below to record a new mark.',
                  style: TextStyle(
                    color: cs.onPrimary.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step card ──────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final Widget child;

  const _StepCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Live preview strip ────────────────────────────────────────────────────

class _PreviewStrip extends StatelessWidget {
  final String grade;
  final ColorScheme cs;

  const _PreviewStrip({required this.grade, required this.cs});

  Color get _color {
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

  String get _message {
    switch (grade) {
      case 'A':
        return 'Excellent! Will be marked as passing.';
      case 'B':
        return 'Good job. Will be marked as passing.';
      case 'C':
        return 'Average. Will be marked as passing.';
      case 'F':
        return 'Below 50. Will be marked as failing.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, color: _color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _message,
              style: TextStyle(
                color: _color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Snackbar ───────────────────────────────────────────────────────────────

enum _SnackTone { success, error }

SnackBar _buildSnack({
  required BuildContext context,
  required IconData icon,
  required String message,
  required _SnackTone tone,
  required Color fg,
  required Color bg,
}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    backgroundColor: bg,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 3),
    content: Row(
      children: [
        Icon(icon, color: fg),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: fg),
          ),
        ),
      ],
    ),
  );
}

// ─── Grade legend ──────────────────────────────────────────────────────────

class _GradeLegend extends StatelessWidget {
  static const _entries = <List<String>>[
    ['A', '80–100'],
    ['B', '65–79'],
    ['C', '50–64'],
    ['F', '0–49'],
  ];

  const _GradeLegend();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
              Icon(Icons.scale_rounded,
                  size: 18, color: cs.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                'Grade scale',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < _entries.length; i++) ...[
                Expanded(
                  child: _LegendCell(
                    grade: _entries[i][0],
                    range: _entries[i][1],
                  ),
                ),
                if (i != _entries.length - 1)
                  Container(
                    height: 28,
                    width: 1,
                    color: cs.onSurface.withOpacity(0.08),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendCell extends StatelessWidget {
  final String grade;
  final String range;
  const _LegendCell({required this.grade, required this.range});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          grade,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          range,
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
