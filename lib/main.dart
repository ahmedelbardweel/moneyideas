import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneyideas/app/app.dart';
import 'package:moneyideas/app/bootstrap.dart';

Future<void> main() async {
  await bootstrap();
  runApp(
    const ProviderScope(
      child: MoneyIdeasApp(),
    ),
  );
}
