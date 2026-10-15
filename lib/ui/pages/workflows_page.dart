import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/comfy.dart';
import '../../state/app_state.dart';

class WorkflowsPage extends StatelessWidget {
  const WorkflowsPage({super.key});

  Future<void> _importDialog(BuildContext context) async {
    final state = AppScope.read(context);
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final jsonController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importWorkflow),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('workflow.name'),
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.workflowName),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('workflow.json'),
                controller: jsonController,
                minLines: 6,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: l10n.workflowJson,
                  hintText: '{"1": {"class_type": ...}}',
                  border: const OutlineInputBorder(),
                ),
              ),
              if (state.pickWorkflowFile != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  key: const Key('workflow.pickFile'),
                  onPressed: () async {
                    final text = await state.pickWorkflowFile!();
                    if (text != null) jsonController.text = text;
                  },
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(l10n.loadFromFile),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('workflow.save'),
            onPressed: () {
              final parsed = WorkflowDef.tryParse(
                jsonController.text,
                name: nameController.text.trim().isEmpty
                    ? 'custom'
                    : nameController.text.trim(),
              );
              if (parsed == null) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.invalidWorkflow)),
                );
                return;
              }
              state.workflows.add(parsed, state.prefs);
              Navigator.of(context).pop(true);
            },
            child: Text(l10n.importAction),
          ),
        ],
      ),
    );
    if (saved == true) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.workflowImported)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([state.workflows, state.settings]),
      builder: (context, _) {
        final active = state.settings.activeWorkflow;
        final workflows = state.workflows.all;
        return RadioGroup<String>(
          groupValue: active.isEmpty ? workflows.first.name : active,
          onChanged: (v) {
            if (v != null) {
              state.settings.setActiveWorkflow(v, state.prefs);
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.workflowsIntro,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                          FilledButton.tonalIcon(
                            key: const Key('workflows.import'),
                            onPressed: () => _importDialog(context),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.importWorkflow),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final workflow in workflows)
                        Card(
                          child: ListTile(
                            leading: Icon(
                              workflow.builtin
                                  ? Icons.auto_awesome
                                  : Icons.account_tree_outlined,
                            ),
                            title: Text(
                              workflow.builtin
                                  ? l10n.builtinWorkflowName
                                  : workflow.name,
                            ),
                            subtitle: Text(
                              workflow.builtin
                                  ? l10n.builtinWorkflowDesc
                                  : l10n.nodeCount(workflow.graph.length),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(value: workflow.name),
                                if (!workflow.builtin)
                                  IconButton(
                                    key: Key(
                                      'workflow.delete.${workflow.name}',
                                    ),
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => state.workflows.remove(
                                      workflow.name,
                                      state.prefs,
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () => state.settings.setActiveWorkflow(
                              workflow.name,
                              state.prefs,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
