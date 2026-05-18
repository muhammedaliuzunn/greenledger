import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

const _uuid = Uuid();

class DataService {
  static const _sellersKey = 'sellers';
  static const _creditsKey = 'credit_applications';

  // Bellek cache — disk I/O'yu minimuma indirir
  static List<Seller>? _sellersCache;
  static List<CreditApplication>? _creditsCache;
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static void _invalidateCache() {
    _sellersCache = null;
    _creditsCache = null;
  }

  static final List<Map<String, dynamic>> _sampleSellers = [
    {
      'id': '1',
      'name': 'EkoModa Store',
      'platform': 'trendyol',
      'monthly_revenue': 850000.0,
      'green_score': 82.0,
      'carbon_emission': 420.0,
      'return_rate': 3.5,
      'customer_satisfaction': 4.8,
      'eco_packaging': true,
      'eco_logistics': true,
      'credit_limit': 595000.0,
      'interest_rate': 0.94,
      'status': 'active',
      'store_rating': 4.9,
      'stock_velocity': 8.0,
      'total_orders': 12400,
    },
    {
      'id': '2',
      'name': 'TechGadget TR',
      'platform': 'amazon',
      'monthly_revenue': 1200000.0,
      'green_score': 58.0,
      'carbon_emission': 890.0,
      'return_rate': 8.2,
      'customer_satisfaction': 4.1,
      'eco_packaging': false,
      'eco_logistics': true,
      'credit_limit': 636000.0,
      'interest_rate': 1.47,
      'status': 'active',
      'store_rating': 4.2,
      'stock_velocity': 18.0,
      'total_orders': 8900,
    },
    {
      'id': '3',
      'name': 'Doğal Ev',
      'platform': 'hepsiburada',
      'monthly_revenue': 420000.0,
      'green_score': 75.0,
      'carbon_emission': 210.0,
      'return_rate': 4.1,
      'customer_satisfaction': 4.6,
      'eco_packaging': true,
      'eco_logistics': false,
      'credit_limit': 252000.0,
      'interest_rate': 1.2,
      'status': 'active',
      'store_rating': 4.7,
      'stock_velocity': 12.0,
      'total_orders': 5600,
    },
    {
      'id': '4',
      'name': 'SpeedTech',
      'platform': 'n11',
      'monthly_revenue': 680000.0,
      'green_score': 35.0,
      'carbon_emission': 1200.0,
      'return_rate': 14.0,
      'customer_satisfaction': 3.4,
      'eco_packaging': false,
      'eco_logistics': false,
      'credit_limit': 231200.0,
      'interest_rate': 1.96,
      'status': 'active',
      'store_rating': 3.5,
      'stock_velocity': 32.0,
      'total_orders': 3200,
    },
    {
      'id': '5',
      'name': 'HandCraft Studio',
      'platform': 'etsy',
      'monthly_revenue': 95000.0,
      'green_score': 91.0,
      'carbon_emission': 45.0,
      'return_rate': 1.2,
      'customer_satisfaction': 4.9,
      'eco_packaging': true,
      'eco_logistics': true,
      'credit_limit': 85500.0,
      'interest_rate': 0.8,
      'status': 'active',
      'store_rating': 5.0,
      'stock_velocity': 5.0,
      'total_orders': 2800,
    },
  ];

