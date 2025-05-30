import 'dart:async';

import 'package:datn_web_admin/common/constants/api_string.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class FullScreenMediaDialog extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const FullScreenMediaDialog({
    Key? key,
    required this.mediaUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenMediaDialogState createState() => _FullScreenMediaDialogState();
}

class _FullScreenMediaDialogState extends State<FullScreenMediaDialog> {
  late PageController _fullScreenPageController;
  late int _currentIndex;
  final String baseUrl = APIbaseUrl;
  final Map<String, ChewieController> _chewieControllers = {};
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _fullScreenPageController = PageController(initialPage: _currentIndex);
    print('Khởi tạo FullScreenMediaDialog, index ban đầu: $_currentIndex, tổng số media: ${widget.mediaUrls.length}');
  }

  @override
  void dispose() {
    print('Hủy FullScreenMediaDialog');
    _fullScreenPageController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    for (var controller in _chewieControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isVideo(String url) {
    final extension = url.toLowerCase().split('.').last;
    return ['mp4', 'avi'].contains(extension);
  }

  Future<ChewieController?> _getChewieController(String url) async {
    if (!_chewieControllers.containsKey(url)) {
      final fullUrl = _buildImageUrl(url);
      final videoController = VideoPlayerController.network(fullUrl);
      _videoControllers[url] = videoController;

      try {
        await videoController.initialize().timeout(Duration(seconds: 15), onTimeout: () {
          throw TimeoutException('Video initialization timeout: $fullUrl');
        });
        print('Video initialized successfully: $fullUrl');

        final chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                'Lỗi phát video: $errorMessage',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        );
        _chewieControllers[url] = chewieController;
      } catch (error, stackTrace) {
        print('Lỗi khởi tạo video $fullUrl: $error');
        print('Stack trace: $stackTrace');
        videoController.dispose();
        _videoControllers.remove(url);
        return null;
      }
    }
    return _chewieControllers[url];
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        print('Chuyển sang media trước đó, index mới: $_currentIndex');
        _fullScreenPageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _nextImage() {
    if (_currentIndex < widget.mediaUrls.length - 1) {
      setState(() {
        _currentIndex++;
        print('Chuyển sang media tiếp theo, index mới: $_currentIndex');
        _fullScreenPageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.9),
      child: Stack(
        children: [
          Center(
            child: PageView.builder(
              controller: _fullScreenPageController,
              itemCount: widget.mediaUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  print('Trang thay đổi, index mới: $_currentIndex');
                });
              },
              itemBuilder: (context, index) {
                final mediaUrl = _buildImageUrl(widget.mediaUrls[index]);
                print('Đang tải media toàn màn hình tại index $index: $mediaUrl');
                if (_isVideo(widget.mediaUrls[index])) {
                  return FutureBuilder<ChewieController?>(
                    future: _getChewieController(widget.mediaUrls[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(
                          child: Text(
                            'Không thể tải video',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return Chewie(controller: snapshot.data!);
                    },
                  );
                } else {
                  return Center(
                    child: Image.network(
                      mediaUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          print('Ảnh toàn màn hình tải thành công: $mediaUrl');
                          return child;
                        }
                        print('Đang tải ảnh toàn màn hình: $mediaUrl, tiến độ: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Lỗi khi tải ảnh toàn màn hình: $error, URL: $mediaUrl');
                        if (stackTrace != null) {
                          print('Stack trace: $stackTrace');
                        }
                        return const Icon(Icons.error, color: Colors.white, size: 50);
                      },
                    ),
                  );
                }
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                print('Đóng FullScreenMediaDialog');
                Navigator.of(context).pop();
              },
            ),
          ),
          if (widget.mediaUrls.length > 1) ...[
            if (_currentIndex > 0)
              Positioned(
                left: 10,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                  onPressed: _previousImage,
                ),
              ),
            if (_currentIndex < widget.mediaUrls.length - 1)
              Positioned(
                right: 10,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                  onPressed: _nextImage,
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
                count: widget.mediaUrls.length,
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
  }

  String _buildImageUrl(String mediaPath) {
    return '$baseUrl/reportimage/$mediaPath';
  }
}