import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/domain/models/ncd_models.dart';
import 'package:mobile_app_standard/feature/auth/pages/user_type_selection_page.dart';
import 'package:mobile_app_standard/feature/nurse/bloc/village_bloc.dart';
import 'package:mobile_app_standard/feature/nurse/pages/nurse_add_edit_vhv_page.dart';
import 'package:mobile_app_standard/feature/nurse/pages/nurse_patient_list_page.dart';
import 'package:mobile_app_standard/feature/nurse/pages/nurse_vhv_list_page.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';

class NurseVillageListPage extends StatefulWidget {
  final Nurse nurse;

  const NurseVillageListPage({super.key, required this.nurse});

  @override
  State<NurseVillageListPage> createState() => _NurseVillageListPageState();
}

class _NurseVillageListPageState extends State<NurseVillageListPage> {
  @override
  void initState() {
    super.initState();
    context.read<VillageBloc>().add(VillageListLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: PColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const UserTypeSelectionPage()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'หมู่บ้าน',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
            tooltip: 'เพิ่ม อสม.',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NurseAddEditVhvPage(nurse: widget.nurse),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Nurse Area Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: PColor.primaryDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ผู้ใช้: ${widget.nurse.fullName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'พื้นที่: ท่าตอน • แม่อาย • เชียงใหม่',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          // Village List
          Expanded(
            child: BlocBuilder<VillageBloc, VillageState>(
              builder: (context, state) {
                if (state.status == VillageStatus.loading && state.villages.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: PColor.primaryColor));
                }

                if (state.villages.isEmpty) {
                  return const Center(child: Text('ไม่พบข้อมูลหมู่บ้าน'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.villages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final village = state.villages[index];
                    return _buildVillageCard(context, village);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVillageCard(BuildContext context, Village village) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            _showVillageActionSheet(context, village);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: PColor.primaryLight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_city_rounded, color: PColor.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'หมู่ ${village.villageNumber} ${village.villageName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: PColor.contentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'กดเพื่อดูรายชื่อ อสม. หรือ ผู้ป่วยในหมู่บ้าน',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: PColor.textNeutralColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFBDBDBD),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVillageActionSheet(BuildContext context, Village village) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'หมู่ ${village.villageNumber} ${village.villageName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: PColor.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PColor.primaryLight.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.volunteer_activism_rounded, color: PColor.primaryColor),
                  ),
                  title: const Text('รายชื่อ อสม. ในหมู่บ้าน', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('ดูข้อมูลและจัดการ อสม. ประจำหมู่บ้านนี้'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NurseVhvListPage(
                          nurse: widget.nurse,
                          village: village,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.people_outline_rounded, color: Colors.blue),
                  ),
                  title: const Text('รายชื่อผู้ป่วยในหมู่บ้าน', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('ดูรายชื่อผู้ป่วยและผลการคัดกรองความเสี่ยง'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NursePatientListPage(
                          nurse: widget.nurse,
                          village: village,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
