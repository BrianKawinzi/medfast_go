import 'dart:io';
import 'dart:math';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medfast_go/controllers/authentication_controller.dart';
import 'package:medfast_go/data/DatabaseHelper.dart';
import 'package:medfast_go/models/product.dart';
import 'package:permission_handler/permission_handler.dart';

class ProductImport extends StatefulWidget {
  const ProductImport({super.key});

  @override
  State<ProductImport> createState() => _ProductImportState();
}

class _ProductImportState extends State<ProductImport> {
  List<List<dynamic>> excelData = [];
  FilePickerResult? filePaths;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool isFromAdding = false;
  final AuthenticationController authenticationController = Get.find();

  Future<void> displayExcelData(String excelFilePath) async {
    var bytes = File(excelFilePath).readAsBytesSync();
    var excelFile = excel.Excel.decodeBytes(bytes);
    var sheet = excelFile.tables.keys.first;
    var table = excelFile.tables[sheet]!;
    setState(() {
      excelData = table.rows
          .map((row) => row.map((cell) => cell!.value).toList())
          .toList();
    });
  }

  Future<void> readProductsFromExcel(String file) async {
    setState(() {
      isFromAdding = true;
    });
    var bytes = File(file).readAsBytesSync();
    var excels = excel.Excel.decodeBytes(bytes);
    List<Product> validProducts = [];
    bool hasValidProducts = false;

    for (var table in excels.tables.keys) {
      var sheet = excels.tables[table];

      if (sheet == null) continue;

      for (var rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
        var row = sheet.rows[rowIndex];
        final Random random = Random();

        try {
          var product = Product(
            id: random.nextInt(1000000000),
            productName: row[0]!.value.toString(),
            medicineDescription: row[1]!.value.toString(),
            buyingPrice: double.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
            sellingPrice: double.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
            unit: row[4]!.value.toString(),
            quantity: int.tryParse(row[5]?.value.toString() ?? '0') ?? 0,
            expiryDate: row[6]!.value.toString(),
            manufactureDate: row[7]!.value.toString(),
            phamacyId: authenticationController.currentUserData.value.phymacyId,
            userId: authenticationController.currentUserData.value.uid,
            lastModified: DateTime.now().toIso8601String(),
            barcode: '',
          );

          if (product.buyingPrice != 0.0 &&
              product.sellingPrice >= product.buyingPrice) {
            validProducts.add(product);
            hasValidProducts = true;
          } else {
            hasValidProducts = false;
            break;
          }
        } catch (e) {
          print('Error parsing row: $rowIndex, $e');
        }
      }
    }

    if (!hasValidProducts) {
      setState(() {
        isFromAdding = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Invalid Pricing'),
            content: const Text(
                'Some products have either incorrect pricing or missing prices.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      for (var product in validProducts) {
        await _databaseHelper.insertProduct(product);
      }
      setState(() {
        isFromAdding = false;
      });
      Navigator.pushReplacementNamed(context, '/product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Products'), actions: [
        excelData.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.cancel_outlined),
                onPressed: () {
                  setState(() {
                    filePaths;
                    excelData.clear();
                  });
                },
              )
            : const SizedBox()
      ]),
      floatingActionButton: excelData.isNotEmpty
          ? isFromAdding
              ? const CircularProgressIndicator()
              : FloatingActionButton.extended(
                  backgroundColor: Colors.green[700],
                  onPressed: () {
                    readProductsFromExcel(filePaths!.files.single.path!);
                  },
                  label: const Row(
                    children: [
                      Icon(
                        Icons.file_upload,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'upload Products',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
          : null,
      body: excelData.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: () async {
                  await Permission.storage.request();
                  filePaths = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xls', 'xlsx'],
                  ).then((value) => value!);

                  await displayExcelData(filePaths!.files.single.path!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Select Excel File',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: DataTable(
                        columns: List.generate(
                          excelData[0].length,
                          (index) =>
                              DataColumn(label: Text('${excelData[0][index]}')),
                        ),
                        rows: List.generate(
                          excelData.length - 1,
                          (rowIndex) => DataRow(
                            cells: List.generate(
                              excelData[rowIndex + 1].length,
                              (colIndex) => DataCell(
                                Text('${excelData[rowIndex + 1][colIndex]}'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
