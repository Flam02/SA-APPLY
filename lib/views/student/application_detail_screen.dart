

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/application_provider.dart';
import '../../models/application_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_routes.dart';
import '../shared/widgets.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final ApplicationModel application;
  const ApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Application Details'),
        actions: [
          if (application.isPending) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit Application',
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.applicationForm,
                arguments: {'application': application},
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete Application',
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Header ─────────────────────────────────────────────────
            _buildStatusHeader(context),
            const SizedBox(height: 24),

            // ── Personal Details ──────────────────────────────────────────────
            SectionHeader(title: 'Applicant Details'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.person_rounded,
                    label: 'Full Name',
                    value: application.studentName,
                  ),
                  const Divider(),
                  InfoRow(
                    icon: Icons.email_rounded,
                    label: 'Email Address',
                    value: application.studentEmail,
                  ),
                  const Divider(),
                  InfoRow(
                    icon: Icons.school_rounded,
                    label: 'Year of Study',
                    value: 'Year ${application.yearOfStudy}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Module 1 ──────────────────────────────────────────────────────
            SectionHeader(title: 'Selected Modules'),
            const SizedBox(height: 12),
            _buildModuleCard(context, 'Module 1', application.module1Level,
                application.module1Code, application.module1Name),
            if (application.hasSecondModule) ...[
              const SizedBox(height: 12),
              _buildModuleCard(context, 'Module 2', application.module2Level!,
                  application.module2Code!, application.module2Name!),
            ],
            const SizedBox(height: 24),

            // ── Eligibility ───────────────────────────────────────────────────
            SectionHeader(title: 'Eligibility & Documentation'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.verified_rounded,
                    label: 'Requirements Met',
                    value: application.meetsRequirements ? 'Confirmed' : 'Not confirmed',
                    valueColor: application.meetsRequirements
                        ? AppTheme.successGreen
                        : AppTheme.errorRed,
                  ),
                  if (application.documentUrl != null ||
                      application.documentName.isNotEmpty) ...[
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppTheme.primaryDeep.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.attach_file_rounded,
                            size: 18, color: AppTheme.primaryDeep),
                      ),
                      title: const Text('Supporting Document',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      subtitle: Text(
                        application.documentName.isNotEmpty
                            ? application.documentName
                            : 'Document uploaded',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDeep,
                        ),
                      ),
                      trailing: application.documentUrl != null
                          ? TextButton(
                              onPressed: () =>
                                  _openDocument(application.documentUrl!),
                              child: const Text('View'),
                            )
                          : null,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Admin Feedback ────────────────────────────────────────────────
            if (application.adminComment != null &&
                application.adminComment!.isNotEmpty) ...[
              SectionHeader(title: 'Admin Feedback'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: application.isApproved
                      // ignore: deprecated_member_use
                      ? AppTheme.successGreen.withOpacity(0.08)
                      // ignore: deprecated_member_use
                      : AppTheme.errorRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: application.isApproved
                        // ignore: deprecated_member_use
                        ? AppTheme.successGreen.withOpacity(0.3)
                        // ignore: deprecated_member_use
                        : AppTheme.errorRed.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          application.isApproved
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 16,
                          color: application.isApproved
                              ? AppTheme.successGreen
                              : AppTheme.errorRed,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          application.isApproved
                              ? 'Application Approved'
                              : 'Application Rejected',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: application.isApproved
                                ? AppTheme.successGreen
                                : AppTheme.errorRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(application.adminComment!),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Timestamps ───────────────────────────────────────────────────
            AppCard(
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date Submitted',
                    value: DateFormat('dd MMMM yyyy, HH:mm').format(application.createdAt),
                  ),
                  const Divider(),
                  InfoRow(
                    icon: Icons.update_rounded,
                    label: 'Last Updated',
                    value: DateFormat('dd MMMM yyyy, HH:mm').format(application.updatedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Delete Button (only if pending) ───────────────────────────────
            if (application.isPending)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.errorRed),
                  label: const Text('Withdraw Application',
                      style: TextStyle(color: AppTheme.errorRed)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.errorRed),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryDeep,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Assistant Application',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                StatusBadge(status: application.status),
              ],
            ),
          ),
          Icon(
            application.isPending
                ? Icons.pending_actions_rounded
                : application.isApproved
                    ? Icons.task_alt_rounded
                    : Icons.cancel_rounded,
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.3),
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, String label, String level,
      String code, String name) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryDeep,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$code — $name',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                Text(level, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Withdraw Application'),
        content: const Text(
          'Are you sure you want to withdraw your application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<ApplicationProvider>(
            builder: (ctx, appProv, _) => ElevatedButton(
              onPressed: appProv.isLoading
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      final success = await appProv.deleteApplication(application.id!);
                      if (success && ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Application withdrawn.'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
              child: const Text('Withdraw'),
            ),
          ),
        ],
      ),
    );
  }
}
