import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/subject_provider.dart';
import 'providers/subject_form_provider.dart';
import 'providers/subject_filter_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/add_subject_screen.dart';
import 'screens/subject_list_screen.dart';
import 'screens/summary_screen.dart';
import 'themes/app_themes.dart';

class NavProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => SubjectFormProvider()),
        ChangeNotifierProvider(create: (_) => SubjectFilterProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Student Grade Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode:
          themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;

  static const List<Widget> _screens = [
    AddSubjectScreen(),
    SubjectListScreen(),
    SummaryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final nav = context.read<NavProvider>();
    nav.addListener(_onNavChanged);
  }

  void _onNavChanged() {
    final next = context.read<NavProvider>().currentIndex;
    if (!_pageController.hasClients) return;
    if (_pageController.page?.round() == next) return;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    context.read<NavProvider>().removeListener(_onNavChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    context.read<NavProvider>().setIndex(i);
  }

  void _onTap(int i) {
    final nav = context.read<NavProvider>();
    nav.setIndex(i);
    if (_pageController.hasClients &&
        _pageController.page?.round() != i) {
      _pageController.animateToPage(
        i,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _AppBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: _CustomNavBar(
        onTap: _onTap,
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = context.select<ThemeProvider, bool>((t) => t.isDarkMode);
    final title = context.select<NavProvider, String>((n) {
      switch (n.currentIndex) {
        case 0:
          return 'Add Subject';
        case 1:
          return 'Subject List';
        case 2:
          return 'Summary';
        default:
          return '';
      }
    });
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: cs.onPrimary,
          ),
          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _CustomNavBar extends StatelessWidget {
  final ValueChanged<int> onTap;

  const _CustomNavBar({required this.onTap});

  static const List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.menu_book_rounded,
      outline: Icons.menu_book_outlined,
      label: 'Add',
    ),
    _NavItemData(
      icon: Icons.view_list_rounded,
      outline: Icons.view_list_outlined,
      label: 'Subjects',
    ),
    _NavItemData(
      icon: Icons.insights_rounded,
      outline: Icons.insights_outlined,
      label: 'Summary',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentIndex =
        context.select<NavProvider, int>((n) => n.currentIndex);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: cs.onSurface.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.16),
                blurRadius: 20,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _items.length;
              return Row(
                children: List.generate(_items.length, (i) {
                  return SizedBox(
                    width: itemWidth,
                    height: 52,
                    child: _NavPill(
                      data: _items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData outline;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.outline,
    required this.label,
  });
}

class _NavPill extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _NavPill({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedFg = cs.onPrimary;
    final unselectedFg = cs.onSurface.withOpacity(0.7);
    final fg = selected ? selectedFg : unselectedFg;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        splashColor: cs.primary.withOpacity(0.08),
        highlightColor: cs.primary.withOpacity(0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [cs.primary, cs.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? cs.onPrimary.withOpacity(0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    selected ? data.icon : data.outline,
                    key: ValueKey(selected),
                    size: 20,
                    color: fg,
                  ),
                ),
              ),
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  widthFactor: selected ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      data.label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}