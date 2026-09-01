import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/mock_scanner.dart';
import '../services/protection_mode_service.dart';
import '../widgets/upload_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const String _protectionPrefKey = 'protection_mode_enabled';

  XFile? _image;
  bool _scanning = false;
  bool _protectionEnabled = false;
  bool _permissionGranted = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProtectionState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionState();
    }
  }

  Future<void> _loadProtectionState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedState = prefs.getBool(_protectionPrefKey) ?? false;
    final hasPermission = await ProtectionModeService.checkOverlayPermission();

    if (!mounted) return;

    setState(() {
      _protectionEnabled = savedState && hasPermission;
      _permissionGranted = hasPermission;
    });

    if (savedState && !hasPermission) {
      _showPermissionNotice();
    }
  }

  Future<void> _refreshPermissionState() async {
    final hasPermission = await ProtectionModeService.checkOverlayPermission();
    if (!mounted) return;

    setState(() {
      _permissionGranted = hasPermission;
      if (!_protectionEnabled && hasPermission) {
        _protectionEnabled = false;
      }
    });

    if (!_permissionGranted && _protectionEnabled) {
      _showPermissionNotice();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, maxWidth: 2048);
      if (!mounted) return;
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image selection cancelled.')));
        return;
      }
      setState(() => _image = image);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _startScan() async {
    if (_image == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image first.')));
      return;
    }

    setState(() => _scanning = true);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const _ScanningDialog();
        },
      );
    }

    final result = await MockScanner.scan(_image!.path);

    if (!mounted) return;
    Navigator.of(context).pop();

    setState(() => _scanning = false);

    if (mounted) {
      Navigator.of(context).pushNamed('/result', arguments: result);
    }
  }

  Future<void> _requestPermissionForProtection() async {
    final opened = await ProtectionModeService.openOverlaySettings();
    if (!mounted) return;

    if (opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please return to Word Scanner and confirm the overlay permission was granted.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open Android overlay settings. Please grant the permission manually.')),
    );
  }

  void _showPermissionNotice() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Protection Mode needs permission'),
        content: const Text(
          'Protection Mode needs permission to display alerts over other apps. This is a prototype feature only and does not capture any content from other apps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissionForProtection();
            },
            child: const Text('Allow Permission'),
          ),
        ],
      ),
    );
  }

  Future<void> _enableProtectionMode() async {
    final hasPermission = await ProtectionModeService.checkOverlayPermission();

    if (!hasPermission) {
      _showPermissionNotice();
      return;
    }

    final ok = await ProtectionModeService.enableProtectionMode();
    if (!mounted) return;

    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_protectionPrefKey, true);
      if (!mounted) return;
      setState(() {
        _protectionEnabled = true;
        _permissionGranted = true;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Protection Mode enabled. The service is running in the background.')),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Protection Mode could not be started. Please try again.')),
    );
  }

  Future<void> _disableProtectionMode() async {
    final ok = await ProtectionModeService.disableProtectionMode();
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_protectionPrefKey, false);

    setState(() {
      _protectionEnabled = false;
    });

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Protection Mode disabled.')),
      );
    }
  }

  Future<void> _triggerTestAlert() async {
    if (!_permissionGranted) {
      _showPermissionNotice();
      return;
    }

    final ok = await ProtectionModeService.triggerTestAlert();
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The prototype alert could not be shown.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Scanner')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'Protect yourself while browsing',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 18),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: _protectionEnabled ? Colors.green.shade50 : Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.shield_rounded,
                              size: 28,
                              color: _protectionEnabled ? Colors.green : Colors.indigo,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Protection Mode',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _protectionEnabled ? 'Active' : 'Not currently active',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _protectionEnabled ? Colors.green : Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (_protectionEnabled)
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _protectionEnabled
                            ? 'Protection Mode is active and ready to display alerts while you use other apps.'
                            : 'Get warnings when potentially suspicious content is detected while using other apps.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 18),
                      if (!_permissionGranted && !_protectionEnabled)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.orange),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Protection Mode needs permission to display alerts over other apps.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _protectionEnabled ? _disableProtectionMode : _enableProtectionMode,
                        icon: Icon(_protectionEnabled ? Icons.toggle_on : Icons.toggle_off),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            _protectionEnabled ? 'Disable Protection Mode' : 'Enable Protection Mode',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _triggerTestAlert,
                        icon: const Icon(Icons.warning_amber_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('Prototype Test: Floating Alert', style: TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Upload or take a photo of any document or image to scan words inside it.',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              UploadCard(
                imageFile: _image != null ? File(_image!.path) : null,
                onUploadPressed: () => _pickImage(ImageSource.gallery),
                onTakePhotoPressed: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _scanning ? null : _startScan,
                icon: const Icon(Icons.search),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Scan Image', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() => _image = null);
                },
                child: const Text('Clear selection'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanningDialog extends StatefulWidget {
  const _ScanningDialog();

  @override
  State<_ScanningDialog> createState() => _ScanningDialogState();
}

class _ScanningDialogState extends State<_ScanningDialog> with SingleTickerProviderStateMixin {
  final List<String> _steps = ['Scanning image...', 'Detecting words...', 'Analyzing results...'];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  void _cycle() async {
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _index = i);
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 6),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_steps[_index], style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('This is a mocked scan — no data is sent anywhere.'),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
