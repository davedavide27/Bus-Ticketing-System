import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ReceiptService {
  static Future<void> saveReceipt(String content, String fileName) async {
    try {
      // Get the path to the app's external files directory.
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Unable to get external storage directory');
      }

      final targetDirectory = Directory('${directory.path}/departure_receipts');

      // Print directory path for debugging
      print('Target directory path: ${targetDirectory.path}');

      // Create the directory if it does not exist.
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
        print('Target directory created.');
      } else {
        print('Target directory already exists.');
      }

      // Define the file path and create the file.
      final filePath = '${targetDirectory.path}/$fileName.txt';
      final file = File(filePath);
      print('File path: $filePath');

      // Write the content to the file.
      await file.writeAsString(content);
      print('Receipt saved to $filePath');
    } catch (e) {
      print('Error saving receipt: $e');
    }
  }
}
