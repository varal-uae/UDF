// GEN-03530 — Administrative User Management View for assigning and revoking user roles.
// Implements M3 responsive layout (single-column mobile, multi-column desktop), Elevated Cards, Status Chips, Bottom Sheet configuration, pull-to-refresh, and 30s background polling with local mock data.

import 'dart:async';
import 'package:flutter/material.dart';

enum UserRole { admin, editor, viewer }
enum UserStatus { active, suspended, pending }

class MockUser {
  final String id;
  final String name;
  final String email;
  UserRole role;
  UserStatus status;

  MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });
}

class MockUserRepository {
  static final List<MockUser> _users = [
    MockUser(id: 'USR-001', name: 'Alice Johnson', email: 'alice@habot.io', role: UserRole.admin, status: UserStatus.active),
    MockUser(id: 'USR-002', name: 'Bob Smith', email: 'bob@habot.io', role: UserRole.editor, status: UserStatus.active),
    MockUser(id: 'USR-003', name: 'Charlie Davis', email: 'charlie@habot.io', role: UserRole.viewer, status: UserStatus.suspended),
    MockUser(id: 'USR-004', name: 'Diana Prince', email: 'diana@habot.io', role: UserRole.editor, status: UserStatus.pending),
    MockUser(id: 'USR-005', name: 'Evan Wright', email: 'evan@habot.io', role: UserRole.viewer, status: UserStatus.active),
  ];

  Future<List<MockUser>> fetchUsers() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Simulate <100ms latency
    return List.from(_users);
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].role = newRole;
    }
  }

  Future<void> revokeUserRole(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index].status = UserStatus.suspended;
    }
  }
}

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final MockUserRepository _repository = MockUserRepository();
  List<MockUser> _users = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadUsers(showLoading: false);
    });
  }

  Future<void> _loadUsers({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoading = true);
    try {
      final users = await _repository.fetchUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRoleBottomSheet(MockUser user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assign Role to ${user.name}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...UserRole.values.map((role) => ListTile(
                title: Text(role.name.toUpperCase()),
                leading: Radio<UserRole>(
                  value: role,
                  groupValue: user.role,
                  onChanged: (val) async {
                    Navigator.pop(context);
                    await _repository.updateUserRole(user.id, role);
                    _loadUsers();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Role updated to ${role.name}'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _repository.updateUserRole(user.id, role);
                  _loadUsers();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Role updated to ${role.name}'), behavior: SnackBarBehavior.floating),
                    );
                  }
                },
              )).toList(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _revokeRole(MockUser user) async {
    await _repository.revokeUserRole(user.id);
    _loadUsers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access revoked for ${user.name}'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.suspended:
        return Colors.red;
      case UserStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin User Management'),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadUsers(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 840;
                  
                  if (isDesktop) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _users.length,
                      itemBuilder: (context, index) => _buildUserCard(_users[index]),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildUserCard(_users[index]),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildUserCard(MockUser user) {
    return Card(
      elevation: 3, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    user.status.name.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: _getStatusColor(user.status).withOpacity(0.2),
                  labelStyle: TextStyle(color: _getStatusColor(user.status)),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Role: ', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  user.role.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 48, // 48x48dp touch targets
                  width: 48,
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Assign Role',
                    onPressed: () => _showRoleBottomSheet(user),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: IconButton(
                    icon: const Icon(Icons.block, color: Colors.redAccent),
                    tooltip: 'Revoke Access',
                    onPressed: () => _revokeRole(user),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}