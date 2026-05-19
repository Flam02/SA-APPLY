

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application_model.dart';
import '../../utils/app_theme.dart';
import '../shared/widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _filter = 'all';
  final List<Map<String, String>> _filters = [
    {'value': 'all',      'label': 'All'},
    {'value': 'pending',  'label': 'Pending'},
    {'value': 'approved', 'label': 'Approved'},
    {'value': 'rejected', 'label': 'Rejected'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().fetchAllApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStats(),
                const SizedBox(height: 24),
                _buildFilterChips(),
                const SizedBox(height: 16),
                _buildApplicationList(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryDeep,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => context.read<ApplicationProvider>()
              .fetchAllApplications(statusFilter: _filter == 'all' ? null : _filter),
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () => context.read<AuthProvider>().signOut(),
          tooltip: 'Sign Out',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryDeep, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: AppTheme.accentGold, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Portal',
                              style: GoogleFonts.dmSerifDisplay(
                                  color: Colors.white, fontSize: 24)),
                          Text('Student Assistant Applications',
                              style: GoogleFonts.dmSans(
                                  color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text('Admin Dashboard',
            style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 18)),
        collapseMode: CollapseMode.none,
      ),
    );
  }

  // ─── Stats ──────────────────────────────────────────────────────────────────
  Widget _buildStats() {
    return Consumer<ApplicationProvider>(
      builder: (_, appProv, __) {
        final all      = appProv.applications;
        final pending  = all.where((a) => a.isPending).length;
        final approved = all.where((a) => a.isApproved).length;
        final rejected = all.where((a) => a.isRejected).length;
        return Row(
          children: [
            _statCard('Total',    all.length.toString(), Icons.assignment_rounded,    AppTheme.primaryDeep),
            const SizedBox(width: 10),
            _statCard('Pending',  pending.toString(),    Icons.schedule_rounded,      AppTheme.warningAmber),
            const SizedBox(width: 10),
            _statCard('Approved', approved.toString(),   Icons.check_circle_rounded,  AppTheme.successGreen),
            const SizedBox(width: 10),
            _statCard('Rejected', rejected.toString(),   Icons.cancel_rounded,        AppTheme.errorRed),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(count,
                style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: color)),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ─── Filter chips ────────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final isSelected = _filter == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f['label']!),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _filter = f['value']!);
                context.read<ApplicationProvider>().fetchAllApplications(
                  statusFilter: f['value'] == 'all' ? null : f['value'],
                );
              },
              selectedColor: AppTheme.primaryDeep,
              labelStyle: GoogleFonts.dmSans(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryDeep : AppTheme.cardBorder,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Application List ────────────────────────────────────────────────────────
  Widget _buildApplicationList() {
    return Consumer<ApplicationProvider>(
      builder: (_, appProv, __) {
        if (appProv.isLoading) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator()));
        }
        if (appProv.applications.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.inbox_rounded,
            title: 'No Applications',
            message: 'There are no applications matching this filter.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${appProv.applications.length} Application(s)',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            ...appProv.applications.map((app) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildApplicationCard(app),
                )),
          ],
        );
      },
    );
  }

  // ─── Application Card ────────────────────────────────────────────────────────
  Widget _buildApplicationCard(ApplicationModel app) {
    return AppCard(
      onTap: () => _showApplicationDetail(app), // ← tap card to see full details
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryDeep.withValues(alpha: 0.08),
                child: Text(
                  app.studentName.isNotEmpty
                      ? app.studentName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 18, color: AppTheme.primaryDeep),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.studentName,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(app.studentEmail,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              StatusBadge(status: app.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // ── Details row ──────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.school_rounded,
                  size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('Year ${app.yearOfStudy}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(DateFormat('dd MMM yyyy').format(app.createdAt),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          Text('${app.module1Code} — ${app.module1Name}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          if (app.hasSecondModule)
            Text('${app.module2Code} — ${app.module2Name}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),

          // ── Document pill (always visible if doc exists) ──────────────────
          if (app.documentUrl != null || app.documentName.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDocumentPill(app),
          ],

          // ── Action buttons ───────────────────────────────────────────────────
          if (app.isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showActionDialog(app, 'rejected'),
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: AppTheme.errorRed),
                    label: const Text('Reject',
                        style: TextStyle(color: AppTheme.errorRed)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.errorRed),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showActionDialog(app, 'approved'),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Show view details hint
                Text('Tap card to view full details',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppTheme.accentTeal)),
                TextButton.icon(
                  onPressed: () => _confirmAdminDelete(app),
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: AppTheme.errorRed),
                  label: const Text('Remove',
                      style:
                          TextStyle(color: AppTheme.errorRed, fontSize: 13)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Document Pill ────────────────────────────────────────────────────────────
  Widget _buildDocumentPill(ApplicationModel app) {
    final hasUrl = app.documentUrl != null && app.documentUrl!.isNotEmpty;
    return GestureDetector(
      onTap: hasUrl ? () => _openDocument(app.documentUrl!) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasUrl
              ? AppTheme.accentTeal.withValues(alpha: 0.08)
              : AppTheme.warningAmber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasUrl
                ? AppTheme.accentTeal.withValues(alpha: 0.3)
                : AppTheme.warningAmber.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasUrl ? Icons.attach_file_rounded : Icons.info_outline_rounded,
              size: 16,
              color: hasUrl ? AppTheme.accentTeal : AppTheme.warningAmber,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                app.documentName.isNotEmpty
                    ? app.documentName
                    : 'Supporting Document',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: hasUrl ? AppTheme.accentTeal : AppTheme.warningAmber,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasUrl) ...[
              const SizedBox(width: 6),
              Icon(Icons.open_in_new_rounded,
                  size: 14, color: AppTheme.accentTeal),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Full Application Detail Bottom Sheet ────────────────────────────────────
  void _showApplicationDetail(ApplicationModel app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryDeep,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Application Details',
                              style: GoogleFonts.dmSerifDisplay(
                                  color: Colors.white, fontSize: 18)),
                          Text(app.studentName,
                              style: GoogleFonts.dmSans(
                                  color: Colors.white60, fontSize: 13)),
                        ],
                      ),
                    ),
                    StatusBadge(status: app.status),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Student Info ─────────────────────────────────────────
                    _sheetSection('Student Information', [
                      _sheetRow(Icons.person_rounded,     'Full Name',      app.studentName),
                      _sheetRow(Icons.email_rounded,      'Email',          app.studentEmail),
                      _sheetRow(Icons.timeline_rounded,   'Year of Study',  'Year ${app.yearOfStudy}'),
                      _sheetRow(Icons.verified_rounded,
                          'Requirements Met',
                          app.meetsRequirements ? 'Yes — Confirmed' : 'Not confirmed',
                          valueColor: app.meetsRequirements
                              ? AppTheme.successGreen
                              : AppTheme.errorRed),
                    ]),
                    const SizedBox(height: 16),

                    // ── Modules ──────────────────────────────────────────────
                    _sheetSection('Module Selection', [
                      _sheetRow(Icons.book_rounded, 'Module 1 Level', app.module1Level),
                      _sheetRow(Icons.menu_book_rounded, 'Module 1',
                          '${app.module1Code} — ${app.module1Name}'),
                      if (app.hasSecondModule) ...[
                        _sheetRow(Icons.book_rounded, 'Module 2 Level', app.module2Level ?? ''),
                        _sheetRow(Icons.menu_book_rounded, 'Module 2',
                            '${app.module2Code} — ${app.module2Name}'),
                      ],
                    ]),
                    const SizedBox(height: 16),

                    // ── Document ─────────────────────────────────────────────
                    _sheetSection('Supporting Document', [
                      if (app.documentUrl != null &&
                          app.documentUrl!.isNotEmpty) ...[
                        _sheetRow(Icons.attach_file_rounded, 'File Name',
                            app.documentName.isNotEmpty
                                ? app.documentName
                                : 'Uploaded document'),
                        const SizedBox(height: 12),
                        // View Document Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _openDocument(app.documentUrl!),
                            icon: const Icon(Icons.open_in_new_rounded,
                                size: 18),
                            label: const Text('Open Document'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentTeal,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Copy URL button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _copyDocumentUrl(app.documentUrl!),
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: const Text('Copy Document URL'),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ] else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.warningAmber.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.warningAmber.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 16,
                                  color: AppTheme.warningAmber),
                              const SizedBox(width: 8),
                              Text('No document uploaded',
                                  style: TextStyle(
                                      color: AppTheme.warningAmber,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                    ]),
                    const SizedBox(height: 16),

                    // ── Admin Comment ────────────────────────────────────────
                    if (app.adminComment != null &&
                        app.adminComment!.isNotEmpty) ...[
                      _sheetSection('Admin Feedback', [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: app.isApproved
                                ? AppTheme.successGreen.withValues(alpha: 0.08)
                                : AppTheme.errorRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: app.isApproved
                                  ? AppTheme.successGreen.withValues(alpha: 0.3)
                                  : AppTheme.errorRed.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(app.adminComment!,
                              style: const TextStyle(fontSize: 14)),
                        ),
                      ]),
                      const SizedBox(height: 16),
                    ],

                    // ── Timestamps ───────────────────────────────────────────
                    _sheetSection('Timeline', [
                      _sheetRow(Icons.calendar_today_rounded, 'Submitted',
                          DateFormat('dd MMM yyyy — HH:mm')
                              .format(app.createdAt)),
                      _sheetRow(Icons.update_rounded, 'Last Updated',
                          DateFormat('dd MMM yyyy — HH:mm')
                              .format(app.updatedAt)),
                    ]),
                    const SizedBox(height: 24),

                    // ── Action Buttons (if pending) ──────────────────────────
                    if (app.isPending) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showActionDialog(app, 'rejected');
                              },
                              icon: const Icon(Icons.close_rounded,
                                  size: 16, color: AppTheme.errorRed),
                              label: const Text('Reject',
                                  style:
                                      TextStyle(color: AppTheme.errorRed)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppTheme.errorRed),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showActionDialog(app, 'approved');
                              },
                              icon: const Icon(Icons.check_rounded,
                                  size: 16),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successGreen,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sheet helpers ────────────────────────────────────────────────────────────
  Widget _sheetSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _sheetRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryDeep.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(icon, size: 16, color: AppTheme.primaryDeep),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: valueColor ?? AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Open Document ────────────────────────────────────────────────────────────
  Future<void> _openDocument(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Cannot open document. Try copying the URL instead.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening document: $e')),
        );
      }
    }
  }

  // ─── Copy Document URL ────────────────────────────────────────────────────────
  Future<void> _copyDocumentUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document URL copied to clipboard!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  // ─── Action Dialog ────────────────────────────────────────────────────────────
  void _showActionDialog(ApplicationModel app, String action) {
    final commentCtrl = TextEditingController();
    final isApproving = action == 'approved';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
            isApproving ? 'Approve Application' : 'Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Applicant: ${app.studentName}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('${app.module1Code} — ${app.module1Name}'),
            const SizedBox(height: 16),
            TextField(
              controller: commentCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: isApproving
                    ? 'Comment (Optional)'
                    : 'Reason for Rejection',
                hintText: isApproving
                    ? 'Congratulations...'
                    : 'Please provide a reason...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          Consumer<ApplicationProvider>(
            builder: (_, appProv, __) => ElevatedButton(
              onPressed: appProv.isLoading
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      final success =
                          await appProv.updateApplicationStatus(
                        applicationId: app.id!,
                        status: action,
                        comment: commentCtrl.text.trim().isEmpty
                            ? null
                            : commentCtrl.text.trim(),
                      );
                      if (success && ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(isApproving
                                ? 'Application approved.'
                                : 'Application rejected.'),
                            backgroundColor: isApproving
                                ? AppTheme.successGreen
                                : AppTheme.errorRed,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isApproving ? AppTheme.successGreen : AppTheme.errorRed,
              ),
              child: Text(isApproving ? 'Approve' : 'Reject'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Admin Delete ─────────────────────────────────────────────────────────────
  void _confirmAdminDelete(ApplicationModel app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Application'),
        content: Text(
            "Permanently remove ${app.studentName}'s application? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<ApplicationProvider>(
            builder: (ctx, appProv, _) => ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await appProv.adminDeleteApplication(app.id!);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed),
              child: const Text('Remove'),
            ),
          ),
        ],
      ),
    );
  }
}
