import 'package:flutter/material.dart';

class UploadCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool isUploading;

  const UploadCard({
    super.key,
    required this.onTap,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUploading ? null : onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              isUploading
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(
                      Icons.upload_file,
                      size: 28,
                    ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUploading
                        ? "Uploading PDF..."
                        : "Upload Study Material",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isUploading
                        ? "Please wait..."
                        : "Upload a PDF to start studying",
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