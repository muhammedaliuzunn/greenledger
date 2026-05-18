import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class GeminiService {
  static const String _apiKey = geminiApiKey;
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent';

  // 429 retry mekanizması
  static Future<String> ask(String prompt,
      {String? systemInstruction, int retryCount = 0}) async {
    try {
      final body = <String, dynamic>{
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 2048,
        },
      };

      if (systemInstruction != null) {
        body['systemInstruction'] = {
          'parts': [
            {'text': systemInstruction}
          ]
        };
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 429) {
        if (retryCount < 1) {
          await Future.delayed(const Duration(seconds: 3));
          return ask(prompt,
              systemInstruction: systemInstruction,
              retryCount: retryCount + 1);
        }
        throw Exception('Sunucu meşgul. Lütfen 1 dakika bekleyip tekrar deneyin.');
      }

      if (response.statusCode != 200) {
        throw Exception('API hatası: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } on TimeoutException {
      throw Exception('Bağlantı zaman aşımına uğradı. Tekrar deneyin.');
    } catch (e) {
      if (e.toString().contains('429')) {
        throw Exception('Çok fazla istek. Lütfen 1 dakika bekleyin.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> askJSON(String prompt,
      {String? systemInstruction}) async {
    final fullPrompt =
        '$prompt\n\nSadece geçerli JSON döndür, başka hiçbir şey yazma. Markdown kullanma.';
    final text =
        await ask(fullPrompt, systemInstruction: systemInstruction);

    String cleaned =
        text.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start != -1 && end != -1) {
        return jsonDecode(cleaned.substring(start, end + 1))
            as Map<String, dynamic>;
      }
      throw Exception('Geçersiz yanıt alındı. Tekrar deneyin.');
    }
  }

  static Future<Map<String, dynamic>> analyzeGreenScore(
      Map<String, dynamic> seller, {String lang = 'TR'}) async {
    final isEN = lang == 'EN';
    return askJSON(
      '''${isEN ? 'E-commerce seller sustainability analysis' : 'E-ticaret satıcısı sürdürülebilirlik analizi'}:
${isEN ? 'Seller' : 'Satıcı'}: ${seller['name']} (${seller['platform']})
${isEN ? 'Revenue' : 'Ciro'}: ₺${seller['monthly_revenue'] ?? 0}
GreenScore: ${seller['green_score'] ?? 0}/100
${isEN ? 'Carbon' : 'Karbon'}: ${seller['carbon_emission'] ?? 0} kg CO₂
${isEN ? 'Return rate' : 'İade'}: %${seller['return_rate'] ?? 0}
${isEN ? 'Satisfaction' : 'Memnuniyet'}: ${seller['customer_satisfaction'] ?? 0}/5
${isEN ? 'Eco Packaging' : 'Eko Paket'}: ${seller['eco_packaging'] == true ? (isEN ? 'Yes' : 'Evet') : (isEN ? 'No' : 'Hayır')}
${isEN ? 'Green Logistics' : 'Yeşil Lojistik'}: ${seller['eco_logistics'] == true ? (isEN ? 'Yes' : 'Evet') : (isEN ? 'No' : 'Hayır')}

JSON:
{
  "genel_degerlendirme": "string",
  "guclu_yonler": ["string", "string", "string"],
  "zayif_yonler": ["string", "string", "string"],
  "oncelikli_adimlar": [{"adim": "string", "etki": "yuksek|orta|dusuk", "aciklama": "string"}],
  "tahmini_yeni_skor": number,
  "karbon_azaltma_potansiyeli": "string",
  "faiz_indirimi_potansiyeli": "string"
}''',
      systemInstruction: isEN
          ? 'You are a sustainability expert. Give short, clear answers in English.'
          : 'Sürdürülebilirlik uzmanısın. Kısa ve net Türkçe yanıt ver.',
    );
  }

  static Future<Map<String, dynamic>> analyzeCreditRisk(
      Map<String, dynamic> seller, {String lang = 'TR'}) async {
    final isEN = lang == 'EN';
    return askJSON(
      '''${isEN ? 'Credit risk analysis' : 'Kredi risk analizi'}:
${isEN ? 'Seller' : 'Satıcı'}: ${seller['name']} (${seller['platform']})
${isEN ? 'Revenue' : 'Ciro'}: ₺${seller['monthly_revenue'] ?? 0}
GreenScore: ${seller['green_score'] ?? 0}/100
${isEN ? 'Return rate' : 'İade'}: %${seller['return_rate'] ?? 0}
${isEN ? 'Satisfaction' : 'Memnuniyet'}: ${seller['customer_satisfaction'] ?? 0}/5
${isEN ? 'Eco Packaging' : 'Eko Paket'}: ${seller['eco_packaging'] == true ? (isEN ? 'Yes' : 'Evet') : (isEN ? 'No' : 'Hayır')}
${isEN ? 'Green Logistics' : 'Yeşil Lojistik'}: ${seller['eco_logistics'] == true ? (isEN ? 'Yes' : 'Evet') : (isEN ? 'No' : 'Hayır')}

JSON:
{
  "risk_seviyesi": "dusuk|orta|yuksek",
  "risk_skoru": number,
  "kredi_karari": "onaylansin|incelensin|reddedilsin",
  "karar_gerekce": "string",
  "onerilen_limit": number,
  "onerilen_faiz": number,
  "risk_faktorleri": [{"faktor": "string", "agirlik": "yuksek|orta|dusuk", "durum": "pozitif|negatif"}],
  "6_ay_tahmin": "string"
}''',
      systemInstruction: isEN
          ? 'You are a fintech credit analyst. Answer in English.'
          : 'Fintech kredi analistisin. Türkçe yanıt ver.',
    );
  }

  static Future<Map<String, dynamic>> askJSON2(
      String prompt, String systemInstruction) async {
    return askJSON(prompt, systemInstruction: systemInstruction);
  }

  static Future<String> chatWithCoach(
      String message, Map<String, dynamic>? seller, {String lang = 'TR'}) async {
    final isEN = lang == 'EN';
    final context = seller != null
        ? '${isEN ? 'Seller' : 'Satıcı'}: ${seller['name']}, GreenScore: ${seller['green_score'] ?? 0}, ${isEN ? 'Revenue' : 'Ciro'}: ₺${seller['monthly_revenue'] ?? 0}\n'
        : '';
    return ask(
      '$context\n${isEN ? 'User' : 'Kullanıcı'}: $message',
      systemInstruction: isEN
          ? 'You are a GreenLedger e-commerce coach. Give short, practical advice in English. Max 3 sentences.'
          : 'GreenLedger e-ticaret koçusun. Kısa, pratik Türkçe tavsiyeler ver. Max 3 cümle.',
    );
  }
}