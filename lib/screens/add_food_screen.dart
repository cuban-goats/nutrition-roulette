import 'package:flutter/material.dart';

import '../models/food.dart';
import '../widgets/gradient_background.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key, this.food});

  final Food? food;

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;

  bool get _editing => widget.food != null;

  @override
  void initState() {
    super.initState();
    final food = widget.food;
    if (food != null) {
      _nameController.text = food.name;
      _descriptionController.text = food.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    final description = _descriptionController.text.trim();
    Navigator.of(context).pop((name, description));
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(_editing ? 'Edit Food' : 'Add Food')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Tacos',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What makes this dish special?',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.add),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}