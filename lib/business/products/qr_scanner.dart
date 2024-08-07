import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medfast_go/business/products/addproductwithoutbarcode.dart';
import 'package:medfast_go/pages/components/my_button.dart';

class BarcodeScanners extends StatefulWidget {
  const BarcodeScanners({super.key});

  @override
  _BarcodeScannersState createState() => _BarcodeScannersState();
}

class _BarcodeScannersState extends State<BarcodeScanners> {
  String? _barcodeResult;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      String barcode = result.rawContent;
      setState(() => _barcodeResult = barcode);
      _playBeepSound();
      _handleScannedBarcode(barcode);
    } catch (e) {
      setState(() => _barcodeResult = 'Failed to get the barcode.');
    }
  }

  void _playBeepSound() async {
    await _audioPlayer.setAsset('lib/assets/scanbeep.mp3');
    _audioPlayer.play();
  }

  void _handleScannedBarcode(String barcode) {
    try {
      if (barcode != '') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddProductForm(barcode: barcode),
          ),
        );
      } else {
        throw const FormatException('Scanned data is not a valid product JSON');
      }
    } catch (e) {
      print('Failed to parse barcode: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to parse barcode')),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Result: $_barcodeResult'),
            const SizedBox(height: 20),
            MyButton(
              onTap: _scanBarcode,
              buttonText: 'Scan',
            )
          ],
        ),
      ),
    );
  }
}
