import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // Data Tim - GANTI DENGAN DATA ASLI TIM ANDA
  static const List<TeamMember> teamMembers = [
    TeamMember(
      name: 'Dhava Gilang Ramadhan',
      role: 'Ketua Kelompok',
      imageUrl:
          'https://msilqepklwsdvftecdov.supabase.co/storage/v1/object/public/user_profiles/bb8IldUR4YVMeKdzJOLHGFpgX0N2_1763718126626.jpg',
      githubUrl: 'https://github.com/dava2532006',
      description:
          'Cita-cita saya adalah menjadi orang yang menagih pajak bukan membayarnya',
    ),
    TeamMember(
      name: 'Sattya Runa Pramudita',
      role: 'Anggota',
      imageUrl:
          'https://msilqepklwsdvftecdov.supabase.co/storage/v1/object/public/user_profiles/WhatsApp%20Image%202025-11-29%20at%2009.41.22_b45b46fe.jpg',
      githubUrl: 'https://github.com/adalahruna',
      description: 'Kudu aku sek to',
    ),
    TeamMember(
      name: 'Rahmat Nugroho Saputra',
      role: 'Anggota',
      imageUrl:
          'https://msilqepklwsdvftecdov.supabase.co/storage/v1/object/public/user_profiles/IMG_20250906_175207.jpg',
      githubUrl: 'https://github.com/rahmatnug',
      description: 'Semoga yang kali ini berhasil',
    ),
    TeamMember(
      name: 'Faiz Ahmad Dien Al-Ghifary',
      role: 'Anggota',
      imageUrl:
          'https://msilqepklwsdvftecdov.supabase.co/storage/v1/object/public/user_profiles/Gambar%20WhatsApp%202025-11-29%20pukul%2023.49.23_7985ab3c.jpg',
      githubUrl: 'https://github.com/Paizzy',
      description: 'Tidur Di Masjid ada Pragos, Hai Aku Faos',
    ),
    TeamMember(
      name: 'Desinta Dian Kusumaningrum',
      role: 'Anggota',
      imageUrl:
          'https://msilqepklwsdvftecdov.supabase.co/storage/v1/object/public/user_profiles/Gambar%20WhatsApp%202025-11-29%20pukul%2023.32.34_5a5106fd.jpg',
      githubUrl: 'https://github.com/dysee-xian',
      description: 'were dreaming of tommorow isnt coming',
    ),
    TeamMember(
      name: 'Dewa Nazwa Marna Putra',
      role: 'Anggota',
      imageUrl:
          'https://msilqepklwsdvftecdov.supabase.co/storage/v1/object/public/user_profiles/WhatsApp%20Image%202025-11-29%20at%2009.54.35_ddb54d1a.jpg',
      githubUrl: ' https://github.com/Marzzzz-bot',
      description: 'Aku mah apa atuh',
    ),
    TeamMember(
      name: 'Della Nur Laili',
      role: 'Anggota',
      imageUrl:
          'https://msilqepklwsdvftecdov.supabase.co/storage/v1/object/public/user_profiles/Gambar%20WhatsApp%202025-11-29%20pukul%2023.32.50_257ab539.jpg',
      githubUrl: 'https://github.com/dellanrl',
      description: 'kalau bukan sekarang kapan lagi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: isMobile ? 180 : 220,
            backgroundColor: AppColors.darkBackground,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.gold,
                  size: 18,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'About Us',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.darkGrey, AppColors.darkBackground],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.1,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200&h=400&fit=crop',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.darkBackground,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 20,
              ),
              child: Column(
                children: [
                  _buildTeamDescription(isMobile),
                  SizedBox(height: isMobile ? 32 : 48),
                  _buildSectionTitle('Our Team', isMobile),
                  const SizedBox(height: 24),
                  _buildTeamGrid(context, screenWidth, isMobile),
                  SizedBox(height: isMobile ? 32 : 48),
                  _buildFooter(isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamDescription(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: AppColors.gold,
                  size: isMobile ? 28 : 36,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Kelompok 1',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            'We are Kelompok 1, a passionate team of developers dedicated to creating innovative digital experiences. Our Cinema Noir project showcases our expertise in mobile and web development, combining elegant design with powerful functionality.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: isMobile ? 13 : 15,
              height: 1.5,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Divider(color: AppColors.gold.withOpacity(0.3)),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Together, we build amazing applications using Flutter, Firebase, and modern web technologies.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isMobile) {
    return Row(
      children: [
        Container(
          width: 4,
          height: isMobile ? 22 : 26,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 22 : 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamGrid(
    BuildContext context,
    double screenWidth,
    bool isMobile,
  ) {
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth > 1200) {
      crossAxisCount = 4;
      childAspectRatio = 0.75;
    } else if (screenWidth > 900) {
      crossAxisCount = 3;
      childAspectRatio = 0.8;
    } else if (screenWidth > 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.85;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 1.1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: isMobile ? 16 : 20,
        crossAxisSpacing: isMobile ? 16 : 20,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: teamMembers.length,
      itemBuilder: (context, index) {
        return _TeamMemberCard(member: teamMembers[index], isMobile: isMobile);
      },
    );
  }

  Widget _buildFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: AppColors.gold, size: 32),
          const SizedBox(height: 12),
          Text(
            'Made with passion by Kelompok 1',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: isMobile ? 13 : 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2025 Cinema Noir. All rights reserved.',
            style: TextStyle(
              color: AppColors.textGrey.withOpacity(0.6),
              fontSize: isMobile ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Team Member Model
class TeamMember {
  final String name;
  final String role;
  final String imageUrl;
  final String githubUrl;
  final String description;

  const TeamMember({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.githubUrl,
    required this.description,
  });
}

// Team Member Card Widget
class _TeamMemberCard extends StatefulWidget {
  final TeamMember member;
  final bool isMobile;

  const _TeamMemberCard({required this.member, required this.isMobile});

  @override
  State<_TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<_TeamMemberCard> {
  bool _isHovered = false;

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse(widget.member.githubUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch GitHub URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..scale(_isHovered && !widget.isMobile ? 1.03 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? AppColors.gold.withOpacity(0.5)
                  : Colors.white10,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.gold.withOpacity(0.2)
                    : Colors.black.withOpacity(0.3),
                blurRadius: _isHovered ? 15 : 8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image Section
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: AppColors.gold.withOpacity(0.1),
                        child: Image.network(
                          widget.member.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.darkGrey,
                              child: const Icon(
                                Icons.person,
                                color: AppColors.gold,
                                size: 60,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.darkGrey.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info Section
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.all(widget.isMobile ? 12 : 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.member.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.member.role,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: widget.isMobile ? 11 : 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.member.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: widget.isMobile ? 10 : 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // GitHub Button
                      SizedBox(
                        height: widget.isMobile ? 36 : 40,
                        child: ElevatedButton.icon(
                          onPressed: _launchGitHub,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.isMobile ? 12 : 16,
                            ),
                          ),
                          icon: Icon(
                            Icons.code,
                            size: widget.isMobile ? 16 : 18,
                          ),
                          label: Text(
                            'GitHub',
                            style: TextStyle(
                              fontSize: widget.isMobile ? 11 : 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
