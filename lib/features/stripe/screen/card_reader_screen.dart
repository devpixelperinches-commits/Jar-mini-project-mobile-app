import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarpay/constants/AppImages.dart';
import 'package:jarpay/features/stripe/helpers/stripe_terminal_helper.dart';
import 'package:jarpay/widgets/customHeader.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:jarpay/features/stripe/screen/payment_setup.dart';

class WisePosReaderScreen extends ConsumerStatefulWidget {
  final Function(Reader) onDeviceConnected;
  final int amountInPence; // Always minor units (e.g. £257.83 => 25783)

  const WisePosReaderScreen({
    super.key,
    required this.onDeviceConnected,
    required this.amountInPence,
  });

  @override
  ConsumerState<WisePosReaderScreen> createState() =>
      _WisePosReaderScreenState();
}

class _WisePosReaderScreenState extends ConsumerState<WisePosReaderScreen> {
  bool showLoader = false;
  Reader? connectedReader;

  @override
  void initState() {
    super.initState();
    // 🔍 Debug: Log the amount received
    debugPrint(
      "📱 WisePosReaderScreen received amount: ${widget.amountInPence} pence (£${(widget.amountInPence / 100).toStringAsFixed(2)})",
    );
    initTerminalAndDiscover();
  }

  // Initialize terminal + discover devices
  Future<void> initTerminalAndDiscover() async {
    setState(() => showLoader = true);

    bool granted = await StripeTerminalHelper.requestBluetoothPermissions(
      context,
    );

    if (!granted) {
      setState(() => showLoader = false);
      return;
    }

    try {
      await StripeTerminalHelper.init();

      final reader = await StripeTerminalHelper.discoverAndConnect(
        context,
        ref,
      );

      if (!mounted) return;

      setState(() {
        connectedReader = reader;
        showLoader = false;
      });

      if (reader != null) {
        StripeTerminalHelper.connectedReader = reader;
        widget.onDeviceConnected(reader);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => showLoader = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Terminal Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: SafeArea(
        child: Center(
          child: showLoader
              ? const _LoaderView()
              : connectedReader != null
              ? _ConnectedReaderView(
                  reader: connectedReader!,
                  amountInPence: widget.amountInPence,
                )
              : const _NoReaderView(),
        ),
      ),
    );
  }
}

//
// ------------ Sub Widgets ------------
//

class _LoaderView extends StatelessWidget {
  const _LoaderView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 16),
        Text('Connecting to reader...', style: TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _NoReaderView extends StatelessWidget {
  const _NoReaderView();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'No reader found',
      style: TextStyle(color: Colors.white, fontSize: 18),
    );
  }
}

class _ConnectedReaderView extends StatelessWidget {
  final Reader reader;
  final int amountInPence;

  const _ConnectedReaderView({
    super.key,
    required this.reader,
    required this.amountInPence,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        const CustomHeader(title: "", showBackButton: true),
        Image.asset(AppImages.cardReadDevice, height: 80),
        const SizedBox(height: 16),

        const Text(
          'Connect your WisePad 3',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        const InstructionStep(
          step: 1,
          text: 'Take your WisePad 3 and cable out from the box',
        ),
        const InstructionStep(
          step: 2,
          text: 'Plug in your card reader so it can charge',
        ),
        const InstructionStep(
          step: 3,
          text: 'Press the power on button \u23FB',
        ),
        const InstructionStep(
          step: 4,
          text: 'Once the app sees your reader it will appear below',
        ),

        const Spacer(),

        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Image.asset(
              AppImages.cardReadDevice,
              width: 40,
              height: 40,
            ),
            title: const Text('WisePad 3'),
            subtitle: Text('Connected: ${reader.label ?? reader.serialNumber}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (reader.serialNumber != null) {
                // 🔍 Debug: Log amount before navigation
                debugPrint(
                  "🔄 Navigating to PaymentSetupScreen with amount: $amountInPence pence (£${(amountInPence / 100).toStringAsFixed(2)})",
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentSetupScreen(
                      amountInPence: amountInPence,
                      serialNumber: reader.serialNumber!,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

//
// ------------- Step UI -------------
//

class InstructionStep extends StatelessWidget {
  final int step;
  final String text;

  const InstructionStep({super.key, required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
