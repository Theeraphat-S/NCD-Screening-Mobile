import 'dart:async';
import 'package:mobile_app_standard/domain/models/sync_queue_item.dart';

abstract class SyncQueueServiceInterface {
  Future<void> enqueue(SyncQueueItem item);
  Future<List<SyncQueueItem>> getPendingItems();
  Future<int> getPendingCount();
  Future<bool> processQueue();
  Future<void> clearSyncedItems();
  Stream<int> get pendingCountStream;
}

class SyncQueueService implements SyncQueueServiceInterface {
  final List<SyncQueueItem> _queue = [];
  final _countController = StreamController<int>.broadcast();
  bool _isProcessing = false;

  SyncQueueService() {
    _countController.add(0);
  }

  @override
  Stream<int> get pendingCountStream => _countController.stream;

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    _queue.removeWhere((existing) => existing.id == item.id);
    _queue.add(item);
    _countController.add(await getPendingCount());
  }

  @override
  Future<List<SyncQueueItem>> getPendingItems() async {
    return _queue
        .where((item) =>
            item.status == SyncStatus.pending || item.status == SyncStatus.failed)
        .toList();
  }

  @override
  Future<int> getPendingCount() async {
    return _queue
        .where((item) =>
            item.status == SyncStatus.pending || item.status == SyncStatus.failed)
        .length;
  }

  @override
  Future<bool> processQueue() async {
    if (_isProcessing) return false;
    _isProcessing = true;

    try {
      final pending = await getPendingItems();
      for (final item in pending) {
        // Mark syncing
        final index = _queue.indexWhere((e) => e.id == item.id);
        if (index != -1) {
          _queue[index] = _queue[index].copyWith(status: SyncStatus.syncing);
        }

        // Simulate REST API network latency & dispatch
        await Future.delayed(const Duration(milliseconds: 300));

        // Mark synced
        if (index != -1) {
          _queue[index] = _queue[index].copyWith(
            status: SyncStatus.synced,
            retryCount: _queue[index].retryCount + 1,
          );
        }
      }

      _countController.add(await getPendingCount());
      return true;
    } catch (e) {
      return false;
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> clearSyncedItems() async {
    _queue.removeWhere((item) => item.status == SyncStatus.synced);
    _countController.add(await getPendingCount());
  }

  void dispose() {
    _countController.close();
  }
}
