import 'package:flutter/material.dart';

class PaymentTypeModal extends StatefulWidget {
  final List<Map<String, dynamic>> options;
  const PaymentTypeModal({super.key, required this.options});

  @override
  State<PaymentTypeModal> createState() => _PaymentTypeModalState();
}

class _PaymentTypeModalState extends State<PaymentTypeModal> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 👈 auto height
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Cancel", style: TextStyle(color: Colors.grey)),
                Text("Payment Type",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text("Clear All", style: TextStyle(color: Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 16),

            // Use shrinkWrap ListView so it only takes as much space as needed
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                var item = widget.options[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item["name"],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black)),
                      Checkbox(
                        value: item["checked"],
                        activeColor: const Color(0xFF6C22A6),
                        onChanged: (val) {
                          setState(() => item["checked"] = val);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C22A6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
