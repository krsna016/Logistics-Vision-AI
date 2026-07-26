import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/constants/manual_content.dart';
import '../../../core/theme/app_theme.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Manual'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppTheme.backgroundDark,
        child: Markdown(
          data: userManualMarkdown,
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(color: AppTheme.primaryBlue, fontSize: 20, fontWeight: FontWeight.bold),
            h3: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            p: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
            listBullet: const TextStyle(color: AppTheme.primaryBlue, fontSize: 16),
            strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
            code: const TextStyle(
              backgroundColor: Color(0xFF1E293B),
              color: AppTheme.accentAmber,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            codeblockPadding: const EdgeInsets.all(8),
            codeblockDecoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
            ),
            blockquote: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
            blockquoteDecoration: BoxDecoration(
              border: Border(left: BorderSide(color: AppTheme.primaryBlue, width: 4)),
            ),
            horizontalRuleDecoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.surfaceDark, width: 2)),
            ),
          ),
        ),
      ),
    );
  }
}
