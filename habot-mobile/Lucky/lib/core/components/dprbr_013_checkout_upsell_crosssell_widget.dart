// DPRBR-013 — Checkout up-sell/cross-sell decision point UI.
// Renders Material 3 side-by-side service-tier cards with outlined text fields and responsive state retention.
import 'package:flutter/material.dart';

class Dprbr013CheckoutUpsellCrossSellWidget extends StatefulWidget {
  const Dprbr013CheckoutUpsellCrossSellWidget({super.key});

  @override
  State<Dprbr013CheckoutUpsellCrossSellWidget> createState() => _Dprbr013CheckoutUpsellCrossSellWidgetState();
}

class _Dprbr013CheckoutUpsellCrossSellWidgetState extends State<Dprbr013CheckoutUpsellCrossSellWidget> {
  final _formKey = GlobalKey<FormState>();
  final _promoController = TextEditingController();
  String? _selectedTier = 'standard';

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const spacing = 8.0;
    const horizontalPadding = 16.0;
    const minInputHeight = 56.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout options')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: spacing),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Enhance your plan', style: theme.textTheme.titleLarge),
                const SizedBox(height: spacing),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;
                    final cards = _buildTierCards(context);
                    if (isNarrow) {
                      return Column(
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            cards[i],
                            if (i != cards.length - 1) const SizedBox(height: spacing),
                          ],
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < cards.length; i++) ...[
                          Expanded(child: cards[i]),
                          if (i != cards.length - 1) const SizedBox(width: spacing),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: spacing * 2),
                TextFormField(
                  controller: _promoController,
                  minLines: 1,
                  maxLines: 1,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Promo code',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: (minInputHeight - 24) / 2),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    if (value.trim().length < 3) return 'Enter a valid code';
                    return null;
                  },
                ),
                const SizedBox(height: spacing),
                FilledButton.icon(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Decision point: apply upsell/cross-sell selection.
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Apply selection'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTierCards(BuildContext context) {
    final theme = Theme.of(context);
    final tiers = <_Tier>[
      const _Tier(id: 'basic', title: 'Basic', price: r'$9', features: ['Core access', 'Email support']),
      const _Tier(id: 'standard', title: 'Standard', price: r'$19', features: ['Everything in Basic', 'Priority support']),
      const _Tier(id: 'premium', title: 'Premium', price: r'$29', features: ['Everything in Standard', 'Advanced analytics']),
    ];
    return tiers.map((tier) {
      final selected = _selectedTier == tier.id;
      return Card(
        elevation: selected ? 6 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tier.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(tier.price, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              for (final feature in tier.features)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(feature, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => setState(() => _selectedTier = tier.id),
                child: Text(selected ? 'Selected' : 'Choose'),
              ),
            ],
          ),
        ),
      );
    }).toList(growable: false);
  }
}

class _Tier {
  const _Tier({required this.id, required this.title, required this.price, required this.features});
  final String id;
  final String title;
  final String price;
  final List<String> features;
}
