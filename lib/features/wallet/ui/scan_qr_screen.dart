import 'package:flutter/material.dart';

class ScanQrScreen extends StatelessWidget {
  const ScanQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Scan QR'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // =====================
          // CAMERA PREVIEW (PLACEHOLDER)
          // =====================
          Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: const Text(
              'Camera Preview',
              style: TextStyle(color: Colors.white54),
            ),
          ),

          // =====================
          // SCAN OVERLAY
          // =====================
          const _ScanOverlay(),

          // =====================
          // INSTRUCTIONS
          // =====================
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  'Align the QR code within the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We will scan automatically',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
