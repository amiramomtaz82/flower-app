import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';

class SelectionTab {
  const SelectionTab({required this.id, required this.label});

  final String id;
  final String label;
}

class SelectionTabs extends StatefulWidget {
  const SelectionTabs({
    super.key,
    required this.tabs,
    required this.selectedId,
    required this.onSelected,
  });

  final List<SelectionTab> tabs;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  State<SelectionTabs> createState() => _SelectionTabsState();
}

class _SelectionTabsState extends State<SelectionTabs> {
  final Map<String, GlobalKey> _tabKeys = {};

  @override
  void initState() {
    super.initState();
    _revealSelected();
  }

  @override
  void didUpdateWidget(SelectionTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _revealSelected();
    }
  }

  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // off-screen tabs may not be built yet — nothing to scroll to then
      final tabContext = _tabKeys[widget.selectedId]?.currentContext;
      if (tabContext == null) return;
      Scrollable.ensureVisible(
        tabContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.tabs.length,
      separatorBuilder: (_, _) => const SizedBox(width: 24),
      itemBuilder: (context, index) {
        final tab = widget.tabs[index];
        return _Tab(
          key: _tabKeys.putIfAbsent(tab.id, GlobalKey.new),
          label: tab.label,
          isSelected: tab.id == widget.selectedId,
          onTap: () => widget.onSelected(tab.id),
        );
      },
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = LightColors();

    return InkWell(
      onTap: onTap,
      // sizes the underline to the label instead of a fixed width
      child: IntrinsicWidth(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? colors.primary : colors.darkGrey,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              color: isSelected ? colors.primary : colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
