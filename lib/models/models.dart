class Seller {
  final String id;
  final String name;
  final String platform;
  final double monthlyRevenue;
  final double greenScore;
  final double carbonEmission;
  final double returnRate;
  final double customerSatisfaction;
  final bool ecoPackaging;
  final bool ecoLogistics;
  final double creditLimit;
  final double interestRate;
  final String status;
  final double storeRating;
  final double stockVelocity;
  final int totalOrders;

  Seller({
    required this.id,
    required this.name,
    required this.platform,
    this.monthlyRevenue = 0,
    this.greenScore = 0,
    this.carbonEmission = 0,
    this.returnRate = 0,
    this.customerSatisfaction = 0,
    this.ecoPackaging = false,
    this.ecoLogistics = false,
    this.creditLimit = 0,
    this.interestRate = 1.8,
    this.status = 'active',
    this.storeRating = 0,
    this.stockVelocity = 15,
    this.totalOrders = 0,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      platform: json['platform'] ?? 'trendyol',
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      greenScore: (json['green_score'] ?? 0).toDouble(),
      carbonEmission: (json['carbon_emission'] ?? 0).toDouble(),
      returnRate: (json['return_rate'] ?? 0).toDouble(),
      customerSatisfaction: (json['customer_satisfaction'] ?? 0).toDouble(),
      ecoPackaging: json['eco_packaging'] ?? false,
      ecoLogistics: json['eco_logistics'] ?? false,
      creditLimit: (json['credit_limit'] ?? 0).toDouble(),
      interestRate: (json['interest_rate'] ?? 1.8).toDouble(),
      status: json['status'] ?? 'active',
      storeRating: (json['store_rating'] ?? 0).toDouble(),
      stockVelocity: (json['stock_velocity'] ?? 15).toDouble(),
      totalOrders: (json['total_orders'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'platform': platform,
    'monthly_revenue': monthlyRevenue,
    'green_score': greenScore,
    'carbon_emission': carbonEmission,
    'return_rate': returnRate,
    'customer_satisfaction': customerSatisfaction,
    'eco_packaging': ecoPackaging,
    'eco_logistics': ecoLogistics,
    'credit_limit': creditLimit,
    'interest_rate': interestRate,
    'status': status,
    'store_rating': storeRating,
    'stock_velocity': stockVelocity,
    'total_orders': totalOrders,
  };

  double calculateGreenScore() {
    double score = 40;
    if (ecoPackaging) score += 15;
    if (ecoLogistics) score += 20;
    score -= (returnRate * 1.5).clamp(0, 15);
    score += (customerSatisfaction - 3) * 5;
    score += (storeRating - 3) * 3;
    if (stockVelocity < 15) score += 5;
    return score.clamp(0, 100);
  }

  double calculateInterestRate() {
    final score = calculateGreenScore();
    return (2.4 - (score / 100) * 1.6).clamp(0.8, 2.4);
  }

  double calculateCreditLimit() {
    final score = calculateGreenScore();
    return monthlyRevenue * (0.3 + (score / 100) * 0.4);
  }

  Seller copyWith({
    double? greenScore,
    double? interestRate,
    double? creditLimit,
    double? carbonEmission,
  }) {
    return Seller(
      id: id,
      name: name,
      platform: platform,
      monthlyRevenue: monthlyRevenue,
      greenScore: greenScore ?? this.greenScore,
      carbonEmission: carbonEmission ?? this.carbonEmission,
      returnRate: returnRate,
      customerSatisfaction: customerSatisfaction,
      ecoPackaging: ecoPackaging,
      ecoLogistics: ecoLogistics,
      creditLimit: creditLimit ?? this.creditLimit,
      interestRate: interestRate ?? this.interestRate,
      status: status,
      storeRating: storeRating,
      stockVelocity: stockVelocity,
      totalOrders: totalOrders,
    );
  }
}

class CreditApplication {
  final String id;
  final String sellerId;
  final String sellerName;
  final double amount;
  final double interestRate;
  final double greenScoreAtTime;
  final String status;
  final String type;
  final int termDays;
  final DateTime? createdDate;

  CreditApplication({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.amount,
    this.interestRate = 1.8,
    this.greenScoreAtTime = 0,
    this.status = 'pending',
    this.type = 'credit',
    this.termDays = 30,
    this.createdDate,
  });

  factory CreditApplication.fromJson(Map<String, dynamic> json) {
    return CreditApplication(
      id: json['id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      sellerName: json['seller_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      interestRate: (json['interest_rate'] ?? 1.8).toDouble(),
      greenScoreAtTime: (json['green_score_at_time'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      type: json['type'] ?? 'credit',
      termDays: json['term_days'] ?? 30,
      createdDate: json['created_date'] != null
          ? DateTime.tryParse(json['created_date'])
          : null,
    );
  }
}