  static final List<Map<String, dynamic>> _sampleCredits = [
    {
      'id': 'c1',
      'seller_id': '1',
      'seller_name': 'EkoModa Store',
      'amount': 595000.0,
      'interest_rate': 0.94,
      'green_score_at_time': 82.0,
      'status': 'disbursed',
      'type': 'credit',
      'term_days': 30,
      'created_date': DateTime.now()
          .subtract(const Duration(days: 15))
          .toIso8601String(),
    },
    {
      'id': 'c2',
      'seller_id': '2',
      'seller_name': 'TechGadget TR',
      'amount': 300000.0,
      'interest_rate': 1.47,
      'green_score_at_time': 58.0,
      'status': 'approved',
      'type': 'factoring',
      'term_days': 45,
      'created_date': DateTime.now()
          .subtract(const Duration(days: 5))
          .toIso8601String(),
    },
    {
      'id': 'c3',
      'seller_id': '3',
      'seller_name': 'Doğal Ev',
      'amount': 150000.0,
      'interest_rate': 1.2,
      'green_score_at_time': 75.0,
      'status': 'pending',
      'type': 'credit',
      'term_days': 30,
      'created_date': DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
    },
  ];

  // Satıcıları getir
  static Future<List<Seller>> getSellers() async {
    if (_sellersCache != null) return List.from(_sellersCache!);
    final prefs = await _getPrefs();
    final data = prefs.getString(_sellersKey);
    late List<Seller> sellers;
    if (data == null) {
      await prefs.setString(_sellersKey, jsonEncode(_sampleSellers));
      sellers = _sampleSellers.map((e) => Seller.fromJson(e)).toList();
    } else {
      final List<dynamic> list = jsonDecode(data);
      sellers = list.map((e) => Seller.fromJson(e)).toList();
    }
    _sellersCache = sellers;
    return List.from(sellers);
  }

  // Satıcı ekle
  static Future<void> addSeller(Seller seller) async {
    final sellers = await getSellers();
    sellers.add(seller);
    _sellersCache = sellers;
    final prefs = await _getPrefs();
    await prefs.setString(
        _sellersKey, jsonEncode(sellers.map((e) => e.toJson()).toList()));
  }

  // Satıcı güncelle
  static Future<void> updateSeller(Seller updated) async {
    final sellers = await getSellers();
    final idx = sellers.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      sellers[idx] = updated;
      _sellersCache = sellers;
      final prefs = await _getPrefs();
      await prefs.setString(
          _sellersKey, jsonEncode(sellers.map((e) => e.toJson()).toList()));
    }
  }

  // Satıcı sil
  static Future<void> deleteSeller(String id) async {
    final sellers = await getSellers();
    sellers.removeWhere((s) => s.id == id);
    _sellersCache = sellers;
    final prefs = await _getPrefs();
    await prefs.setString(
        _sellersKey, jsonEncode(sellers.map((e) => e.toJson()).toList()));
  }

  // Kredi başvurularını getir
  static Future<List<CreditApplication>> getCreditApplications() async {
    if (_creditsCache != null) return List.from(_creditsCache!);
    final prefs = await _getPrefs();
    final data = prefs.getString(_creditsKey);
    late List<CreditApplication> apps;
    if (data == null) {
      await prefs.setString(_creditsKey, jsonEncode(_sampleCredits));
      apps = _sampleCredits.map((e) => CreditApplication.fromJson(e)).toList();
    } else {
      final List<dynamic> list = jsonDecode(data);
      apps = list.map((e) => CreditApplication.fromJson(e)).toList();
    }
    _creditsCache = apps;
    return List.from(apps);
  }

  // Kredi başvurusu ekle
  static Future<void> addCreditApplication(CreditApplication app) async {
    final apps = await getCreditApplications();
    apps.insert(0, app);
    _creditsCache = apps;
    final prefs = await _getPrefs();
    final json = apps
        .map((e) => {
              'id': e.id,
              'seller_id': e.sellerId,
              'seller_name': e.sellerName,
              'amount': e.amount,
              'interest_rate': e.interestRate,
              'green_score_at_time': e.greenScoreAtTime,
              'status': e.status,
              'type': e.type,
              'term_days': e.termDays,
              'created_date': e.createdDate?.toIso8601String(),
            })
        .toList();
    await prefs.setString(_creditsKey, jsonEncode(json));
  }

  // Yeni ID üret
  static String newId() => _uuid.v4().substring(0, 8);
}