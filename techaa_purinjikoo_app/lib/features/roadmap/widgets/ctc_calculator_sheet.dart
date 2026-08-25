import 'package:flutter/material.dart';

class CtcCalculatorSheet extends StatefulWidget {
  const CtcCalculatorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CtcCalculatorSheet(),
    );
  }

  @override
  State<CtcCalculatorSheet> createState() => _CtcCalculatorSheetState();
}

class _CtcCalculatorSheetState extends State<CtcCalculatorSheet> {
  double _ctcLpa = 6.0; // In Lakhs
  bool _isMetro = true;

  // Calculation Logic
  double get _annualCtc => _ctcLpa * 100000;
  double get _basicAnnual => _annualCtc * 0.40;
  double get _epfMonthly => (_basicAnnual * 0.12) / 12;
  double get _gratuityMonthly => (_basicAnnual * 0.0481) / 12;
  double get _profTaxMonthly => _isMetro ? 200.0 : 0.0;

  double get _taxMonthly {
    // New Tax Regime Simplified for Freshers (Nil up to 7 LPA rebate)
    if (_ctcLpa <= 7.0) return 0.0;
    if (_ctcLpa <= 10.0) return ((_annualCtc - 700000) * 0.10) / 12;
    if (_ctcLpa <= 15.0) return (30000 + (_annualCtc - 1000000) * 0.15) / 12;
    return (105000 + (_annualCtc - 1500000) * 0.30) / 12;
  }

  double get _monthlyInHand {
    final grossMonthly = _annualCtc / 12;
    final totalDeductions = _epfMonthly + _gratuityMonthly + _profTaxMonthly + _taxMonthly;
    final net = grossMonthly - totalDeductions;
    return net > 0 ? net : 0;
  }

  String get _techaaVerdict {
    if (_ctcLpa <= 4.0) {
      return '“Kanna... idhula PF + Insurance poga in-hand ₹24,000 varum. Skills build pannu, 1 year-la 3x package switch pannalam! 🚀”';
    } else if (_ctcLpa <= 8.0) {
      return '“CTC 6 LPA nu potrukanga da nu ₹50,000 kanavu kaanadha! Account-la ₹42,500 dhaan varum. Aana fresher-ku semma start! 💰”';
    } else if (_ctcLpa <= 15.0) {
      return '“Mass package da! In-hand around ₹82,000 varum. Swiggy-la daily order pannama savings & stocks-la invest pannu! 📈”';
    } else {
      return '“Gethu product company package! In-hand ₹1.2L+ varum. Tax-e ₹25k+ pudipaanga aana high life! 👑”';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0F1423),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calculate_rounded, color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💰 CTC vs In-Hand Calculator',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Know your real take-home salary before signing offer letter',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0x1AFFFFFF), height: 20),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // In-hand Highlight Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ESTIMATED MONTHLY IN-HAND CASH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6EE7B7),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${_monthlyInHand.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gross: ₹${(_annualCtc / 12).toStringAsFixed(0)}/mo  •  Package: ${_ctcLpa.toStringAsFixed(1)} LPA',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CTC Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Annual CTC Offer:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_ctcLpa.toStringAsFixed(1)} LPA',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF38BDF8)),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _ctcLpa,
                  min: 2.0,
                  max: 40.0,
                  divisions: 76,
                  activeColor: const Color(0xFF10B981),
                  inactiveColor: Colors.white12,
                  onChanged: (val) {
                    setState(() {
                      _ctcLpa = val;
                    });
                  },
                ),

                const SizedBox(height: 10),

                // Metro switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Metro City (Chennai/Bangalore/Hyd/Mumbai)',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Includes ₹200 Professional Tax deduction',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  value: _isMetro,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (val) {
                    setState(() {
                      _isMetro = val;
                    });
                  },
                ),

                const SizedBox(height: 14),

                // Monthly Deductions Table
                const Text(
                  '📊 Monthly Salary Breakdown:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 10),

                _buildRow('Basic Pay (40%)', '₹${(_basicAnnual / 12).toStringAsFixed(0)}', const Color(0xFFCBD5E1)),
                _buildRow('Employee PF (12%)', '- ₹${_epfMonthly.toStringAsFixed(0)}', const Color(0xFFF87171)),
                _buildRow('Gratuity Provision', '- ₹${_gratuityMonthly.toStringAsFixed(0)}', const Color(0xFFF87171)),
                _buildRow('Income Tax (TDS)', '- ₹${_taxMonthly.toStringAsFixed(0)}', const Color(0xFFF87171)),
                if (_isMetro) _buildRow('Professional Tax', '- ₹200', const Color(0xFFF87171)),

                const Divider(color: Color(0x1AFFFFFF), height: 20),

                // Techaa Tanglish Punchline Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🚀', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Techaa Advice:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFFBBF24)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _techaaVerdict,
                              style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color valColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: valColor)),
        ],
      ),
    );
  }
}
