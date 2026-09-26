import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/storage/session_preferences.dart';
import 'package:app_do_an/navigator/navigator_tabbar/schedule_tabbar.dart';
import 'package:app_do_an/navigator/navigator_screen/ai_chat_screen.dart';
import 'package:app_do_an/navigator/fourth_screen/result_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final requests = <RequestOptions>[];
  final handlers = <RequestInterceptorHandler>[];
  late List<Interceptor> originalInterceptors;
  setUp(() {
    requests.clear();
    handlers.clear();
    originalInterceptors = AppServices.api.dio.interceptors.toList();
    AppServices.api.dio.interceptors.clear();
    AppServices.api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handlers.add(handler);
        },
      ),
    );
  });
  tearDown(() {
    AppServices.api.dio.interceptors.clear();
    AppServices.api.dio.interceptors.addAll(originalInterceptors);
  });
  void respond(int index, Object data) => handlers[index].resolve(
    Response(requestOptions: requests[index], statusCode: 200, data: data),
  );
  Map<String, dynamic> page(
    String prefix, {
    int count = 1,
    int number = 0,
    bool more = false,
  }) => {
    'data': {
      'content': List.generate(
        count,
        (i) => {
          'id': '$prefix$i',
          'title': '$prefix$i',
          'amount': 100,
          'direction': 'IN',
          'status': 'COMPLETED',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ),
      'number': number,
      'size': 20,
      'totalPages': more ? 2 : 1,
      'totalElements': more ? 40 : count,
      'last': !more,
    },
  };
  Future<void> flush(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('history ignores responses for older searches', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ScheduleTabbar()));
    await flush(tester);
    await tester.enterText(find.byType(TextField), 'NEW');
    await flush(tester);
    expect(requests.length, 2);
    respond(1, page('NEW'));
    await tester.pumpAndSettle();
    respond(0, page('OLD'));
    await tester.pumpAndSettle();
    expect(find.text('NEW0'), findsOneWidget);
    expect(find.text('OLD0'), findsNothing);
  });

  testWidgets('history invalidates errors during search debounce', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ScheduleTabbar()));
    await flush(tester);
    await tester.enterText(find.byType(TextField), 'NEW');
    handlers[0].reject(
      DioException(
        requestOptions: requests[0],
        type: DioExceptionType.connectionError,
      ),
    );
    await tester.pump();
    expect(find.text('Không tải được lịch sử giao dịch'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await flush(tester);
    respond(1, page('NEW'));
    await tester.pumpAndSettle();
    expect(find.text('NEW0'), findsOneWidget);
  });

  testWidgets('old pagination cannot append into refreshed history', (
    tester,
  ) async {
    final key = GlobalKey<ScheduleTabbarState>();
    await tester.pumpWidget(MaterialApp(home: ScheduleTabbar(key: key)));
    await flush(tester);
    respond(0, page('OLD', count: 20, more: true));
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).last,
    );
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await flush(tester);
    expect(requests.length, 2);
    expect(requests[1].queryParameters['page'], 1);
    final refresh = key.currentState!.refreshFromOutside();
    await flush(tester);
    respond(2, page('NEW'));
    await refresh;
    await tester.pumpAndSettle();
    respond(1, page('STALE', number: 1));
    await tester.pumpAndSettle();
    expect(find.text('NEW0'), findsOneWidget);
    expect(find.text('STALE0'), findsNothing);
  });

  testWidgets('keyboard cannot send twice while waiting and draft survives', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AiChatScreen()));
    await tester.enterText(find.byType(TextField), 'First');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await flush(tester);
    await tester.enterText(find.byType(TextField), 'Second');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await flush(tester);
    expect(requests.length, 1);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Second',
    );
    respond(0, {
      'success': true,
      'data': {'reply': 'Reply one'},
    });
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.send));
    await flush(tester);
    expect(requests.length, 2);
    expect(requests[1].data['message'], 'Second');
    respond(1, {
      'success': true,
      'data': {'reply': 'Reply two'},
    });
    await tester.pumpAndSettle();
  });

  test(
    'logout cleanup preserves device preferences but removes account data',
    () async {
      SharedPreferences.setMockInitialValues({
        'anpay.favorite-services.v1': ['Hóa đơn'],
        'language': 'vi',
        'locale': 'vi',
        'isLoggedIn': true,
        'user_email': 'test@example.com',
        'name': 'Test',
        'notification_history': ['private'],
      });
      await clearSessionPreferences();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('anpay.favorite-services.v1'), ['Hóa đơn']);
      expect(prefs.getString('language'), 'vi');
      expect(prefs.getString('locale'), 'vi');
      expect(prefs.getKeys(), {
        'anpay.favorite-services.v1',
        'language',
        'locale',
      });
    },
  );

  testWidgets('result receipt requires backend detail and supports retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionResultScreen(
          transactionId: 'tx-123',
          bankName: 'Bank',
          accountName: 'Initial name',
          amount: 100,
          time: 'Initial time',
        ),
      ),
    );
    await tester.ensureVisible(find.text('Xem và chia sẻ biên lai'));
    await tester.tap(find.text('Xem và chia sẻ biên lai'));
    await flush(tester);
    expect(requests.single.path, '/transactions/tx-123');
    expect(find.byIcon(Icons.ios_share), findsNothing);
    handlers[0].reject(
      DioException(
        requestOptions: requests[0],
        type: DioExceptionType.connectionError,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Thử lại'), findsOneWidget);
    expect(find.byIcon(Icons.ios_share), findsNothing);
    await tester.tap(find.text('Thử lại'));
    await flush(tester);
    respond(1, {
      'data': {
        'status': 'COMPLETED',
        'direction': 'OUT',
        'amount': 100,
        'fee': 2000,
        'counterpartyName': 'Verified name',
        'counterpartyAccount': 'ANP99887766',
        'reference': 'REF-123',
        'createdAt': '2026-09-26T10:20:00',
        'simulated': true,
      },
    });
    await tester.pumpAndSettle();
    expect(find.text('Verified name'), findsOneWidget);
    expect(find.text('ANP99887766'), findsOneWidget);
    expect(find.text('REF-123'), findsOneWidget);
    expect(find.text('Phí giao dịch'), findsOneWidget);
    expect(find.textContaining('GIAO DỊCH MÔ PHỎNG'), findsOneWidget);
    expect(find.byIcon(Icons.ios_share), findsOneWidget);
  });
}
