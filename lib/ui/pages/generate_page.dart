import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/comfy.dart';
import '../../services/workflow_builder.dart';
import '../../state/app_state.dart';
import '../../state/generate_controller.dart';
import '../widgets/generation_image.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  late final TextEditingController _prompt;
  late final TextEditingController _negative;
  late final TextEditingController _seed;
  bool _advanced = false;

  @override
  void initState() {
    super.initState();
    _prompt = TextEditingController();
    _negative = TextEditingController();
    _seed = TextEditingController(text: '-1');
  }

  @override
  void dispose() {
    _prompt.dispose();
    _negative.dispose();
    _seed.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final state = AppScope.read(context);
    final settings = state.settings;
    final params = settings.params.copyWith(
      prompt: _prompt.text.trim(),
      negativePrompt: _negative.text.trim(),
      seed: int.tryParse(_seed.text.trim()) ?? -1,
    );
    final workflow = state.workflows.active(settings.activeWorkflow);
    final job = await state.generator.submit(params, workflow);
    if (mounted && job.status == JobStatus.failed) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(job.error ?? '')));
    }
    if (job.status != JobStatus.failed && !settings.keepSeed) {
      _seed.text = '-1';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([state.generator, state.settings]),
      builder: (context, _) {
        final job = state.generator.activeJob;
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.generateHeadline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      key: const Key('generate.prompt'),
                      controller: _prompt,
                      minLines: 3,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: l10n.promptHint,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            key: const Key('generate.advancedToggle'),
                            onPressed: () =>
                                setState(() => _advanced = !_advanced),
                            icon: Icon(
                              _advanced ? Icons.expand_less : Icons.tune,
                              size: 18,
                            ),
                            label: Text(l10n.advancedOptions),
                          ),
                        ),
                        FilledButton.icon(
                          key: const Key('generate.submit'),
                          onPressed: _generate,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(l10n.generate),
                        ),
                      ],
                    ),
                    if (_advanced) ...[
                      const SizedBox(height: 16),
                      _AdvancedPanel(
                        negative: _negative,
                        seed: _seed,
                        state: state,
                      ),
                    ],
                    if (job != null) ...[
                      const SizedBox(height: 20),
                      _JobProgress(job: job, l10n: l10n),
                    ],
                    const SizedBox(height: 20),
                    _LatestResults(state: state, l10n: l10n),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdvancedPanel extends StatelessWidget {
  final TextEditingController negative;
  final TextEditingController seed;
  final AppState state;

  const _AdvancedPanel({
    required this.negative,
    required this.seed,
    required this.state,
  });

  void _save(GenerationParams params) {
    state.settings.setParams(params, state.prefs);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final params = state.settings.params;
    final models = state.generator.models;
    final colors = Theme.of(context).colorScheme;

    DropdownMenuEntry<String> entry(String value) =>
        DropdownMenuEntry(value: value, label: value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('generate.negative'),
            controller: negative,
            decoration: InputDecoration(
              labelText: l10n.negativePrompt,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: DropdownMenu<String>(
                  key: const Key('generate.model'),
                  initialSelection: params.model,
                  label: Text(l10n.model),
                  dropdownMenuEntries: [
                    for (final m in models) entry(m),
                    if (models.isEmpty) entry(params.model),
                  ],
                  onSelected: (v) =>
                      _save(params.copyWith(model: v ?? params.model)),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownMenu<String>(
                  key: const Key('generate.sampler'),
                  initialSelection: params.sampler,
                  label: Text(l10n.sampler),
                  dropdownMenuEntries: [for (final s in samplers) entry(s)],
                  onSelected: (v) =>
                      _save(params.copyWith(sampler: v ?? params.sampler)),
                ),
              ),
              SizedBox(
                width: 160,
                child: DropdownMenu<String>(
                  key: const Key('generate.scheduler'),
                  initialSelection: params.scheduler,
                  label: Text(l10n.scheduler),
                  dropdownMenuEntries: [for (final s in schedulers) entry(s)],
                  onSelected: (v) =>
                      _save(params.copyWith(scheduler: v ?? params.scheduler)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SliderField(
                  label: l10n.steps,
                  value: params.steps.toDouble(),
                  min: 1,
                  max: 60,
                  onChanged: (v) => _save(params.copyWith(steps: v.round())),
                ),
              ),
              Expanded(
                child: _SliderField(
                  label: l10n.cfg,
                  value: params.cfg,
                  min: 1,
                  max: 20,
                  onChanged: (v) =>
                      _save(params.copyWith(cfg: (v * 10).round() / 10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final preset in const [
                (l: '1:1', w: 1024, h: 1024),
                (l: '3:4', w: 832, h: 1216),
                (l: '4:3', w: 1216, h: 832),
                (l: '9:16', w: 768, h: 1344),
                (l: '16:9', w: 1344, h: 768),
              ])
                ChoiceChip(
                  label: Text(preset.l),
                  selected:
                      params.width == preset.w && params.height == preset.h,
                  onSelected: (_) =>
                      _save(params.copyWith(width: preset.w, height: preset.h)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  key: const Key('generate.seed'),
                  controller: seed,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.seed,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                key: const Key('generate.dice'),
                tooltip: l10n.randomSeed,
                icon: const Icon(Icons.casino_outlined),
                onPressed: () {
                  seed.text = '${state.generator.nextSeed()}';
                  state.settings.setKeepSeed(true, state.prefs);
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                key: const Key('generate.keepSeed'),
                label: Text(l10n.keepSeed),
                selected: state.settings.keepSeed,
                onSelected: (v) => state.settings.setKeepSeed(v, state.prefs),
              ),
              const Spacer(),
              Text(
                l10n.batchCount(params.batchSize),
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              SizedBox(
                width: 140,
                child: Slider(
                  key: const Key('generate.batch'),
                  value: params.batchSize.toDouble(),
                  min: 1,
                  max: 8,
                  divisions: 7,
                  onChanged: (v) =>
                      _save(params.copyWith(batchSize: v.round())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ${value % 1 == 0 ? value.toInt() : value}'),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _JobProgress extends StatelessWidget {
  final GenerateJob job;
  final AppLocalizations l10n;

  const _JobProgress({required this.job, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: job.progress,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 6),
        Text(
          job.status == JobStatus.queued
              ? l10n.jobQueued
              : l10n.jobRunning('${(job.progress * 100).round()}'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _LatestResults extends StatelessWidget {
  final AppState state;
  final AppLocalizations l10n;

  const _LatestResults({required this.state, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final entries = state.history.entries;
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            l10n.emptyResults,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    final latest = entries.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.latestResult,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final key in latest.imageKeys)
              SizedBox(
                width: 200,
                height: 200,
                child: GenerationImage(imageKey: key),
              ),
          ],
        ),
      ],
    );
  }
}
