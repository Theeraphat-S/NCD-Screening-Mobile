import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/domain/models/ncd_models.dart';
import 'package:mobile_app_standard/feature/auth/bloc/auth_bloc.dart';
import 'package:mobile_app_standard/feature/auth/pages/login_page.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Hospital / MOPH Emblem Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_hospital_rounded,
                    size: 64,
                    color: PColor.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'คัดกรองความเสี่ยง\n4 โรคไม่ติดต่อเรื้อรัง',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: PColor.primaryColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'รพ.สต.แม่อาย จ.เชียงใหม่',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: PColor.textNeutralColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: PColor.primaryLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'เลือกประเภทผู้ใช้งานเพื่อเข้าสู่ระบบ',
                  style: TextStyle(
                    fontSize: 14,
                    color: PColor.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Role Option 1: Patient (บุคคลทั่วไป)
              _buildRoleCard(
                context: context,
                role: UserRole.patient,
                title: 'บุคคลทั่วไป',
                subtitle: 'เข้าดูประวัติและผลการคัดกรองสุขภาพของตนเอง',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),

              // Role Option 2: VHV (อสม.)
              _buildRoleCard(
                context: context,
                role: UserRole.vhv,
                title: 'สำหรับ อสม.',
                subtitle: 'บันทึกข้อมูลผู้ป่วยและทำแบบคัดกรองสุขภาพในชุมชน',
                icon: Icons.volunteer_activism_outlined,
              ),
              const SizedBox(height: 16),

              // Role Option 3: Nurse (พยาบาล)
              _buildRoleCard(
                context: context,
                role: UserRole.nurse,
                title: 'สำหรับพยาบาล',
                subtitle: 'ดูแลข้อมูล อสม. และอนุมัติผลการประเมินความเสี่ยง',
                icon: Icons.medical_services_outlined,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.read<AuthBloc>().add(AuthSelectRole(role));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LoginPage(role: role),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: PColor.primaryColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: PColor.contentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: PColor.textNeutralColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: PColor.primaryColor,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
