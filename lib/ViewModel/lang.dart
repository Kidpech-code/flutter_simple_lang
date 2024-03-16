import 'dart:convert'; // นำเข้าไลบรารี dart:convert เพื่อใช้งานการแปลงข้อมูล JSON
import 'package:flutter/material.dart'; // นำเข้าไลบรารี material.dart เพื่อใช้งาน material design บน Flutter
import 'package:flutter/services.dart'; // นำเข้าไลบรารี services.dart เพื่อใช้งานบริการต่างๆ บน Flutter เช่น rootBundle ซึ่งใช้ในการโหลดไฟล์จาก assets
import 'package:hive/hive.dart'; // นำเข้าไลบรารี hive.dart เพื่อใช้งาน Hive บน Flutter
import 'package:hive_flutter/hive_flutter.dart'; // นำเข้าไลบรารี hive_flutter.dart เพื่อใช้งาน Hive บน Flutter

class LocaleProvider with ChangeNotifier {
  // กำหนดตัวแปร _locale ให้เป็น Locale และให้เป็น null เริ่มต้น หรือไม่มีค่าเริ่มต้น
  Locale? _locale;

  // กำหนดตัวแปร _localizedStrings ให้เป็น Map ที่มี key เป็น String และ value เป็น String และให้เป็น Map ว่างเริ่มต้น
  Map<String, String> _localizedStrings = {};

  // กำหนด constructor ของ LocaleProvider ให้เป็น _loadSavedLocale เพื่อโหลดข้อมูล locale ที่เก็บไว้ หรือเป็นการเรียกใช้งานฟังก์ชัน _loadSavedLocale เมื่อมีการสร้าง object ของ LocaleProvider
  LocaleProvider() {
    _loadSavedLocale();
  }

  // กำหนด getter ของ locale ให้เป็น _locale ถ้า _locale มีค่า แต่ถ้าไม่มีค่าให้เป็น Locale ที่มีภาษาเป็น 'en' เป็นค่าเริ่มต้น
  Locale get locale => _locale ?? const Locale('en');

  // กำหนด getter ของ isLocaleLoaded ให้เป็น _locale ไม่เท่ากับ null หรือมีค่า ถ้ามีค่าให้เป็น true แต่ถ้าไม่มีค่าให้เป็น false
  bool get isLocaleLoaded => _locale != null;

  // กำหนดฟังก์ชัน _loadSavedLocale ที่เป็น Future และไม่มีค่าเป็น async เพื่อโหลดข้อมูล locale ที่เก็บไว้ หรือเป็นการเรียกใช้งานฟังก์ชัน loadLanguage เมื่อมีการสร้าง object ของ LocaleProvider และเก็บข้อมูล locale ที่เก็บไว้ไว้ในตัวแปร localeCode
  Future<void> _loadSavedLocale() async {
    // กำหนดตัวแปร box ให้เป็นการเปิดกล่องข้อมูลที่เก็บข้อมูลการตั้งค่าของแอพ หรือสร้างกล่องข้อมูลใหม่ถ้ายังไม่มี
    final box = await Hive.openBox('settings');

    // กำหนดตัวแปร localeCode ให้เป็นการเรียกใช้งานฟังก์ชัน get ของ box โดยให้ key เป็น 'localeCode' และ defaultValue เป็น 'en' หรือภาษาอังกฤษเป็นค่าเริ่มต้น
    var localeCode = box.get('localeCode', defaultValue: 'en');

    // กำหนด _locale ให้เป็น Locale ที่มีภาษาเป็น localeCode
    _locale = Locale(localeCode);

    // เรียกใช้งานฟังก์ชัน loadLanguage เพื่อโหลดข้อมูล locale ที่เก็บไว้
    await loadLanguage();
  }

