import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/manual_content.dart';
import '../../../theme/app_theme.dart';

class UserManualScreen extends StatefulWidget {
  const UserManualScreen({super.key});

  @override
  State<UserManualScreen> createState() => _UserManualScreenState();
}

class _UserManualScreenState extends State<UserManualScreen> {
  bool _isHindi = false;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 700;
    if (shouldShow != _showBackToTop) {
      setState(() => _showBackToTop = shouldShow);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _changeLanguage(bool hindi) {
    if (_isHindi == hindi) return;
    setState(() => _isHindi = hindi);
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  List<String> _manualSections(String markdown) {
    final sections = <String>[];
    final lines = markdown.split('\n');
    final buffer = StringBuffer();
    for (final line in lines) {
      if (line.startsWith('## ') && buffer.isNotEmpty) {
        sections.add(buffer.toString().trim());
        buffer.clear();
      }
      buffer.writeln(line);
    }
    if (buffer.isNotEmpty) sections.add(buffer.toString().trim());
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final sections = _manualSections(
      _isHindi ? userManualHindiMarkdown : userManualMarkdown,
    );
    return Scaffold(
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
        title: Text(_isHindi ? 'सहायता और दस्तावेज' : 'Help & Documentation'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ToggleButtons(
              isSelected: [!_isHindi, _isHindi],
              onPressed: (index) {
                _changeLanguage(index == 1);
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
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              tooltip: _isHindi ? 'ऊपर जाएं' : 'Back to top',
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
              ),
              child: const Icon(Icons.keyboard_arrow_up_rounded),
            )
          : null,
      body: Container(
        color: AppTheme.backgroundColor,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(18, 20, 22, 96),
          physics: const ClampingScrollPhysics(),
          itemCount: sections.length,
          itemBuilder: (context, index) => MarkdownBody(
            data: sections[index],
            selectable: false,
            styleSheet: _manualStyleSheet(),
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _manualStyleSheet() {
    return MarkdownStyleSheet(
      h1: const TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      h2: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold),
      h3: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      p: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
      listBullet: const TextStyle(color: AppTheme.primaryColor, fontSize: 16),
      strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
      code: const TextStyle(
        backgroundColor: Color(0xFF1E293B),
        color: AppTheme.warningColor,
        fontFamily: 'monospace',
        fontSize: 14,
      ),
      codeblockPadding: const EdgeInsets.all(8),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      blockquote:
          const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
      blockquoteDecoration: const BoxDecoration(
        border:
            Border(left: BorderSide(color: AppTheme.primaryColor, width: 4)),
      ),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.dividerColor, width: 2)),
      ),
    );
  }
}
