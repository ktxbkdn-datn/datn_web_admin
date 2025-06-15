// lib/src/features/report/presentations/widgets/report_detail_dialog.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:datn_web_admin/common/constants/api_string.dart';
import 'package:datn_web_admin/feature/report/domain/entities/report_entity.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../bloc/report/report_bloc.dart';
import '../../../bloc/report/report_event.dart';
import '../../../bloc/report/report_state.dart';
import '../../../bloc/rp_image/rp_image_bloc.dart';
import '../../../bloc/rp_image/rp_image_event.dart';
import '../../../bloc/rp_image/rp_image_state.dart';
import 'full_screen_image.dart';

final String baseUrl = APIbaseUrl;

class ReportDetailDialog extends StatefulWidget {
  final ReportEntity report;

  const ReportDetailDialog({Key? key, required this.report}) : super(key: key);

  @override
  _ReportDetailDialogState createState() => _ReportDetailDialogState();
}

class _ReportDetailDialogState extends State<ReportDetailDialog> {
  final PageController _pageController = PageController();
  String? _selectedStatus;
  ReportEntity? _updatedReport;
  final Map<String, ChewieController> _chewieControllers = {};
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.report.status;
    // Nếu trạng thái là PENDING thì tự động chuyển sang RECEIVED
    if (widget.report.status == 'PENDING') {
      context.read<ReportBloc>().add(UpdateReportStatusEvent(
        reportId: widget.report.reportId,
        status: 'RECEIVED',
      ));
      _selectedStatus = 'RECEIVED';
    }
    context.read<ReportImageBloc>().add(ResetReportImageStateEvent());
    context.read<ReportImageBloc>().add(GetReportImagesEvent(widget.report.reportId));
    context.read<ReportBloc>().add(GetReportByIdEvent(widget.report.reportId));
  }

  @override
  void dispose() {
    print('Hủy ReportDetailDialog cho report ID: ${widget.report.reportId}');
    _pageController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    for (var controller in _chewieControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showFullScreenMedia(BuildContext context, List<String> mediaUrls, int initialIndex) {
    print('Hiển thị media toàn màn hình tại index: $initialIndex, tổng số media: ${mediaUrls.length}');
    print('Danh sách URL media: $mediaUrls');
    showDialog(
      context: context,
      builder: (context) => FullScreenMediaDialog(
        mediaUrls: mediaUrls,
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
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportUpdated) {
          Navigator.of(context).pop(); // Đóng dialog khi cập nhật thành công
          // Có thể show SnackBar nếu muốn
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật trạng thái thành công!')),
          );
        }
        if (state is ReportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${state.message}')),
          );
        }
      },
      child: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReportError) {
            return Center(child: Text('${state.message}'));
          }

          if (state is ReportLoaded) {
            _updatedReport = state.report;
            print('Dữ liệu report đã cập nhật: ${state.report.toJson()}');
            _selectedStatus = state.report.status;
          }

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
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 50),
                        BlocBuilder<ReportImageBloc, ReportImageState>(
                          builder: (context, imageState) {
                            List<String> mediaUrls = [];
                            bool isLoading = false;
                            String? errorMessage;

                            print('Trạng thái ReportImageBloc: $imageState');
                            if (imageState is ReportImageInitial) {
                              isLoading = true;
                            } else if (imageState is ReportImageLoading) {
                              isLoading = true;
                              print('Đang tải media...');
                            } else if (imageState is ReportImagesLoaded) {
                              mediaUrls = imageState.imageUrls;
                              print('Media đã tải: $mediaUrls');
                            } else if (imageState is ReportImageError) {
                              errorMessage = 'Không tải được media do lỗi hệ thống, vui lòng thử lại sau.';
                              print('Lỗi nghiêm trọng khi tải media: ${imageState.message}');
                            }

                            return Column(
                              children: [
                                if (isLoading)
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    child: const Center(child: CircularProgressIndicator()),
                                  )
                                else if (errorMessage != null) ...[
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    width: double.infinity,
                                    color: Colors.grey[100],
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 50,
                                          color: Colors.red[400],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          errorMessage,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            print('Thử lại tải media cho report ID: ${widget.report.reportId}');
                                            context.read<ReportImageBloc>().add(GetReportImagesEvent(widget.report.reportId));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Thử lại',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ] else if (mediaUrls.isEmpty) ...[
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    width: double.infinity,
                                    color: Colors.grey[100],
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Báo cáo này chưa có hình ảnh hoặc video',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
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
                                          itemCount: mediaUrls.length,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            final mediaUrl = _buildImageUrl(mediaUrls[index]);
                                            print('Đang tải media tại index $index: $mediaUrl');
                                            if (_isVideo(mediaUrls[index])) {
                                              return FutureBuilder<ChewieController?>(
                                                future: _getChewieController(mediaUrls[index]),
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
                                                  _showFullScreenMedia(context, mediaUrls, index);
                                                },
                                                child: Image.network(
                                                  mediaUrl,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      print('Ảnh đã tải thành công: $mediaUrl');
                                                      return child;
                                                    }
                                                    print('Đang tải ảnh: $mediaUrl, tiến độ: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
                                                    return const Center(child: CircularProgressIndicator());
                                                  },
                                                  errorBuilder: (context, error, stackTrace) {
                                                    print('Lỗi khi tải ảnh: $error, URL: $mediaUrl');
                                                    if (stackTrace != null) {
                                                      print('Stack trace: $stackTrace');
                                                    }
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
                                            print('Chuyển sang media trước đó');
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
                                            print('Chuyển sang media tiếp theo');
                                            _pageController.nextPage(
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                        ),
                                      ),
                                      if (mediaUrls.length > 1)
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
                                    count: mediaUrls.length,
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
                                            _buildInfoRow(Icons.star, 'Tiêu đề: ${(_updatedReport ?? widget.report).title}', Colors.black),
                                            const SizedBox(height: 10),
                                            _buildInfoRow(Icons.person, 'Người gửi: ${(_updatedReport ?? widget.report).userFullname ?? 'N/A'}', Colors.black),
                                            const SizedBox(height: 10),
                                            _buildInfoRow(Icons.description, 'Mô tả: ${(_updatedReport ?? widget.report).description ?? 'Chưa có mô tả'}', Colors.black),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildInfoRow(Icons.info, 'Trạng thái: ${_getStatusDisplayText((_updatedReport ?? widget.report).status)}', _getStatusColor((_updatedReport ?? widget.report).status)),
                                            const SizedBox(height: 10),
                                            _buildInfoRow(Icons.calendar_today, 'Ngày tạo: ${_formatDateTime((_updatedReport ?? widget.report).createdAt) ?? 'N/A'}', Colors.black),
                                            const SizedBox(height: 10),
                                            _buildInfoRow(Icons.calendar_today, 'Ngày đóng: ${_formatDateTime((_updatedReport ?? widget.report).closedAt) ?? 'Chưa đóng'}', Colors.black),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildInfoRow(Icons.message, 'Loại báo cáo: ${(_updatedReport ?? widget.report).reportTypeName ?? 'N/A'}', Colors.black),
                                            const SizedBox(height: 10),
                                            _buildInfoRow(Icons.location_on, 'Phòng: ${(_updatedReport ?? widget.report).roomName ?? 'N/A'} (${(_updatedReport ?? widget.report).areaName ?? 'N/A'})', Colors.black),
                                            const SizedBox(height: 10),
                                            _buildStatusDropdown(),
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
                      ],
                    ),
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
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Fetch reports again to ensure the list is up-to-date
                          context.read<ReportBloc>().add(const GetAllReportsEvent(page: 1, limit: 1000));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  Widget _buildStatusDropdown() {
    return Row(
      children: [
        const Icon(Icons.settings, color: Colors.black),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedStatus,
            isExpanded: true,
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
            items: const [
              DropdownMenuItem<String>(
                value: 'PENDING',
                child: Text('Chưa tiếp nhận'),
              ),
              DropdownMenuItem<String>(
                value: 'RECEIVED',
                child: Text('Đã tiếp nhận'),
              ),
              DropdownMenuItem<String>(
                value: 'IN_PROGRESS',
                child: Text('Đang xử lý'),
              ),
              DropdownMenuItem<String>(
                value: 'RESOLVED',
                child: Text('Đã giải quyết'),
              ),
              DropdownMenuItem<String>(
                value: 'CLOSED',
                child: Text('Hoàn tất'),
              ),
            ],
            onChanged: (value) {
              if (value != null && value != (_updatedReport ?? widget.report).status) {
                setState(() {
                  _selectedStatus = value;
                });
                context.read<ReportBloc>().add(UpdateReportStatusEvent(
                  reportId: widget.report.reportId,
                  status: value,
                ));
                // Không pop dialog ở đây nữa!
              }
            },
          ),
        ),
      ],
    );
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chưa tiếp nhận';
      case 'RECEIVED':
        return 'Đã tiếp nhận';
      case 'IN_PROGRESS':
        return 'Đang xử lý';
      case 'RESOLVED':
        return 'Đã giải quyết';
      case 'CLOSED':
        return 'Hoàn tất';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.grey;
      case 'RECEIVED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _buildImageUrl(String mediaPath) {
    return '$baseUrl/reportimage/$mediaPath';
  }

  String? _formatDateTime(String? dateTime) {
    if (dateTime == null) return null;
    return dateTime.replaceFirst('T', ' ');
  }
}