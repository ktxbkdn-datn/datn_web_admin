import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:datn_web_admin/feature/notification/presentation/pages/noti_tab/local_notification_storage';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

import '../../../../../common/constants/api_string.dart';
import '../../../../../common/constants/colors.dart';
import '../../../../../common/widget/filter_tab.dart';
import '../../../../../common/widget/search_bar.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../bloc/noti/notification_bloc.dart';
import '../../bloc/noti/notification_event.dart';
import '../../bloc/noti/notification_state.dart';
import '../../bloc/noti_media/notification_media_bloc.dart';
import '../../bloc/noti_media/notification_media_event.dart';
import '../../bloc/noti_media/notification_media_state.dart';

import 'create_notification_dialog.dart';
import 'full_screen_media_dialog.dart';
import 'notification_item.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  NotificationListPageState createState() => NotificationListPageState();
}

class NotificationListPageState extends State<NotificationListPage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String _filterTargetType = 'ALL'; // Giá trị API: ALL, ROOM, USER
  String _searchQuery = '';
  bool _isProcessing = false;
  bool _isDataLoaded = false;
  final String baseUrl = APIbaseUrl;
  final Map<String, ChewieController> _chewieControllers = {};
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<int, PageController> _pageControllers = {};
  List<Notification> _localNotifications = [];
  String? _authToken;
  final Map<int, List<MediaInfo>> _mediaCache = {};
  final LocalNotificationStorage _storage = LocalNotificationStorage();

  // Ánh xạ target_type sang nhãn hiển thị tiếng Việt
  String _getFilterDisplayText(String targetType) {
    switch (targetType.toUpperCase()) {
      case 'ALL':
        return 'Tất cả';
      case 'USER':
        return 'Cá nhân';
      case 'ROOM':
        return 'Phòng';
      default:
        return targetType;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  @override
  void dispose() {
    _chewieControllers.forEach((_, controller) => controller.dispose());
    _chewieControllers.clear();
    _videoControllers.forEach((_, controller) => controller.dispose());
    _videoControllers.clear();
    _pageControllers.forEach((_, controller) => controller.dispose());
    _pageControllers.clear();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalData() async {
    try {
      setState(() {
        _isProcessing = true;
      });
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      // Kiểm tra và sửa giá trị lưu trữ
      final storedFilter = await _storage.loadFilterType();
      print('Loaded filter from storage: $storedFilter');
      _filterTargetType = ['ALL', 'ROOM', 'USER'].contains(storedFilter) ? storedFilter! : 'ALL';
      // Xóa giá trị không hợp lệ
      if (storedFilter != null && !['ALL', 'ROOM', 'USER'].contains(storedFilter)) {
        await _storage.saveFilterType('ALL');
        _filterTargetType = 'ALL';
        print('Cleared invalid stored filter, set to ALL');
      }
      _searchQuery = await _storage.loadSearchQuery();
      final notificationsWithMedia = await _storage.loadNotifications();
      _localNotifications = notificationsWithMedia.map((item) {
        final notification = Notification.fromJson(item['notification']);
        if (notification.notificationId != null && item['media'] != null) {
          final mediaItems = (item['media'] as List<dynamic>)
              .map((media) => MediaInfo.fromJson(media as Map<String, dynamic>))
              .toList();
          _mediaCache[notification.notificationId!] = mediaItems;
          print('Đã tải phương tiện cho thông báo ${notification.notificationId}: $mediaItems');
        }
        return notification;
      }).toList();

      if (_authToken == null) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thiếu mã xác thực. Vui lòng đăng nhập lại.')),
        );
      } else {
        _fetchNotifications();
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu cục bộ: $e');
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu cục bộ: $e')),
      );
    }
  }

  Future<void> _saveLocalData(List<Notification> notifications) async {
    try {
      final notificationsWithMedia = notifications.map((notification) {
        return {
          'notification': notification.toJson(),
          'media': (_mediaCache[notification.notificationId] ?? notification.media ?? []),
        };
      }).toList();
      await _storage.saveNotifications(notificationsWithMedia);
      await _storage.saveFilterType(_filterTargetType);
      print('Saved filter to storage: $_filterTargetType');
      await _storage.saveSearchQuery(_searchQuery);
      setState(() {
        _localNotifications = notifications;
        _localNotifications.sort((a, b) {
          final dateA = a.createdAt ?? '1970-01-01';
          final dateB = b.createdAt ?? '1970-01-01';
          return DateTime.parse(dateB).compareTo(DateTime.parse(dateA));
        });
      });
    } catch (e) {
      print('Lỗi khi lưu dữ liệu cục bộ: $e');
    }
  }

  void _fetchNotifications() {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    print('Gửi GetAllNotificationsEvent với targetType: $_filterTargetType');
    context.read<NotificationBloc>().add(GetAllNotificationsEvent(
      page: 1,
      limit: 50,
      targetType: _filterTargetType,
    ));
  }

  void _fetchMediaForNotifications(List<Notification> notifications) {
    for (var notification in notifications) {
      if (notification.notificationId != null && !_mediaCache.containsKey(notification.notificationId)) {
        context.read<NotificationMediaBloc>().add(GetNotificationMediaEvent(
          notificationId: notification.notificationId!,
          page: 1,
          limit: 10,
        ));
      }
    }
  }

  void _showFullScreenMedia(
      BuildContext context, List<MediaInfo> mediaItems, int initialIndex, int notificationId) {
    if (_isProcessing) return;

    if (mediaItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có phương tiện hợp lệ để hiển thị'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Hiển thị phương tiện toàn màn hình tại chỉ số: $initialIndex, ID thông báo: $notificationId, tổng phương tiện: ${mediaItems.length}');
    showDialog(
      context: context,
      builder: (context) => FullScreenMediaDialog(
        mediaItems: mediaItems
            .map((media) => {
                  'media_url': media.mediaUrl,
                  'file_type': media.fileType ?? 'image',
                  'filename': media.filename,
                })
            .toList(),
        initialIndex: initialIndex,
        chewieControllers: _chewieControllers,
        videoControllers: _videoControllers,
        baseUrl: baseUrl,
      ),
    );
  }

  String? _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'Không xác định';
    try {
      final utcDateTime = DateTime.parse(dateTime);
      final vnDateTime = utcDateTime.add(const Duration(hours: 7));
      return DateFormat('dd/MM/yyyy HH:mm').format(vnDateTime);
    } catch (e) {
      print('Lỗi định dạng ngày: $e');
      return 'Ngày không hợp lệ';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 960,
              minHeight: 600,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: MultiBlocListener(
                listeners: [
                  BlocListener<NotificationBloc, NotificationState>(
                    listener: (context, state) {
                      if (state is NotificationError) {
                        setState(() {
                          _isProcessing = false;
                          _isDataLoaded = true;
                          // Sửa lỗi target_type
                          if (state.message.contains('target_type')) {
                            _filterTargetType = 'ALL';
                            _saveLocalData(_localNotifications);
                            // Tự động thử lại
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _fetchNotifications();
                            });
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: ${state.message}'),
                            action: SnackBarAction(
                              label: 'Thử lại',
                              onPressed: _fetchNotifications,
                            ),
                          ),
                        );
                      } else if (state is NotificationDeleted) {
                        setState(() {
                          _isProcessing = false;
                        });
                        if (state.notificationId != null) {
                          _mediaCache.remove(state.notificationId);
                          _localNotifications.removeWhere((notification) => notification.notificationId == state.notificationId);
                          _saveLocalData(_localNotifications);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Xóa thông báo thành công!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          _fetchNotifications();
                        }
                      } else if (state is NotificationCreated) {
                        setState(() {
                          _isProcessing = false;
                        });
                        _fetchNotifications();
                      } else if (state is NotificationsLoaded) {
                        setState(() {
                          _isProcessing = false;
                          _isDataLoaded = true;
                        });
                        _localNotifications = state.notifications;
                        for (var notification in state.notifications) {
                          if (notification.notificationId != null) {
                            _mediaCache[notification.notificationId!] = notification.media ?? [];
                          }
                        }
                        _saveLocalData(state.notifications);
                        _fetchMediaForNotifications(state.notifications);
                      }
                    },
                  ),
                  BlocListener<NotificationMediaBloc, NotificationMediaState>(
                    listener: (context, state) {
                      if (state is NotificationMediaLoaded) {
                        setState(() {
                          _mediaCache[state.notificationId] = state.mediaItems;
                          _localNotifications = _localNotifications.map((notification) {
                            if (notification.notificationId == state.notificationId) {
                              print('Cập nhật phương tiện cho thông báo ${state.notificationId}: ${state.mediaItems}');
                              return Notification(
                                notificationId: notification.notificationId,
                                title: notification.title,
                                message: notification.message,
                                targetType: notification.targetType,
                                createdAt: notification.createdAt,
                                isDeleted: notification.isDeleted,
                                deletedAt: notification.deletedAt,
                                uploadedMedia: notification.uploadedMedia,
                                failedUploads: notification.failedUploads,
                                media: state.mediaItems,
                              );
                            }
                            return notification;
                          }).toList();
                          _saveLocalData(_localNotifications);
                        });
                      } else if (state is NotificationMediaError) {
                        setState(() {
                          _mediaCache[state.notificationId] = [];
                          _localNotifications = _localNotifications.map((notification) {
                            if (notification.notificationId == state.notificationId) {
                              print('Không thể tải phương tiện cho thông báo ${state.notificationId}: ${state.message}');
                              return Notification(
                                notificationId: notification.notificationId,
                                title: notification.title,
                                message: notification.message,
                                targetType: notification.targetType,
                                createdAt: notification.createdAt,
                                isDeleted: notification.isDeleted,
                                deletedAt: notification.deletedAt,
                                uploadedMedia: notification.uploadedMedia,
                                failedUploads: notification.failedUploads,
                                media: [],
                              );
                            }
                            return notification;
                          }).toList();
                          _saveLocalData(_localNotifications);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi khi tải phương tiện: ${state.message}')),
                        );
                      }
                    },
                  ),
                ],
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    print('Trạng thái BLoC: $state, _isDataLoaded: $_isDataLoaded');
                    if (!_isDataLoaded || state is NotificationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filteredNotifications = _localNotifications.where((notification) {
                      try {
                        bool matchesTargetType =
                            _filterTargetType == 'ALL' || notification.targetType == _filterTargetType;
                        bool matchesSearch = _searchQuery.isEmpty ||
                            (notification.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                            (notification.message?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
                        return matchesTargetType && matchesSearch;
                      } catch (e) {
                        print('Lỗi khi lọc thông báo: $e');
                        return false;
                      }
                    }).toList();

                    if (filteredNotifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Không còn thông báo'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isProcessing ? null : _fetchNotifications,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      );
                    }

                    final screenWidth = MediaQuery.of(context).size.width;
                    final horizontalPadding = screenWidth > 1200 ? screenWidth * 0.1 : 16.0;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      FilterTab(
                                        label: _getFilterDisplayText('ALL'),
                                        isSelected: _filterTargetType == 'ALL',
                                        onTap: () {
                                          if (_isProcessing) return;
                                          setState(() {
                                            _filterTargetType = 'ALL';
                                            _saveLocalData(_localNotifications);
                                            _fetchNotifications();
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      FilterTab(
                                        label: _getFilterDisplayText('USER'),
                                        isSelected: _filterTargetType == 'USER',
                                        onTap: () {
                                          if (_isProcessing) return;
                                          setState(() {
                                            _filterTargetType = 'USER';
                                            _saveLocalData(_localNotifications);
                                            _fetchNotifications();
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      FilterTab(
                                        label: _getFilterDisplayText('ROOM'),
                                        isSelected: _filterTargetType == 'ROOM',
                                        onTap: () {
                                          if (_isProcessing) return;
                                          setState(() {
                                            _filterTargetType = 'ROOM';
                                            _saveLocalData(_localNotifications);
                                            _fetchNotifications();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: SearchBarTab(
                                        onChanged: (value) {
                                          if (_isProcessing) return;
                                          setState(() {
                                            _searchQuery = value;
                                            _saveLocalData(_localNotifications);
                                            context.read<NotificationBloc>().add(SearchNotificationsEvent(
                                              keyword: _searchQuery,
                                              page: 1,
                                              limit: 50,
                                            ));
                                          });
                                        },
                                        hintText: 'Tìm kiếm thông báo...',
                                        initialValue: _searchQuery,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: _isProcessing ? null : _fetchNotifications,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Làm mới'),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: _isProcessing
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _isProcessing = true;
                                                  });
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => CreateNotificationDialog(),
                                                  ).then((_) {
                                                    setState(() {
                                                      _isProcessing = false;
                                                    });
                                                  });
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          icon: const Icon(Icons.add),
                                          label: const Text('Tạo thông báo'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                            itemCount: filteredNotifications.length,
                            itemBuilder: (context, index) {
                              try {
                                final notification = filteredNotifications[index];
                                final mediaItems = _mediaCache[notification.notificationId] ?? notification.media ?? [];
                                print('Hiển thị thông báo ${notification.notificationId} với phương tiện: $mediaItems');
                                return NotificationItem(
                                  notification: notification,
                                  pageControllers: _pageControllers,
                                  chewieControllers: _chewieControllers,
                                  videoControllers: _videoControllers,
                                  showFullScreenMedia: (context, _, initialIndex, notificationId) {
                                    _showFullScreenMedia(context, mediaItems, initialIndex, notificationId);
                                  },
                                  formatDateTime: _formatDateTime,
                                  baseUrl: baseUrl,
                                  onDelete: _isProcessing
                                      ? null
                                      : () {
                                          setState(() {
                                            _isProcessing = true;
                                          });
                                          context.read<NotificationBloc>().add(
                                              DeleteNotificationEvent(notificationId: notification.notificationId!));
                                        },
                                );
                              } catch (e) {
                                print('Lỗi khi hiển thị mục thông báo tại chỉ số $index: $e');
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}