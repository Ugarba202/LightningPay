import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:breez_sdk/breez_sdk.dart';
import 'package:breez_sdk/sdk.dart';
import 'package:breez_sdk/bridge_generated.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Lightweight service wrapper for BreezSDK configured for Testnet.
class BreezeService {
  BreezeService._();
  static final BreezeService instance = BreezeService._();
  factory BreezeService() => instance;

  BreezSDK? _sdk;

  BreezSDK get _internalSdk => _sdk ??= BreezSDK();

  /// Initialize SDK event/log streams and ensure working directory exists.
  Future<Directory> init({String subDirName = 'breez'}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final workingDir = Directory('${appDir.path}/$subDirName');
    if (!await workingDir.exists()) {
      await workingDir.create(recursive: true);
    }

    // Initialize SDK streams (idempotent)
    final breez = _internalSdk;
    try {
      final initialized = await breez.isInitialized();
      if (!initialized) {
        breez.initialize();
      }
    } catch (e) {
      try {
        breez.initialize();
      } catch (_) {}
    }

    if (kDebugMode) debugPrint('BreezeService: workingDir=${workingDir.path}');
    return workingDir;
  }

  /// Connects the Breez node using a mnemonic for Testnet.
  Future<void> connect({
    required String mnemonic,
    String apiKey = 'YOUR_BREEZ_API_KEY', // Recommended to pass this via secret management
    String? workingDirPath,
  }) async {
    final breez = _internalSdk;

    // Ensure streams are initialized and working dir exists
    final workingDir = workingDirPath ?? (await init()).path;

    // Testnet Configuration
    final config = Config(
      network: Network.Testnet,
      apiKey: apiKey,
      workingDir: workingDir,
      // Greenlight is the default node provider for Breez SDK
      nodeConfig: NodeConfig.greenlight(config: GreenlightNodeConfig()),
    );

    await breez.connect(req: ConnectRequest(config: config, mnemonic: mnemonic, seed: null));

    if (kDebugMode) debugPrint('BreezeService: connect() to Testnet completed');
  }

  /// Returns true if Breez node service is initialized (connected and ready).
  Future<bool> isConnected() async {
    final breez = _sdk ?? _internalSdk;
    try {
      return await breez.isInitialized();
    } catch (_) {
      return false;
    }
  }

  /// Fetch node information.
  Future<NodeState?> nodeInfo() async {
    final breez = _sdk ?? _internalSdk;
    try {
      return await breez.nodeInfo();
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // ⚡ LIGHTNING / BITCOIN METHODS (TESTNET)
  // ============================================================

  /// Generate a Bolt11 invoice to receive Lightning payments.
  Future<ReceivePaymentResponse> receivePayment({
    required int amountSats,
    String description = '',
  }) async {
    final breez = _internalSdk;
    return await breez.receivePayment(
      req: ReceivePaymentRequest(
        amountMsat: amountSats * 1000,
        description: description,
      ),
    );
  }

  /// Pay a Bolt11 invoice.
  Future<SendPaymentResponse> sendPayment({required String bolt11}) async {
    final breez = _internalSdk;
    return await breez.sendPayment(req: SendPaymentRequest(bolt11: bolt11));
  }

  /// Get an on-chain address for deposits (Testnet).
  Future<ReceiveOnchainResponse> receiveOnchain() async {
    final breez = _internalSdk;
    return await breez.receiveOnchain(req: const ReceiveOnchainRequest());
  }

  /// Parse a Bolt11 invoice to get details.
  Future<LnInvoice> parseInvoice(String bolt11) async {
    final breez = _internalSdk;
    return await breez.parseInvoice(invoice: bolt11);
  }

  /// Fetch current balance (Lightning + On-chain).
  Future<NodeState?> fetchBalance() async {
    return await nodeInfo();
  }

  /// Stream of node state (balance, height, etc.).
  Stream<NodeState?> get nodeStateStream => _internalSdk.nodeStateStream;

  /// Stream of SDK events (payment success, node sync, etc.).
  Stream<BreezEvent> get eventsStream => _internalSdk.eventsStream;

  /// Stream of ONLY paid invoices (useful for UI notifications).
  Stream<BreezEvent_InvoicePaid> get invoicePaidStream => eventsStream
      .where((event) => event is BreezEvent_InvoicePaid)
      .cast<BreezEvent_InvoicePaid>();

  /// Stream of payments (history).
  Stream<List<Payment>> get paymentsStream => _internalSdk.paymentsStream;

  /// Exposes the underlying SDK instance (if needed).
  BreezSDK? get sdk => _sdk ?? _internalSdk;
}
