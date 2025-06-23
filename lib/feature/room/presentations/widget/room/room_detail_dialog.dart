import 'dart:async';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../../common/constants/api_string.dart';
import '../../../domain/entities/room_entity.dart';
import '../../bloc/room_image_bloc/room_image_bloc.dart';
import '../../bloc/room_image_bloc/room_image_state.dart';
import '../../bloc/room_bloc/room_bloc.dart';


final String baseUrl = APIbaseUrl;

class RoomDetailDialog extends StatefulWidget {
  final RoomEntity room;

  const RoomDetailDialog({Key? key, required this.room}) : super(key: key);

  @override
  _RoomDetailDialogState createState() => _RoomDetailDialogState();
}

class _RoomDetailDialogState extends State<RoomDetailDialog> {
  final PageController _pageController = PageController();
  final Map<String, ChewieController> _chewieControllers = {};
  final Map<String, VideoPlayerController> _videoControllers = {};
  bool _studentsLoaded = false;

  @override
  void initState() {
    super.initState();
    context.read<RoomImageBloc>().add(ResetRoomImageStateEvent());
    context.read<RoomImageBloc>().add(GetRoomImagesEvent(widget.room.roomId));
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    for (var controller in _chewieControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showFullScreenMedia(BuildContext context, List<Map<String, dynamic>> mediaItems, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => FullScreenMediaDialog(
        mediaItems: mediaItems,
        initialIndex: initialIndex,
      ),
    );
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
                style: TextStyle(color: Colors.black),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width < 1200 ? MediaQuery.of(context).size.width * 0.95 : 1200,
        height: MediaQuery.of(context).size.height < 800 ? MediaQuery.of(context).size.height * 0.95 : 800,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: DefaultTabController(
          length: 2,
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 50),
                  TabBar(
                    tabs: const [
                      Tab(text: 'Thông tin phòng'),
                      Tab(text: 'Danh sách sinh viên'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Room details
                        SingleChildScrollView(
                          child: _buildRoomInfoTab(),
                        ),
                        // Tab 2: Students list
                        _buildStudentsTab(),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              BlocListener<RoomBloc, RoomState>(
                listener: (context, state) {
                  if (state is ExportFileReady) {
                    try {
                      FileSaver.instance.saveFile(
                        name: state.filename,
                        bytes: state.fileBytes,
                        ext: 'xlsx',
                        mimeType: MimeType.microsoftExcel,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã tải xuống file Excel thành công!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi khi tải file: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomInfoTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<RoomImageBloc, RoomImageState>(
          builder: (context, imageState) {
            List<Map<String, dynamic>> mediaItems = [];
            bool isLoading = false;
            String? errorMessage;

            if (imageState is RoomImageLoading) {
              isLoading = true;
            } else if (imageState is RoomImagesLoaded) {
              mediaItems = imageState.images.where((item) {
                final url = item['imageUrl'] as String?;
                if (url == null) {
                  print('Invalid image data: imageUrl is null for item $item');
                  return false;
                }
                return true;
              }).toList();
            } else if (imageState is RoomImagesUploaded) {
              mediaItems = imageState.imageUrls.map((url) => {'imageUrl': url}).toList();
            } else if (imageState is RoomImageError) {
              print('RoomImageError: ${imageState.message}');
              errorMessage = 'Không tải được media, vui lòng thử lại.';
            }

            print('Media Items: $mediaItems');

            return Column(
              children: [
                if (isLoading)
                  const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (errorMessage != null) ...[
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else if (mediaItems.isEmpty) ...[
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text(
                        'Chưa có media',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height < 700 ? MediaQuery.of(context).size.height * 0.95 : 700,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: mediaItems.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final mediaUrl = mediaItems[index]['imageUrl'] as String;
                            if (_isVideo(mediaUrl)) {
                              return FutureBuilder<ChewieController?>(
                                future: _getChewieController(mediaUrl),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (snapshot.hasError || !snapshot.hasData) {
                                    return const Center(
                                      child: Text(
                                        'Không thể tải video',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }
                                  return Chewie(controller: snapshot.data!);
                                },
                              );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  _showFullScreenMedia(context, mediaItems, index);
                                },
                                child: Image.network(
                                  _buildImageUrl(mediaUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading image: $error, URL: ${_buildImageUrl(mediaUrl)}');
                                    return const Icon(Icons.error);
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Positioned(
                        left: 10,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                      if (mediaItems.length > 1)
                        Positioned(
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Lướt để xem media tiếp theo',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: mediaItems.length,
                    effect: const WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      activeDotColor: Colors.blue,
                      spacing: 8,
                      dotColor: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.monetization_on, 'Giá: ${widget.room.price} VND', Colors.green),
                            const SizedBox(height: 10),
                            _buildInfoRow(Icons.group, 'Sức chứa: ${widget.room.capacity}', Colors.black),
                            const SizedBox(height: 10),
                            _buildInfoRow(Icons.person, 'Số người hiện tại: ${widget.room.currentPersonNumber}', Colors.black),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.info, 'Trạng thái: ${_getStatusDisplayText(widget.room.status)}', _getStatusColor(widget.room.status)),
                            const SizedBox(height: 10),
                            _buildInfoRow(Icons.location_on, 'Khu vực: ${widget.room.areaDetails?.name ?? 'Chưa có'}', Colors.black),
                            const SizedBox(height: 10),
                            _buildInfoRow(Icons.description, 'Mô tả: ${widget.room.description ?? 'Chưa có mô tả'}', Colors.black),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.star, 'Tên phòng: ${widget.room.name}', Colors.black),
                            const SizedBox(height: 10),
                            _buildInfoRow(Icons.check_circle, 'Thông tin bổ sung: Chưa có', Colors.black),
                            const SizedBox(height: 10),
                            _buildInfoRow(Icons.help, 'Hỗ trợ: Liên hệ quản lý', Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ]
      
    );
    
  }

  Widget _buildStudentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách sinh viên trong phòng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<RoomBloc>().add(ExportUsersInRoomEvent(widget.room.roomId));
                },
                icon: const Icon(Icons.download),
                label: const Text('Xuất Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<RoomBloc, RoomState>(
              builder: (context, state) {
                if (state is RoomLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UsersInRoomLoaded && state.roomId == widget.room.roomId) {
                  if (state.users.isEmpty) {
                    return const Center(
                      child: Text('Không có sinh viên nào trong phòng này'),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(user['fullname']?.substring(0, 1) ?? '?'),
                          ),
                          title: Text(user['fullname'] ?? 'Không có tên'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('MSSV: ${user['student_code'] ?? 'N/A'}'),
                              Text('Email: ${user['email'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: Text('Quê: ${user['hometown'] ?? 'N/A'}'),
                        ),
                      );
                    },
                  );
                } else {
                  // Load students when this tab is shown
                  if (!_studentsLoaded) {
                    _studentsLoaded = true;
                    Future.microtask(() {
                      context.read<RoomBloc>().add(GetUsersInRoomEvent(widget.room.roomId));
                    });
                  }
                  return const Center(child: Text('Đang tải dữ liệu...'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: textColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: textColor),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  // Hàm hiển thị trạng thái bằng tiếng Việt, đồng bộ với room_list_page.dart
  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'AVAILABLE':
        return 'Còn trống';
      case 'OCCUPIED':
        return 'Hết chỗ';
      case 'RESERVED':
        return 'Đã đặt';
      case 'MAINTENANCE':
        return 'Bảo trì';
      case 'DISABLED':
        return 'Không hoạt động';
      default:
        return 'Không xác định';
    }
  }

  // Hàm lấy màu trạng thái, đồng bộ với room_list_page.dart
  Color _getStatusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return Colors.green;
      case 'OCCUPIED':
        return Colors.blue;
      case 'RESERVED':
        return Colors.yellow;
      case 'MAINTENANCE':
        return Colors.red;
      case 'DISABLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _buildImageUrl(String imagePath) {
    return '$baseUrl/roomimage/$imagePath';
  }
}

class FullScreenMediaDialog extends StatefulWidget {
  final List<Map<String, dynamic>> mediaItems;
  final int initialIndex;

  const FullScreenMediaDialog({
    Key? key,
    required this.mediaItems,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenMediaDialogState createState() => _FullScreenMediaDialogState();
}

class _FullScreenMediaDialogState extends State<FullScreenMediaDialog> {
  late PageController _fullScreenPageController;
  late int _currentIndex;
  final Map<String, ChewieController> _chewieControllers = {};
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _fullScreenPageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
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

  void _previousMedia() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _fullScreenPageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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
              itemCount: widget.mediaItems.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final mediaUrl = widget.mediaItems[index]['imageUrl'] as String;
                if (_isVideo(mediaUrl)) {
                  return FutureBuilder<ChewieController?>(
                    future: _getChewieController(mediaUrl),
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
                  return Image.network(
                    _buildImageUrl(mediaUrl),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading full-screen image: $error, URL: ${_buildImageUrl(mediaUrl)}');
                      return const Icon(Icons.error, color: Colors.white, size: 50);
                    },
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
  }

  String _buildImageUrl(String imagePath) {
    return '$baseUrl/roomimage/$imagePath';
  }
}