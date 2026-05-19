

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_routes.dart';
import '../shared/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().fetchMyApplication();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatusCard(),
                const SizedBox(height: 20),
                _buildApplicationContent(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<ApplicationProvider>(
        builder: (_, appProv, __) {
          if (appProv.hasApplication) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.applicationForm),
            backgroundColor: AppTheme.accentGold,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: Text('Apply Now', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        return SliverAppBar(
          expandedHeight: 180,
          floating: false,
          pinned: true,
          backgroundColor: AppTheme.primaryDeep,
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: AppTheme.accentGold.withOpacity(0.2),
                              shape: BoxShape.circle,
                              // ignore: deprecated_member_use
                              border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
                            ),
                            child: Center(
                              child: Text(
                                auth.userFullName.isNotEmpty
                                    ? auth.userFullName[0].toUpperCase()
                                    : 'S',
                                style: GoogleFonts.dmSerifDisplay(
                                  color: AppTheme.accentGold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${auth.userFullName.split(' ').first}',
                                  style: GoogleFonts.dmSerifDisplay(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  auth.userEmail,
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                            onPressed: () => _confirmSignOut(),
                            tooltip: 'Sign Out',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: Text(
              'My Applications',
              style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 18),
            ),
            collapseMode: CollapseMode.parallax,
          ),
        );
      },
    );
  }

  Widget _buildStatusCard() {
    return Consumer<ApplicationProvider>(
      builder: (_, appProv, __) {
        final app = appProv.myApplication;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryDeep, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app != null ? 'Application Submitted' : 'No Application Yet',
                      style: GoogleFonts.dmSerifDisplay(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app != null
                          ? 'Submitted on ${DateFormat('dd MMM yyyy').format(app.createdAt)}'
                          : 'Apply for a Student Assistant position',
                      style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 13),
                    ),
                    if (app != null) ...[
                      const SizedBox(height: 12),
                      StatusBadge(status: app.status),
                    ],
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  app != null ? Icons.task_alt_rounded : Icons.assignment_outlined,
                  color: AppTheme.accentGold,
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildApplicationContent() {
    return Consumer<ApplicationProvider>(
      builder: (_, appProv, __) {
        if (appProv.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final app = appProv.myApplication;
        if (app == null) {
          return EmptyStateWidget(
            icon: Icons.assignment_outlined,
            title: 'No Application Found',
            message:
                'You have not yet applied for a Student Assistant position.\nTap the button below to get started.',
            action: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.applicationForm),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Start Application'),
            ),
          );
        }

        return _buildApplicationCard(app);
      },
    );
  }

  Widget _buildApplicationCard(ApplicationModel app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Your Application',
          subtitle: 'Tap to view full details',
        ),
        const SizedBox(height: 16),
        AppCard(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.applicationDetail,
            arguments: app,
          // ignore: use_build_context_synchronously
          ).then((_) => context.read<ApplicationProvider>().fetchMyApplication()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Student Assistant Application',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  StatusBadge(status: app.status),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _moduleChip('Module 1', app.module1Code, app.module1Name, app.module1Level),
              if (app.hasSecondModule) ...[
                const SizedBox(height: 8),
                _moduleChip('Module 2', app.module2Code!, app.module2Name!, app.module2Level!),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Submitted ${DateFormat('dd MMM yyyy').format(app.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                ],
              ),
              if (app.isRejected && app.adminComment != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppTheme.errorRed.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    // ignore: deprecated_member_use
                    border: Border.all(color: AppTheme.errorRed.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: AppTheme.errorRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          app.adminComment!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _moduleChip(String label, String code, String name, String level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppTheme.primaryDeep.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        // ignore: deprecated_member_use
        border: Border.all(color: AppTheme.primaryDeep.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryDeep,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$code — $name',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  level,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
