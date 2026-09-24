// GEN-02284 — HR Manager Role Permissions Configuration Card.
// Displays RBAC permissions for the HR Manager role using M3 Elevated Cards, status chips, and responsive single/multi-column layout with mock data.

import 'package:flutter/material.dart';

enum RbacStatus { pass, fail }

class PermissionItem {
  final String id;
  final String name;
  final String description;
  final RbacStatus status;

  const PermissionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });
}

const List<PermissionItem> kMockHrManagerPermissions = [
  PermissionItem(
    id: 'PERM-001',
    name: 'View Employee Records',
    description: 'Read-only access to all employee PII and employment history.',
    status: RbacStatus.pass,
  ),
  PermissionItem(
    id: 'PERM-002',
    name: 'Manage Leave Requests',
    description: 'Approve or reject leave applications within the department.',
    status: RbacStatus.pass,
  ),
  PermissionItem(
    id: 'PERM-003',
    name: 'Edit Payroll Data',
    description: 'Modify base salary and bonus structures (restricted).',
    status: RbacStatus.fail,
  ),
  PermissionItem(
    id: 'PERM-004',
    name: 'Onboard New Hires',
    description: 'Create new user accounts and assign initial roles.',
    status: RbacStatus.pass,
  ),
  PermissionItem(
    id: 'PERM-005',
    name: 'Access Compliance Reports',
    description: 'View ISO/IEC 27001 and NIST compliance audit logs.',
    status: RbacStatus.pass,
  ),
];

class HrManagerPermissionsCardGen02284 extends StatefulWidget {
  const HrManagerPermissionsCardGen02284({super.key});

  @override
  State<HrManagerPermissionsCardGen02284> createState() => _HrManagerPermissionsCardGen02284State();
}

class _HrManagerPermissionsCardGen02284State extends State<HrManagerPermissionsCardGen02284> {
  late List<PermissionItem> _permissions;
  double _rbacEnforcementRate = 0.0;

  @override
  void initState() {
    super.initState();
    _permissions = kMockHrManagerPermissions;
    _calculateEnforcementRate();
  }

  void _calculateEnforcementRate() {
    if (_permissions.isEmpty) {
      _rbacEnforcementRate = 0.0;
      return;
    }
    final passedCount = _permissions.where((p) => p.status == RbacStatus.pass).length;
    _rbacEnforcementRate = passedCount / _permissions.length;
  }

  bool get _isCompliant => _rbacEnforcementRate >= 0.999;

  void _onRefresh() {
    setState(() {
      // Simulate pull-to-refresh sync
      _calculateEnforcementRate();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Permissions synced successfully.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showConfigurationSheet(PermissionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Configure: ${item.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Enable Permission'),
                value: item.status == RbacStatus.pass,
                onChanged: (value) {
                  Navigator.pop(context);
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HR Manager Permissions'),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _onRefresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('RBAC Enforcement Rate', style: textTheme.titleMedium),
                            Chip(
                              label: Text(
                                _isCompliant ? 'Compliant' : 'Non-Compliant',
                                style: TextStyle(
                                  color: _isCompliant ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: _isCompliant ? colorScheme.primaryContainer : colorScheme.errorContainer,
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(_rbacEnforcementRate * 100).toStringAsFixed(1)}%',
                          style: textTheme.displaySmall?.copyWith(
                            color: _isCompliant ? colorScheme.primary : colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _rbacEnforcementRate,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isCompliant ? colorScheme.primary : colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Target Floor: 99.9% | Standard: ISO/IEC 27001, NIST CSF',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.crossAxisExtent >= 840;
                  final crossAxisCount = isDesktop ? 2 : 1;

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isDesktop ? 3.5 : 3.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _permissions[index];
                        return _PermissionTile(
                          item: item,
                          onTap: () => _showConfigurationSheet(item),
                        );
                      },
                      childCount: _permissions.length,
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final PermissionItem item;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPass = item.status == RbacStatus.pass;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                isPass ? Icons.check_circle_outline : Icons.cancel_outlined,
                color: isPass ? colorScheme.primary : colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: Text(isPass ? 'Pass' : 'Fail'),
                avatar: Icon(
                  isPass ? Icons.shield_outlined : Icons.warning_amber_rounded,
                  size: 16,
                  color: isPass ? colorScheme.onSecondaryContainer : colorScheme.onErrorContainer,
                ),
                backgroundColor: isPass ? colorScheme.secondaryContainer : colorScheme.errorContainer,
                labelStyle: TextStyle(
                  color: isPass ? colorScheme.onSecondaryContainer : colorScheme.onErrorContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                onPressed: onTap,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}