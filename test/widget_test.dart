import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_test/main.dart';

void main() {
  testWidgets('ESP8266 LED控制应用测试', (WidgetTester tester) async {
    // 构建应用并触发一帧
    await tester.pumpWidget(const MyApp());

    // 验证应用标题存在
    expect(find.text('ESP8266 LED控制'), findsOneWidget);
    
    // 验证连接状态文本存在
    expect(find.text('连接状态: 未连接'), findsOneWidget);
    
    // 验证连接按钮存在
    expect(find.text('连接服务器'), findsOneWidget);
  });
}