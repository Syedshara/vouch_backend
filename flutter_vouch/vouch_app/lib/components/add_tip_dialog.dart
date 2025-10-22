import 'package:flutter/material.dart';
import 'package:vouch_app/app_theme.dart';

class AddTipDialog extends StatefulWidget {
  final String businessId;
  final String businessName;
  final Function(String content) onSubmit;

  const AddTipDialog({
    super.key,
    required this.businessId,
    required this.businessName,
    required this.onSubmit,
  });

  @override
  State<AddTipDialog> createState() => _AddTipDialogState();
}

class _AddTipDialogState extends State<AddTipDialog> {
  final _tipController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _tipController.dispose();
    super.dispose();
  }

  void _submitTip() {
    if (_tipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a tip')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onSubmit(_tipController.text);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share a Tip for ${widget.businessName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Help other users with helpful tips and suggestions',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _tipController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., Try the Ghee Roast, it\'s the best!',
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitTip,
                      child: _isSubmitting
                          ? const SizedBox(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
