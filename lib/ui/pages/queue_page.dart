import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../state/generate_controller.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  @override
  void initState() {
    super.initState();
    final state = AppScope.read(context);
    unawaited(state.generator.refreshQueue());
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: state.generator,
      builder: (context, _) {
        final jobs = state.generator.jobs;
        final queue = state.generator.queueSnapshot;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.queueSummary(queue.running, queue.pending),
                              ),
                            ),
                            IconButton(
                              key: const Key('queue.refresh'),
                              tooltip: l10n.refresh,
                              icon: const Icon(Icons.refresh),
                              onPressed: state.generator.refreshQueue,
                            ),
                            TextButton.icon(
                              key: const Key('queue.interrupt'),
                              onPressed: state.generator.interrupt,
                              icon: const Icon(Icons.stop_circle_outlined),
                              label: Text(l10n.interrupt),
                            ),
                            TextButton.icon(
                              key: const Key('queue.clear'),
                              onPressed: state.generator.clearQueue,
                              icon: const Icon(Icons.clear_all),
                              label: Text(l10n.clearQueue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (jobs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            l10n.queueEmpty,
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                      ),
                    for (final job in jobs.reversed)
                      Card(
                        child: ListTile(
                          leading: Icon(_iconFor(job.status)),
                          title: Text(
                            job.params.prompt.isEmpty
                                ? l10n.untitledJob
                                : job.params.prompt,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_statusLabel(job, l10n)),
                              if (job.status == JobStatus.running)
                                LinearProgressIndicator(value: job.progress),
                              if (job.error != null)
                                Text(
                                  job.error!,
                                  style: TextStyle(color: colors.error),
                                ),
                            ],
                          ),
                          trailing: job.imageKeys.isEmpty
                              ? null
                              : Text(l10n.imageCount(job.imageKeys.length)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _iconFor(JobStatus status) => switch (status) {
    JobStatus.queued => Icons.schedule,
    JobStatus.running => Icons.play_circle_outline,
    JobStatus.done => Icons.check_circle_outline,
    JobStatus.failed => Icons.error_outline,
    JobStatus.interrupted => Icons.stop_circle_outlined,
  };

  String _statusLabel(GenerateJob job, AppLocalizations l10n) =>
      switch (job.status) {
        JobStatus.queued => l10n.jobQueued,
        JobStatus.running => l10n.jobRunning('${(job.progress * 100).round()}'),
        JobStatus.done => l10n.jobDone,
        JobStatus.failed => l10n.jobFailed,
        JobStatus.interrupted => l10n.jobInterrupted,
      };
}
