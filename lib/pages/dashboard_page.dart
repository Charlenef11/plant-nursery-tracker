

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'account_settings_page.dart';
import 'plant_collection_page.dart';

const _forest = Color(0xFF285943);
const _sage = Color(0xFF91A98A);
const _lightSage = Color(0xFFE5EDE2);
const _ivory = Color(0xFFF6F4EA);
const _gold = Color(0xFFC5A66A);
const _textDark = Color(0xFF263C30);
const _muted = Color(0xFF7C887C);

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
      const PlantCollectionPage(),
      const AccountSettingsPage(),
    ];

    return Scaffold(
      backgroundColor: _ivory,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _navigateToTab,
        backgroundColor: Colors.white,
        indicatorColor: _lightSage,
        elevation: 3,
        height: 70,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: _forest),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist, color: _forest),
            label: 'My Plants',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: _forest),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _DashboardHome({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in again.'));
    }

    final plants = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('plants');

    final displayName = user.email?.split('@').first ?? 'Plant Lover';

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 750;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 36 : 20,
              vertical: 22,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP HEADER
                    Row(
                      children: [
                        Container(
                          height: 43,
                          width: 43,
                          decoration: BoxDecoration(
                            color: _lightSage,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            color: _forest,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 11),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'plant nursery',
                              style: TextStyle(
                                color: _forest,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'BOTANICAL CARE TRACKER',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 8,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => onNavigate(2),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _forest,
                          ),
                          icon: const Icon(Icons.person_outline_rounded),
                        ),
                      ],
                    ),

                    const SizedBox(height: 27),

                    // WELCOME SECTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(23),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE8D8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -5,
                            bottom: -12,
                            child: Icon(
                              Icons.eco_rounded,
                              size: isWide ? 155 : 120,
                              color: _forest.withValues(alpha: 0.09),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  '✦  YOUR BOTANICAL SPACE',
                                  style: TextStyle(
                                    color: _forest,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Hello, $displayName!',
                                style: TextStyle(
                                  color: _forest,
                                  fontSize: isWide ? 31 : 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const SizedBox(
                                width: 260,
                                child: Text(
                                  'A little care goes a long way. Keep your plants healthy and your garden growing.',
                                  style: TextStyle(
                                    color: Color(0xFF526D57),
                                    fontSize: 12,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: () => onNavigate(1),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _forest,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Explore my garden',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 15),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // GARDEN OVERVIEW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Garden Overview',
                              style: TextStyle(
                                color: _textDark,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your little garden at a glance',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.analytics_outlined,
                          color: _sage,
                          size: 23,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: plants.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text(
                            'Unable to load plant statistics.',
                            style: TextStyle(color: Colors.red),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(22),
                              child: CircularProgressIndicator(
                                color: _forest,
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs;
                        final totalRecords = docs.length;

                        final totalQuantity = docs.fold<int>(
                          0,
                          (sum, doc) {
                            final quantity = doc.data()['quantity'];
                            return sum +
                                (quantity is num ? quantity.toInt() : 0);
                          },
                        );

                        final categories = docs
                            .map((doc) => doc.data()['category'])
                            .whereType<String>()
                            .where((category) => category.isNotEmpty)
                            .toSet()
                            .length;

                        return GridView.count(
                          crossAxisCount: isWide ? 3 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: isWide ? 2.1 : 1.5,
                          children: [
                            _OverviewCard(
                              title: 'Plant Records',
                              value: '$totalRecords',
                              subtitle: 'Registered plants',
                              icon: Icons.local_florist_rounded,
                              accent: _lightSage,
                            ),
                            _OverviewCard(
                              title: 'Total Quantity',
                              value: '$totalQuantity',
                              subtitle: 'Plants in stock',
                              icon: Icons.yard_rounded,
                              accent: const Color(0xFFF0E9D9),
                            ),
                            _OverviewCard(
                              title: 'Plant Types',
                              value: '$categories',
                              subtitle: 'Different categories',
                              icon: Icons.category_outlined,
                              accent: const Color(0xFFE8E9E1),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 29),

                    // QUICK ACCESS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Explore',
                          style: TextStyle(
                            color: _textDark,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => onNavigate(1),
                          child: const Text(
                            'View all',
                            style: TextStyle(
                              color: _forest,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    _ExploreTile(
                      icon: Icons.eco_outlined,
                      title: 'My Plant Collection',
                      subtitle: 'View and manage your plants',
                      color: _lightSage,
                      onTap: () => onNavigate(1),
                    ),

                    const SizedBox(height: 11),

                    _ExploreTile(
                      icon: Icons.water_drop_outlined,
                      title: 'Plant Care',
                      subtitle: 'Check your plant care information',
                      color: const Color(0xFFF0E9D9),
                      onTap: () => onNavigate(1),
                    ),

                    const SizedBox(height: 11),

                    _ExploreTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Account Settings',
                      subtitle: 'Manage your account preferences',
                      color: const Color(0xFFE8E9E1),
                      onTap: () => onNavigate(2),
                    ),

                    const SizedBox(height: 28),

                    // FOOTER
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.spa_outlined,
                            color: _sage,
                            size: 23,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'GROW WITH NATURE  •  BLOOM WITH CARE',
                            style: TextStyle(
                              color: _forest.withValues(alpha: 0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// OVERVIEW CARD
class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFEAECE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: _forest,
                  size: 18,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.north_east_rounded,
                color: _muted,
                size: 14,
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: _forest,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// EXPLORE TILE
class _ExploreTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ExploreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: _forest,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: _sage,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
