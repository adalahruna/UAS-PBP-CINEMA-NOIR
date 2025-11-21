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
  final _provCtrl = TextEditingController();
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
    _provCtrl.dispose();
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
            _provCtrl.text = data['province'] ?? '';
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
          province: _provCtrl.text.trim(),
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

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                            radius: 70,
                            backgroundColor: AppColors.darkGrey,
                            backgroundImage: imageProvider,
                            child: (imageProvider == null)
                                ? const Icon(Icons.person, size: 60, color: AppColors.textGrey)
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
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.edit, color: AppColors.darkBackground, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _nameCtrl.text.isNotEmpty ? _nameCtrl.text : "No Name",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Center(
                      child: Text(
                        user?.email ?? '',
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Form Section ---
                    _buildSectionHeader('User Information'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: _buildInputDecoration(label: 'Full Name', icon: Icons.person_outline),
                      style: const TextStyle(color: AppColors.textWhite),
                      validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: user?.email,
                      // readOnly: true,  
                      style: const TextStyle(color: AppColors.textGrey),
                      decoration: _buildInputDecoration(label: 'Email (Read-only)', icon: Icons.email_outlined).copyWith(
                        fillColor: AppColors.darkGrey.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Location'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _provCtrl,
                            style: const TextStyle(color: AppColors.textWhite),
                            decoration: _buildInputDecoration(label: 'Province', icon: Icons.location_city_outlined),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cityCtrl,
                            style: const TextStyle(color: AppColors.textWhite),
                            decoration: _buildInputDecoration(label: 'City', icon: Icons.map_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // --- Save Button ---
                    ElevatedButton(
                      onPressed: isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.darkBackground,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.darkBackground),
                            )
                          : const Text('SAVE CHANGES'),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.darkGrey),
                    const SizedBox(height: 8),
                    // --- Logout Button ---
                    TextButton.icon(
                      onPressed: isSaving ? null : _logout,
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
              ),
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