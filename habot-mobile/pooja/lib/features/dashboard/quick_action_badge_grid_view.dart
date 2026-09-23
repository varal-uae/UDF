import 'package:flutter/material.dart';

/// Unique styling tokens for the Quick Action Badge Grid View.
abstract final class QuickActionBadgeTokens {
  static const Color primaryBlue = Color(0xFF1E40AF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Action item colors
  static const Color bookAccent = Color(0xFF2563EB);
  static const Color chatAccent = Color(0xFF0D9488);
  static const Color historyAccent = Color(0xFFD97706);
  static const Color supportAccent = Color(0xFF7C3AED);

  // Badge alert color
  static const Color badgeRed = Color(0xFFDC2626);
  static const Color badgeEmerald = Color(0xFF059669);

  static const double borderRadius = 16.0;
  static const double iconSize = 28.0;
  static const double minTouchTarget = 48.0;
}

/// Metadata model for each quick action card.
class QuickActionItem {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final int badgeCount;
  final bool showBadgeDot;

  const QuickActionItem({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.badgeCount = 0,
    this.showBadgeDot = false,
  });
}

/// A responsive 2x2 quick-action grid view leveraging Material 3 Icon Badges.
class QuickActionBadgeGridView extends StatefulWidget {
  final void Function(QuickActionItem action)? onActionSelected;

  const QuickActionBadgeGridView({
    super.key,
    this.onActionSelected,
  });

  @override
  State<QuickActionBadgeGridView> createState() => _QuickActionBadgeGridViewState();
}

class _QuickActionBadgeGridViewState extends State<QuickActionBadgeGridView> {
  String _selectedActionId = 'book';
  int _chatUnreadCount = 4;
  int _supportTicketCount = 1;
  bool _historyHasUpdate = true;

  List<QuickActionItem> get _actions => [
    const QuickActionItem(
      id: 'book',
      label: 'Book Service',
      subtitle: 'Schedule slots',
      icon: Icons.calendar_month_outlined,
      accentColor: QuickActionBadgeTokens.bookAccent,
      badgeCount: 0,
      showBadgeDot: false,
    ),
    QuickActionItem(
      id: 'chat',
      label: 'Live Chat',
      subtitle: 'Provider line',
      icon: Icons.chat_bubble_outline_rounded,
      accentColor: QuickActionBadgeTokens.chatAccent,
      badgeCount: _chatUnreadCount,
      showBadgeDot: false,
    ),
    QuickActionItem(
      id: 'history',
      label: 'Past Orders',
      subtitle: 'Audit logs',
      icon: Icons.history_rounded,
      accentColor: QuickActionBadgeTokens.historyAccent,
      badgeCount: 0,
      showBadgeDot: _historyHasUpdate,
    ),
    QuickActionItem(
      id: 'support',
      label: 'Help Desk',
      subtitle: '24/7 Escalations',
      icon: Icons.headset_mic_outlined,
      accentColor: QuickActionBadgeTokens.supportAccent,
      badgeCount: _supportTicketCount,
      showBadgeDot: false,
    ),
  ];

  void _handleTap(QuickActionItem item) {
    setState(() {
      _selectedActionId = item.id;
      if (item.id == 'chat' && _chatUnreadCount > 0) {
        _chatUnreadCount = 0;
      }
      if (item.id == 'history') {
        _historyHasUpdate = false;
      }
      if (item.id == 'support' && _supportTicketCount > 0) {
        _supportTicketCount = 0;
      }
    });

    widget.onActionSelected?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: QuickActionBadgeTokens.surfaceCard,
        borderRadius: BorderRadius.circular(QuickActionBadgeTokens.borderRadius),
        border: Border.all(color: QuickActionBadgeTokens.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: QuickActionBadgeTokens.primaryBlue.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: QuickActionBadgeTokens.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions Matrix',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: QuickActionBadgeTokens.textDark,
                      ),
                    ),
                    Text(
                      'M3 badge indicators with instant drill-down',
                      style: TextStyle(
                        fontSize: 12,
                        color: QuickActionBadgeTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'GEN-01623',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 2x2 Grid Layout
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final item = _actions[index];
              final isSelected = _selectedActionId == item.id;

              return _buildActionTile(item, isSelected);
            },
          ),
          const SizedBox(height: 14),
          // Quick Status Banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: QuickActionBadgeTokens.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: QuickActionBadgeTokens.borderLight),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: QuickActionBadgeTokens.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Active Selection: ${_actions.firstWhere((a) => a.id == _selectedActionId).label}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: QuickActionBadgeTokens.textDark,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _chatUnreadCount = 3;
                      _supportTicketCount = 2;
                      _historyHasUpdate = true;
                    });
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Reset Badges',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(QuickActionItem item, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleTap(item),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? item.accentColor.withAlpha(20)
                : QuickActionBadgeTokens.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? item.accentColor : QuickActionBadgeTokens.borderLight,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.accentColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _buildBadgedIcon(item),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: item.accentColor,
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? item.accentColor : QuickActionBadgeTokens.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: QuickActionBadgeTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgedIcon(QuickActionItem item) {
    if (item.badgeCount > 0) {
      return Badge.count(
        count: item.badgeCount,
        backgroundColor: QuickActionBadgeTokens.badgeRed,
        textStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        child: Icon(
          item.icon,
          color: item.accentColor,
          size: 22,
        ),
      );
    } else if (item.showBadgeDot) {
      return Badge(
        backgroundColor: QuickActionBadgeTokens.badgeEmerald,
        smallSize: 8,
        child: Icon(
          item.icon,
          color: item.accentColor,
          size: 22,
        ),
      );
    }

    return Icon(
      item.icon,
      color: item.accentColor,
      size: 22,
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: QuickActionBadgeGridView(),
          ),
        ),
      ),
    ),
  );
}
