/// AISS: BPTR-0160-A01 -- "Code and isolate mobile compound fields into
/// distinct, standalone UI components featuring strict 48x48dp touch targets."
///
/// Setup Step Description: "Identify all compound entry fields (e.g., split
/// address blocks, combined date-time fields) in mobile views."
/// Completion Measure: `Invalid_Data_Type_Errors == 0`.
///
/// A compound field is one logical value made of several inputs. Left as loose
/// TextFields on a screen, each part drifts: one gets a numeric keyboard and
/// one does not, one validates on blur and one on submit. Isolating them as
/// components is what makes the completion measure achievable at all.
library;

import 'package:flutter/material.dart';

import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'field_validation.dart';
import 'form_gate.dart';
import 'validated_input_field.dart';

/// One part of a compound field.
class CompoundPart {
  const CompoundPart({
    required this.name,
    required this.label,
    required this.cde,
    this.required = true,
    this.flex = 1,
  });

  final String name;
  final String label;
  final HabotCde cde;
  final bool required;

  /// Relative width within the compound row. Clamped by the grid.
  final int flex;
}

/// The catalogue of compound fields the app supports. Declared as data so the
/// "identify all compound entry fields" audit has something to be checked
/// against, rather than living in whichever screen happened to need one.
class HabotCompoundFields {
  const HabotCompoundFields._();

  static const List<CompoundPart> addressBlock = <CompoundPart>[
    CompoundPart(
      name: 'address.line1',
      label: 'Street address',
      cde: HabotCde.addressLine,
      flex: 3,
    ),
    CompoundPart(
      name: 'address.line2',
      label: 'Apartment, suite',
      cde: HabotCde.addressLine,
      required: false,
      flex: 3,
    ),
    CompoundPart(
      name: 'address.city',
      label: 'City',
      cde: HabotCde.personName,
      flex: 2,
    ),
    CompoundPart(
      name: 'address.postal',
      label: 'Postal code',
      cde: HabotCde.postalCode,
      flex: 1,
    ),
  ];

  static const List<CompoundPart> dateTimeBlock = <CompoundPart>[
    CompoundPart(
      name: 'when.date',
      label: 'Date',
      cde: HabotCde.dateIso,
      flex: 2,
    ),
    CompoundPart(
      name: 'when.time',
      label: 'Time',
      cde: HabotCde.timeOfDay,
      flex: 1,
    ),
  ];

  static const List<CompoundPart> contactBlock = <CompoundPart>[
    CompoundPart(
      name: 'contact.name',
      label: 'Full name',
      cde: HabotCde.personName,
      flex: 2,
    ),
    CompoundPart(
      name: 'contact.phone',
      label: 'Phone',
      cde: HabotCde.phoneNumber,
      flex: 1,
    ),
    CompoundPart(
      name: 'contact.email',
      label: 'Email',
      cde: HabotCde.emailAddress,
      flex: 2,
    ),
  ];

  static const List<CompoundPart> amountBlock = <CompoundPart>[
    CompoundPart(
      name: 'amount.value',
      label: 'Amount',
      cde: HabotCde.currencyAmount,
      flex: 2,
    ),
    CompoundPart(
      name: 'amount.quantity',
      label: 'Quantity',
      cde: HabotCde.quantity,
      flex: 1,
    ),
  ];

  static const Map<String, List<CompoundPart>> all =
      <String, List<CompoundPart>>{
        'address': addressBlock,
        'dateTime': dateTimeBlock,
        'contact': contactBlock,
        'amount': amountBlock,
      };

  /// Every part across every block. Used by the identification-accuracy gate.
  static List<CompoundPart> get allParts => all.values
      .expand((List<CompoundPart> parts) => parts)
      .toList(growable: false);
}

/// Renders a compound field. Stacks on compact viewports (one input per row,
/// which is the only way each part keeps a comfortable target), and lays parts
/// side by side once there is room.
class CompoundField extends StatelessWidget {
  const CompoundField({
    required this.parts,
    required this.gate,
    this.title,
    super.key,
  });

  final List<CompoundPart> parts;
  final HabotFormGate gate;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stack =
            HabotGrid.windowClassFor(constraints.maxWidth) ==
            HabotWindowClass.compact;

        final List<Widget> fields = <Widget>[
          for (final CompoundPart part in parts)
            ValidatedInputField(
              fieldName: part.name,
              label: part.label,
              cde: part.cde,
              gate: gate,
              required: part.required,
            ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: HabotSpacing.xs),
                child: Text(title!, style: theme.textTheme.titleSmall),
              ),
            if (stack)
              for (int i = 0; i < fields.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: HabotGrid.verticalRhythm),
                fields[i],
              ]
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (int i = 0; i < fields.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: HabotGrid.gutter),
                    Expanded(flex: parts[i].flex, child: fields[i]),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}