  // กำหนดฟังก์ชัน loadLanguage ที่เป็น Future และไม่มีค่าเป็น async เพื่อโหลดข้อมูลภาษาที่เราต้องการ โดยการโหลดไฟล์ภาษาที่เราต้องการจาก assets และแปลงข้อมูล JSON ที่ได้มาเป็น Map และเก็บข้อมูลที่ได้ไว้ในตัวแปร _localizedStrings และแจ้งเตือนให้ผู้ฟังเห็นได้ว่าข้อมูลเปลี่ยนแปลง หรือเป็นการเรียกใช้งาน notifyListeners เพื่อให้ผู้ฟังเห็นได้ว่าข้อมูลเปลี่ยนแปลง
  Future<void> loadLanguage() async {
    // กำหนดตัวแปร jsonString ให้เป็นการโหลดข้อมูลจากไฟล์ที่อยู่ในโฟลเดอร์ assets/lang โดยให้ชื่อไฟล์เป็นภาษาที่เราต้องการ และใช้ rootBundle ในการโหลดไฟล์ และใช้ภาษาที่เราต้องการจาก _locale?.languageCode ซึ่งเป็นภาษาที่เราต้องการ และถ้าไม่มีค่าให้เป็น null
    String jsonString = await rootBundle
        .loadString('assets/lang/${_locale?.languageCode}.json');

    // กำหนดตัวแปร jsonMap ให้เป็นการแปลงข้อมูล JSON ที่ได้มาจาก jsonString และใช้ json.decode ในการแปลงข้อมูล JSON
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // กำหนด _localizedStrings ให้เป็น Map ที่มี key เป็น String และ value เป็น String โดยให้เป็น Map ที่ได้จากการแปลงข้อมูล JSON ที่ได้มาจาก jsonMap โดยใช้ map และให้ key เป็น key และ value เป็น value และแปลง value ให้เป็น String ด้วย value.toString()
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    // แจ้งเตือนให้ผู้ฟังเห็นได้ว่าข้อมูลเปลี่ยนแปลง หรือเป็นการเรียกใช้งาน notifyListeners เพื่อให้ผู้ฟังเห็นได้ว่าข้อมูลเปลี่ยนแปลง
    notifyListeners();
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  } // กำหนดฟังก์ชัน translate ที่มีการรับ key และให้เป็น _localizedStrings[key] ถ้า _localizedStrings[key] มีค่า แต่ถ้าไม่มีค่าให้เป็น key เดิม

  // กำหนดฟังก์ชัน setLocale ที่เป็น Future และไม่มีค่าเป็น async เพื่อเปลี่ยนเป็นภาษาที่เราต้องการ โดยการเปลี่ยนเป็นภาษาที่เราต้องการ และเก็บข้อมูล locale ที่เราต้องการไว้ในตัวแปร _locale และเก็บข้อมูล locale ที่เราต้องการไว้ในกล่องข้อมูลที่เก็บข้อมูลการตั้งค่าของแอพ และโหลดข้อมูล locale ที่เราต้องการ และแจ้งเตือนให้ผู้ฟังเห็นได้ว่าข้อมูลเปลี่ยนแปลง หรือเป็นการเรียกใช้งาน notifyListeners เพื่อให้ผู้ฟังเห็นได้ว่าข้อมูลเปลี่ยนแปลง
  Future<void> setLocale(Locale newLocale) async {
    // ถ้า _locale มีค่าเท่ากับ newLocale ให้หยุดการทำงาน
    if (_locale == newLocale) {
      return;
    }
    // กำหนด _locale ให้เป็น newLocale
    _locale = newLocale;

    // กำหนดตัวแปร box ให้เป็นการเปิดกล่องข้อมูลที่เก็บข้อมูลการตั้งค่าของแอพ หรือสร้างกล่องข้อมูลใหม่ถ้ายังไม่มี
    final box = await Hive.openBox('settings');

    // ให้เก็บข้อมูล locale ที่เราต้องการไว้ในกล่องข้อมูลที่เก็บข้อมูลการตั้งค่าของแอพ โดยให้ key เป็น 'localeCode' และ value เป็น newLocale.languageCode หรือภาษาที่เราต้องการ
    await box.put('localeCode', newLocale.languageCode);

    // เรียกใช้งานฟังก์ชัน loadLanguage เพื่อโหลดข้อมูล locale ที่เราต้องการ
    await loadLanguage();

    // แจ้งเตือนให้ผู้ฟังเห็นได้ว่าข้อมูลเปลี่ยนแปลง หรือเป็นการเรียกใช้งาน notifyListeners เพื่อให้ผู้ฟังเห็นได้ว่าข้อมูลเปลี่ยนแปลง
    notifyListeners();
  }
}
