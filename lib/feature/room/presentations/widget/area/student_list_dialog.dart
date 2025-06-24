import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_saver/file_saver.dart';
import '../../../domain/entities/area_entity.dart';
import '../../bloc/area_bloc/area_bloc.dart';
import '../../bloc/area_bloc/area_event.dart';
import '../../bloc/area_bloc/area_state.dart';

class StudentListDialog extends StatefulWidget {
  final AreaEntity? area; // Null nếu xem tất cả sinh viên
  
  const StudentListDialog({
    Key? key, 
    this.area,
  }) : super(key: key);

  @override
  _StudentListDialogState createState() => _StudentListDialogState();
}

class _StudentListDialogState extends State<StudentListDialog> {  
  // Biến này đánh dấu khi nào nút "Tải Excel" được nhấn
  bool _isExportRequested = false;

  @override
  void initState() {
    super.initState();
    if (widget.area != null) {
      // Lấy danh sách sinh viên theo khu vực
      context.read<AreaBloc>().add(GetUsersInAreaEvent(widget.area!.areaId));
    } else {
      // Lấy tất cả sinh viên
      context.read<AreaBloc>().add(GetAllUsersInAllAreasEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.area != null
        ? 'Danh sách sinh viên - ${widget.area!.name}'
        : 'Danh sách tất cả sinh viên';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isExportRequested = true;
                        });
                        if (widget.area != null) {
                          context.read<AreaBloc>().add(ExportUsersInAreaEvent(widget.area!.areaId));
                        } else {
                          context.read<AreaBloc>().add(ExportAllUsersInAllAreasEvent());
                        }
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Tải Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 16),            Expanded(
              child: BlocListener<AreaBloc, AreaState>(
                listener: (context, state) {
                  // Chỉ tải file nếu đã có yêu cầu xuất file từ nút "Tải Excel" trong dialog
                  if (state.exportFile != null && _isExportRequested) {
                    try {
                      final filename = widget.area != null
                          ? 'danh_sach_sv_${widget.area!.name}.xlsx'
                          : 'danh_sach_tat_ca_sv.xlsx';
                          
                      FileSaver.instance.saveFile(
                        name: filename,
                        bytes: state.exportFile!,
                        ext: 'xlsx',
                        mimeType: MimeType.microsoftExcel,
                      );
                      
                      // Reset lại cờ đánh dấu đã xử lý yêu cầu xuất file
                      setState(() {
                        _isExportRequested = false;
                      });
                      
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
                child: BlocBuilder<AreaBloc, AreaState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (state.error != null) {
                      return Center(child: Text('Lỗi: ${state.error}'));
                    }
                    
                    List<Map<String, dynamic>>? usersList;
                    
                    if (widget.area != null) {
                      usersList = state.usersInArea;
                    } else {
                      usersList = state.allUsersInAllAreas;
                    }
                    
                    if (usersList == null || usersList.isEmpty) {
                      return const Center(
                        child: Text('Không có sinh viên nào'),
                      );
                    }
                    
                    return SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Họ tên')),
                          DataColumn(label: Text('MSSV')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('SĐT')),
                          DataColumn(label: Text('Quê quán')),
                        ],
                        rows: usersList.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(Text(user['fullname'] ?? 'N/A')),
                              DataCell(Text(user['student_code'] ?? 'N/A')),
                              DataCell(Text(user['email'] ?? 'N/A')),
                              DataCell(Text(user['phone'] ?? 'N/A')),
                              DataCell(Text(user['hometown'] ?? 'N/A')),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}