import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/domain/models/ncd_models.dart';
import 'package:mobile_app_standard/domain/models/village_analytics.dart';
import 'package:mobile_app_standard/feature/auth/pages/user_type_selection_page.dart';
import 'package:mobile_app_standard/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:mobile_app_standard/feature/nurse/bloc/village_bloc.dart';
import 'package:mobile_app_standard/feature/nurse/pages/nurse_add_edit_vhv_page.dart';
import 'package:mobile_app_standard/feature/nurse/pages/nurse_patient_list_page.dart';
import 'package:mobile_app_standard/feature/nurse/pages/nurse_vhv_list_page.dart';
import 'package:mobile_app_standard/feature/nurse/pages/nurse_vhv_detail_page.dart';
import 'package:mobile_app_standard/feature/patient/pages/patient_detail_page.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app_standard/domain/repositories/ncd_repository.dart';
import 'package:mobile_app_standard/domain/services/health_data_export_service.dart';
import 'package:mobile_app_standard/locator.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';
import 'package:mobile_app_standard/shared/widgets/sync_badge_widget.dart';

class NurseVillageListPage extends StatefulWidget {
  final Nurse nurse;

  const NurseVillageListPage({super.key, required this.nurse});

  @override
  State<NurseVillageListPage> createState() => _NurseVillageListPageState();
}

