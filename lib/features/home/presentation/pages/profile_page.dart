// File: lib/features/home/presentation/pages/profile_page.dart

import 'dart:typed_data';
import 'package:cinema_noir/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cinema_noir/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cinema_noir/features/auth/presentation/cubit/auth_state.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  Uint8List? _newImageBytes;
  String? _imageExtension;

  String? _currentPhotoUrl;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (user == null) {
      if (mounted) setState(() => _isLoadingData = false);
      return;
    }
    
    // Set initial values from FirebaseAuth
    _nameCtrl.text = user!.displayName ?? '';
    _currentPhotoUrl = user!.photoURL;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        // Use setState to update controllers and photo URL from Firestore
        if (mounted) {
          setState(() {
            _nameCtrl.text = data['fullName'] ?? _nameCtrl.text;
            _cityCtrl.text = data['city'] ?? '';
            if (data['photoUrl'] != null && data['photoUrl'].isNotEmpty) {
              _currentPhotoUrl = data['photoUrl'];
            }
          });
        }
      }
    } catch (e) {
      // Handle potential errors, e.g., show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800, // Resize for performance
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last;
      setState(() {
        _newImageBytes = bytes;
        _imageExtension = ext;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Let the BlocListener handle the UI feedback
    context.read<AuthCubit>().updateProfile(
          uid: user!.uid,
          fullName: _nameCtrl.text.trim(),
          province: 'Jawa Timur', // Default province
          city: _cityCtrl.text.trim(),
          imageBytes: _newImageBytes,
          imageExtension: _imageExtension,
        );
  }

  void _logout() {
    context.read<AuthCubit>().logout();
    // The main app listener should redirect to /login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.gold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated && state.message != null) {
            final isSuccess = state.message!.toLowerCase().contains('berhasil') || state.message!.toLowerCase().contains('success');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
                ),
              );
            }
            if (isSuccess) {
              setState(() {
                _newImageBytes = null; // Reset preview after successful save
              });
              _loadUserData(); // Reload data to show new photo URL
            }
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (_isLoadingData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('You are not logged in.', style: TextStyle(color: AppColors.textWhite)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.darkBackground
                      ),
                      child: const Text('GO TO LOGIN'),
                    )
                  ],
                ),
              );
            }

            bool isSaving = state is AuthLoading;

            ImageProvider? imageProvider;
            if (_newImageBytes != null) {
              imageProvider = MemoryImage(_newImageBytes!);
            } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
              imageProvider = NetworkImage(_currentPhotoUrl!);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isMobile = screenWidth < 768;
                
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 32,
                      vertical: isMobile ? 16 : 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // --- Avatar Section ---
                            Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: isMobile ? 60 : 70,
                                    backgroundColor: AppColors.darkGrey,
                                    backgroundImage: imageProvider,
                                    child: (imageProvider == null)
                                        ? Icon(Icons.person, size: isMobile ? 50 : 60, color: AppColors.textGrey)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Material(
                                      color: AppColors.gold,
                                      shape: const CircleBorder(),
                                      elevation: 2,
                                      child: InkWell(
                                        onTap: isSaving ? null : _pickImage,
                                        customBorder: const CircleBorder(),
                                        child: Padding(
                                          padding: EdgeInsets.all(isMobile ? 6 : 8),
                                          child: Icon(
                                            Icons.edit,
                                            color: AppColors.darkBackground,
                                            size: isMobile ? 18 : 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isMobile ? 12 : 16),
                            Center(
                              child: Text(
                                _nameCtrl.text.isNotEmpty ? _nameCtrl.text : "No Name",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: isMobile ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                user?.email ?? '',
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 24 : 32),

                            // --- Form Container ---
                            Container(
                              padding: EdgeInsets.all(isMobile ? 20 : 24),
                              decoration: BoxDecoration(
                                color: AppColors.darkGrey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.gold.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildSectionHeader('User Information'),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  TextFormField(
                                    controller: _nameCtrl,
                                    decoration: _buildInputDecoration(
                                      label: 'Full Name',
                                      icon: Icons.person_outline,
                                    ),
                                    style: const TextStyle(color: AppColors.textWhite),
                                    validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
                                  ),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  TextFormField(
                                    initialValue: user?.email,
                                    readOnly: true,
                                    style: const TextStyle(color: AppColors.textGrey),
                                    decoration: _buildInputDecoration(
                                      label: 'Email (Read-only)',
                                      icon: Icons.email_outlined,
                                    ).copyWith(
                                      fillColor: AppColors.darkGrey.withOpacity(0.5),
                                    ),
                                  ),
                                  SizedBox(height: isMobile ? 16 : 20),
                                  _buildSectionHeader('Location'),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  TextFormField(
                                    controller: _cityCtrl,
                                    style: const TextStyle(color: AppColors.textWhite),
                                    decoration: _buildInputDecoration(
                                      label: 'City',
                                      icon: Icons.location_city,
                                    ),
                                    validator: (v) => v!.isEmpty ? 'City cannot be empty' : null,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isMobile ? 24 : 32),

                            // --- Save Button ---
                            ElevatedButton(
                              onPressed: isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: AppColors.darkBackground,
                                minimumSize: Size(double.infinity, isMobile ? 48 : 54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 3,
                                textStyle: TextStyle(
                                  fontSize: isMobile ? 15 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: AppColors.darkBackground,
                                      ),
                                    )
                                  : const Text('SAVE CHANGES'),
                            ),
                            SizedBox(height: isMobile ? 16 : 20),
                            
                            // --- Logout Button ---
                            OutlinedButton.icon(
                              onPressed: isSaving ? null : _logout,
                              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                              label: Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: isMobile ? 15 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(double.infinity, isMobile ? 48 : 54),
                                side: const BorderSide(color: Colors.redAccent, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 16 : 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Helper for InputDecoration
  InputDecoration _buildInputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textGrey),
      prefixIcon: Icon(icon, color: AppColors.textGrey, size: 20),
      filled: true,
      fillColor: AppColors.darkGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.gold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  // Helper for Section Headers
  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textGrey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}