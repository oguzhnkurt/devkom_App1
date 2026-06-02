import 'package:flutter/material.dart';
import 'package:devkom_app/services/permission_manager.dart';

class PermissionSheet extends StatefulWidget {
  final List<AppPermission> permissions;
  final VoidCallback? onComplete;
  final bool canSkip;

  const PermissionSheet({
    super.key,
    required this.permissions,
    this.onComplete,
    this.canSkip = true,
  });

  @override
  State<PermissionSheet> createState() => _PermissionSheetState();

  /// Show the permission sheet as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required List<AppPermission> permissions,
    VoidCallback? onComplete,
    bool canSkip = true,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PermissionSheet(
        permissions: permissions,
        onComplete: onComplete,
        canSkip: canSkip,
      ),
    );
  }
}

class _PermissionSheetState extends State<PermissionSheet> {
  final PermissionManager _permissionManager = PermissionManager();
  final Map<AppPermission, bool> _permissionResults = {};
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkExistingPermissions();
  }

  Future<void> _checkExistingPermissions() async {
    for (var permission in widget.permissions) {
      final isGranted = await _permissionManager.isPermissionGranted(permission);
      setState(() {
        _permissionResults[permission] = isGranted;
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isRequesting = true;
    });

    final results =
        await _permissionManager.requestMultiplePermissions(widget.permissions);

    setState(() {
      _permissionResults.addAll(results);
      _isRequesting = false;
    });

    // Show success message
    if (mounted) {
      final grantedCount = results.values.where((v) => v).length;
      final totalCount = results.length;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$grantedCount/$totalCount izin verildi',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Close sheet and call onComplete
      Navigator.of(context).pop();
      widget.onComplete?.call();
    }
  }

  void _skip() {
    Navigator.of(context).pop();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_user,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'İzinler',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daha iyi bir deneyim için bazı izinlere ihtiyacımız var',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Permission list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: widget.permissions.length,
                itemBuilder: (context, index) {
                  final permission = widget.permissions[index];
                  final isGranted = _permissionResults[permission] ?? false;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isGranted ? Colors.green : Colors.grey[200]!,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isGranted
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _permissionManager.getPermissionIcon(permission),
                            color: isGranted ? Colors.green : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _permissionManager
                                        .getPermissionName(permission),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isGranted) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _permissionManager
                                    .getPermissionDescription(permission),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Allow button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isRequesting ? null : _requestAllPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isRequesting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'İzin Ver',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  // Skip button
                  if (widget.canSkip) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _skip,
                      child: const Text(
                        'Şimdi Değil',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
