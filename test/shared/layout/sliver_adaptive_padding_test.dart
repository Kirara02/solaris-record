import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solaris_record_app/src/shared/layout/window_size.dart';

void main() {
  const body = Key('body');

  Future<void> pump(
    WidgetTester tester, {
    required EdgeInsets padding,
    bool clearBottomInset = true,
    double width = 1000,
    double height = 600,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(width, height), padding: padding),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(
            slivers: [
              SliverAdaptivePadding(
                clearBottomInset: clearBottomInset,
                sliver: const SliverToBoxAdapter(
                  child: SizedBox(key: body, height: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('uses the window margin when nothing covers the page', (
    tester,
  ) async {
    await pump(tester, padding: EdgeInsets.zero);
    // 1000 wide is the expanded class: a 32 margin on both sides.
    expect(tester.getTopLeft(find.byKey(body)).dx, 32);
    expect(tester.getSize(find.byKey(body)).width, 1000 - 64);
  });

  testWidgets('keeps clear of a rail the page extends under', (tester) async {
    await pump(tester, padding: const EdgeInsets.only(left: 280));
    // 720 is left beside the rail (medium class, margin 24).
    expect(tester.getTopLeft(find.byKey(body)).dx, 280 + 24);
    expect(tester.getSize(find.byKey(body)).width, 1000 - 280 - 24 - 24);
  });

  testWidgets('adds the bottom inset, unless told not to', (tester) async {
    double scrollExtent() => tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position
        .maxScrollExtent;

    // A 30 high window, so the content (10 + 24 padding) has to scroll.
    await pump(tester, padding: const EdgeInsets.only(bottom: 80), height: 30);
    expect(scrollExtent(), 10 + 24 + 80 - 30);

    await pump(
      tester,
      padding: const EdgeInsets.only(bottom: 80),
      clearBottomInset: false,
      height: 30,
    );
    expect(scrollExtent(), 10 + 24 - 30);
  });
}
