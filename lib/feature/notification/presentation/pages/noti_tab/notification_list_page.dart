import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:datn_web_admin/common/widget/pagination_controls.dart';
import 'package:datn_web_admin/feature/notification/presentation/pages/noti_tab/local_notification_storage.dart';
import 'package:datn_web_admin/feature/notification/presentation/pages/noti_tab/update_noti_dialog.dart';
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
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _NotificationListView();
  }
}

class _NotificationListView extends StatefulWidget {
  @override
  _NotificationListViewState createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<_NotificationListView> {
  final ScrollController _scrollController = ScrollController();
  String _filterTargetType = 'ALL';
  String _searchQuery = '';
  int _currentPage = 1;
  bool _isProcessing = false;
  final String baseUrl = APIbaseUrl;
  final Map<String, ChewieController> _chewieControllers = {};
  final Map<String, VideoPlayerController> _videoControllers = {};
  final Map<int, PageController> _pageControllers = {};
  final Map<int, List<MediaInfo>> _mediaCache = {};
  Timer? _debounce;
  Notification? _lastUpdatedNotification;

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
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _chewieControllers.forEach((_, controller) => controller.dispose());
    _chewieControllers.clear();
    _videoControllers.forEach((_, controller) => controller.dispose());
    _videoControllers.clear();
    _pageControllers.forEach((_, controller) => controller.dispose());
    _pageControllers.clear();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 1;
        _fetchNotifications();
      });
    });
  }

  void _fetchNotifications() {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    context.read<NotificationBloc>().add(GetAllNotificationsEvent(
      page: _currentPage,
      limit: 10,
      targetType: _filterTargetType,
      keyword: _searchQuery,
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

  void _showFullScreenMedia(BuildContext context, List<MediaInfo> mediaItems, int initialIndex, int notificationId) {
    if (_isProcessing) return;
    if (mediaItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có phương tiện hợp lệ để nhận'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
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
      return 'Ngày không hợp lệ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 1200 ? screenWidth * 0.1 : 16.0;

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
            constraints: const BoxConstraints(minWidth: 960, minHeight: 600),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
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
                                      _currentPage = 1;
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
                                      _currentPage = 1;
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
                                      _currentPage = 1;
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
                                  key: const ValueKey('search_bar'),
                                  onChanged: _onSearchChanged,
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Làm mới'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed: _isProcessing
                                        ? null
                                        : () {
                                            setState(() => _isProcessing = true);
                                            showDialog(
                                              context: context,
                                              builder: (context) => CreateNotificationDialog(),
                                            ).then((_) {
                                              setState(() => _isProcessing = false);
                                              _fetchNotifications();
                                            });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    child: Stack(
                      children: [
                        MultiBlocListener(
                          listeners: [
                            BlocListener<NotificationBloc, NotificationState>(
                              listener: (context, state) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (state is NotificationError) {
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${state.message}'),
                                        action: SnackBarAction(label: 'Thử lại', onPressed: _fetchNotifications),
                                      ),
                                    );
                                  } else if (state is NotificationDeleted) {
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                    _fetchNotifications();
                                  } else if (state is NotificationCreated) {
                                    setState(() {
                                      _isProcessing = false;
                                      _currentPage = 1;
                                    });
                                    _fetchNotifications();
                                  } else if (state is NotificationUpdated) {
                                    setState(() {
                                      _isProcessing = false;
                                      _lastUpdatedNotification = state.notification;
                                    });
                                    // Gọi lại event để lấy danh sách mới (hoặc cập nhật lại UI)
                                    context.read<NotificationBloc>().add(GetAllNotificationsEvent(
                                      page: _currentPage,
                                      limit: 10,
                                      targetType: _filterTargetType,
                                      keyword: _searchQuery,
                                    ));
                                  } else if (state is NotificationsLoaded) {
                                    setState(() {
                                      _isProcessing = false;
                                    });
                                    // Chỉ fetch media nếu không vừa update
                                    if (_lastUpdatedNotification == null) {
                                      _fetchMediaForNotifications(state.notifications);
                                    }
                                  }
                                });
                              },
                            ),
                            BlocListener<NotificationMediaBloc, NotificationMediaState>(
                              listener: (context, state) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (state is NotificationMediaLoaded) {
                                    setState(() {
                                      _mediaCache[state.notificationId] = state.mediaItems;
                                    });
                                  } else if (state is NotificationMediaError) {
                                    setState(() {
                                      _mediaCache[state.notificationId] = [];
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Lỗi khi tải phương tiện: ${state.message}')),
                                    );
                                  }
                                });
                              },
                            ),
                          ],
                          child: Column(
                            children: [
                              Expanded(
                                child: BlocBuilder<NotificationBloc, NotificationState>(
                                  builder: (context, state) {
                                    if (state is NotificationLoading) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    if (state is NotificationsLoaded) {
                                      var notifications = state.notifications;
                                      // Nếu vừa update, cập nhật notification vào list
                                      if (_lastUpdatedNotification != null) {
                                        final idx = notifications.indexWhere((n) => n.notificationId == _lastUpdatedNotification!.notificationId);
                                        if (idx != -1) {
                                          notifications = List<Notification>.from(notifications);
                                          notifications[idx] = _lastUpdatedNotification!;
                                        }
                                        _lastUpdatedNotification = null;
                                      }
                                      final filtered = notifications.where((notification) {
                                        final matchesTargetType = _filterTargetType == 'ALL' || notification.targetType == _filterTargetType;
                                        final matchesSearch = _searchQuery.isEmpty ||
                                            (notification.title.toLowerCase().contains(_searchQuery.toLowerCase())) ||
                                            (notification.message.toLowerCase().contains(_searchQuery.toLowerCase()));
                                        return matchesTargetType && matchesSearch;
                                      }).toList()
                                        ..sort((a, b) {
                                          final dateA = a.createdAt ?? '1970-01-01';
                                          final dateB = b.createdAt ?? '1970-01-01';
                                          return DateTime.parse(dateB).compareTo(DateTime.parse(dateA));
                                        });

                                      if (filtered.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text('Không có thông báo nào'),
                                              const SizedBox(height: 16),
                                              ElevatedButton.icon(
                                                onPressed: _isProcessing ? null : _fetchNotifications,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                icon: const Icon(Icons.refresh),
                                                label: const Text('Thử lại'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return ListView.builder(
                                        controller: _scrollController,
                                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                                        itemCount: filtered.length + 1, // Thêm 1 cho pagination
                                        itemBuilder: (context, index) {
                                          if (index < filtered.length) {
                                            try {
                                              final notification = filtered[index];
                                              final mediaItems = _mediaCache[notification.notificationId] ?? notification.media ?? [];
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
                                                        setState(() => _isProcessing = true);
                                                        context.read<NotificationBloc>().add(
                                                            DeleteNotificationEvent(notificationId: notification.notificationId!));
                                                      },
                                                onEdit: _isProcessing
                                                    ? null
                                                    : () {
                                                        setState(() => _isProcessing = true);
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => UpdateNotificationDialog(
                                                            notification: notification,
                                                          ),
                                                        ).then((_) {
                                                          setState(() => _isProcessing = false);
                                                        });
                                                      },
                                              );
                                            } catch (e) {
                                              return const SizedBox.shrink();
                                            }
                                          } else {
                                            // PaginationControls ở cuối danh sách
                                            int totalItems = 0;
                                            if (state is NotificationsLoaded) {
                                              totalItems = state.totalItems;
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 16, bottom: 8),
                                              child: PaginationControls(
                                                currentPage: _currentPage,
                                                totalItems: totalItems,
                                                limit: 10,
                                                onPageChanged: (page) {
                                                  if (_isProcessing) return;
                                                  setState(() {
                                                    _currentPage = page;
                                                    _fetchNotifications();
                                                  });
                                                },
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    }
                                    if (state is NotificationError) {
                                      return Center(
                                        child: Text('Lỗi: ${state.message}'),
                                      );
                                    }
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isProcessing)
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
