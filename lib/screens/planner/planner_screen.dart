import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database_provider.dart';
import '../../database/document_repository.dart';
import '../../database/app_database.dart';

import '../../models/study_session.dart';
import '../../providers/study_session_provider.dart';

import '../study_material/study_material_screen.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  DateTime selectedDate = DateTime.now();

  List<Document> selectedDocuments = [];

  Future<void> _openAddTaskModal() async {
    final repository = DocumentRepository(ref.read(databaseProvider));

    final documents = await repository.getAllDocuments();

    if (!mounted) return;

    if (documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload a PDF first before adding it to your planner."),
        ),
      );
      return;
    }

    Document? selectedDocument;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Add Study Task",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // PDF SELECTOR
                      DropdownButtonFormField<Document>(
                        isExpanded: true,
                        value: selectedDocument,
                        decoration: const InputDecoration(
                          labelText: "Select PDF",
                          border: OutlineInputBorder(),
                        ),
                        items:
                            documents.map((document) {
                              return DropdownMenuItem<Document>(
                                value: document,
                                child: Text(
                                  document.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                        onChanged: (document) {
                          setModalState(() {
                            selectedDocument = document;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // DATE SELECTOR
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text("Study Date"),
                        subtitle: Text(
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );

                          if (date != null) {
                            setModalState(() {
                              selectedDate = date;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              selectedDocument == null
                                  ? null
                                  : () {
                                    setState(() {
                                      // Prevent duplicate PDFs.
                                      if (!selectedDocuments.any(
                                        (document) =>
                                            document.id == selectedDocument!.id,
                                      )) {
                                        selectedDocuments.add(
                                          selectedDocument!,
                                        );
                                      }
                                    });

                                    Navigator.pop(modalContext);
                                  },
                          child: const Text("Add to Planner"),
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
    );
  }

  void _openStudyMaterial(Document document) {
    final session = StudySession(
      documentId: document.id,
      fileName: document.fileName,
      filePath: document.filePath,
    );

    // Make this PDF the currently selected study material.
    ref.read(studySessionProvider.notifier).setSession(session);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudyMaterialScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Study Planner")),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskModal,
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
      ),

      body:
          selectedDocuments.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "No upcoming study tasks",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Tap Add Task to add one of your uploaded PDFs.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    "UPCOMING",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...selectedDocuments.map((document) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.picture_as_pdf,
                            color: Color(0xFFF5C4B3),
                          ),

                          title: Text(
                            document.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          subtitle: Text(
                            "Study on ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          trailing: const Icon(Icons.chevron_right),

                          onTap: () {
                            _openStudyMaterial(document);
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
    );
  }
}
