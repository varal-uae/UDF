import 'package:flutter/material.dart';

/// Row 294: GEN-00208 (Seq 16917)
/// Action: Ingest material_color_token_hex as a string field.
/// Quality Gate: JSON Schema Specification (Draft 2020-12) / OpenAPI 3.0 Hex String Standard.
class MaterialColorTokenIngestionPanel extends StatefulWidget {
  final String globalRefId;
  final String atomicStepRefId;
  final int sequenceOrder;

  const MaterialColorTokenIngestionPanel({
    super.key,
    this.globalRefId = 'GEN-00208',
    this.atomicStepRefId = 'GEN-00208',
    this.sequenceOrder = 16917,
  });

  @override
  State<MaterialColorTokenIngestionPanel> createState() =>
      _MaterialColorTokenIngestionPanelState();
}

class _MaterialColorTokenIngestionPanelState
    extends State<MaterialColorTokenIngestionPanel> {
  final TextEditingController _hexController =
      TextEditingController(text: '#6750A4');
  String _ingestedHex = '#6750A4';
  Color _parsedColor = const Color(0xFF6750A4);
  bool _isValidHex = true;
  String _validationMsg = 'Valid 6-digit RGB hex string';

  void _validateAndIngest(String input) {
    final cleanInput = input.trim();
    final hexRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$');
    if (hexRegex.hasMatch(cleanInput)) {
      final hexDigits = cleanInput.replaceAll('#', '');
      final intVal = int.parse(
        hexDigits.length == 6 ? 'FF$hexDigits' : hexDigits,
        radix: 16,
      );
      setState(() {
        _isValidHex = true;
        _ingestedHex = cleanInput;
        _parsedColor = Color(intVal);
        _validationMsg = 'Schema Valid: Ingested as string "$cleanInput"';
      });
    } else {
      setState(() {
        _isValidHex = false;
        _validationMsg = r'Schema Error: Must match ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$';
      });
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.palette_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Material Color Hex Ingestion',
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
                    color: _isValidHex
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isValidHex ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    _isValidHex ? 'SCHEMA PASS' : 'INVALID HEX',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _isValidHex ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ingests material_color_token_hex as a validated string field conforming to JSON Schema Draft 2020-12 and OpenAPI 3.0 hex token specifications.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hexController,
                    decoration: InputDecoration(
                      labelText: 'material_color_token_hex',
                      hintText: '#6750A4 or #FF6750A4',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      errorText: _isValidHex ? null : 'Invalid Hex Format',
                    ),
                    onChanged: _validateAndIngest,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isValidHex ? _parsedColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ingested Field Value', style: TextStyle(fontSize: 11)),
                      Text(
                        _ingestedHex,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Field Type Contract', style: TextStyle(fontSize: 11)),
                      Text('string (hex)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _validationMsg,
              style: TextStyle(
                fontSize: 11,
                color: _isValidHex ? Colors.green : Colors.red,
              ),
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
            child: MaterialColorTokenIngestionPanel(),
          ),
        ),
      ),
    ),
  );
}
