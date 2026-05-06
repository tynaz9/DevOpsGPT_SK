import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../services/api_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() =>
      _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController controller =
      TextEditingController();
  final ScrollController scrollController =
      ScrollController();
  bool isLoading = false;

  List<Map<String, String>> conversationHistory = [];

  List<Map<String, String>> messages = [
    {
      "role": "ai",
      "text":
          "👋 Hello! I'm **DevOpsGPT AI**\n\nI have access to your real server data. Ask me:\n• *\"Summarize my alerts\"*\n• *\"What's wrong with my servers?\"*\n• *\"Why is CPU high?\"*\n• *\"Show recent logs\"*"
    }
  ];

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    String userMsg = controller.text.trim();
    controller.clear();

    setState(() {
      messages.add({"role": "user", "text": userMsg});
      isLoading = true;
    });
    scrollToBottom();

    conversationHistory.add({'role': 'user', 'content': userMsg});

    try {
      final response = await ApiService
          .sendAiMessageWithHistory(userMsg, conversationHistory);

      Map<String, dynamic> aiData = response;
      if (response.containsKey('body') && response['body'] is String) {
        aiData = jsonDecode(response['body']) as Map<String, dynamic>;
      }

      String aiReply = aiData['explanation'] ??
          '${aiData['root_cause'] ?? ''}\nFix: ${aiData['suggested_fix'] ?? ''}';

      conversationHistory.add({'role': 'assistant', 'content': aiReply});

      setState(() {
        messages.add({"role": "ai", "text": aiReply});
        isLoading = false;
      });
      scrollToBottom();
    } catch (e) {
      conversationHistory.removeLast();
      setState(() {
        messages.add({
          "role": "ai",
          "text": "⚠️ Connection error. Please try again.\n\n*Error: $e*"
        });
        isLoading = false;
      });
      scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary   = AppTheme.textPrimary(context);
    final textMuted     = AppTheme.textMuted(context);
    final textSecondary = AppTheme.textSecondary(context);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [

              // App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: AppColors.primaryGradient),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.smart_toy_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Assistant',
                              style: GoogleFonts.inter(
                                  color: textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text('DevOpsGPT · Server Context',
                              style: GoogleFonts.inter(
                                  color: textMuted, fontSize: 10)),
                        ],
                      ),
                    ]),
                    GestureDetector(
                      onTap: () => setState(() {
                        messages = [
                          {
                            "role": "ai",
                            "text":
                                "👋 Hello! I'm **DevOpsGPT AI**\n\nI have access to your real server data. Ask me anything!"
                          }
                        ];
                        conversationHistory = [];
                      }),
                      child: GlassCard(
                        padding: const EdgeInsets.all(8),
                        borderRadius: 20,
                        child: const Icon(Icons.refresh_rounded,
                            color: AppColors.accent, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick action chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _quickChip(context, '📊 Summarize alerts'),
                    _quickChip(context, '🔴 Why CPU high?'),
                    _quickChip(context, '📋 Recent logs'),
                    _quickChip(context, '🖥️ Server status'),
                    _quickChip(context, '🔧 Available fixes'),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    bool isUser = msg["role"] == "user";
                    return _buildMessage(context, msg["text"]!, isUser);
                  },
                ),
              ),

              // Loading indicator
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('AI thinking...',
                            style: TextStyle(
                                color: textSecondary, fontSize: 13)),
                      ]),
                    ),
                  ]),
                ),

              // Input bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: TextStyle(
                            color: textPrimary, fontSize: 14),
                        onSubmitted: (_) => sendMessage(),
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Ask about your servers...',
                          hintStyle: TextStyle(
                              color: textMuted, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: isLoading ? null : sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: isLoading
                              ? null
                              : const LinearGradient(
                                  colors: AppColors.primaryGradient),
                          color: isLoading ? textMuted : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, String text, bool isUser) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppTheme.textPrimary(context);
    final glassBorder = AppTheme.glassBorder(context);
    // AI bubble bg: slightly more opaque in light mode for readability
    final aiBubbleBg    = isDark
        ? AppColors.darkGlassWhite
        : const Color(0xFFFFFFFF);
    final aiTextColor   = textPrimary;
    final codeBlockBg   = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : const Color(0xFFE8EDF5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : aiBubbleBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: glassBorder),
                boxShadow: isUser
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
              ),
              child: isUser
                  ? Text(text,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14))
                  : MarkdownBody(
                      data: text,
                      shrinkWrap: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                            color: aiTextColor,
                            fontSize: 14,
                            height: 1.5),
                        h1: GoogleFonts.inter(
                            color: aiTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        h2: GoogleFonts.inter(
                            color: aiTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                        h3: GoogleFonts.inter(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                        strong: TextStyle(
                            color: isDark
                                ? AppColors.accent
                                : AppColors.purple,
                            fontWeight: FontWeight.bold),
                        em: TextStyle(
                            color: AppTheme.textSecondary(context),
                            fontStyle: FontStyle.italic),
                        code: TextStyle(
                            color: AppColors.accent,
                            backgroundColor: codeBlockBg,
                            fontSize: 12,
                            fontFamily: 'monospace'),
                        codeblockDecoration: BoxDecoration(
                          color: codeBlockBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        listBullet: const TextStyle(
                            color: AppColors.accent),
                        blockquote: TextStyle(
                            color: AppTheme.textSecondary(context)),
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _quickChip(BuildContext context, String text) {
    final textPrimary = AppTheme.textPrimary(context);
    final glassWhite  = AppTheme.glassWhite(context);
    final glassBorder = AppTheme.glassBorder(context);

    return GestureDetector(
      onTap: () {
        controller.text = text
            .replaceAll('📊 ', '')
            .replaceAll('🔴 ', '')
            .replaceAll('📋 ', '')
            .replaceAll('🖥️ ', '')
            .replaceAll('🔧 ', '');
        sendMessage();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: glassWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: glassBorder),
        ),
        child: Text(text,
            style: TextStyle(color: textPrimary, fontSize: 12)),
      ),
    );
  }
}
