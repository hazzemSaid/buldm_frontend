import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class BuildCategorySelector extends StatefulWidget {
  final TextEditingController categoryController;
  final List<String> categories;
  final List<IconData> categoryIcons;
  final List<XFile> images;

  const BuildCategorySelector({
    super.key,
    required this.categoryController,
    required this.categories,
    required this.categoryIcons,
    required this.images,
  });

  @override
  State<BuildCategorySelector> createState() => _BuildCategorySelectorState();
}

class _BuildCategorySelectorState extends State<BuildCategorySelector> {
  Interpreter? _interpreter;
  List<String>? _labels;

  @override
  void initState() {
    super.initState();
    // _loadModel();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  // Future<void> _loadModel() async {
  // try {
  //   // Load the model
  //   // - assets/ai/buldm.tflite

  //   _interpreter = await Interpreter.fromAsset('assets/ai/buldm.tflite');

  //   // Load labels if you have them
  //   // _labels = await _loadLabels('assets/ai/labels.txt');

  //   // Run prediction after model is loaded
  //   for (var imageFile in widget.images) {
  //     await predictCategory(imageFile);
  //   }
  // } catch (e) {
  //   print('Error loading model: $e');
  // }
  // }

  // Future<List<String>> _loadLabels(String labelsPath) async {
  //   final labelsData =
  //       await DefaultAssetBundle.of(context).loadString(labelsPath);
  //   return labelsData.split('\n').where((line) => line.isNotEmpty).toList();
  // }

  // Future<void> predictCategory(XFile imageFile) async {
  //   if (_interpreter == null) return;

  //   try {
  //     // Read and decode the image
  //     final imageBytes = await File(imageFile.path).readAsBytes();
  //     img.Image? image = img.decodeImage(imageBytes);

  //     if (image == null) return;

  //     // Resize image to model input size (adjust size as needed for your model)
  //     final resized = img.copyResize(image, width: 224, height: 224);

  //     // Convert to input tensor
  //     final input = _imageToByteListFloat32(resized, 224, 224, 127.5, 127.5);

  //     // Get input and output tensor shapes
  //     final inputTensor = _interpreter!.getInputTensor(0);
  //     final outputTensor = _interpreter!.getOutputTensor(0);

  //     print('Input shape: ${inputTensor.shape}');
  //     print('Output shape: ${outputTensor.shape}');

  //     // Prepare output buffer
  //     final output = List.filled(outputTensor.shape[1], 0.0)
  //         .reshape([1, outputTensor.shape[1]]);

  //     // Run inference
  //     _interpreter!.run(input, output);

  //     // Process results
  //     final results = output[0] as List<double>;

  //     // Find the index with highest confidence
  //     double maxScore = results[0];
  //     int maxIndex = 0;

  //     for (int i = 1; i < results.length; i++) {
  //       if (results[i] > maxScore) {
  //         maxScore = results[i];
  //         maxIndex = i;
  //       }
  //     }

  //     print("Predicted index: $maxIndex with confidence: $maxScore");

  //     // If you have labels, you can use them
  //     if (_labels != null && maxIndex < _labels!.length) {
  //       final predictedLabel = _labels![maxIndex];
  //       print("Predicted: $predictedLabel");

  //       // Auto-select category if it matches one of your categories
  //       if (widget.categories.contains(predictedLabel)) {
  //         setState(() {
  //           widget.categoryController.text = predictedLabel;
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print('Error during prediction: $e');
  //   }
  // }

  // Uint8List _imageToByteListFloat32(
  //   img.Image image, int inputSize, int inputSize2, double mean, double std) {
  // var convertedBytes = Float32List(1 * inputSize * inputSize2 * 3);
  // var buffer = Float32List.view(convertedBytes.buffer);
  // int pixelIndex = 0;

  // for (int i = 0; i < inputSize; i++) {
  //   for (int j = 0; j < inputSize2; j++) {
  //     var pixel = image.getPixel(j, i);

  //     // Extract RGB values
  //     final r = pixel.r;
  //     final g = pixel.g;
  //     final b = pixel.b;

  //     // Normalize pixel values
  //     buffer[pixelIndex++] = (r - mean) / std;
  //     buffer[pixelIndex++] = (g - mean) / std;
  //     buffer[pixelIndex++] = (b - mean) / std;
  //   }
  // }

  // return convertedBytes.buffer.asUint8List();
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isSelected = widget.categoryController.text == category;

            return GestureDetector(
              onTap: () {
                setState(() {
                  widget.categoryController.text = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.categoryIcons[index],
                      size: 16,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
