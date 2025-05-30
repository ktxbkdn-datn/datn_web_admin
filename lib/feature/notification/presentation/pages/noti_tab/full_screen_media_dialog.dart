import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart' show launchUrl, LaunchMode;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FullScreenMediaDialog extends StatefulWidget {
  final List<Map<String, dynamic>> mediaItems;
  final int initialIndex;
  final Map<String, ChewieController> chewieControllers;
  final Map<String, VideoPlayerController> videoControllers;
  final String baseUrl;

  const FullScreenMediaDialog({
    Key? key,
    required this.mediaItems,
    required this.initialIndex,
    required this.chewieControllers,
    required this.videoControllers,
    required this.baseUrl,
  }) : super(key: key);

  @override
  _FullScreenMediaDialogState createState() => _FullScreenMediaDialogState();
}

class _FullScreenMediaDialogState extends State<FullScreenMediaDialog> {
  late PageController _fullScreenPageController;
  late int _currentIndex;
  Future<String?>? _authTokenFuture;
  String? _authToken;
  final Map<String, String> _documentPaths = {};
  String? _pdfError;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _fullScreenPageController = PageController(initialPage: _currentIndex);
    _authTokenFuture = _loadAuthToken();
  }

  Future<String?> _loadAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('Loaded auth token: $token');
    setState(() {
      _authToken = token;
    });
    return token;
  }

  bool _isVideo(Map<String, dynamic> media) {
    final url = media['media_url'] as String? ?? '';
    if (url.isEmpty) return false;
    final extension = url.toLowerCase().split('.').last;
    return ['mp4', 'avi'].contains(extension);
  }

  bool _isDocument(Map<String, dynamic> media) {
    final fileType = media['file_type'] as String? ?? '';
    return fileType == 'document';
  }

  bool _isWordDocument(Map<String, dynamic> media) {
    final filename = media['filename'] as String? ?? '';
    final extension = filename.toLowerCase().split('.').last;
    return ['doc', 'docx'].contains(extension);
  }

  String _buildMediaUrl(String mediaPath) {
    return '${widget.baseUrl}/notification_media/$mediaPath';
  }

  Future<ChewieController?> _getChewieController(String url) async {
    if (!widget.chewieControllers.containsKey(url)) {
      final authToken = await _authTokenFuture;
      if (authToken == null) {
        print('Error: Auth token is null, cannot load video for URL: $url');
        return null;
      }

      final videoController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {'Authorization': 'Bearer $authToken'},
      );
      widget.videoControllers[url] = videoController;

      try {
        await videoController.initialize().timeout(const Duration(seconds: 30), onTimeout: () {
          throw Exception('Video initialization timeout: $url');
        });
        print('Video initialized successfully: $url');

        final chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          showControlsOnInitialize: true,
          allowPlaybackSpeedChanging: false,
          placeholder: const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Không thể tải video: $errorMessage',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        );
        widget.chewieControllers[url] = chewieController;
      } catch (error, stackTrace) {
        print('Error initializing video $url: $error');
        print('Stack trace: $stackTrace');
        videoController.dispose();
        widget.videoControllers.remove(url);
        return null;
      }
    }
    return widget.chewieControllers[url];
  }

  Future<String?> _downloadDocument(String mediaUrl, String filename) async {
    if (_documentPaths.containsKey(mediaUrl)) {
      return _documentPaths[mediaUrl];
    }

    final authToken = await _authTokenFuture;
    if (authToken == null) {
      print('Error: Auth token is null, cannot download document for URL: $mediaUrl');
      return null;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$filename';

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(mediaUrl))
        ..headers['Authorization'] = 'Bearer $authToken';
      
      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception('Lỗi tải tài liệu, mã trạng thái: ${response.statusCode}');
      }

      final file = File(filePath);
      final sink = file.openWrite();
      await response.stream.pipe(sink);
      await sink.close();
      client.close();

      print('Document downloaded successfully: $filePath');
      _documentPaths[mediaUrl] = filePath;
      return filePath;
    } catch (e) {
      print('Error downloading document $mediaUrl: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải tài liệu: $e'), backgroundColor: Colors.red),
      );
      return null;
    }
  }

  void _previousMedia() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _fullScreenPageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _pdfError = null; // Reset error state
      });
    }
  }

  void _nextMedia() {
    if (_currentIndex < widget.mediaItems.length - 1) {
      setState(() {
        _currentIndex++;
        _fullScreenPageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _pdfError = null; // Reset error state
      });
    }
  }

  @override
  void dispose() {
    _fullScreenPageController.dispose();
    if (!kIsWeb) {
      for (var filePath in _documentPaths.values) {
        File(filePath).delete().catchError((e) => print('Error deleting file $filePath: $e'));
      }
    }
    _documentPaths.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItems.isEmpty) {
      return Dialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        child: const Center(
          child: Text(
            'Không có media để hiển thị',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return FutureBuilder<String?>(
      future: _authTokenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Dialog(
            backgroundColor: Colors.black.withOpacity(0.9),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Dialog(
            backgroundColor: Colors.black.withOpacity(0.9),
            child: const Center(
              child: Text(
                'Thiếu token xác thực',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          );
        }

        final authToken = snapshot.data!;
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          child: Stack(
            children: [
              Center(
                child: PageView.builder(
                  controller: _fullScreenPageController,
                  itemCount: widget.mediaItems.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _pdfError = null; // Reset error state
                    });
                  },
                  itemBuilder: (context, index) {
                    final media = widget.mediaItems[index];
                    final mediaUrl = _buildMediaUrl(media['media_url'] as String);

                    if (_isDocument(media)) {
                      if (kIsWeb) {
                        launchUrl(Uri.parse(mediaUrl), mode: LaunchMode.externalApplication);
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description, size: 80, color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Tài liệu đang được tải xuống...',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      if (_isWordDocument(media)) {
                        _downloadDocument(mediaUrl, media['filename'] as String).then((filePath) {
                          if (filePath != null) {
                            OpenFile.open(filePath).then((result) {
                              if (result.type != ResultType.done) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi mở tài liệu: ${result.message}'), backgroundColor: Colors.red),
                                );
                              }
                            }).catchError((e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi mở tài liệu: $e'), backgroundColor: Colors.red),
                              );
                            });
                          }
                        });
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.description, size: 80, color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Mở tài liệu Word trong ứng dụng bên ngoài...',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return FutureBuilder<String?>(
                        future: _downloadDocument(mediaUrl, media['filename'] as String),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasData && snapshot.data != null) {
                            if (_pdfError != null) {
                              return Center(
                                child: Text(
                                  'Lỗi tải PDF: $_pdfError',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }
                            return PDFView(
                              filePath: snapshot.data!,
                              enableSwipe: true,
                              swipeHorizontal: false,
                              autoSpacing: true,
                              pageFling: true,
                              onError: (error) {
                                print('PDFView error: $error');
                                setState(() {
                                  _pdfError = error.toString();
                                });
                              },
                              onRender: (pages) => print('PDF rendered with $pages pages'),
                            );
                          }
                          return const Center(
                            child: Text('Không thể tải tài liệu PDF', style: TextStyle(color: Colors.white)),
                          );
                        },
                      );
                    } else if (_isVideo(media)) {
                      return FutureBuilder<ChewieController?>(
                        future: _getChewieController(mediaUrl),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasData) {
                            return Chewie(controller: snapshot.data!);
                          }
                          return const Center(
                            child: Text('Không thể tải video', style: TextStyle(color: Colors.white)),
                          );
                        },
                      );
                    }
                    return InteractiveViewer(
                      child: CachedNetworkImage(
                        imageUrl: mediaUrl,
                        fit: BoxFit.contain,
                        httpHeaders: {'Authorization': 'Bearer $authToken'},
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Center(
                          child: Text('Không thể tải hình ảnh', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              if (widget.mediaItems.length > 1) ...[
                if (_currentIndex > 0)
                  Positioned(
                    left: 10,
                    top: MediaQuery.of(context).size.height / 2 - 30,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                      onPressed: _previousMedia,
                    ),
                  ),
                if (_currentIndex < widget.mediaItems.length - 1)
                  Positioned(
                    right: 10,
                    top: MediaQuery.of(context).size.height / 2 - 30,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                      onPressed: _nextMedia,
                    ),
                  ),
              ],
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _fullScreenPageController,
                    count: widget.mediaItems.length,
                    effect: const WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Colors.blue,
                      spacing: 8,
                      dotColor: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}