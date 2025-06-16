import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/stat_page/room_stat_page.dart';
import '../widgets/stat_page/user_stat_page.dart';
import '../widgets/stat_page/report_stat_page.dart';

class StatisticsOverviewPage extends StatefulWidget {
  const StatisticsOverviewPage({Key? key}) : super(key: key);

  @override
  State<StatisticsOverviewPage> createState() => _StatisticsOverviewPageState();
}

class _StatisticsOverviewPageState extends State<StatisticsOverviewPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    RoomStatsPage(),
    UserStatsPage(),
    ReportStatsPage(),
  ];

  final List<String> _titles = const [
    'Thống kê phòng',
    'Tỉ lệ lấp đầy',
    'Thống kê báo cáo',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
                _controller.jumpToPage(index);
              },
              labelType: NavigationRailLabelType.all,
              leading: IconButton(
                icon: const Icon(Iconsax.home),
                tooltip: 'Quay lại',
                onPressed: () => Navigator.pop(context),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.house),
                  label: Text('Phòng'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Lấp đầy'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.report),
                  label: Text('Báo cáo'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                children: [
                  // Hiển thị tiêu đề nhỏ phía trên mỗi trang
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(_titles[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const Expanded(child: RoomStatsPage()),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(_titles[1], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const Expanded(child: UserStatsPage()),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(_titles[2], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const Expanded(child: ReportStatsPage()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}