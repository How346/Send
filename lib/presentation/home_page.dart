import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onToggleTheme});
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final selected = <PlatformFile>[];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(context),
      const _Nearby(),
      const _Queue(),
      const _History(),
      _settings(context),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('HyperDrop', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Theme',
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.wifi_find_outlined), selectedIcon: Icon(Icons.wifi_find), label: 'Nearby'),
          NavigationDestination(icon: Icon(Icons.swap_vert_outlined), selectedIcon: Icon(Icons.swap_vert), label: 'Queue'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _home(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Send files.\\nAt local-network speed.', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text('Private, offline-first transfers between Android and Windows.', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _actionCard(context, Icons.upload_rounded, 'Send', 'Choose files or folders', _pick)),
                  const SizedBox(width: 16),
                  Expanded(child: _actionCard(context, Icons.download_rounded, 'Receive', 'Wait for a nearby device', () => setState(() => index = 1))),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Selected', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (selected.isEmpty) const Text('Nothing selected yet.'),
                    ...selected.map((f) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.insert_drive_file_outlined),
                      title: Text(f.name),
                      subtitle: Text('${f.size} bytes'),
                    )),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext context, IconData icon, String title, String sub, VoidCallback tap) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: tap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 38),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(sub),
          ]),
        ),
      ),
    );
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: false);
    if (result == null) return;
    setState(() => selected
      ..clear()
      ..addAll(result.files));
  }

  Widget _settings(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Settings', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      const ListTile(leading: Icon(Icons.security_outlined), title: Text('Security'), subtitle: Text('Pairing confirmation and encrypted sessions')),
      const ListTile(leading: Icon(Icons.folder_outlined), title: Text('Receive folder'), subtitle: Text('Files are never written outside the selected root')),
      const ListTile(leading: Icon(Icons.network_check_outlined), title: Text('Network diagnostics'), subtitle: Text('LAN address, discovery and transport status')),
      const ListTile(leading: Icon(Icons.devices_outlined), title: Text('Trusted devices'), subtitle: Text('Review and revoke paired devices')),
    ],
  );
}

class _Nearby extends StatelessWidget {
  const _Nearby();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.wifi_find, size: 72),
        SizedBox(height: 16),
        Text('Nearby devices', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        SizedBox(height: 8),
        Text('Discovery service is ready for the LAN transport layer.'),
      ]),
    ),
  );
}

class _Queue extends StatelessWidget {
  const _Queue();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Transfer queue\\n\\nNo active transfers.'));
}

class _History extends StatelessWidget {
  const _History();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Transfer history\\n\\nNo transfers yet.'));
}
