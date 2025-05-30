import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageDropArea extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onImagesDropped;
  final List<Map<String, dynamic>> initialImages;

  const ImageDropArea({
    Key? key,
    required this.onImagesDropped,
    this.initialImages = const [],
  }) : super(key: key);

  @override
  _ImageDropAreaState createState() => _ImageDropAreaState();
}

class _ImageDropAreaState extends State<ImageDropArea> {
  late DropzoneViewController _controller;
  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> _removedImages = [];

  // Danh sách định dạng file được phép (ảnh và video)
  final List<String> _allowedFormats = ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'avi'];

  @override
  void initState() {
    super.initState();
    _images = widget.initialImages.toList();
  }

  // Kiểm tra định dạng file có được phép không
  bool _isAllowedFile(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return _allowedFormats.contains(extension);
  }

  // Kiểm tra file có phải là video không
  bool _isVideoFile(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return ['mp4', 'avi'].contains(extension);
  }

  // Chọn file từ thiết bị
  Future<void> _pickFiles() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      List<Map<String, dynamic>> newFiles = [];
      for (var file in pickedFiles) {
        if (!_isAllowedFile(file.name)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File ${file.name} không được hỗ trợ (chỉ hỗ trợ jpg, jpeg, png, gif, mp4, avi)')),
          );
          continue;
        }

        if (kIsWeb) {
          final Uint8List? bytes = await file.readAsBytes();
          if (bytes != null) {
            int fileSize = bytes.length;
            if (fileSize > 100 * 1024 * 1024) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('File ${file.name} vượt quá giới hạn 100 MB')),
              );
              continue;
            }
            newFiles.add({
              'bytes': bytes,
              'name': file.name,
              'size': fileSize,
              'isProcessing': true,
              'fileType': _isVideoFile(file.name) ? 'video' : 'image',
            });
          }
        } else {
          File tempFile = File(file.path);
          int fileSize = await tempFile.length();
          if (fileSize > 100 * 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File ${file.name} vượt quá giới hạn 100 MB')),
            );
            continue;
          }
          final Uint8List bytes = await tempFile.readAsBytes();
          newFiles.add({
            'bytes': bytes,
            'file': tempFile,
            'name': file.name,
            'size': fileSize,
            'isProcessing': true,
            'fileType': _isVideoFile(file.name) ? 'video' : 'image',
          });
        }
      }

      setState(() {
        if (_images.length + newFiles.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chỉ được tải lên tối đa 5 file mỗi lần')),
          );
          newFiles = newFiles.sublist(0, 5 - _images.length);
        }
        _images.addAll(newFiles);
      });

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        for (var file in newFiles) {
          file['isProcessing'] = false;
        }
      });

      widget.onImagesDropped(_images);
    }
  }

  // Hàm tiện ích để lưu Uint8List thành File tạm thời (chỉ dùng cho mobile)
  Future<File> _createFileFromUint8List(Uint8List data, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(data);
    return file;
  }

  // Hàm tính kích thước file dưới dạng KB hoặc MB
  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024 * 1024) {
      double sizeInKB = sizeInBytes / 1024;
      return '${sizeInKB.toStringAsFixed(1)} KB';
    } else {
      double sizeInMB = sizeInBytes / (1024 * 1024);
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thông báo giới hạn
        const Text(
          'Bạn chỉ có thể tải lên tối đa 5 file mỗi lần (jpg, jpeg, png, gif, mp4, avi). Kích thước tối đa mỗi file là 100 MB.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        // Khu vực kéo thả
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, style: BorderStyle.solid, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                DropzoneView(
                  operation: DragOperation.copy,
                  cursor: CursorType.grab,
                  onCreated: (controller) => _controller = controller,
                  onDropMultiple: (files) async {
                    if (files != null) {
                      List<Map<String, dynamic>> droppedFiles = [];
                      for (var file in files) {
                        final String filename = await _controller.getFilename(file);
                        if (!_isAllowedFile(filename)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('File $filename không được hỗ trợ (chỉ hỗ trợ jpg, jpeg, png, gif, mp4, avi)')),
                          );
                          continue;
                        }

                        final Uint8List data = await _controller.getFileData(file);
                        int fileSize = data.length;
                        if (fileSize > 100 * 1024 * 1024) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('File $filename vượt quá giới hạn 100 MB')),
                          );
                          continue;
                        }

                        if (kIsWeb) {
                          droppedFiles.add({
                            'bytes': data,
                            'name': filename,
                            'size': fileSize,
                            'isProcessing': true,
                            'fileType': _isVideoFile(filename) ? 'video' : 'image',
                          });
                        } else {
                          final File tempFile = await _createFileFromUint8List(data, filename);
                          droppedFiles.add({
                            'bytes': data,
                            'file': tempFile,
                            'name': filename,
                            'size': fileSize,
                            'isProcessing': true,
                            'fileType': _isVideoFile(filename) ? 'video' : 'image',
                          });
                        }
                      }

                      setState(() {
                        if (_images.length + droppedFiles.length > 5) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chỉ được tải lên tối đa 5 file mỗi lần')),
                          );
                          droppedFiles = droppedFiles.sublist(0, 5 - _images.length);
                        }
                        _images.addAll(droppedFiles);
                      });

                      await Future.delayed(const Duration(milliseconds: 500));
                      setState(() {
                        for (var file in droppedFiles) {
                          file['isProcessing'] = false;
                        }
                      });

                      widget.onImagesDropped(_images);
                    }
                  },
                ),
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_file, size: 32, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Kéo và thả file vào đây hoặc Nhấn để chọn',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Kích thước tối đa mỗi file là 100 MB',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Danh sách file đã chọn
        if (_images.isNotEmpty) ...[
          const Text(
            'File đã chọn:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._images.map((file) {
            final int size = file['size'] as int;
            final bool isProcessing = file['isProcessing'] as bool;
            final String filename = file['name'] as String;
            final String fileType = file['fileType'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isProcessing ? Colors.grey[200] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (isProcessing)
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (fileType == 'video')
                    const Icon(
                      Icons.videocam,
                      size: 50,
                      color: Colors.grey,
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        file['bytes'] as Uint8List,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filename,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isProcessing ? 'Đang xử lý...' : _formatFileSize(size),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _images.remove(file);
                        _removedImages.add(file);
                      });
                      widget.onImagesDropped(_images);
                    },
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}