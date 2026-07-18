import 'package:flutter/material.dart';

class UploadCard extends StatelessWidget {
  final VoidCallback? onTap;
  final String? selectedFileName;
  const UploadCard({super.key, this.onTap, this.selectedFileName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  if (selectedFileName != null) ...[
                    SizedBox(height: 10),
                    Text("Selected file: $selectedFileName"),

                    Icon(Icons.upload_file, size: 40),
                    SizedBox(width: 10),
                    Text(
                      "Upload Your Study Materials",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
