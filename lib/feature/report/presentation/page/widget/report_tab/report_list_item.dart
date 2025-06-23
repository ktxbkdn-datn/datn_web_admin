import 'package:flutter/material.dart';
import '../../../../domain/entities/report_entity.dart';

class ReportListItem extends StatefulWidget {
  final ReportEntity report;
  final VoidCallback? onViewDetail;
  final VoidCallback? onEdit;
  final VoidCallback? onExport;

  const ReportListItem({
    Key? key,
    required this.report,
    this.onViewDetail,
    this.onEdit,
    this.onExport,
  }) : super(key: key);

  @override
  State<ReportListItem> createState() => _ReportListItemState();
}

class _ReportListItemState extends State<ReportListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'Báo cáo hư hỏng':
        return Colors.redAccent;
      case 'Báo cáo vệ sinh':
        return Colors.orangeAccent;
      case 'Báo cáo sự cố':
        return Colors.blueAccent;
      case 'Báo cáo bảo trì':
        return Colors.purpleAccent;
      case 'Báo cáo an ninh':
        return Colors.indigoAccent;
      default:
        return Colors.blueGrey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      case 'URGENT':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'Báo cáo hư hỏng':
        return Icons.build_circle_rounded;
      case 'Báo cáo vệ sinh':
        return Icons.cleaning_services_rounded;
      case 'Báo cáo sự cố':
        return Icons.warning_amber_rounded;
      case 'Báo cáo bảo trì':
        return Icons.handyman_rounded;
      case 'Báo cáo an ninh':
        return Icons.security_rounded;
      default:
        return Icons.report_rounded;
    }
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays == 0) {
        return 'Hôm nay';
      } else if (difference.inDays == 1) {
        return 'Hôm qua';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ngày trước';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateTime.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(widget.report.reportTypeName);
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              transform: Matrix4.identity()..scale(_isHovered ? 1.025 : 1.0),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: typeColor.withOpacity(0.13),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? typeColor.withOpacity(0.18)
                        : Colors.black.withOpacity(0.07),
                    blurRadius: _isHovered ? 22 : 12,
                    offset: Offset(0, _isHovered ? 10 : 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon + Type badge
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.09),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: typeColor.withOpacity(0.22),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            _getTypeIcon(widget.report.reportTypeName),
                            color: typeColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Title, type, status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.report.title ?? 'Không có tiêu đề',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.grey.shade900,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildStatusBadge(widget.report.status ?? ''),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildTypeChip(widget.report.reportTypeName ?? 'Không xác định', typeColor),
                                  // Nếu muốn hiển thị chip khẩn cấp, cần kiểm tra trường khác, ví dụ: status == 'URGENT'
                                  if (widget.report.status == 'URGENT')
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: _buildUrgentChip(),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if ((widget.report.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.report.description ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        // Info chips
                        Expanded(
                          child: Wrap(
                            spacing: 18,
                            runSpacing: 8,
                            children: [
                              _buildInfoChip(
                                icon: Icons.access_time,
                                label: _formatDate(widget.report.createdAt),
                                color: Colors.blue,
                              ),
                              if ((widget.report.roomName ?? '').isNotEmpty)
                                _buildInfoChip(
                                  icon: Icons.meeting_room,
                                  label: widget.report.roomName!,
                                  color: Colors.orange,
                                ),
                              if ((widget.report.areaName ?? '').isNotEmpty)
                                _buildInfoChip(
                                  icon: Icons.location_on,
                                  label: widget.report.areaName!,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        // Action buttons
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildActionButton(
                                icon: Icons.visibility_outlined,
                                tooltip: 'Xem chi tiết',
                                color: Colors.blue,
                                onPressed: widget.onViewDetail,
                              ),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                icon: Icons.edit_outlined,
                                tooltip: 'Chỉnh sửa',
                                color: Colors.orange,
                                onPressed: widget.onEdit,
                              ),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                icon: Icons.download_outlined,
                                tooltip: 'Xuất file',
                                color: Colors.green,
                                onPressed: widget.onExport,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final text = _getStatusDisplayText(status);
    final icon = _getStatusIcon(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
      
  }

  Widget _buildTypeChip(String? type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            type ?? 'Không xác định',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      )
    );
  }

  Widget _buildUrgentChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 13, color: Colors.red),
          const SizedBox(width: 4),
          const Text(
            'Khẩn cấp',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: onPressed != null ? color.withOpacity(0.13) : Colors.grey.withOpacity(0.09),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onPressed != null ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: onPressed != null ? color : Colors.grey,
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'OPEN':
        return Icons.error_outline;
      case 'IN_PROGRESS':
        return Icons.autorenew;
      case 'RESOLVED':
        return Icons.check_circle_outline;
      case 'CLOSED':
        return Icons.lock_outline;
      case 'URGENT':
        return Icons.priority_high;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'OPEN':
        return 'Mở';
      case 'IN_PROGRESS':
        return 'Đang xử lý';
      case 'RESOLVED':
        return 'Đã xử lý';
      case 'CLOSED':
        return 'Đã đóng';
      case 'URGENT':
        return 'Khẩn cấp';
      default:
        return 'Không xác định';
    }
  }
}

// ...existing code for EnhancedReportList...
