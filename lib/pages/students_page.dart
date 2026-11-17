import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'student_form_page.dart';

const deepTeal = Color(0xFF164E52);
const champagne = Color(0xFFC9A875);
const cream = Color(0xFFF5F2E9);

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('students');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Records',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: deepTeal,
        foregroundColor: cream,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StudentFormPage(),
          ),
        ),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Student'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final isLandscape =
                constraints.maxWidth > constraints.maxHeight;

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: collection.orderBy('fullName').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Unable to load students.'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: deepTeal),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isLandscape ? 16 : 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: isLandscape ? 75 : 100,
                            height: isLandscape ? 75 : 100,
                            decoration: BoxDecoration(
                              color: champagne,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Icon(
                              Icons.people_outline_rounded,
                              color: deepTeal,
                              size: isLandscape ? 40 : 52,
                            ),
                          ),
                          SizedBox(height: isLandscape ? 12 : 22),
                          Text(
                            'No Student Records Yet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: deepTeal,
                              fontSize: isLandscape ? 19 : 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap Add Student to create your first record.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: deepTeal),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1050),
                    child: ListView(
                      padding: EdgeInsets.only(
                        bottom: 100,
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            isWide ? 28 : 20,
                            isLandscape ? 12 : 24,
                            isWide ? 28 : 20,
                            isLandscape ? 12 : 18,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(
                              isLandscape ? 16 : 22,
                            ),
                            decoration: BoxDecoration(
                              color: deepTeal,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: champagne),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'STUDENT MANAGEMENT',
                                        style: TextStyle(
                                          color: champagne,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Student Records',
                                        style: TextStyle(
                                          color: cream,
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'View and manage your student information.',
                                        style: TextStyle(
                                          color: cream,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.groups_rounded,
                                  color: champagne,
                                  size: isLandscape ? 32 : 42,
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 28 : 20,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.people_alt_rounded,
                                color: deepTeal,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'All Students',
                                style: TextStyle(
                                  color: deepTeal,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${docs.length} records',
                                style: const TextStyle(
                                  color: deepTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        ...docs.map((doc) {
                          final data = doc.data();

                          final name =
                              (data['fullName'] ?? '').toString().trim();

                          final initial = name.isNotEmpty
                              ? name.substring(0, 1).toUpperCase()
                              : '?';

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 28 : 20,
                            ),
                            child: Card(
                              color: cream,
                              elevation: 2,
                              margin: EdgeInsets.only(
                                bottom: isLandscape ? 10 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: const BorderSide(color: champagne),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StudentDetailsPage(
                                        studentRef: doc.reference,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    isLandscape ? 12 : 15,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: isLandscape ? 46 : 52,
                                        height: isLandscape ? 46 : 52,
                                        decoration: BoxDecoration(
                                          color: champagne,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          initial,
                                          style: const TextStyle(
                                            color: deepTeal,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name.isEmpty
                                                  ? 'Unnamed Student'
                                                  : name,
                                              style: const TextStyle(
                                                color: deepTeal,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Student No: ${data['studentNumber'] ?? ''}',
                                              style: const TextStyle(
                                                color: deepTeal,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: [
                                                _InfoChip(
                                                  text:
                                                      '${data['course'] ?? ''}',
                                                ),
                                                _InfoChip(
                                                  text:
                                                      '${data['yearLevel'] ?? ''}',
                                                ),
                                                _InfoChip(
                                                  text:
                                                      '${data['section'] ?? 'Not specified'}',
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 7),
                                            Text(
                                              '${data['email'] ?? ''}',
                                              style: const TextStyle(
                                                color: deepTeal,
                                                fontSize: 12,
                                              ),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: champagne,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// STUDENT DETAILS VIEW

class StudentDetailsPage extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> studentRef;

  const StudentDetailsPage({
    super.key,
    required this.studentRef,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: studentRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Unable to load student details.'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: deepTeal),
              );
            }

            if (!snapshot.data!.exists) {
              return const Center(
                child: Text('This student record no longer exists.'),
              );
            }

            final data = snapshot.data!.data()!;
            final name = (data['fullName'] ?? '').toString();
            final initial = name.trim().isNotEmpty
                ? name.trim().substring(0, 1).toUpperCase()
                : '?';

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    constraints.maxWidth >= 700 ? 32.0 : 20.0;

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(26),
                            decoration: BoxDecoration(
                              color: deepTeal,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: champagne),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 42,
                                  backgroundColor: champagne,
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: deepTeal,
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  name.isEmpty ? 'Unnamed Student' : name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: cream,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Student No: ${data['studentNumber'] ?? ''}',
                                  style: const TextStyle(
                                    color: champagne,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'STUDENT PROFILE',
                                  style: TextStyle(
                                    color: cream,
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              color: deepTeal,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DetailTile(
                            icon: Icons.badge_outlined,
                            label: 'Full Name',
                            value: name,
                          ),
                          _DetailTile(
                            icon: Icons.numbers_rounded,
                            label: 'Student Number',
                            value: '${data['studentNumber'] ?? ''}',
                          ),
                          _DetailTile(
                            icon: Icons.school_outlined,
                            label: 'Course',
                            value: '${data['course'] ?? ''}',
                          ),
                          _DetailTile(
                            icon: Icons.calendar_today_outlined,
                            label: 'Year Level',
                            value: '${data['yearLevel'] ?? ''}',
                          ),
                          _DetailTile(
                            icon: Icons.class_outlined,
                            label: 'Section',
                            value: '${data['section'] ?? ''}',
                          ),
                          _DetailTile(
                            icon: Icons.email_outlined,
                            label: 'Email Address',
                            value: '${data['email'] ?? ''}',
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: deepTeal,
                                foregroundColor: cream,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudentFormPage(
                                      documentId: studentRef.id,
                                      initialData: data,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text(
                                'Edit Student',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: deepTeal,
                                side: const BorderSide(
                                  color: deepTeal,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    backgroundColor: cream,
                                    title: const Text(
                                      'Delete student?',
                                      style: TextStyle(
                                        color: deepTeal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      'Delete $name? This cannot be undone.',
                                      style: const TextStyle(
                                        color: deepTeal,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            dialogContext,
                                            false,
                                          );
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: deepTeal,
                                          ),
                                        ),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: deepTeal,
                                          foregroundColor: cream,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(
                                            dialogContext,
                                            true,
                                          );
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  final messenger =
                                      ScaffoldMessenger.of(context);

                                  try {
                                    await studentRef.delete();

                                    if (!context.mounted) return;

                                    Navigator.pop(context);

                                    messenger
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: deepTeal,
                                          elevation: 6,
                                          duration:
                                              const Duration(seconds: 3),
                                          margin: const EdgeInsets.fromLTRB(
                                            16,
                                            0,
                                            16,
                                            20,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            side: const BorderSide(
                                              color: champagne,
                                              width: 1,
                                            ),
                                          ),
                                          content: const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle_rounded,
                                                color: champagne,
                                                size: 26,
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Student deleted successfully!',
                                                  style: TextStyle(
                                                    color: cream,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                  } catch (e) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text('Delete failed: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: const Text(
                                'Delete Student',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// REUSABLE STUDENT INFORMATION TILE

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: champagne),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: champagne,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: deepTeal),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: deepTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    color: deepTeal,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: champagne,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: deepTeal,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

