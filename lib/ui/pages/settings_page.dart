import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/comfy_api.dart';
import '../../services/version_checker.dart';
import '../../state/app_state.dart';
import '../../state/settings_store.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const accentChoices = [
    0xFF6C5CE7,
    0xFFD32F2F,
    0xFF2E7D32,
    0xFF0277BD,
    0xFFF9A825,
    0xFFC2185B,
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([state.settings, state.generator, state]),
      builder: (context, _) {
        final settings = state.settings;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Section(title: l10n.serverSection),
                    _ServerSection(state: state, l10n: l10n),
                    const SizedBox(height: 16),
                    _Section(title: l10n.appearanceSection),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.dark_mode_outlined),
                            title: Text(l10n.theme),
                            trailing: DropdownButton<AppTheme>(
                              key: const Key('settings.theme'),
                              value: settings.theme,
                              underline: const SizedBox.shrink(),
                              items: [
                                DropdownMenuItem(
                                  value: AppTheme.system,
                                  child: Text(l10n.themeSystem),
                                ),
                                DropdownMenuItem(
                                  value: AppTheme.light,
                                  child: Text(l10n.themeLight),
                                ),
                                DropdownMenuItem(
                                  value: AppTheme.dark,
                                  child: Text(l10n.themeDark),
                                ),
                                DropdownMenuItem(
                                  value: AppTheme.oled,
                                  child: Text(l10n.themeOled),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  settings.setTheme(v, state.prefs);
                                }
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.palette_outlined),
                            title: Text(l10n.accentColor),
                            trailing: Wrap(
                              spacing: 6,
                              children: [
                                for (final color in accentChoices)
                                  InkWell(
                                    key: Key(
                                      'settings.accent.${color.toRadixString(16)}',
                                    ),
                                    onTap: () => settings.setAccentColor(
                                      color,
                                      state.prefs,
                                    ),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Color(color),
                                      child: settings.accentColor == color
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.language_outlined),
                            title: Text(l10n.language),
                            trailing: DropdownButton<String>(
                              key: const Key('settings.language'),
                              value: _localeValue(settings.locale),
                              underline: const SizedBox.shrink(),
                              items: [
                                DropdownMenuItem(
                                  value: '',
                                  child: Text(l10n.languageSystem),
                                ),
                                const DropdownMenuItem(
                                  value: 'en_GB',
                                  child: Text('Traditional English'),
                                ),
                                const DropdownMenuItem(
                                  value: 'zh_Hans',
                                  child: Text('简体中文'),
                                ),
                                const DropdownMenuItem(
                                  value: 'ru',
                                  child: Text('Русский'),
                                ),
                                const DropdownMenuItem(
                                  value: 'ga',
                                  child: Text('Gaeilge'),
                                ),
                              ],
                              onChanged: (v) =>
                                  settings.setLocale(_parse(v), state.prefs),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Section(title: l10n.aboutSection),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text(l10n.appTitle),
                            subtitle: FutureBuilder(
                              future: state.packageInfo(),
                              builder: (context, snapshot) => Text(
                                l10n.versionLabel(
                                  snapshot.data?.version ?? '...',
                                ),
                              ),
                            ),
                          ),
                          _UpdateTile(state: state, l10n: l10n),
                          ListTile(
                            key: const Key('settings.releases'),
                            leading: const Icon(Icons.new_releases_outlined),
                            title: Text(l10n.releasesLink),
                            trailing: const Icon(Icons.open_in_new, size: 18),
                            onTap: () => state.launch(
                              Uri.parse(VersionChecker.releasesUrl),
                            ),
                          ),
                          ListTile(
                            key: const Key('settings.source'),
                            leading: const Icon(Icons.code),
                            title: Text(l10n.sourceLink),
                            trailing: const Icon(Icons.open_in_new, size: 18),
                            onTap: () => state.launch(
                              Uri.parse(
                                'https://gitlab.com/HttpAnimations/simpleui',
                              ),
                            ),
                          ),
                        ],
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

  static String _localeValue(Locale? locale) {
    if (locale == null) return '';
    if (locale.countryCode == null || locale.countryCode!.isEmpty) {
      return locale.languageCode;
    }
    return '${locale.languageCode}_${locale.countryCode}';
  }

  static Locale? _parse(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : null);
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ServerSection extends StatefulWidget {
  final AppState state;
  final AppLocalizations l10n;

  const _ServerSection({required this.state, required this.l10n});

  @override
  State<_ServerSection> createState() => _ServerSectionState();
}

class _ServerSectionState extends State<_ServerSection> {
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.state.settings.serverUrl);
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l10n = widget.l10n;
    final stats = state.generator.stats;
    final error = state.generator.serverError;
    final uri = parseServerUri(_url.text);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('settings.serverUrl'),
              controller: _url,
              decoration: InputDecoration(
                labelText: l10n.serverUrl,
                hintText: 'http://127.0.0.1:8188',
                border: const OutlineInputBorder(),
                errorText: uri == null && _url.text.isNotEmpty
                    ? l10n.invalidServerUrl
                    : null,
              ),
              onChanged: (v) => state.settings.setServerUrl(v, state.prefs),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.tonalIcon(
                  key: const Key('settings.testConnection'),
                  onPressed: state.generator.checkingServer
                      ? null
                      : state.generator.testConnection,
                  icon: state.generator.checkingServer
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: Text(l10n.testConnection),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: stats != null
                      ? Text(
                          l10n.serverOk(
                            stats.comfyVersion.isEmpty
                                ? 'ComfyUI'
                                : stats.comfyVersion,
                            stats.deviceName,
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : error != null
                      ? Text(
                          l10n.serverFailed,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      : Text(
                          l10n.serverHint,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateTile extends StatefulWidget {
  final AppState state;
  final AppLocalizations l10n;

  const _UpdateTile({required this.state, required this.l10n});

  @override
  State<_UpdateTile> createState() => _UpdateTileState();
}

class _UpdateTileState extends State<_UpdateTile> {
  bool _checking = false;
  bool _failed = false;

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _failed = false;
    });
    final update = await widget.state.checkForUpdate();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _failed = update == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final update = widget.state.update;
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          key: const Key('settings.checkUpdates'),
          leading: const Icon(Icons.system_update_alt),
          title: Text(l10n.checkUpdates),
          subtitle: _checking
              ? Text(l10n.updateChecking)
              : _failed
              ? Text(l10n.updateFailed, style: TextStyle(color: colors.error))
              : update == null
              ? null
              : update.updateAvailable
              ? Text(l10n.updateAvailable(update.latestVersion))
              : Text(l10n.upToDate),
          trailing: _checking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: _checking ? null : _check,
        ),
        if (update != null && update.updateAvailable)
          ListTile(
            key: const Key('settings.getUpdate'),
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.getUpdate(update.latestVersion)),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => widget.state.launch(Uri.parse(update.releaseUrl)),
          ),
      ],
    );
  }
}
