import 'package:flutter/material.dart';

import '../../../core/design/design_tokens.dart';
import '../../../core/theme/live_jury_theme.dart';
import '../widgets/jury_room_components.dart';

class DeliberationRoomScreen extends StatefulWidget {
  const DeliberationRoomScreen({
    super.key,
    required this.onNotifications,
    required this.onProfile,
    required this.onOpenEvidence,
    required this.onVerdictSubmitted,
  });

  final VoidCallback onNotifications;
  final VoidCallback onProfile;
  final VoidCallback onOpenEvidence;
  final VoidCallback onVerdictSubmitted;

  @override
  State<DeliberationRoomScreen> createState() => _DeliberationRoomScreenState();
}

class _DeliberationRoomScreenState extends State<DeliberationRoomScreen> {
  final _controller = TextEditingController();
  final _messages = <_JuryMessage>[
    const _JuryMessage(
      author: 'Prosecution',
      initials: 'PR',
      time: '10:42 am',
      content:
          'The sequence of events indicates premeditation. Exhibit C confirms a calculated transfer exactly 48 hours before the incident.',
      accent: AppColors.textSecondary,
    ),
    const _JuryMessage(
      author: 'Defense',
      initials: 'DF',
      time: '10:45 am',
      content:
          'The ledger entries are circumstantial. Testimony 4A states that the transfer was automated by a legacy protocol.',
      accent: AppColors.urgent,
    ),
    const _JuryMessage(
      author: 'Lead juror · You',
      initials: 'VK',
      time: '10:48 am',
      content:
          'We should cross-reference the contract timestamp with Server Logs, Exhibit F. That would test whether the automation defense holds.',
      accent: AppColors.primary,
      mine: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmeraldBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            JuryRoomHeader(
              title: 'Deliberate',
              compact: true,
              onNotifications: widget.onNotifications,
              onProfile: widget.onProfile,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: GlassPanel(
                radius: AppRadii.lg,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const StatusDot(color: AppColors.urgent),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PHASE III ACTIVE',
                            style: AppTypography.overline.copyWith(
                              color: AppColors.urgent,
                            ),
                          ),
                          Text(
                            'Intent analysis',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.timer_outlined,
                      size: 17,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '00:45:12',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                key: const Key('deliberation-message-list'),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                itemCount: _messages.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Center(
                        child: Text(
                          'SESSION DECRYPTED  ·  10:40 AM',
                          style: AppTypography.overline.copyWith(
                            color: AppColors.textSecondary.withValues(
                              alpha: .48,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (index == 3) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: GlassPanel(
                        radius: 99,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_tree_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Defense attached one new document to the registry',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final messageIndex = index == 4 ? 2 : index - 1;
                  return _MessageBubble(message: _messages[messageIndex]);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow.withValues(alpha: .96),
                border: Border(
                  top: BorderSide(
                    color: AppColors.primary.withValues(alpha: .12),
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: widget.onOpenEvidence,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          icon: const Icon(Icons.attach_file_rounded, size: 18),
                          label: const Text('Exhibit'),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _showVoteSheet,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          icon: const Icon(
                            Icons.how_to_vote_outlined,
                            size: 18,
                          ),
                          label: const Text('Call vote'),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'P2P Secure',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primaryPressed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Draft your reasoning for the chamber…',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton.filled(
                        onPressed: _controller.text.trim().isEmpty
                            ? null
                            : _send,
                        tooltip: 'Send reasoning',
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _JuryMessage(
          author: 'Lead juror · You',
          initials: 'VK',
          time: 'Now',
          content: text,
          accent: AppColors.primary,
          mine: true,
        ),
      );
      _controller.clear();
    });
  }

  void _showVoteSheet() {
    String? selected;
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Call the final vote',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Your verdict is final after submission.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              for (final option in ['Guilty', 'Not guilty'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Semantics(
                    button: true,
                    selected: selected == option,
                    inMutuallyExclusiveGroup: true,
                    child: Material(
                      color: selected == option
                          ? AppColors.primaryContainer.withValues(alpha: .35)
                          : AppColors.surfaceLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        side: BorderSide(
                          color: selected == option
                              ? AppColors.primary
                              : AppColors.outline,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => setSheetState(() => selected = option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 15,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected == option
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: selected == option
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                option,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: selected == null
                    ? null
                    : () {
                        Navigator.pop(sheetContext);
                        widget.onVerdictSubmitted();
                        showDemoFeedback(
                          this.context,
                          'Final verdict submitted securely.',
                        );
                      },
                child: const Text('Submit final verdict'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _JuryMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 410),
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: message.mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  JuryAvatar(initials: message.initials, size: 28),
                  Text(
                    message.author.toUpperCase(),
                    style: AppTypography.overline.copyWith(
                      color: message.accent,
                    ),
                  ),
                  Text(
                    message.time,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: .5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: message.mine
                    ? AppColors.primaryContainer.withValues(alpha: .35)
                    : AppColors.surfaceHigh.withValues(alpha: .72),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.mine ? 24 : 5),
                  topRight: Radius.circular(message.mine ? 5 : 24),
                  bottomLeft: const Radius.circular(24),
                  bottomRight: const Radius.circular(24),
                ),
                border: Border.all(
                  color: message.accent.withValues(alpha: .28),
                ),
              ),
              child: Text(
                message.content,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: message.mine ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JuryMessage {
  const _JuryMessage({
    required this.author,
    required this.initials,
    required this.time,
    required this.content,
    required this.accent,
    this.mine = false,
  });

  final String author;
  final String initials;
  final String time;
  final String content;
  final Color accent;
  final bool mine;
}
