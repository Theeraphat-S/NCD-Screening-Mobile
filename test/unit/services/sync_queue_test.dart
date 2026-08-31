import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/sync_queue_item.dart';
import 'package:ncd_screening_mobile/domain/services/sync_queue_service.dart';
import 'package:ncd_screening_mobile/shared/bloc/sync_badge_bloc.dart';

void main() {
  group('SyncQueueService', () {
    late SyncQueueService syncService;

    setUp(() {
      syncService = SyncQueueService();
    });

    tearDown(() {
      syncService.dispose();
    });

    test('enqueues items and calculates pending count', () async {
      expect(await syncService.getPendingCount(), 0);

      final item1 = SyncQueueItem(
        id: 'ITEM_1',
        entityType: 'screening',
        entityId: 'SCR001',
        action: 'create',
        payload: const {'weight': 65.0},
        createdAt: DateTime.now(),
      );

      final item2 = SyncQueueItem(
        id: 'ITEM_2',
        entityType: 'patient',
        entityId: 'P001',
        action: 'create',
        payload: const {'name': 'สมชาย'},
        createdAt: DateTime.now(),
      );

      await syncService.enqueue(item1);
      await syncService.enqueue(item2);

      expect(await syncService.getPendingCount(), 2);
      final pending = await syncService.getPendingItems();
      expect(pending.length, 2);
    });

    test('processes queue and marks items as synced', () async {
      final item = SyncQueueItem(
        id: 'ITEM_1',
        entityType: 'screening',
        entityId: 'SCR001',
        action: 'create',
        payload: const {},
        createdAt: DateTime.now(),
      );

      await syncService.enqueue(item);
      expect(await syncService.getPendingCount(), 1);

      final success = await syncService.processQueue();
      expect(success, isTrue);
      expect(await syncService.getPendingCount(), 0);
    });

    test('clears synced items', () async {
      final item = SyncQueueItem(
        id: 'ITEM_1',
        entityType: 'screening',
        entityId: 'SCR001',
        action: 'create',
        payload: const {},
        createdAt: DateTime.now(),
      );

      await syncService.enqueue(item);
      await syncService.processQueue();
      await syncService.clearSyncedItems();

      expect(await syncService.getPendingCount(), 0);
    });
  });

  group('SyncBadgeBloc', () {
    late SyncQueueService syncService;
    late SyncBadgeBloc bloc;

    setUp(() {
      syncService = SyncQueueService();
      bloc = SyncBadgeBloc(syncService: syncService);
    });

    tearDown(() {
      bloc.close();
      syncService.dispose();
    });

    test('initial state has 0 pending items and isOnline true', () {
      expect(bloc.state.pendingCount, 0);
      expect(bloc.state.isOnline, isTrue);
      expect(bloc.state.isFullySynced, isTrue);
    });

    test('reacts to network change and offline queueing', () async {
      bloc.add(const SyncBadgeNetworkChanged(false));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.isOnline, isFalse);

      final item = SyncQueueItem(
        id: 'ITEM_OFFLINE',
        entityType: 'screening',
        entityId: 'SCR_OFF',
        action: 'create',
        payload: const {},
        createdAt: DateTime.now(),
      );

      bloc.add(SyncBadgeItemEnqueued(item));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.pendingCount, 1);
      expect(bloc.state.isFullySynced, isFalse);

      // Reconnects network
      bloc.add(const SyncBadgeNetworkChanged(true));
      await Future.delayed(const Duration(milliseconds: 500));

      expect(bloc.state.pendingCount, 0);
      expect(bloc.state.isFullySynced, isTrue);
    });
  });
}