class _NurseVillageListPageState extends State<NurseVillageListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<VillageBloc>().add(VillageListLoadRequested());
    context
        .read<VillageAnalyticsBloc>()
        .add(const VillageAnalyticsLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showExportDataDialog(BuildContext context) {
    ExportPrivacyMode selectedMode = ExportPrivacyMode.anonymized;
    final passwordController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.file_download_rounded, color: PColor.primaryColor),
              SizedBox(width: 8),
              Text(
                'ส่งออกข้อมูลสุขภาพ (Excel/CSV)',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'เลือกรูปแบบความเป็นส่วนตัวตามมาตรฐานสาธารณสุข:',
                  style: TextStyle(fontSize: 13.5, color: PColor.textSecondary),
                ),
                const SizedBox(height: 12),
                RadioListTile<ExportPrivacyMode>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('โหมดนิรนาม สถิติวิจัย (PDPA)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('ซ่อนเลขบัตร ปชช. (1-5002-XXXXX-XX-0) และย่อชื่อผู้ป่วย', style: TextStyle(fontSize: 12)),
                  value: ExportPrivacyMode.anonymized,
                  groupValue: selectedMode,
                  activeColor: PColor.primaryColor,
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedMode = val;
                        errorMessage = null;
                      });
                    }
                  },
                ),
                RadioListTile<ExportPrivacyMode>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('โหมดเวชระเบียนเต็ม (Full HIS)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('แสดงเลขและชื่อเต็มเพื่อนำเข้า JHCIS/HOSxP (ต้องใส่รหัสพยาบาล)', style: TextStyle(fontSize: 12)),
                  value: ExportPrivacyMode.clinicalFull,
                  groupValue: selectedMode,
                  activeColor: PColor.primaryColor,
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedMode = val;
                        errorMessage = null;
                      });
                    }
                  },
                ),
                if (selectedMode == ExportPrivacyMode.clinicalFull) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'กรอกรหัสผ่านพยาบาลเพื่อยืนยันสิทธิ์',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(errorMessage!, style: const TextStyle(color: PColor.riskHigh, fontSize: 12)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PColor.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
              label: const Text('ส่งออกและคัดลอก CSV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () async {
                if (selectedMode == ExportPrivacyMode.clinicalFull) {
                  if (passwordController.text.trim() != widget.nurse.nursePassword) {
                    setDialogState(() => errorMessage = 'รหัสผ่านพยาบาลไม่ถูกต้อง');
                    return;
                  }
                }

                final repo = locator<NcdRepositoryInterface>();
                final patients = await repo.getPatients();
                final screenings = await repo.getAllScreenings();
                final villages = await repo.getVillages();

                final csvData = HealthDataExportService.generateCsv(
                  patients: patients,
                  screenings: screenings,
                  villages: villages,
                  mode: selectedMode,
                );

                await Clipboard.setData(ClipboardData(text: csvData));

                if (!mounted) return;
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'ส่งออกข้อมูล ${screenings.length} รายการเรียบร้อยแล้ว (คัดลอกลง Clipboard แล้ว)',
                    ),
                    backgroundColor: PColor.riskLow,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: PColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const UserTypeSelectionPage()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'ระบบพยาบาล รพ.สต.แม่อาย',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          const SyncBadgeWidget(),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            tooltip: 'ส่งออกข้อมูลสุขภาพ (Excel/CSV)',
            onPressed: () => _showExportDataDialog(context),
          ),
          IconButton(
            icon:
                const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics_rounded, size: 20),
              text: 'ภาพรวมสถิติสุขภาพ',
            ),
            Tab(
              icon: Icon(Icons.holiday_village_rounded, size: 20),
              text: 'จัดการหมู่บ้านและ อสม.',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Nurse Area Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: PColor.primaryDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'พยาบาล: ${widget.nurse.fullName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'พื้นที่รับผิดชอบ: ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined,
                          color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'รพ.สต.แม่อาย',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAnalyticsDashboardTab(context),
                _buildVillageManagementTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: HEALTH ANALYTICS DASHBOARD
  // ==========================================

  Widget _buildAnalyticsDashboardTab(BuildContext context) {
    return BlocBuilder<VillageAnalyticsBloc, VillageAnalyticsState>(
      builder: (context, state) {
        if (state.status == VillageAnalyticsStatus.loading &&
            state.analytics == null) {
          return const Center(
            child: CircularProgressIndicator(color: PColor.primaryColor),
          );
        }

        if (state.status == VillageAnalyticsStatus.failure &&
            state.analytics == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: PColor.errorColor, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage ?? 'เกิดข้อผิดพลาดในการโหลดข้อมูล',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, color: PColor.contentColor),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<VillageAnalyticsBloc>()
                          .add(const VillageAnalyticsLoadRequested());
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('ลองใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PColor.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final analytics = state.analytics;
        if (analytics == null) {
          return const Center(child: Text('ไม่พบข้อมูลสถิติ'));
        }

        return RefreshIndicator(
          color: PColor.primaryColor,
          onRefresh: () async {
            context
                .read<VillageAnalyticsBloc>()
                .add(const VillageAnalyticsRefreshRequested());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Controls (Village Filter & Sort Order)
                _buildFilterControls(context, state, analytics),
                const SizedBox(height: 16),

                // 4 KPI Summary Cards
                _buildKpiSummaryCards(analytics),
                const SizedBox(height: 20),

                // 4 NCD Risk Breakdown Progress Meters
                _buildNcdRiskBreakdownSection(analytics),
                const SizedBox(height: 20),

                // Demographic Distribution (Gender & Age)
                _buildDemographicSection(analytics.demographics),
                const SizedBox(height: 20),

                // Village Comparison Ranking (Visible when All Villages is selected)
                if (analytics.isAllVillages &&
                    analytics.villageComparisons.isNotEmpty) ...[
                  _buildVillageComparisonSection(context, analytics),
                  const SizedBox(height: 20),
                ],

                // High-Risk Patient Priority Queue
                _buildHighRiskPriorityQueueSection(
                    context, analytics.highRiskPriorityQueue),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterControls(
    BuildContext context,
    VillageAnalyticsState state,
    VillageAnalytics analytics,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Village Dropdown
          Row(
            children: [
              const Icon(Icons.filter_alt_rounded,
                  color: PColor.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'เลือกพื้นที่:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: PColor.contentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: PColor.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: state.selectedVillageId ?? 'ALL',
                      icon: const Icon(Icons.arrow_drop_down_rounded,
                          color: PColor.primaryColor),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: PColor.contentColor,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (val) {
                        context.read<VillageAnalyticsBloc>().add(
                              VillageAnalyticsFilterChanged(
                                val == 'ALL' ? null : val,
                              ),
                            );
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: 'ALL',
                          child: Text(
                            'ทุกหมู่บ้าน (${state.villages.length} หมู่บ้าน)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...state.villages.map(
                          (v) => DropdownMenuItem<String>(
                            value: v.villageId,
                            child: Text(
                              'หมู่ ${v.villageNumber} ${v.villageName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sort Order Selector
          Row(
            children: [
              const Icon(Icons.sort_rounded,
                  color: PColor.textNeutralColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'เรียงลำดับ:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PColor.textNeutralColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: PColor.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AnalyticsSortOrder>(
                      isExpanded: true,
                      value: state.sortOrder,
                      icon: const Icon(Icons.arrow_drop_down_rounded,
                          color: PColor.textNeutralColor),
                      style: const TextStyle(
                        fontSize: 13,
                        color: PColor.contentColor,
                      ),
                      onChanged: (order) {
                        if (order != null) {
                          context.read<VillageAnalyticsBloc>().add(
                                VillageAnalyticsSortOrderChanged(order),
                              );
                        }
                      },
                      items: AnalyticsSortOrder.values.map((order) {
                        return DropdownMenuItem<AnalyticsSortOrder>(
                          value: order,
                          child: Text(order.labelTh,
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSummaryCards(VillageAnalytics analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'ประชากรทั้งหมด',
                value: '${analytics.totalPatients}',
                unit: 'คน',
                subtitle: 'ลงทะเบียนในระบบ',
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: 'ความครอบคลุม',
                value: '${analytics.screeningCoveragePercentage}%',
                unit: '',
                subtitle:
                    'คัดกรอง ${analytics.screenedPatientsCount}/${analytics.totalPatients} คน',
                icon: Icons.fact_check_rounded,
                iconColor: const Color(0xFF0EA5E9),
                bgColor: const Color(0xFFE0F2FE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'กลุ่มเสี่ยงสูง',
                value: '${analytics.highRiskPatientsCount}',
                unit: 'คน',
                subtitle: 'ต้องติดตามเร่งด่วน',
                icon: Icons.warning_amber_rounded,
                iconColor: PColor.errorColor,
                bgColor: const Color(0xFFFEE2E2),
                isAlert: analytics.highRiskPatientsCount > 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: 'รอพยาบาลตรวจ',
                value: '${analytics.pendingReviewsCount}',
                unit: 'รายการ',
                subtitle: 'อนุมัติแล้ว ${analytics.approvedReviewsCount}',
                icon: Icons.pending_actions_rounded,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isAlert
            ? Border.all(color: PColor.errorColor.withValues(alpha: 0.4), width: 1.5)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: PColor.textNeutralColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isAlert ? PColor.errorColor : PColor.contentColor,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: PColor.textNeutralColor,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: PColor.textNeutralColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNcdRiskBreakdownSection(VillageAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.monitor_heart_rounded,
                  color: PColor.primaryColor, size: 22),
              SizedBox(width: 8),
              Text(
                'สถิติความเสี่ยงรายโรค NCDs (4 โรค)',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: PColor.contentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'ประเมินจากผลการคัดกรองล่าสุดของผู้ป่วยแต่ละราย',
            style: TextStyle(fontSize: 12, color: PColor.textNeutralColor),
          ),
          const Divider(height: 24),

          // 1. Diabetes
          if (analytics.diabetesBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.bloodtype_outlined,
              breakdown: analytics.diabetesBreakdown!,
            ),
          const SizedBox(height: 16),

          // 2. Hypertension
          if (analytics.hypertensionBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.speed_rounded,
              breakdown: analytics.hypertensionBreakdown!,
            ),
          const SizedBox(height: 16),

          // 3. CVD
          if (analytics.cvdBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.favorite_border_rounded,
              breakdown: analytics.cvdBreakdown!,
            ),
          const SizedBox(height: 16),

          // 4. Metabolic Obesity
          if (analytics.obesityBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.accessibility_new_rounded,
              breakdown: analytics.obesityBreakdown!,
            ),
        ],
      ),
    );
  }

  Widget _buildDiseaseRiskMeter({
    required IconData icon,
    required NcdDiseaseBreakdown breakdown,
  }) {
    final total = breakdown.totalScreened;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 17, color: PColor.primaryColor),
                const SizedBox(width: 6),
                Text(
                  breakdown.diseaseName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: PColor.contentColor,
                  ),
                ),
              ],
            ),
            Text(
              'คัดกรองแล้ว $total คน',
              style: const TextStyle(
                fontSize: 11.5,
                color: PColor.textNeutralColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Multi-segment horizontal progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: total == 0
                ? Container(color: Colors.grey.shade200)
                : Row(
                    children: [
                      if (breakdown.lowCount > 0)
                        Expanded(
                          flex: breakdown.lowCount,
                          child: Container(
                            color: PColor.riskLow,
                          ),
                        ),
                      if (breakdown.moderateCount > 0)
                        Expanded(
                          flex: breakdown.moderateCount,
                          child: Container(
                            color: PColor.riskModerate,
                          ),
                        ),
                      if (breakdown.highCount > 0)
                        Expanded(
                          flex: breakdown.highCount,
                          child: Container(
                            color: PColor.riskHigh,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),

        // Legend with exact counts & percentages
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRiskLegendItem(
              color: PColor.riskLow,
              label: 'ปกติ/ต่ำ',
              count: breakdown.lowCount,
              percentage: breakdown.lowPercentage,
            ),
            _buildRiskLegendItem(
              color: PColor.riskModerate,
              label: 'ปานกลาง',
              count: breakdown.moderateCount,
              percentage: breakdown.moderatePercentage,
            ),
            _buildRiskLegendItem(
              color: PColor.riskHigh,
              label: 'สูง',
              count: breakdown.highCount,
              percentage: breakdown.highPercentage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRiskLegendItem({
    required Color color,
    required String label,
    required int count,
    required double percentage,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count ($percentage%)',
          style: const TextStyle(
            fontSize: 11,
            color: PColor.contentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDemographicSection(DemographicDistribution demographics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded,
                  color: PColor.primaryColor, size: 22),
              SizedBox(width: 8),
              Text(
                'การกระจายตัวของประชากร',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: PColor.contentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Gender Ratio
          const Text(
            'สัดส่วนเพศ (Gender Ratio)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PColor.contentColor,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: demographics.totalPatients == 0
                  ? Container(color: Colors.grey.shade200)
                  : Row(
                      children: [
                        if (demographics.maleCount > 0)
                          Expanded(
                            flex: demographics.maleCount,
                            child: Container(color: const Color(0xFF3B82F6)),
                          ),
                        if (demographics.femaleCount > 0)
                          Expanded(
                            flex: demographics.femaleCount,
                            child: Container(color: const Color(0xFFEC4899)),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ชาย: ${demographics.maleCount} คน (${demographics.maleRatio}%)',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEC4899),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'หญิง: ${demographics.femaleCount} คน (${demographics.femaleRatio}%)',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // Age Brackets
          const Text(
            'กลุ่มช่วงอายุ (Age Groups)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PColor.contentColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildAgeBracketCard(
                  label: '< 35 ปี',
                  desc: 'วัยหนุ่มสาว',
                  count: demographics.ageUnder35Count,
                  percentage: demographics.ageUnder35Ratio,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAgeBracketCard(
                  label: '35–59 ปี',
                  desc: 'วัยทำงาน',
                  count: demographics.age35To59Count,
                  percentage: demographics.age35To59Ratio,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAgeBracketCard(
                  label: '≥ 60 ปี',
                  desc: 'ผู้สูงอายุ',
                  count: demographics.age60AndAboveCount,
                  percentage: demographics.age60AndAboveRatio,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeBracketCard({
    required String label,
    required String desc,
    required int count,
    required double percentage,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 10.5,
              color: PColor.textNeutralColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count คน',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: PColor.contentColor,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVillageComparisonSection(
    BuildContext context,
    VillageAnalytics analytics,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.leaderboard_rounded,
                      color: PColor.primaryColor, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'การเปรียบเทียบสถิติรายหมู่บ้าน',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: PColor.contentColor,
                    ),
                  ),
                ],
              ),
              Text(
                '${analytics.villageComparisons.length} หมู่บ้าน',
                style: const TextStyle(
                  fontSize: 12,
                  color: PColor.textNeutralColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'กดที่หมู่บ้านเพื่อดูรายละเอียดเฉพาะพื้นที่ (Drill-down)',
            style: TextStyle(fontSize: 11.5, color: PColor.textNeutralColor),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: analytics.villageComparisons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = analytics.villageComparisons[index];
              return _buildVillageComparisonCard(context, item, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVillageComparisonCard(
    BuildContext context,
    VillageComparisonSummary summary,
    int rank,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.read<VillageAnalyticsBloc>().add(
              VillageAnalyticsFilterChanged(summary.village.villageId),
            );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PColor.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: rank == 1
                    ? const Color(0xFFF59E0B)
                    : PColor.primaryLight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rank == 1 ? Colors.white : PColor.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Village Info & Coverage
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'หมู่ ${summary.village.villageNumber} ${summary.village.villageName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PColor.contentColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: summary.totalPatients == 0
                                ? 0.0
                                : summary.screenedPatientsCount /
                                    summary.totalPatients,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              PColor.primaryColor,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${summary.screeningCoveragePercentage}%',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: PColor.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'คัดกรอง ${summary.screenedPatientsCount}/${summary.totalPatients} คน',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PColor.textNeutralColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // High Risk & Pending Badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (summary.highRiskPatientsCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: PColor.errorColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 13, color: PColor.errorColor),
                        const SizedBox(width: 3),
                        Text(
                          'เสี่ยงสูง ${summary.highRiskPatientsCount}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: PColor.errorColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'ไม่มีเสี่ยงสูง',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                if (summary.pendingReviewCount > 0)
                  Text(
                    'รอตรวจ ${summary.pendingReviewCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: PColor.textNeutralColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighRiskPriorityQueueSection(
    BuildContext context,
    List<HighRiskPriorityPatient> queue,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: PColor.errorColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'กลุ่มเสี่ยงสูงที่ต้องติดตามเร่งด่วน',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: PColor.contentColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: queue.isEmpty
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${queue.length} คน',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: queue.isEmpty
                        ? const Color(0xFF059669)
                        : PColor.errorColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'ผู้ป่วยที่มีผลคัดกรองความเสี่ยงระดับสูง กดเพื่อดูรายละเอียดหรือวางแผนลงพื้นที่',
            style: TextStyle(fontSize: 11.5, color: PColor.textNeutralColor),
          ),
          const Divider(height: 20),

          if (queue.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: Color(0xFF10B981), size: 40),
                    SizedBox(height: 8),
                    Text(
                      'ไม่พบผู้ป่วยกลุ่มเสี่ยงสูงในพื้นที่ที่เลือก',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: PColor.textNeutralColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: queue.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = queue[index];
                return _buildHighRiskPatientCard(context, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHighRiskPatientCard(
    BuildContext context,
    HighRiskPriorityPatient item,
  ) {
    final patient = item.patient;
    final village = item.village;
    final date = item.latestScreeningDate;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year + 543}';

    return Container(
      decoration: BoxDecoration(
        color: PColor.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PColor.errorColor.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDetailPage(
                  patient: patient,
                  nurse: widget.nurse,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFFEE2E2),
                  child: Icon(Icons.person_rounded,
                      color: PColor.errorColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              patient.fullName,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: PColor.contentColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'ตรวจ: $dateStr',
                            style: const TextStyle(
                              fontSize: 11,
                              color: PColor.textNeutralColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'อายุ ${patient.age} ปี • ${patient.patientGender} • ${village != null ? 'หมู่ ${village.villageNumber} ${village.villageName}' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PColor.textNeutralColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Risk chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: item.highRiskDiseases.map((d) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: PColor.errorColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: PColor.errorColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'เสี่ยงสูง: $d',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: PColor.errorColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: PColor.textNeutralColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: VILLAGES & VHV MANAGEMENT
  // ==========================================

  Widget _buildVillageManagementTab(BuildContext context) {
    return BlocBuilder<VillageBloc, VillageState>(
      builder: (context, state) {
        if (state.status == VillageStatus.loading && state.villages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: PColor.primaryColor),
          );
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
    );
  }

  Widget _buildVillageCard(BuildContext context, Village village) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                    color: PColor.primaryLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_city_rounded,
                      color: PColor.primaryColor, size: 24),
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
                      color: PColor.primaryLight.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.volunteer_activism_rounded,
                        color: PColor.primaryColor),
                  ),
                  title: const Text('รายชื่อ อสม. ในหมู่บ้าน',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      const Text('ดูข้อมูลและจัดการ อสม. ประจำหมู่บ้านนี้'),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
                    child: const Icon(Icons.people_outline_rounded,
                        color: Colors.blue),
                  ),
                  title: const Text('รายชื่อผู้ป่วยในหมู่บ้าน',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      const Text('ดูรายชื่อผู้ป่วยและผลการคัดกรองความเสี่ยง'),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
