
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'plant_form_page.dart';

const _forest = Color(0xFF285943);
const _sage = Color(0xFF91A98A);
const _cream = Color(0xFFF6F4EA);
const _gold = Color(0xFFC5A66A);
const _dark = Color(0xFF263C30);

class PlantCollectionPage extends StatelessWidget {
  const PlantCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('plants');

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _forest,
        elevation: 0,
        title: const Text(
          'My Plant Collection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _forest,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PlantFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Plant'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: collection.orderBy('plantName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load your plants.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _forest),
            );
          }

          final plants = snapshot.data!.docs;

          if (plants.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EDE2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_florist_rounded,
                        color: _forest,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Your Garden is Empty',
                      style: TextStyle(
                        color: _forest,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start building your plant collection by adding your first plant.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _dark,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _forest,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlantFormPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Your First Plant'),
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 750;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: _forest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'YOUR LITTLE GREEN SPACE',
                                    style: TextStyle(
                                      color: _gold,
                                      fontSize: 11,
                                      letterSpacing: 1.3,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 9),
                                  Text(
                                    'Every Plant Has a Story.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Keep your growing collection organized.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.eco_rounded,
                              color: _gold,
                              size: 48,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Icon(
                            Icons.spa_rounded,
                            color: _forest,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'All My Plants',
                            style: TextStyle(
                              color: _forest,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${plants.length} plants',
                            style: const TextStyle(
                              color: _forest,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (isWide)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: plants.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 420,
                            mainAxisExtent: 180,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemBuilder: (context, index) {
                            return _PlantCard(
                              data: plants[index].data(),
                              onTap: () => _openDetails(
                                context,
                                plants[index],
                              ),
                            );
                          },
                        )
                      else
                        ...plants.map(
                          (plant) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PlantCard(
                              data: plant.data(),
                              onTap: () => _openDetails(context, plant),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openDetails(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> plant,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantDetailsPage(
          plantRef: plant.reference,
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _PlantCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = (data['plantName'] ?? '').toString();
    final category = (data['category'] ?? 'Plant').toString();
    final scientificName =
        (data['scientificName'] ?? '').toString();
    final quantity = (data['quantity'] ?? 1).toString();

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFDCE5D8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EDE2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.local_florist_rounded,
                  color: _forest,
                  size: 36,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name.isEmpty ? 'Unnamed Plant' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _forest,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (scientificName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        scientificName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      children: [
                        _PlantChip(text: category),
                        _PlantChip(text: 'Qty: $quantity'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _sage,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlantChip extends StatelessWidget {
  final String text;

  const _PlantChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDE2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _forest,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// PLANT DETAILS PAGE

class PlantDetailsPage extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> plantRef;

  const PlantDetailsPage({
    super.key,
    required this.plantRef,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _forest,
        elevation: 0,
        title: const Text(
          'Plant Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: plantRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load plant details.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _forest),
            );
          }

          if (!snapshot.data!.exists) {
            return const Center(
              child: Text('This plant record no longer exists.'),
            );
          }

          final data = snapshot.data!.data()!;
          final name = (data['plantName'] ?? '').toString();

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: _forest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              color: _cream,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_florist_rounded,
                              color: _forest,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 17),
                          Text(
                            name.isEmpty ? 'Unnamed Plant' : name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (data['scientificName'] ?? '').toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _gold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'PLANT PROFILE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Plant Information',
                      style: TextStyle(
                        color: _forest,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PlantDetailTile(
                      icon: Icons.local_florist_outlined,
                      label: 'Plant Name',
                      value: name,
                    ),
                    _PlantDetailTile(
                      icon: Icons.science_outlined,
                      label: 'Scientific Name',
                      value: '${data['scientificName'] ?? ''}',
                    ),
                    _PlantDetailTile(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: '${data['category'] ?? ''}',
                    ),
                    _PlantDetailTile(
                      icon: Icons.numbers_rounded,
                      label: 'Quantity',
                      value: '${data['quantity'] ?? ''}',
                    ),
                    _PlantDetailTile(
                      icon: Icons.water_drop_outlined,
                      label: 'Watering Frequency',
                      value: '${data['wateringFrequency'] ?? ''}',
                    ),
                    _PlantDetailTile(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Sunlight',
                      value: '${data['sunlight'] ?? ''}',
                    ),
                    _PlantDetailTile(
                      icon: Icons.notes_rounded,
                      label: 'Notes',
                      value: '${data['notes'] ?? ''}',
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _forest,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlantFormPage(
                                documentId: plantRef.id,
                                initialData: data,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Plant'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _forest,
                          side: const BorderSide(
                            color: _forest,
                            width: 1.4,
                          ),
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              backgroundColor: _cream,
                              title: const Text(
                                'Delete Plant?',
                                style: TextStyle(
                                  color: _forest,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to delete $name?',
                                style: const TextStyle(color: _dark),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(
                                    dialogContext,
                                    false,
                                  ),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _forest,
                                  ),
                                  onPressed: () => Navigator.pop(
                                    dialogContext,
                                    true,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            try {
                              await plantRef.delete();

                              if (!context.mounted) return;

                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Plant deleted successfully!',
                                  ),
                                  backgroundColor: _forest,
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Delete failed: $e'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete Plant'),
                      ),
                    ),
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

class _PlantDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PlantDetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE5D8)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE5EDE2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _forest),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _forest,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    color: _dark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
