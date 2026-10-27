import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../petugas/petugas_dashboard.dart';

const _background = Color(0xFF050607);
const _card = Color(0xFF242628);
const _input = Color(0xFF424446);
const _primary = Color(0xFF0866F5);
const _text = Color(0xFFFFFFFF);
const _muted = Color(0xFFC5C8CE);
const _error = Color(0xFFFFB4AB);
const _line = Color(0xFF5C5F66);
const _registerCard = Color(0xFF323538);
const _assetDir = 'assets/asset_login_page';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _emailError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(email);
    if (!valid) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password wajib diisi.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_loading) {
      return;
    }
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || passwordError != null) {
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = await _authService.login(
        email: email,
        password: password,
      );
      final role = _authService.roleFromAccessToken(
        auth.accessToken,
      );
      if (!mounted) {
        return;
      }
      final Widget? page = switch (role) {
        'ADMIN' => const AdminDashboard(),
        'PETUGAS' => const PetugasDashboard(),
        _ => null,
      };
      if (page == null) {
        await _authService.logout();
        if (!mounted) {
          return;
        }
        setState(() {
          _loading = false;
          _formError =
              'Peran akun tidak dikenali. Hubungi admin.';
        });
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => page),
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _formError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _formError = 'Login gagal. Coba lagi.';
      });
    }
  }

  void _showUnavailable(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final heroHeight = media.viewInsets.bottom > 0
        ? 150.0
        : media.size.height * 0.40;

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: const _LoginHero(),
          ),
          Positioned(
            top: heroHeight - 32,
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  24 + media.padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Selamat Datang',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _text,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Login untuk mengakses\nsistem Smart Class',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _LoginField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Masukkan email anda',
                      icon: 'Email.svg',
                      errorText: _emailError,
                      keyboardType:
                          TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !_loading,
                      onChanged: (_) {
                        if (_emailError != null ||
                            _formError != null) {
                          setState(() {
                            _emailError = null;
                            _formError = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _LoginField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Masukkan password anda',
                      icon: 'Password.svg',
                      errorText: _passwordError,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !_loading,
                      onSubmitted: (_) => _submit(),
                      onChanged: (_) {
                        if (_passwordError != null ||
                            _formError != null) {
                          setState(() {
                            _passwordError = null;
                            _formError = null;
                          });
                        }
                      },
                      suffix: IconButton(
                        tooltip: _obscurePassword
                            ? 'Tampilkan password'
                            : 'Sembunyikan password',
                        onPressed: _loading
                            ? null
                            : () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                        icon: const _AssetImage(
                          name: 'Blind.svg',
                          height: 22,
                          semanticLabel:
                              'Visibilitas password',
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () => _showUnavailable(
                                'Reset password belum tersedia.',
                              ),
                        child: const Text(
                          'Lupa password?',
                          style: TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (_formError != null) ...[
                      Text(
                        _formError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _error,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _primary,
                          disabledBackgroundColor: _primary
                              .withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _loading
                            ? null
                            : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _text,
                                    ),
                              )
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  _AssetImage(
                                    name: 'Enter.svg',
                                    height: 20,
                                    semanticLabel: 'Masuk',
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Login',
                                    style: TextStyle(
                                      color: _text,
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(color: _line),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            'atau',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: _line),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: _registerCard,
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                        onTap: _loading
                            ? null
                            : () => _showUnavailable(
                                'Halaman daftar belum tersedia.',
                              ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              _AssetImage(
                                name: 'Add User Male.svg',
                                height: 28,
                                semanticLabel:
                                    'Daftar petugas',
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      'Belum punya akun?',
                                      style: TextStyle(
                                        color: _text,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Daftar sebagai petugas',
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _AssetImage(
                                name: 'Arrow.svg',
                                height: 16,
                                semanticLabel: 'Daftar',
                              ),
                            ],
                          ),
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
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          '$_assetDir/FotoKelas.png',
          fit: BoxFit.cover,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x990866F5),
                Color(0xCC12305B),
              ],
            ),
          ),
        ),
        const SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AssetImage(
                  name: 'LogoSmartClass.svg',
                  width: 176,
                  semanticLabel: 'Logo Smart Class',
                ),
                SizedBox(height: 8),
                Text(
                  'Sistem Monitoring dan\nPengelolaan Kelas Pintar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _text,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffix,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String icon;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _input,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          child: Row(
            children: [
              _AssetImage(name: icon, height: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextField(
                      controller: controller,
                      enabled: enabled,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      autocorrect: false,
                      enableSuggestions: !obscureText,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                      ),
                      cursorColor: _primary,
                      decoration: InputDecoration(
                        isDense: true,
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: const TextStyle(
                          color: _muted,
                          fontSize: 13,
                        ),
                      ),
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                    ),
                  ],
                ),
              ),
              ?suffix,
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: _error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _AssetImage extends StatelessWidget {
  const _AssetImage({
    required this.name,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final String name;
  final double? width;
  final double? height;
  final String? semanticLabel;

  static final Map<String, Future<Uint8List?>> _pngCache =
      {};

  static Future<Uint8List?> _embeddedPng(String asset) {
    return _pngCache.putIfAbsent(asset, () async {
      final raw = await rootBundle.loadString(asset);
      const marker = 'data:image/png;base64,';
      final start = raw.indexOf(marker);
      if (start < 0) {
        return null;
      }
      final from = start + marker.length;
      final end = raw.indexOf('"', from);
      if (end < 0) {
        return null;
      }
      return base64Decode(raw.substring(from, end));
    });
  }

  @override
  Widget build(BuildContext context) {
    final asset = '$_assetDir/$name';
    return FutureBuilder<Uint8List?>(
      future: _embeddedPng(asset),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            name,
            style: const TextStyle(
              color: _error,
              fontSize: 10,
            ),
          );
        }
        final bytes = snapshot.data;
        if (bytes != null) {
          return Image.memory(
            bytes,
            width: width,
            height: height,
            fit: BoxFit.contain,
            semanticLabel: semanticLabel,
            gaplessPlayback: true,
          );
        }
        if (snapshot.connectionState !=
            ConnectionState.done) {
          return SizedBox(width: width, height: height);
        }
        return SvgPicture.asset(
          asset,
          width: width,
          height: height,
          fit: BoxFit.contain,
          semanticsLabel: semanticLabel,
        );
      },
    );
  }
}
