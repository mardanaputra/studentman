import 'package:flutter/material.dart';

enum FeedbackStateType { loading, empty, error }

class StateFeedbackPlaceholder extends StatelessWidget {
  final FeedbackStateType type;
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String retryLabel;

  const StateFeedbackPlaceholder({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.icon,
    this.onRetry,
    this.retryLabel = 'Coba Lagi',
  });

  const StateFeedbackPlaceholder.loading({
    super.key,
    this.title = 'Memuat Data...',
    this.message = 'Mohon tunggu sebentar',
    this.icon,
    this.onRetry,
    this.retryLabel = 'Coba Lagi',
  }) : type = FeedbackStateType.loading;

  const StateFeedbackPlaceholder.empty({
    super.key,
    this.title = 'Belum Ada Data',
    this.message = 'Data saat ini masih kosong.',
    this.icon = Icons.inbox_outlined,
    this.onRetry,
    this.retryLabel = 'Segarkan',
  }) : type = FeedbackStateType.empty;

  const StateFeedbackPlaceholder.error({
    super.key,
    this.title = 'Terjadi Kesalahan',
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
    this.retryLabel = 'Coba Lagi',
  }) : type = FeedbackStateType.error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (type == FeedbackStateType.loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: type == FeedbackStateType.error
                      ? Colors.red.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? (type == FeedbackStateType.error ? Icons.warning_rounded : Icons.info_outline),
                  size: 48,
                  color: type == FeedbackStateType.error
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

