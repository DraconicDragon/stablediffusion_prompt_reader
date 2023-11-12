import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:png_chunks_extract/png_chunks_extract.dart' as pngExtract;

void main() {
  runApp(const MyApp());
}

// TODO: make code cleaner 💀 and learn design patterns soon™️
class MyApp extends StatelessWidget {
  const MyApp({super.key});
// TODO: add memory for saving location of used images
// TODO: add settings
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SD prompt reader',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SD prompt reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<XFile> imgs = [];
  XFile? selectedImage; // Track the selected image

// Function to read image metadata using pngExtract library
  Future<String> readImageMetadata(XFile image) async {
    final File file = File(image.path);
    final Uint8List data = file.readAsBytesSync();

    final trunk = pngExtract.extractChunks(data);
    final names = trunk.map((e) => e['name']).toList(growable: false);

    // Find the 'tEXt' chunk in the extracted chunks
    int textChunkIndex = names.indexOf('tEXt');

    if (textChunkIndex != -1) {
      // Extract the 'tEXt' chunk data
      Map<String, dynamic> textChunk = trunk[textChunkIndex];
      Uint8List textData = textChunk['data'];

      // Convert the text data to a string
      String text = String.fromCharCodes(textData);

      return text; // Return the textual information
    } else {
      return 'tEXt chunk not found in the PNG file.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) => setState(() => imgs.addAll(detail.files)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  buildImages(),
                ],
              ),
            ),
            if (selectedImage != null)
              // TODO: Make into separate function to not have so much indentation (possibility)
              Expanded(
                child: FutureBuilder<String>(
                  future: Future.delayed(const Duration(seconds: 0),
                      () => readImageMetadata(selectedImage!)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // Display metadata using the returned value or a default message
                      String metadata = snapshot.data ?? 'tEXt chunk not found';
                      // The regex to split the string
                      RegExp regex = RegExp(
                        r"(Positive prompt: |Negative prompt: |Steps:|Sampler:|CFG scale:|Seed:|Model hash:|Model:|VAE hash:|VAE:|Clip skip:|TI hashes:|Version:)",
                      );

// The list of substrings
                      List<String> substrings = metadata.split(regex);

// The list of labels for the substrings
                      List<String> labels = [
                        "Positive prompt",
                        "Negative prompt",
                        "Steps",
                        "Sampler",
                        "CFG scale",
                        "Seed",
                        "Model hash",
                        "Model",
                        "VAE hash",
                        "VAE",
                        "Clip skip",
                        "ControlNet 0",
                        "TI hashes",
                        "Version"
                      ];

// The list of widgets to display the substrings
                      List<Widget> widgets = [];

// Loop through the substrings and labels
                      for (int i = 0; i < substrings.length; i++) {
                        // Create a text field widget for each substring
                        Widget widget = Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, right: 8.0, top: 8.0, bottom: 0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText:
                                    labels[i], // Use the corresponding label
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(
                                text: substrings[
                                    i], // Use the corresponding substring
                              ),
                              readOnly: true,
                              maxLines: null, // Allow multiple lines of text
                            ),
                          ),
                        );

                        // Add the widget to the list
                        widgets.add(widget);
                      }

// Display the widgets in a column
                      return SingleChildScrollView(
                        child: Column(
                          children: widgets,
                        ),
                      );
                      // TODO: make this an option
                      // TODO: make option to exclude specific parts like version
                      //return Padding(
                      //  padding: const EdgeInsets.only(
                      //      left: 0.0, right: 8.0, top: 8.0, bottom: 8.0),
                      //  child: Align(
                      //    alignment: Alignment.topLeft,
                      //    child: TextField(
                      //      decoration: const InputDecoration(
                      //        labelText: 'Metadata',
                      //        border: OutlineInputBorder(),
                      //      ),
                      //      controller: TextEditingController(
                      //          text:
                      //              "Positive prompt: ${metadata.substring(11)}"),
                      //      readOnly: true,
                      //      maxLines: null, // Allow multiple lines of text
                      //    ),
                      //  ),
                      //);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildImages() => Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SingleChildScrollView(
            child: Column(
              children: imgs.mapIndexed((index, image) {
                final isSelected = image == selectedImage;
                return Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => setState(() => selectedImage = image),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(image.path),
                              width: 256,
                              height: 256,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                          if (isSelected)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 4.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (index < imgs.length - 1) const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
}
