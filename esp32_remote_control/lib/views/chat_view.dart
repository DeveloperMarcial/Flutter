import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/node_session_viewmodel.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _selectedDestAddress = 43; // Default to Master 43
  int _currentByteLength = 0;
  static const int maxMeshPayloadBytes = 120;

  @override
  void initState() {
    super.initState();
    _msgController.addListener(_updateByteCount);
  }

  @override
  void dispose() {
    _msgController.removeListener(_updateByteCount);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateByteCount() {
    final bytes = utf8.encode(_msgController.text).length;
    if (bytes != _currentByteLength) {
      setState(() {
        _currentByteLength = bytes;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _currentByteLength > maxMeshPayloadBytes) return;

    final session = context.read<NodeSessionViewModel>();
    _msgController.clear();
    _scrollToBottom();

    try {
      await session.sendMessage(_selectedDestAddress, text);
      _scrollToBottom();
    } catch (_) {
      _scrollToBottom();
    }
  }

  Widget _buildStatusBadge(ChatMessageStatus status, int? msgId, String? error) {
    switch (status) {
      case ChatMessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white70),
        );
      case ChatMessageStatus.delivered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.done_all, size: 14, color: Colors.tealAccent),
            if (msgId != null) ...[
              const SizedBox(width: 3),
              Text('ID:$msgId', style: const TextStyle(fontSize: 9, color: Colors.tealAccent)),
            ],
          ],
        );
      case ChatMessageStatus.uncertain:
        return Tooltip(
          message: error ?? 'Delivery uncertain',
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amberAccent),
              SizedBox(width: 3),
              Text('Uncertain', style: TextStyle(fontSize: 9, color: Colors.amberAccent)),
            ],
          ),
        );
      case ChatMessageStatus.failed:
        return Tooltip(
          message: error ?? 'Delivery failed',
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 14, color: Colors.redAccent),
              SizedBox(width: 3),
              Text('Failed', style: TextStyle(fontSize: 9, color: Colors.redAccent)),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<NodeSessionViewModel>();
    final messages = session.chatMessages;
    final isExceeded = _currentByteLength > maxMeshPayloadBytes;

    return Column(
      children: [
        // Destination Selector Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: Colors.grey.shade900,
          child: Row(
            children: [
              const Text(
                'To Node: ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedDestAddress,
                dropdownColor: Colors.grey.shade900,
                underline: Container(height: 1, color: Colors.tealAccent),
                items: const [
                  DropdownMenuItem(value: 43, child: Text('Master 43 (Primary)')),
                  DropdownMenuItem(value: 42, child: Text('Master 42')),
                  DropdownMenuItem(value: 48, child: Text('eNode 48')),
                  DropdownMenuItem(value: 49, child: Text('eNode 49')),
                  DropdownMenuItem(value: 255, child: Text('Broadcast (255)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedDestAddress = val;
                    });
                  }
                },
              ),
              const Spacer(),
              Text(
                '${messages.length} msgs',
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
        ),

        // Messages Bubble List
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_outlined, size: 54, color: Colors.grey.shade600),
                      const SizedBox(height: 12),
                      const Text(
                        'No Mesh Messages Yet',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Send a message to Node $_selectedDestAddress over RF mesh',
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.isOutgoing;
                    final timeStr =
                        '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}:${msg.timestamp.second.toString().padLeft(2, '0')}';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.teal.shade800.withValues(alpha: 0.9)
                              : Colors.blueGrey.shade800.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isMe ? 12 : 2),
                            bottomRight: Radius.circular(isMe ? 2 : 12),
                          ),
                          border: Border.all(
                            color: isMe ? Colors.tealAccent.shade400 : Colors.white24,
                            width: 0.8,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMe ? 'To Node ${msg.toAddress}' : 'From Node ${msg.fromAddress}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isMe ? Colors.tealAccent.shade100 : Colors.amberAccent.shade100,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              msg.text,
                              style: const TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  timeStr,
                                  style: const TextStyle(fontSize: 9, color: Colors.white54),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 6),
                                  _buildStatusBadge(msg.status, msg.msgId, msg.error),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Input & Mesh Constraints Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: const Border(top: BorderSide(color: Colors.white12, width: 1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mesh RF Constraint: max 120 bytes',
                    style: TextStyle(fontSize: 10, color: Colors.white38),
                  ),
                  Text(
                    '$_currentByteLength / $maxMeshPayloadBytes bytes',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: isExceeded ? Colors.redAccent : Colors.tealAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type mesh message...',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.white38),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: (session.isExecutingCommand ||
                            _currentByteLength == 0 ||
                            isExceeded)
                        ? null
                        : _handleSendMessage,
                    icon: session.isExecutingCommand
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
