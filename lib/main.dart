import 'package:flutter/material.dart'; // นำเข้าไลบรารี material.dart
import 'package:flutter_localizations/flutter_localizations.dart'; // นำเข้าไลบรารี flutter_localizations.dart เพื่อใช้งานภาษาที่เป็นค่าเริ่มต้น
import 'package:hive_flutter/hive_flutter.dart'; // นำเข้าไลบรารี hive_flutter.dart เพื่อใช้งาน Hive บน Flutter
import 'package:path_provider/path_provider.dart'; // นำเข้าไลบรารี path_provider.dart เพื่อใช้งาน path_provider บน Flutter
import 'package:provider/provider.dart'; // นำเข้าไลบรารี provider.dart เพื่อใช้งาน Provider บน Flutter
import 'ViewModel/lang.dart'; // นำเข้าไลบรารี lang.dart เพื่อใช้งาน LocaleProvider

void main() async {
  // ตรวจสอบว่า Flutter ได้เริ่มต้นการทำงานหรือยัง
  WidgetsFlutterBinding.ensureInitialized();
  // ดึงข้อมูลของโฟลเดอร์ที่เก็บข้อมูลของแอพ
  final appDocumentDir = await getApplicationDocumentsDirectory();
  // กำหนดที่เก็บข้อมูลของแอพ ให้เป็นที่เก็บข้อมูลของแอพที่ได้จาก appDocumentDir
  Hive.init(appDocumentDir.path);
  // เปิดกล่องข้อมูลที่เก็บข้อมูลการตั้งค่าของแอพ หรือสร้างกล่องข้อมูลใหม่ถ้ายังไม่มี
  await Hive.openBox('settings');

  runApp(
    // ใช้ MultiProvider เพื่อให้สามารถใช้งานหลายๆ Provider ได้พร้อมๆกัน
    MultiProvider(
      // กำหนด Provider ที่จะใช้งาน
      providers: [
        // ใช้ ChangeNotifierProvider เพื่อให้สามารถใช้งาน Provider ที่เป็น ChangeNotifier ได้
        ChangeNotifierProvider(
          create: (context) => LocaleProvider(),
        ),
      ],
      // กำหนดว่า MyApp คือ child ของ MultiProvider
      child: const MyApp(),
    ),
  );
}

// คลาส MyApp ที่เป็นคลาสหลักของแอพ ซึ่งเป็น Stateless Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ Consumer เพื่อให้สามารถใช้งาน Provider ได้
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        // ถ้า localeProvider ยังไม่ได้โหลดข้อมูล locale ให้แสดงหน้าจอว่างๆ
        if (!localeProvider.isLocaleLoaded) {
          return MaterialApp(
            home: Container(),
          );
        }
        // ถ้า localeProvider โหลดข้อมูล locale แล้ว ให้แสดงหน้าจอหลักของแอพ
        return MaterialApp(
          // กำหนด MediaQuery ให้เป็น 24 ชั่วโมง และ ขนาดตัวอักษรเป็น 1.0 เสมอ
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(
                  1.0,
                ),
                alwaysUse24HourFormat: true,
              ),
              child: child!,
            );
          },
          // กำหนดภาษาที่ใช้งาน ให้เป็นภาษาที่โหลดมาจาก localeProvider
          locale: localeProvider.locale,
          // กำหนด localizationsDelegates ที่ใช้งาน ให้เป็นค่าเริ่มต้น และ CupertinoLocalizations ที่ใช้งาน ให้เป็นค่าเริ่มต้น
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // กำหนด supportedLocales ที่ใช้งาน ให้เป็นภาษาอังกฤษและภาษาไทย
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('th', 'TH'),
          ],
          // กำหนดหน้าจอหลักของแอพ ให้เป็นหน้าจอที่เป็น LanguageSwitcherWidget
          home: const LanguageSwitcherWidget(),
        );
      },
    );
  }
}

class LanguageSwitcherWidget extends StatelessWidget {
  const LanguageSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // กำหนด localeLanguage ให้เป็น Provider ที่ใช้งาน
    final localeLanguage = Provider.of<LocaleProvider>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // แสดงข้อความที่แปลแล้ว จากไฟล์ภาษา โดยใช้ฟังก์ชัน translate จาก localeLanguage ที่เป็น Provider
            Text(localeLanguage.translate('hello')),
            Text(localeLanguage.translate('welcome')),
            ElevatedButton(
              // กำหนดภาษาให้เป็นภาษาอังกฤษ โดยใช้ฟังก์ชัน setLocale จาก localeLanguage ที่เป็น Provider
              onPressed: () => localeLanguage.setLocale(const Locale('en')),
              child: const Text('English'),
            ),
            ElevatedButton(
              onPressed: () => localeLanguage.setLocale(const Locale('th')),
              child: const Text('ไทย'),
            ),
          ],
        ),
      ),
    );
  }
}
