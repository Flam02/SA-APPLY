

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application_model.dart';
import '../../utils/app_theme.dart';
import '../shared/widgets.dart';

class ApplicationFormScreen extends StatefulWidget {
  final ApplicationModel? existingApp;
  const ApplicationFormScreen({super.key, this.existingApp});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _studentNameCtrl = TextEditingController();

  // Form State
  int?    _yearOfStudy;
  String? _mod1Level;
  String? _mod1Code;
  String? _mod1Name;
  bool    _hasSecondModule = false;
  String? _mod2Level;
  String? _mod2Code;
  String? _mod2Name;
  bool    _meetsRequirements = false;
  File?   _pickedFile;
  String? _existingDocName;

  bool get _isEditing => widget.existingApp != null;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _studentNameCtrl.text = auth.userFullName;

    if (_isEditing) {
      final app = widget.existingApp!;
      _yearOfStudy       = app.yearOfStudy;
      _mod1Level         = app.module1Level;
      _mod1Code          = app.module1Code;
      _mod1Name          = app.module1Name;
      _hasSecondModule   = app.hasSecondModule;
      _mod2Level         = app.module2Level;
      _mod2Code          = app.module2Code;
      _mod2Name          = app.module2Name;
      _meetsRequirements = app.meetsRequirements;
      _existingDocName   = app.documentName.isNotEmpty ? app.documentName : null;
    }
  }

  @override
  void dispose() {
    _studentNameCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getModules(String? level) {
    return level != null ? ModuleData.getModules(level) : [];
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _existingDocName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_meetsRequirements) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm that you meet the eligibility requirements.'),
        ),
      );
      return;
    }

    final auth  = context.read<AuthProvider>();
    final appProv = context.read<ApplicationProvider>();

    final application = ApplicationModel(
      userId:           auth.userId,
      studentName:      _studentNameCtrl.text.trim(),
      studentEmail:     auth.userEmail,
      yearOfStudy:      _yearOfStudy!,
      module1Level:     _mod1Level!,
      module1Code:      _mod1Code!,
      module1Name:      _mod1Name!,
      module2Level:     _hasSecondModule ? _mod2Level : null,
      module2Code:      _hasSecondModule ? _mod2Code : null,
      module2Name:      _hasSecondModule ? _mod2Name : null,
      meetsRequirements: _meetsRequirements,
      documentName:     _existingDocName ?? '',
      documentUrl:      _isEditing ? widget.existingApp!.documentUrl : null,
    );

    bool success;
    if (_isEditing) {
      success = await appProv.updateApplication(
        applicationId: widget.existingApp!.id!,
        application:   application,
        newDocumentFile: _pickedFile,
      );
    } else {
      success = await appProv.submitApplication(
        application:  application,
        documentFile: _pickedFile,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Application updated successfully!'
                : 'Application submitted successfully!',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appProv.errorMessage ?? 'Something went wrong.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Application' : 'Apply for SA Position'),
        leading: const BackButton(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Banner ───────────────────────────────────────────────
              _buildHeaderBanner(),
              const SizedBox(height: 24),

              // ── Section 1: Personal Info ─────────────────────────────────────
              _buildSectionTitle('1', 'Personal Information', Icons.person_rounded),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _studentNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Full name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _yearOfStudy,
                      decoration: const InputDecoration(
                        labelText: 'Current Year of Study',
                        prefixIcon: Icon(Icons.timeline_rounded),
                      ),
                      items: ModuleData.studyYears
                          .map((y) => DropdownMenuItem(
                                value: y,
                                child: Text('Year $y'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _yearOfStudy = v),
                      validator: (v) =>
                          v == null ? 'Please select your year of study' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Section 2: Module 1 ─────────────────────────────────────────
              _buildSectionTitle('2', 'Module Selection', Icons.book_rounded),
              const SizedBox(height: 12),
              ModuleSelectionCard(
                title: 'Module 1 (Required)',
                selectedLevel: _mod1Level,
                selectedCode: _mod1Code,
                selectedName: _mod1Name,
                levels: ModuleData.levels,
                modules: _getModules(_mod1Level),
                onLevelChanged: (v) => setState(() {
                  _mod1Level = v;
                  _mod1Code  = null;
                  _mod1Name  = null;
                }),
                onModuleChanged: (v) {
                  if (v == null) return;
                  final modules = _getModules(_mod1Level);
                  final selected = modules.firstWhere((m) => m['code'] == v);
                  setState(() {
                    _mod1Code = v;
                    _mod1Name = selected['name'];
                  });
                },
              ),
              const SizedBox(height: 16),

              // ── Module 2 Toggle ─────────────────────────────────────────────
              if (!_hasSecondModule)
                OutlinedButton.icon(
                  onPressed: () => setState(() => _hasSecondModule = true),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Add Second Module (Optional)'),
                )
              else ...[
                ModuleSelectionCard(
                  title: 'Module 2 (Optional)',
                  selectedLevel: _mod2Level,
                  selectedCode: _mod2Code,
                  selectedName: _mod2Name,
                  levels: ModuleData.levels,
                  modules: _getModules(_mod2Level),
                  onLevelChanged: (v) => setState(() {
                    _mod2Level = v;
                    _mod2Code  = null;
                    _mod2Name  = null;
                  }),
                  onModuleChanged: (v) {
                    if (v == null) return;
                    final modules = _getModules(_mod2Level);
                    final selected = modules.firstWhere((m) => m['code'] == v);
                    setState(() {
                      _mod2Code = v;
                      _mod2Name = selected['name'];
                    });
                  },
                  isOptional: true,
                  onRemove: () => setState(() {
                    _hasSecondModule = false;
                    _mod2Level = null;
                    _mod2Code  = null;
                    _mod2Name  = null;
                  }),
                ),
              ],
              const SizedBox(height: 24),

              // ── Section 3: Supporting Document ──────────────────────────────
              _buildSectionTitle('3', 'Supporting Documentation', Icons.attach_file_rounded),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload your academic transcript or proof of registration',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Accepted formats: PDF, DOC, DOCX',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    if (_existingDocName != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          
                          color: AppTheme.successGreen.withAlpha((0.08 * 255).round()),
                          borderRadius: BorderRadius.circular(10),
                          
                          border: Border.all(color: AppTheme.successGreen.withAlpha((0.3 * 255).round())),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 18, color: AppTheme.successGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _existingDocName!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.successGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _existingDocName = null),
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _pickDocument,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text('Choose File'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Section 4: Eligibility ───────────────────────────────────────
              _buildSectionTitle('4', 'Eligibility Confirmation', Icons.verified_rounded),
              const SizedBox(height: 12),
              AppCard(
                borderColor: _meetsRequirements
                  ? AppTheme.successGreen.withAlpha((0.4 * 255).round())
                  : AppTheme.cardBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minimum Requirements',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _requirementItem('Achieved 60% or above in the module'),
                    _requirementItem('Currently enrolled at CUT'),
                    _requirementItem('Not on academic probation'),
                    _requirementItem('Available for required SA hours'),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _meetsRequirements,
                      onChanged: (v) =>
                          setState(() => _meetsRequirements = v ?? false),
                      title: Text(
                        'I confirm that I meet all the minimum requirements listed above',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppTheme.primaryDeep,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Submit Button ────────────────────────────────────────────────
              Consumer<ApplicationProvider>(
                builder: (_, appProv, __) => PrimaryButton(
                  label: _isEditing ? 'Update Application' : 'Submit Application',
                  onPressed: _submit,
                  isLoading: appProv.isLoading,
                  icon: Icons.send_rounded,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGold.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, color: AppTheme.accentGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You may apply to assist with a maximum of two modules. '
              'Eligibility decisions are made by administrative staff.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.accentGold.withAlpha((0.9 * 255).round()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String number, String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppTheme.primaryDeep,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: AppTheme.primaryDeep),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _requirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, size: 16, color: AppTheme.successGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
