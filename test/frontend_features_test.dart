import 'dart:ui' as ui;
import 'package:app_do_an/features/transaction/data/transaction_summary.dart';
import 'package:app_do_an/navigator/navigator_screen/transaction_receipt_screen.dart';
import 'package:app_do_an/navigator/navigator_widget/favorite_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'Monthly totals exclude failed, pending, other months and unknown direction',
    () {
      Map<String, dynamic> tx(
        String direction,
        num amount, {
        String status = 'COMPLETED',
        int month = 9,
      }) => {
        'direction': direction,
        'amount': amount,
        'status': status,
        'createdAt': DateTime(2026, month, 15, 12).toIso8601String(),
        'type': 'INTERNAL_TRANSFER',
      };
      final summary = TransactionSummary([
        tx('IN', 100),
        tx('CREDIT', 50),
        tx('OUT', 30),
        tx('DEBIT', 20),
        tx('OUT', 999, status: 'FAILED'),
        tx('IN', 999, status: 'PENDING'),
        tx('IN', 999, month: 8),
        tx('UNKNOWN', 999),
      ], DateTime(2026, 9));
      expect(summary.income, 150);
      expect(summary.expense, 50);
      expect(summary.daily(15, true), 150);
      expect(summary.daily(14, false), 0);
      expect(summary.groups['INTERNAL_TRANSFER'], hasLength(4));
    },
  );

  testWidgets(
    'Search without accents opens matching service and pins persist',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      Map<String, dynamic>? opened;
      Widget app() => MaterialApp(
        home: Scaffold(
          body: FavoriteServices(
            items: const [
              {'label': 'Hóa đơn', 'icon': Icons.receipt},
              {'label': 'Viễn thông', 'icon': Icons.phone},
            ],
            onOpen: (item) => opened = item,
          ),
        ),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'dien');
      await tester.pump();
      expect(find.text('Hóa đơn'), findsOneWidget);
      await tester.tap(find.text('Hóa đơn'));
      expect(opened?['label'], 'Hóa đơn');
      await tester.tap(find.byTooltip('Xóa tìm kiếm'));
      await tester.pump();
      await tester.tap(find.text('Chỉnh sửa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hóa đơn'));
      await tester.pump();
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();
      expect(find.byType(InputChip), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.byType(InputChip), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('anpay.favorite-services.v1'), ['Hóa đơn']);
    },
  );

  testWidgets(
    'Receipt fits narrow screens, retains simulated status and exports full PNG',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionReceiptScreen(
            data: {
              'amount': 150000,
              'status': 'FAILED',
              'simulated': true,
              'counterpartyName':
                  'Người nhận có tên rất dài để kiểm tra bố cục',
              'description': List.filled(12, 'Nội dung chuyển tiền').join(' '),
              'reference': 'ANPAY123456789012345678901234567890',
              'createdAt': '2026-09-25T12:00:00',
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Giao dịch thất bại'), findsOneWidget);
      expect(find.textContaining('GIAO DỊCH MÔ PHỎNG'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final finder = find
          .ancestor(
            of: find.text('AnPay'),
            matching: find.byType(RepaintBoundary),
          )
          .first;
      final boundary = tester.renderObject<RenderRepaintBoundary>(finder);
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        expect(image.height, greaterThan(600));
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        expect(bytes!.lengthInBytes, greaterThan(1000));
        image.dispose();
      });
    },
  );
}
