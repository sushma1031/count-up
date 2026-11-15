import 'package:count_up/widgets/offset_animated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const longText =
      'Next Up: Bulgarian split squats with a very long exercise name';

  Future<RenderParagraph> pumpInSlot(WidgetTester tester, String text) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            height: 50,
            child: OffsetAnimatedText(text),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(seconds: 1));
    return tester.renderObject<RenderParagraph>(find.text(text));
  }

  testWidgets('long text is truncated to one line', (tester) async {
    final paragraph = await pumpInSlot(tester, longText);

    expect(paragraph.didExceedMaxLines, isTrue);
  });

  testWidgets('long text is not clipped at the bottom', (tester) async {
    final paragraph = await pumpInSlot(tester, longText);

    expect(paragraph.getMaxIntrinsicHeight(paragraph.size.width),
        lessThanOrEqualTo(paragraph.size.height));
  });
}
