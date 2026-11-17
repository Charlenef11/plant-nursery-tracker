import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentFormPage extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;

  const StudentFormPage({
    super.key,
    this.documentId,
    this.initialData,
  });

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  static const deepTeal = Color(0xFF164E52);
  static const champagne = Color(0xFFC9A875);
  static const cream = Color(0xFFF5F2E9);

  final _key = GlobalKey<FormState>();

  late final TextEditingController _number;
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _otherCourse;
  late final TextEditingController _otherSection;

  String? _selectedCourse;
  String? _selectedYear;
  String? _selectedSection;

  final List<String> _courses = [
    'BSIT',
    'BSCS',
    'BSIS',
    'BSEMC',
    'BSBA',
    'BSA',
    'BSHM',
    'BSTM',
    'BS Psychology',
    'BS Criminology',
    'BS Nursing',
    'BS Education',
    'BEEd',
    'BSEd',
    'BS Accountancy',
    'BS Entrepreneurship',
    'BS Architecture',
    'BS Civil Engineering',
    'BS Electrical Engineering',
    'BS Mechanical Engineering',
    'BS Biology',
    'BS Mathematics',
    'Associate in Computer Technology (ACT)',
    'Others',
  ];

  final List<String> _yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year',
    '6th Year',
  ];

  final List<String> _sections = [
    'Section A',
    'Section B',
    'Section C',
    'Section D',
    'Section E',
    'Section F',
    'Others',
  ];

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final d = widget.initialData ?? {};

    _number = TextEditingController(text: d['studentNumber'] ?? '');
    _name = TextEditingController(text: d['fullName'] ?? '');
    _email = TextEditingController(text: d['email'] ?? '');
    _otherCourse = TextEditingController();
    _otherSection = TextEditingController();

    final savedCourse = d['course'] as String?;
    final savedYear = d['yearLevel'] as String?;
    final savedSection = d['section'] as String?;

    if (savedCourse != null && _courses.contains(savedCourse)) {
      _selectedCourse = savedCourse;
    } else if (savedCourse != null && savedCourse.isNotEmpty) {
      _selectedCourse = 'Others';
      _otherCourse.text = savedCourse;
    }

    _selectedYear =
        _yearLevels.contains(savedYear) ? savedYear : null;

    if (savedSection != null && _sections.contains(savedSection)) {
      _selectedSection = savedSection;
    } else if (savedSection != null && savedSection.isNotEmpty) {
      _selectedSection = 'Others';
      _otherSection.text = savedSection;
    }
  }

  @override
  void dispose() {
    _number.dispose();
    _name.dispose();
    _email.dispose();
    _otherCourse.dispose();
    _otherSection.dispose();
    super.dispose();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: deepTeal,
          elevation: 6,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: champagne,
              width: 1,
            ),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: champagne,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: cream,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;

    setState(() => _saving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('students');

    final course = _selectedCourse == 'Others'
        ? _otherCourse.text.trim()
        : _selectedCourse!;

    final section = _selectedSection == 'Others'
        ? _otherSection.text.trim()
        : _selectedSection!;

    final data = <String, dynamic>{
      'studentNumber': _number.text.trim(),
      'fullName': _name.text.trim(),
      'course': course,
      'yearLevel': _selectedYear,
      'section': section,
      'email': _email.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.documentId == null) {
        await collection.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await collection.doc(widget.documentId).update(data);
      }

      if (mounted) {
        _showSuccessSnackBar(
          widget.documentId == null
              ? 'Student successfully added!'
              : 'Student information updated!',
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    required IconData icon,
    bool email = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: deepTeal,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType:
                email ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              prefixIcon: Icon(icon, color: champagne),
              filled: true,
              fillColor: cream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: champagne),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: champagne),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: deepTeal,
                  width: 2,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return '$label is required';
              }

              if (email &&
                  !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(v.trim())) {
                return 'Enter a valid email';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: deepTeal,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: champagne),
              filled: true,
              fillColor: cream,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: champagne),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: champagne),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: deepTeal,
                  width: 2,
                ),
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: deepTeal,
            ),
            hint: Text(
              hint,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: deepTeal,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.documentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Student' : 'Add Student',
          style: const TextStyle(fontWeight: FontWeight.w600),
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
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Card(
                    color: cream,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: const BorderSide(color: champagne),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isWide ? 32 : 22),
                      child: Form(
                        key: _key,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: deepTeal,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: champagne,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  isEditing
                                      ? Icons.edit_note_rounded
                                      : Icons.person_add_alt_1_rounded,
                                  color: champagne,
                                  size: 40,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              isEditing
                                  ? 'Update Student Information'
                                  : 'Student Information',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: deepTeal,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              isEditing
                                  ? 'Edit the details below and save your changes.'
                                  : 'Fill in the details below to add a new student.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: deepTeal,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 30),

                            _field(
                              _number,
                              'Student Number',
                              icon: Icons.badge_outlined,
                            ),

                            _field(
                              _name,
                              'Full Name',
                              icon: Icons.person_outline_rounded,
                            ),

                            _dropdownField(
                              label: 'Course',
                              hint: 'Select Your Course',
                              icon: Icons.menu_book_rounded,
                              value: _selectedCourse,
                              items: _courses,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCourse = value;
                                  if (value != 'Others') {
                                    _otherCourse.clear();
                                  }
                                });
                              },
                            ),

                            if (_selectedCourse == 'Others')
                              _field(
                                _otherCourse,
                                'Specify Your Course',
                                icon: Icons.edit_outlined,
                              ),

                            _dropdownField(
                              label: 'Year Level',
                              hint: 'Select Your Year Level',
                              icon: Icons.school_outlined,
                              value: _selectedYear,
                              items: _yearLevels,
                              onChanged: (value) {
                                setState(() {
                                  _selectedYear = value;
                                });
                              },
                            ),

                            _dropdownField(
                              label: 'Section',
                              hint: 'Select Your Section',
                              icon: Icons.groups_outlined,
                              value: _selectedSection,
                              items: _sections,
                              onChanged: (value) {
                                setState(() {
                                  _selectedSection = value;
                                  if (value != 'Others') {
                                    _otherSection.clear();
                                  }
                                });
                              },
                            ),

                            if (_selectedSection == 'Others')
                              _field(
                                _otherSection,
                                'Specify Your Section',
                                icon: Icons.edit_outlined,
                              ),

                            _field(
                              _email,
                              'Email',
                              icon: Icons.email_outlined,
                              email: true,
                            ),

                            const SizedBox(height: 8),

                            SizedBox(
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: _saving ? null : _save,
                                style: FilledButton.styleFrom(
                                  backgroundColor: deepTeal,
                                  foregroundColor: cream,
                                  disabledBackgroundColor: deepTeal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: _saving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: cream,
                                        ),
                                      )
                                    : Icon(
                                        isEditing
                                            ? Icons.save_rounded
                                            : Icons.person_add_alt_1_rounded,
                                      ),
                                label: Text(
                                  _saving
                                      ? 'Saving...'
                                      : isEditing
                                          ? 'Update Student'
                                          : 'Save Student',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
