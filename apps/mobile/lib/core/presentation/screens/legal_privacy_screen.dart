import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../constants/legal_content.dart';
import '../../../theme/app_theme.dart';
import '../layout/responsive.dart';

class LegalPrivacyScreen extends StatefulWidget {
  const LegalPrivacyScreen({super.key});

  @override
  State<LegalPrivacyScreen> createState() => _LegalPrivacyScreenState();
}

class _LegalPrivacyScreenState extends State<LegalPrivacyScreen> {
  bool _isHindi = false;
  int _selectedTabIndex = 0; // 0: Privacy, 1: Terms, 2: Disclaimer

  String get _currentContent {
    switch (_selectedTabIndex) {
      case 0:
        return _isHindi
            ? LegalContent.privacyPolicyHi
            : LegalContent.privacyPolicyEn;
      case 1:
        return _isHindi ? LegalContent.termsOfUseHi : LegalContent.termsOfUseEn;
      case 2:
        return _isHindi ? LegalContent.disclaimerHi : LegalContent.disclaimerEn;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/wagons');
            }
          },
        ),
        title: const Text('Legal & Privacy'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ToggleButtons(
              isSelected: [!_isHindi, _isHindi],
              onPressed: (index) {
                if (_isHindi != (index == 1)) {
                  setState(() => _isHindi = index == 1);
                }
              },
              color: Colors.white54,
              selectedColor: Colors.white,
              fillColor: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
              constraints:
                  const BoxConstraints(minHeight: 36.0, minWidth: 48.0),
              children: const [
                Text('EN', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('HI',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabs
          Container(
            color: AppTheme.surfaceColor,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab(0, _isHindi ? 'गोपनीयता नीति' : 'Privacy Policy',
                      Icons.privacy_tip_outlined),
                  const SizedBox(width: 8),
                  _buildTab(1, _isHindi ? 'उपयोग की शर्तें' : 'Terms of Use',
                      Icons.gavel_outlined),
                  const SizedBox(width: 8),
                  _buildTab(2, _isHindi ? 'अस्वीकरण' : 'Disclaimer',
                      Icons.verified_user_outlined),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.pagePadding(context),
                vertical: 16,
              ),
              children: [
                // Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF143B5B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security_rounded,
                          color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isHindi
                              ? 'SmartLoad का स्पष्ट, जिम्मेदार और पारदर्शी उपयोग।'
                              : 'Clear, responsible and transparent use of SmartLoad.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const _OpenFrontierLabsCredit(),
                const SizedBox(height: 24),

                // Content
                MarkdownBody(
                  data: _currentContent,
                  styleSheet: MarkdownStyleSheet(
                    h1: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.4),
                    h2: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.4),
                    h3: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.4),
                    p: const TextStyle(
                        color: Colors.white70, fontSize: 14, height: 1.6),
                    strong: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    listBullet: const TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black87 : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.white70,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenFrontierLabsCredit extends StatelessWidget {
  const _OpenFrontierLabsCredit();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/openfrontier_labs_logo.jpg',
            width: 150,
            height: 56,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'OpenFrontier Labs\nExpanding the Possible — ambitious without sounding exaggerated',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
