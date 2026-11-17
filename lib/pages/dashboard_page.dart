import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'account_settings_page.dart';
import 'students_page.dart';

const deepTeal = Color(0xFF164E52);
const champagne = Color(0xFFC9A875);
const cream = Color(0xFFF5F2E9);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardHome(onNavigate: _navigateToTab),
      const StudentsPage(),
      const AccountSettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _navigateToTab,
        backgroundColor: cream,
        indicatorColor: champagne.withValues(alpha: 0.35),
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _DashboardHome({
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    final students = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('students');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 32 : 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isWide ? 32 : 24),
                        decoration: BoxDecoration(
                          color: deepTeal,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: champagne,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'STUDENT INFORMATION SYSTEM',
                                    style: TextStyle(
                                      color: champagne,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Welcome, ${user.email ?? 'User'}!',
                                    style: TextStyle(
                                      color: cream,
                                      fontSize: isWide ? 28 : 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Manage your student records in one place.',
                                    style: TextStyle(
                                      color: cream,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isWide) ...[
                              const SizedBox(width: 16),
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: champagne,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: deepTeal,
                                  size: 42,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: deepTeal,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: students.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'Unable to load student count.',
                                  style: TextStyle(color: deepTeal),
                                ),
                              ),
                            );
                          }

                          if (!snapshot.hasData) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: deepTeal,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Card(
                            color: cream,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: champagne),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: champagne,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.groups_rounded,
                                      color: deepTeal,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Total Students',
                                          style: TextStyle(
                                            color: deepTeal,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${snapshot.data!.docs.length}',
                                          style: const TextStyle(
                                            color: deepTeal,
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.school_outlined,
                                    color: champagne,
                                    size: 32,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          color: deepTeal,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (isWide)
                        Row(
                          children: [
                            Expanded(
                              child: _ActionCard(
                                title: 'Manage Students',
                                description:
                                    'View, add, edit, and delete student records.',
                                icon: Icons.people_alt_rounded,
                                onTap: () => onNavigate(1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ActionCard(
                                title: 'Account Settings',
                                description:
                                    'Manage your account and password.',
                                icon: Icons.settings_rounded,
                                onTap: () => onNavigate(2),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _ActionCard(
                              title: 'Manage Students',
                              description:
                                  'View, add, edit, and delete student records.',
                              icon: Icons.people_alt_rounded,
                              onTap: () => onNavigate(1),
                            ),
                            const SizedBox(height: 14),
                            _ActionCard(
                              title: 'Account Settings',
                              description:
                                  'Manage your account and password.',
                              icon: Icons.settings_rounded,
                              onTap: () => onNavigate(2),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cream,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: champagne),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: champagne,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: deepTeal,
                  size: 29,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: deepTeal,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: deepTeal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: champagne,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

