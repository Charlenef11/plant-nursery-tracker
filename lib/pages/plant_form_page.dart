
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const _forest = Color(0xFF285943);
const _sage = Color(0xFF91A98A);
const _cream = Color(0xFFF6F4EA);
const _gold = Color(0xFFC5A66A);
const _dark = Color(0xFF263C30);
const _muted = Color(0xFF7C887C);
const _border = Color(0xFFE1E6DC);

class PlantFormPage extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;

  const PlantFormPage({
    super.key,
    this.documentId,
    this.initialData,
  });

  @override
  State<PlantFormPage> createState() => _PlantFormPageState();
}

class _PlantFormPageState extends State<PlantFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _plantName;
  late final TextEditingController _scientificName;
  late final TextEditingController _quantity;
  late final TextEditingController _notes;

  String? _category;
  String? _wateringFrequency;
  String? _sunlight;

  bool _saving = false;

  final List<String> _categories = [
    'Indoor Plant',
    'Outdoor Plant',
    'Flowering Plant',
    'Succulent',
    'Cactus',
    'Herb',
    'Vegetable',
    'Fruit Plant',
    'Ornamental Plant',
    'Tree',
    'Others',
  ];

  final List<String> _wateringOptions = [
    'Daily',
    'Every 2 Days',
    'Every 3 Days',
    'Twice a Week',
    'Once a Week',
    'Every 2 Weeks',
    'When Soil is Dry',
  ];

  final List<String> _sunlightOptions = [
    'Direct Sunlight',
    'Partial Sunlight',
    'Indirect Sunlight',
    'Low Light',
    'Full Shade',
  ];

  @override
  void initState() {
    super.initState();

    final data = widget.initialData ?? {};

    _plantName = TextEditingController(
      text: data['plantName']?.toString() ?? '',
    );

    _scientificName = TextEditingController(
      text: data['scientificName']?.toString() ?? '',
    );

    _quantity = TextEditingController(
      text: data['quantity']?.toString() ?? '1',
    );

    _notes = TextEditingController(
      text: data['notes']?.toString() ?? '',
    );

    _category = _categories.contains(data['category'])
        ? data['category'] as String
        : null;

    _wateringFrequency =
        _wateringOptions.contains(data['wateringFrequency'])
            ? data['wateringFrequency'] as String
            : null;

    _sunlight = _sunlightOptions.contains(data['sunlight'])
        ? data['sunlight'] as String
        : null;
  }

  @override
  void dispose() {
    _plantName.dispose();
    _scientificName.dispose();
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Please log in again.');
      }

      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('plants');

      final data = <String, dynamic>{
        'plantName': _plantName.text.trim(),
        'scientificName': _scientificName.text.trim(),
        'category': _category,
        'quantity': int.parse(_quantity.text.trim()),
        'wateringFrequency': _wateringFrequency,
        'sunlight': _sunlight,
        'notes': _notes.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.documentId == null) {
        await collection.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await collection.doc(widget.documentId).update(data);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _forest,
          content: Text(
            widget.documentId == null
                ? 'Plant added successfully!'
                : 'Plant information updated!',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save plant: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool multiline = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFA0A99E),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: _sage, size: 20),
      alignLabelWithHint: multiline,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _forest,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _fieldLabel(String title, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _dark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (optional) ...[
            const SizedBox(width: 6),
            const Text(
              'OPTIONAL',
              style: TextStyle(
                color: _muted,
                fontSize: 9,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool optional = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label, optional: optional),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: _inputDecoration(
              hint: hint,
              icon: icon,
              multiline: maxLines > 1,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
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
          _fieldLabel(label),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: _inputDecoration(
              hint: hint,
              icon: icon,
            ),
            hint: Text(
              hint,
              style: const TextStyle(
                color: Color(0xFFA0A99E),
                fontSize: 13,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _forest,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: _dark,
                    fontSize: 13,
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

  Widget _sectionHeader({
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: _lightSage,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _forest, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number  $title',
                  style: const TextStyle(
                    color: _forest,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.documentId != null;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _forest,
        elevation: 0,
        centerTitle: false,
        title: Text(
          isEditing ? 'Edit Plant' : 'Add New Plant',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 35 : 20,
                vertical: 12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // INTRO
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCE8D8),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEditing
                                          ? 'UPDATE YOUR PLANT'
                                          : 'GROW YOUR COLLECTION',
                                      style: const TextStyle(
                                        color: _forest,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      isEditing
                                          ? 'Edit plant details'
                                          : 'Add a new plant',
                                      style: const TextStyle(
                                        color: _forest,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Keep your garden organized, one plant at a time.',
                                      style: TextStyle(
                                        color: Color(0xFF526D57),
                                        fontSize: 11,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.local_florist_rounded,
                                color: _forest,
                                size: 58,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // SECTION 1
                        _sectionHeader(
                          number: '01',
                          title: 'Basic Information',
                          subtitle: 'Tell us about your plant',
                          icon: Icons.eco_outlined,
                        ),

                        _textField(
                          controller: _plantName,
                          label: 'Plant Name',
                          hint: 'e.g. Monstera Deliciosa',
                          icon: Icons.local_florist_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Plant name is required';
                            }
                            return null;
                          },
                        ),

                        _textField(
                          controller: _scientificName,
                          label: 'Scientific Name',
                          hint: 'e.g. Monstera deliciosa',
                          icon: Icons.science_outlined,
                          optional: true,
                        ),

                        _dropdown(
                          label: 'Plant Category',
                          hint: 'Select plant category',
                          icon: Icons.category_outlined,
                          value: _category,
                          items: _categories,
                          onChanged: (value) {
                            setState(() => _category = value);
                          },
                        ),

                        _textField(
                          controller: _quantity,
                          label: 'Quantity',
                          hint: 'Enter number of plants',
                          icon: Icons.numbers_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final number = int.tryParse(
                              value?.trim() ?? '',
                            );

                            if (number == null || number < 1) {
                              return 'Enter a quantity of at least 1';
                            }
                            return null;
                          },
                        ),

                        const Divider(color: _border, height: 35),

                        // SECTION 2
                        _sectionHeader(
                          number: '02',
                          title: 'Plant Care Details',
                          subtitle: 'Set the care preferences',
                          icon: Icons.water_drop_outlined,
                        ),

                        _dropdown(
                          label: 'Watering Frequency',
                          hint: 'Select watering schedule',
                          icon: Icons.water_drop_outlined,
                          value: _wateringFrequency,
                          items: _wateringOptions,
                          onChanged: (value) {
                            setState(() {
                              _wateringFrequency = value;
                            });
                          },
                        ),

                        _dropdown(
                          label: 'Sunlight Requirement',
                          hint: 'Select sunlight requirement',
                          icon: Icons.wb_sunny_outlined,
                          value: _sunlight,
                          items: _sunlightOptions,
                          onChanged: (value) {
                            setState(() => _sunlight = value);
                          },
                        ),

                        const Divider(color: _border, height: 35),

                        // SECTION 3
                        _sectionHeader(
                          number: '03',
                          title: 'Additional Notes',
                          subtitle: 'Other details about your plant',
                          icon: Icons.notes_rounded,
                        ),

                        _textField(
                          controller: _notes,
                          label: 'Plant Notes',
                          hint: 'Write something about your plant...',
                          icon: Icons.edit_note_rounded,
                          maxLines: 4,
                          optional: true,
                        ),

                        const SizedBox(height: 8),

                        // SAVE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _savePlant,
                            style: FilledButton.styleFrom(
                              backgroundColor: _forest,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: _saving
                                ? const SizedBox(
                                    width: 19,
                                    height: 19,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    isEditing
                                        ? Icons.save_rounded
                                        : Icons.add_rounded,
                                  ),
                            label: Text(
                              _saving
                                  ? 'Saving...'
                                  : isEditing
                                      ? 'Save Changes'
                                      : 'Add to My Garden',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Center(
                          child: Text(
                            'GROW WITH NATURE  •  BLOOM WITH CARE',
                            style: TextStyle(
                              color: _forest.withValues(alpha: 0.65),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),
                      ],
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

const _lightSage = Color(0xFFE5EDE2);
