
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: (config['text'] as Color).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'] as IconData, size: 12, color: config['text'] as Color),
          const SizedBox(width: 5),
          Text(
            config['label'] as String,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config['text'] as Color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getConfig() {
    switch (status.toLowerCase()) {
      case 'approved':
        return {
          'label': 'Approved',
          'icon': Icons.check_circle_rounded,
          // ignore: deprecated_member_use
          'bg': AppTheme.successGreen.withOpacity(0.12),
          'text': AppTheme.successGreen,
        };
      case 'rejected':
        return {
          'label': 'Rejected',
          'icon': Icons.cancel_rounded,
          // ignore: deprecated_member_use
          'bg': AppTheme.errorRed.withOpacity(0.12),
          'text': AppTheme.errorRed,
        };
      default:
        return {
          'label': 'Pending Review',
          'icon': Icons.schedule_rounded,
          // ignore: deprecated_member_use
          'bg': AppTheme.warningAmber.withOpacity(0.12),
          'text': AppTheme.warningAmber,
        };
    }
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppTheme.primaryDeep.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryDeep),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
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

// ─── App Card ─────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: AppTheme.primaryDeep.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppTheme.primaryDeep.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primaryDeep,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

// ─── Module Card (used in form) ───────────────────────────────────────────────
class ModuleSelectionCard extends StatelessWidget {
  final String title;
  final String? selectedLevel;
  final String? selectedCode;
  final String? selectedName;
  final List<String> levels;
  final List<Map<String, String>> modules;
  final ValueChanged<String?> onLevelChanged;
  final ValueChanged<String?> onModuleChanged;
  final bool isOptional;
  final VoidCallback? onRemove;

  const ModuleSelectionCard({
    super.key,
    required this.title,
    this.selectedLevel,
    this.selectedCode,
    this.selectedName,
    required this.levels,
    required this.modules,
    required this.onLevelChanged,
    required this.onModuleChanged,
    this.isOptional = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      // ignore: deprecated_member_use
      borderColor: AppTheme.primaryDeep.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDeep,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book_rounded, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (isOptional && onRemove != null)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppTheme.errorRed),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: selectedLevel,
            decoration: const InputDecoration(
              labelText: 'Academic Level',
              prefixIcon: Icon(Icons.school_rounded),
            ),
            items: levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: onLevelChanged,
            validator: (v) => v == null ? 'Please select an academic level' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedCode,
            decoration: const InputDecoration(
              labelText: 'Module',
              prefixIcon: Icon(Icons.menu_book_rounded),
            ),
            items: modules
                .map((m) => DropdownMenuItem(
                      value: m['code'],
                      child: Text('${m['code']} — ${m['name']}'),
                    ))
                .toList(),
            onChanged: onModuleChanged,
            validator: (v) => v == null ? 'Please select a module' : null,
            hint: selectedLevel == null
                ? const Text('Select a level first')
                : const Text('Select module'),
          ),
        ],
      ),
    );
  }
}
