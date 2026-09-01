import 'package:flutter/material.dart';
import '../design/design_tokens.dart';
import '../theme/live_jury_theme.dart';
import 'primitives.dart';

class VerdictCard extends StatelessWidget {
  const VerdictCard({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '$label. $description',
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: .14) : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : AppColors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        letterSpacing: .8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? color : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class JurorStrip extends StatelessWidget {
  const JurorStrip({super.key, required this.voted, this.speaking});
  final int voted;
  final int? speaking;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(
      6,
      (i) => Column(
        children: [
          Semantics(
            label:
                '${i == 0 ? 'You' : 'Juror ${i + 1}'}, '
                '${speaking == i ? 'speaking, ' : ''}'
                '${i < voted ? 'voted' : 'has not voted yet'}',
            child: Stack(
              children: [
                JurorAvatar(
                  initials: ['VK', 'AM', 'SK', 'RN', 'JT', 'LP'][i],
                  size: 40,
                  color: i < voted ? AppColors.teal : AppColors.muted,
                ),
                if (speaking == i)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 7,
                      backgroundColor: AppColors.gold,
                      child: Icon(Icons.mic, size: 9, color: AppColors.navy),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            i == 0 ? 'YOU' : '${i + 1}',
            style: AppTypography.caption.copyWith(
              fontSize: 9,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    ),
  );
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.name,
    required this.message,
    required this.mine,
  });
  final String name;
  final String message;
  final bool mine;
  @override
  Widget build(BuildContext context) => Align(
    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      constraints: const BoxConstraints(maxWidth: 330),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: mine
            ? AppColors.gold.withValues(alpha: .15)
            : AppColors.surfaceRaised,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(mine ? 16 : 4),
          bottomRight: Radius.circular(mine ? 4 : 16),
        ),
        border: Border.all(
          color: mine
              ? AppColors.gold.withValues(alpha: .25)
              : AppColors.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              color: mine ? AppColors.gold : AppColors.teal,
            ),
          ),
          const SizedBox(height: 5),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}
