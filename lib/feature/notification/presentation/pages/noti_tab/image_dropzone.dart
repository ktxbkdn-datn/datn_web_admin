import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class MediaDropzone extends StatefulWidget {
  final Function(List<Map<String, dynamic>>, List<String>) onMediaDropped;
  final List<Map<String, dynamic>> initialMedia;
  final List<String> initialAltTexts;

  const MediaDropzone({
    Key? key,
    required this.onMediaDropped,
    this.initialMedia = const [],
    this.initialAltTexts = const [],
  }) : super(key: key);

  @override
  _MediaDropzoneState createState() => _MediaDropzoneState();
}

class _MediaDropzoneState extends State<MediaDropzone> {
  List<Map<String, dynamic>> _media = [];
  List<String> _altTexts = [];
  static const int MAX_FILES = 20; // Tăng từ 15 lên 20
  static const int MAX_IMAGES = 10;
  static const int MAX_DOCUMENTS = 5;
  static const int MAX_IMAGE_SIZE = 50 * 1024 * 1024; // 50MB for images
  static const int MAX_VIDEO_SIZE = 100 * 1024 * 1024; // 100MB for videos
  static const int MAX_DOCUMENT_SIZE = 50 * 1024 * 1024; // 50MB for documents
  final List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'mp4', 'avi', 'pdf', 'doc', 'docx'];
  final ImagePicker _picker = ImagePicker();
  bool _isProcessingFiles = false;

  @override
  void initState() {
    super.initState();
    _media = List.from(widget.initialMedia);
    _altTexts = List.from(widget.initialAltTexts);
  }

  // Kiểm tra định dạng file có được phép không
  bool _isAllowedFile(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    return _allowedExtensions.contains(extension);
  }

  // Xác định loại file
  String _getFileType(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    if (['mp4', 'avi'].contains(extension)) {
      return 'video';
    } else if (['pdf', 'doc', 'docx'].contains(extension)) {
      return 'document';
    }
    return 'image';
  }

  // Chọn file từ thiết bị
  Future<void> _pickFiles() async {
    if (_isProcessingFiles || _media.length >= MAX_FILES) {
      if (_media.length >= MAX_FILES) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đạt giới hạn 20 file')),
        );
      }
      return;
    }

    setState(() {
      _isProcessingFiles = true;
    });

    try {
      // Sử dụng pickMultiImage hoặc getContent tùy thuộc vào nền tảng
      List<XFile>? pickedFiles;
      if (kIsWeb) {
        // Trên web, sử dụng pickMultiImage (có thể không hỗ trợ tất cả các loại file)
        pickedFiles = await _picker.pickMultiImage();
      } else {
        // Trên mobile, sử dụng pickMedia để chọn bất kỳ loại file nào
        pickedFiles = await _picker.pickMultipleMedia();
      }

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        List<Map<String, dynamic>> newFiles = [];
        int imageCount = _media.where((item) => item['fileType'] == 'image').length;
        int documentCount = _media.where((item) => item['fileType'] == 'document').length;

        // Xử lý từng file bất đồng bộ
        for (var file in pickedFiles) {
          if (!_isAllowedFile(file.name)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File ${file.name} không được hỗ trợ (chỉ hỗ trợ ${_allowedExtensions.join(', ')})')),
            );
            continue;
          }

          // Kiểm tra kích thước file
          int fileSize = await file.length();
          String fileType = _getFileType(file.name);
          int maxSize = fileType == 'video' ? MAX_VIDEO_SIZE : MAX_DOCUMENT_SIZE;
          if (fileSize > maxSize) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File ${file.name} vượt quá giới hạn ${maxSize ~/ (1024 * 1024)} MB')),
            );
            continue;
          }

          // Kiểm tra giới hạn số lượng ảnh và tài liệu
          if (fileType == 'image') {
            if (imageCount >= MAX_IMAGES) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đạt giới hạn 10 ảnh')),
              );
              continue;
            }
            imageCount++;
          } else if (fileType == 'document') {
            if (documentCount >= MAX_DOCUMENTS) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đạt giới hạn 5 tài liệu')),
              );
              continue;
            }
            documentCount++;
          }

          // Lưu thông tin file
          newFiles.add({
            'file': file,
            'name': file.name,
            'size': fileSize,
            'fileType': fileType,
          });
        }

        setState(() {
          if (_media.length + newFiles.length > MAX_FILES) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chỉ được tải lên tối đa 20 file mỗi lần')),
            );
            newFiles = newFiles.sublist(0, MAX_FILES - _media.length);
          }
          _media.addAll(newFiles);
          _altTexts.addAll(List.filled(newFiles.length, '')); // Thêm alt texts rỗng
        });

        widget.onMediaDropped(_media, _altTexts);
      }
    } catch (e) {
      print('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn file: $e')),
      );
    } finally {
      setState(() {
        _isProcessingFiles = false;
      });
    }
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
        Text(
          'Tải lên tối đa 20 file (jpg, jpeg, png, mp4, avi, pdf, doc, docx). Kích thước tối đa: 50 MB cho ảnh/tài liệu, 100 MB cho video. Tối đa 10 ảnh và 5 tài liệu.',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),

        // Khu vực chọn file
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, style: BorderStyle.solid, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: _isProcessingFiles
                  ? const CircularProgressIndicator()
                  : const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file, size: 32, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Nhấn để chọn file',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tối đa 20 file, ảnh/tài liệu < 50 MB, video < 100 MB',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Danh sách file đã chọn
        if (_media.isNotEmpty) ...[
          const Text(
            'File đã chọn:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._media.map((file) {
            final int size = file['size'] as int;
            final String filename = file['name'] as String;
            final String fileType = file['fileType'] as String;
            final XFile xFile = file['file'] as XFile;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (fileType == 'video')
                    const Icon(
                      Icons.videocam,
                      size: 50,
                      color: Colors.grey,
                    )
                  else if (fileType == 'document')
                    const Icon(
                      Icons.description,
                      size: 50,
                      color: Colors.grey,
                    )
                  else
                    FutureBuilder<Uint8List>(
                      future: xFile.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasData) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              snapshot.data!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
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
                          _formatFileSize(size),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        final index = _media.indexOf(file);
                        _media.removeAt(index);
                        _altTexts.removeAt(index);
                      });
                      widget.onMediaDropped(_media, _altTexts);
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