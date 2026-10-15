import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/responsive_utils.dart';
import '../core/theme/app_theme.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.initialPrompt});

  final String initialPrompt;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _send(widget.initialPrompt);
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? value]) async {
    final prompt = (value ?? _input.text).trim();
    if (prompt.isEmpty || _isLoading) return;
    _input.clear();
    setState(() {
      _messages.add(_ChatMessage(text: prompt, fromUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final answer = await context.read<AIService>().generateChatResponse(prompt);
      if (!mounted) return;
      setState(() => _messages.add(_ChatMessage(text: answer, fromUser: false)));
    } catch (error) {
      if (!mounted) return;
      setState(() => _messages.add(_ChatMessage(
            text: 'I could not reach the AI service. $error',
            fromUser: false,
          )));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = AppResponsive.screenPadding(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Assistant'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: padding,
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppResponsive.spacing(context)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CircularProgressIndicator(color: scheme.primary),
                    ),
                  );
                }
                final message = _messages[index];
                return Align(
                  alignment: message.fromUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: AppResponsive.isTablet(context) ? 700 : 500,
                    ),
                    margin: EdgeInsets.only(bottom: AppResponsive.spacing(context)),
                    padding: EdgeInsets.all(AppResponsive.spacing(context, multiplier: 1.5)),
                    decoration: BoxDecoration(
                      gradient: message.fromUser
                          ? AppColors.brandGradient
                          : LinearGradient(
                              colors: isDark 
                                  ? [scheme.surfaceContainerHighest, scheme.surfaceContainerHigh]
                                  : [scheme.surfaceContainerHighest, scheme.surface],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: message.fromUser
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!message.fromUser) ...[
                          Text(
                            '🤖',
                            style: TextStyle(fontSize: AppResponsive.iconSize(context, size: AppIconSize.small, base: 16)),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: message.fromUser
                                  ? Colors.white
                                  : scheme.onSurface,
                              height: 1.4,
                              fontSize: AppResponsive.responsiveFontSize(context, min: 14, max: 16),
                            ),
                          ),
                        ),
                        if (message.fromUser) ...[
                          const SizedBox(width: 8),
                          Text(
                            '👤',
                            style: TextStyle(fontSize: AppResponsive.iconSize(context, size: AppIconSize.small, base: 16)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.all(AppResponsive.spacing(context)),
              decoration: BoxDecoration(
                color: scheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Ask a follow-up question',
                        filled: true,
                        fillColor: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: scheme.primary, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.spacing(context, multiplier: 2),
                          vertical: AppResponsive.spacing(context),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppResponsive.spacing(context)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _send,
                      tooltip: 'Send message',
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      padding: EdgeInsets.all(AppResponsive.spacing(context, multiplier: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}