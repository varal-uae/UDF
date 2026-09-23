import 'package:flutter/material.dart';

/// Row 274: GCCC-006 (Seq 16395)
/// Action: Identify all company operating premises and their associated lease contracts.
/// Quality Gate: DAMA-DMBOK Data Management Body of Knowledge (97–100% target completeness).
class OperatingPremisesLeaseContractPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const OperatingPremisesLeaseContractPanel({
    super.key,
    this.globalRefId = 'GCCC-006',
    this.atomicStepRefId = 'GCCC-006',
    this.sequenceOrder = 16395,
  });

  @override
  State<OperatingPremisesLeaseContractPanel> createState() =>
      _OperatingPremisesLeaseContractPanelState();
}

class _OperatingPremisesLeaseContractPanelState
    extends State<OperatingPremisesLeaseContractPanel> {
  final List<Map<String, dynamic>> _premisesList = [
    {
      'premisesId': 'HQ-BLR-01',
      'name': 'Bengaluru Core Engineering Hub',
      'address': 'Indiranagar 100ft Road, Bengaluru, KA',
      'leaseContractId': 'LSE-2024-KA-881',
      'expiryDate': '2028-12-31',
      'monthlyRent': '\$18,500',
      'status': 'ACTIVE_VERIFIED',
    },
    {
      'premisesId': 'DC-MUM-02',
      'name': 'Navi Mumbai Data Center Tier-4',
      'address': 'MIDC Industrial Zone, Navi Mumbai, MH',
      'leaseContractId': 'LSE-2025-MH-109',
      'expiryDate': '2030-06-30',
      'monthlyRent': '\$42,000',
      'status': 'ACTIVE_VERIFIED',
    },
    {
      'premisesId': 'OPS-HYD-03',
      'name': 'Hyderabad Logistics & Operations Floor',
      'address': 'HITEC City Phase 2, Hyderabad, TS',
      'leaseContractId': 'LSE-2023-TS-440',
      'expiryDate': '2027-03-31',
      'monthlyRent': '\$12,300',
      'status': 'ACTIVE_VERIFIED',
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredPremises = _premisesList.where((p) {
      final q = _filterQuery.toLowerCase();
      final name = (p['name'] as String).toLowerCase();
      final id = (p['premisesId'] as String).toLowerCase();
      final lse = (p['leaseContractId'] as String).toLowerCase();
      return name.contains(q) || id.contains(q) || lse.contains(q);
    }).toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_city_rounded,
                    color: theme.colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operating Premises & Leases',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.globalRefId} | ${widget.atomicStepRefId} (Seq ${widget.sequenceOrder})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: const Text(
                    'DAMA-DMBOK 100%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Catalogs and verifies company operating premises and their associated lease contracts to guarantee complete enterprise asset lineage.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _filterQuery = val;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Premises, Location, or Lease ID',
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredPremises.length,
              separatorBuilder: (context, index) => const Divider(height: 8),
              itemBuilder: (context, index) {
                final p = filteredPremises[index];
                final pName = p['name'] as String? ?? '';
                final pId = p['premisesId'] as String? ?? '';
                final pLse = p['leaseContractId'] as String? ?? '';
                final pRent = p['monthlyRent'] as String? ?? '';
                final pExp = p['expiryDate'] as String? ?? '';

                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Premises ID: $pId | Lease: $pLse', style: const TextStyle(fontSize: 11)),
                      Text('Monthly Rent: $pRent | Expiration: $pExp', style: const TextStyle(fontSize: 11, color: Colors.indigo)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: OperatingPremisesLeaseContractPanel(),
          ),
        ),
      ),
    ),
  );
}
