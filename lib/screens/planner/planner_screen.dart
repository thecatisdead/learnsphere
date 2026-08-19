import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database_provider.dart';
import '../../database/document_repository.dart';
import '../../database/app_database.dart';

import '../../models/study_session.dart';
import '../../providers/study_session_provider.dart';
import '../../providers/planner_provider.dart';

import '../study_material/study_material_screen.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  // ============================================================
  // ADD TASK
  // ============================================================

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
    DateTime selectedDate = DateTime.now();

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

                      // ==================================================
                      // PDF SELECTOR
                      // ==================================================
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

                      // ==================================================
                      // DATE
                      // ==================================================
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_outlined),
                        title: const Text("Study Date"),
                        subtitle: Text(
                          "${selectedDate.day}/"
                          "${selectedDate.month}/"
                          "${selectedDate.year}",
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

                      // ==================================================
                      // ADD BUTTON
                      // ==================================================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              selectedDocument == null
                                  ? null
                                  : () async {
                                    await ref
                                        .read(plannerProvider.notifier)
                                        .addTask(
                                          documentId: selectedDocument!.id,
                                          studyDate: selectedDate,
                                        );

                                    if (modalContext.mounted) {
                                      Navigator.pop(modalContext);
                                    }
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

  // ============================================================
  // OPEN STUDY MATERIAL
  // ============================================================

  void _openStudyMaterial(Document document) {
    final session = StudySession(
      documentId: document.id,
      fileName: document.fileName,
      filePath: document.filePath,
    );

    ref.read(studySessionProvider.notifier).setSession(session);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudyMaterialScreen()),
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final plannerState = ref.watch(plannerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Study Planner")),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskModal,
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
      ),

      body: plannerState.when(
        // ==========================================================
        // LOADING
        // ==========================================================
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        // ==========================================================
        // ERROR
        // ==========================================================
        error: (error, stack) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                "Failed to load planner:\n$error",
                textAlign: TextAlign.center,
              ),
            ),
          );
        },

        // ==========================================================
        // DATA
        // ==========================================================
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
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
            );
          }

          return FutureBuilder<List<Document>>(
            future:
                DocumentRepository(
                  ref.read(databaseProvider),
                ).getAllDocuments(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final documents = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    "UPCOMING",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...tasks.map((task) {
                    final document = documents.firstWhere(
                      (document) => document.id == task.documentId,
                    );

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
                            "Study on ${_formatDate(task.studyDate)}",
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
              );
            },
          );
        },
      ),
    );
  }
}
