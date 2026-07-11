import 'package:flutter/material.dart';

import '../admin/job_form.dart';
import 'app_text_styles.dart';


/// Recreates the sticky `<header>` TopAppBar shared by all four HTML pages:
/// avatar/logo on the left, nav links (desktop only) + a trailing icon
/// button on the right, with a bottom hairline divider.
class SereneAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SereneAppBar({
    super.key,
    required this.title,
    required this.avatarUrl,
    required this.navItems,
    required this.activeNavItem,
    this.trailingIcon = Icons.settings_outlined,
    this.onTrailingTap,
    this.onMenuTap,
    this.showMenuButton = false,
  });

  final String title;
  final String avatarUrl;
  final List<String> navItems;
  final String activeNavItem;
  final IconData trailingIcon;
  final VoidCallback? onTrailingTap;
  final VoidCallback? onMenuTap;
  final bool showMenuButton;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showMenuButton)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: onMenuTap,
            ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryContainer,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppText.titleMd(color: AppColors.primary)
                  .copyWith(fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isDesktop) ...[
            for (final item in navItems)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    item,
                    style: AppText.labelCaps(
                      color: item == activeNavItem
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ).copyWith(
                      fontWeight:
                          item == activeNavItem ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
          IconButton(
            icon: Icon(trailingIcon, color: AppColors.primary),
            onPressed: onTrailingTap ?? () {},
          ),
        ],
      ),
    );
  }
}
