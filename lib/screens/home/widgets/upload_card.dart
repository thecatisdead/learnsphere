import 'package:flutter/material.dart';

class UploadCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String? selectedFileName;

  const UploadCard({
    super.key,
    this.onTap,
    this.selectedFileName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.upload_file_rounded,
                size: 24,
              ),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add Study Material",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    "Upload a PDF to start learning",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}