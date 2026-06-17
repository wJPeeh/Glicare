import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../chat/data/chat_message.dart';
import '../data/doctor_repository.dart';

class DoctorChatPanel extends StatefulWidget {
  const DoctorChatPanel({
    super.key,
    required this.repo,
    required this.uid,
    required this.doctorName,
  });

  final DoctorRepository repo;
  final String uid;
  final String doctorName;

  @override
  State<DoctorChatPanel> createState() => _DoctorChatPanelState();
}

class _DoctorChatPanelState extends State<DoctorChatPanel> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await widget.repo.chat.send(
        uid: widget.uid,
        sender: ChatSender.doctor,
        text: text,
        authorName: widget.doctorName,
      );
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao enviar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow(opacity: 0.03),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 320,
            child: StreamBuilder<List<ChatMessage>>(
              stream: widget.repo.chat.watch(widget.uid),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? const <ChatMessage>[];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhuma mensagem ainda.\nInicie a conversa com o paciente.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scroll.hasClients) {
                    _scroll.jumpTo(_scroll.position.maxScrollExtent);
                  }
                });
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => _Bubble(
                    message: messages[i],
                    mine: messages[i].sender == ChatSender.doctor,
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    style: GoogleFonts.manrope(),
                    decoration: InputDecoration(
                      hintText: 'Escreva uma mensagem ao paciente…',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: _sending ? null : _send,
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});
  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final bg = mine ? AppColors.primary : AppColors.surfaceContainerHigh;
    final fg = mine ? Colors.white : AppColors.onSurface;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!mine)
              Text(
                message.authorName.isEmpty ? 'Paciente' : message.authorName,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondary,
                ),
              ),
            Text(
              message.text,
              style: GoogleFonts.manrope(fontSize: 14, color: fg, height: 1.35),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('dd/MM HH:mm').format(message.createdAt),
              style: GoogleFonts.manrope(
                fontSize: 9,
                color: (mine ? Colors.white : AppColors.onSurfaceVariant)
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
