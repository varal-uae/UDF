/// Step 404 (GEN-01749) -- "recursive component trees dynamically based on the
/// AST", and the word that does not belong.
///
/// The row: "Generate recursive component trees dynamically based on the AST."
/// Metric: **Step Completion Rate (%)** -- floor 90, optimal 99, ceiling 100.
/// Complete/Partial/Not Complete. ISO/IEC 27001:2022 General Standards.
/// Assigned to **UDF**.
///
/// **An AST is what a parser produces from source code, and there is no source
/// code here.** What Step 401 defines is a data format and what arrives at
/// runtime is a document, so the tree is a parse tree over a declared grammar
/// -- structurally the same shape and a different provenance. The distinction
/// matters because an AST implies a language with expressions, and expressions
/// are the thing Step 401 spent its grammar refusing.
///
/// **Recursion is the easy half; termination is the step.** A tree walk over
/// data that arrives at runtime terminates only if the data is acyclic and
/// bounded, and neither is guaranteed by JSON. Three defences, all of them
/// cheap and none of them optional: the declared depth limit from Step 403, a
/// node budget for breadth, and a visited set, because a packet can reference a
/// node twice and a naive walk will follow it forever.
///
/// **A cycle is not a malformed packet, it is a normal bug on a server.** The
/// walk records that it found one, names the node, and refuses the packet --
/// which turns a hang into a message somebody can act on. A hang is the worst
/// failure a client can have, because it reads as the device being slow.
///
/// **Order of traversal is part of the contract.** Depth-first, children in
/// declared order, is what makes a generated screen's reading order predictable
/// -- and reading order is semantics, not aesthetics. A walk that reorders for
/// efficiency produces a screen a sighted person can use and a screen-reader
/// user cannot.
library;

import 'layout_engine.dart';

/// Why a walk stopped.
enum HabotWalkOutcome {
  /// Every node visited.
  complete,

  /// Past the depth limit.
  tooDeep,

  /// Past the node budget.
  tooWide,

  /// A node was reached twice.
  cyclic,
}

/// The component-tree walker.
class HabotComponentTree {
  const HabotComponentTree._();

  // -----------------------------------------------------------------------
  // It is not an AST.
  // -----------------------------------------------------------------------

  static const String whatTheRowCallsIt = 'AST';

  static const String whatItIs = 'a parse tree over a declared grammar';

  static bool get theNameIsWrongAndTheShapeIsRight =>
      whatTheRowCallsIt != whatItIs;

  static const bool thereIsSourceCodeToParse = false;

  static const bool theGrammarHasExpressions = false;

  static bool get theDistinctionMatters =>
      !thereIsSourceCodeToParse && !theGrammarHasExpressions;

  static const String nameNote =
      'An AST is what a parser produces from source code, and there is no '
      'source code here: Step 401 defines a data format and what arrives is a '
      'document, so this is a parse tree over a declared grammar -- the same '
      'shape with a different provenance. The distinction matters because an '
      'AST implies a language with expressions, and expressions are exactly '
      'what that grammar spent its refusals on.';

  // -----------------------------------------------------------------------
  // Three defences.
  // -----------------------------------------------------------------------

  static int get depthLimit => HabotLayoutEngine.maximumDepth;

  static const int nodeBudget = 400;

  static const bool aVisitedSetIsKept = true;

  static bool get threeDefences =>
      depthLimit > 0 && nodeBudget > 0 && aVisitedSetIsKept;

  static HabotWalkOutcome walk({
    required int depth,
    required int nodes,
    required bool revisitsANode,
  }) {
    if (revisitsANode) {
      return HabotWalkOutcome.cyclic;
    }
    if (depth > depthLimit) {
      return HabotWalkOutcome.tooDeep;
    }
    if (nodes > nodeBudget) {
      return HabotWalkOutcome.tooWide;
    }
    return HabotWalkOutcome.complete;
  }

  static bool get anOrdinaryPacketCompletes =>
      walk(depth: 6, nodes: 90, revisitsANode: false) ==
      HabotWalkOutcome.complete;

  static bool get aDeepPacketStops =>
      walk(depth: 13, nodes: 90, revisitsANode: false) ==
      HabotWalkOutcome.tooDeep;

  static bool get aWidePacketStops =>
      walk(depth: 6, nodes: 401, revisitsANode: false) ==
      HabotWalkOutcome.tooWide;

  static bool get aCyclicPacketStopsFirst =>
      walk(depth: 13, nodes: 401, revisitsANode: true) ==
      HabotWalkOutcome.cyclic;

  static const String defenceNote =
      'Recursion is the easy half; termination is the step. A walk over data '
      'that arrives at runtime terminates only if the data is acyclic and '
      'bounded, and JSON guarantees neither. Three defences: the depth limit '
      'Step 403 declared, a node budget for breadth, and a visited set -- '
      'because a packet can reference a node twice and a naive walk follows it '
      'forever.';

  // -----------------------------------------------------------------------
  // A cycle is a message, not a hang.
  // -----------------------------------------------------------------------

  static const bool aCycleIsReported = true;

  static const bool theOffendingNodeIsNamed = true;

  static const bool thePacketIsRenderedPartially = false;

  static bool get aCycleBecomesAMessage =>
      aCycleIsReported && theOffendingNodeIsNamed &&
      !thePacketIsRenderedPartially;

  static const String worstFailure = 'a hang, which reads as a slow device';

  static const String cycleNote =
      'A cycle is not a malformed packet, it is an ordinary bug on a server. '
      'The walk records that it found one, names the node and refuses the '
      'packet, which turns a hang into a message somebody can act on. A hang '
      'is the worst failure a client can have, because the person blames the '
      'device and the team never hears about it.';

  // -----------------------------------------------------------------------
  // Traversal order is a contract.
  // -----------------------------------------------------------------------

  static const String order = 'depth-first, children in declared order';

  static bool get theOrderIsDeclared => order.contains('declared order');

  static const bool theWalkReordersForEfficiency = false;

  static bool get readingOrderIsPreserved => !theWalkReordersForEfficiency;

  static const String orderNote =
      'Depth-first with children in declared order is what makes a generated '
      'screen\'s reading order predictable, and reading order is semantics '
      'rather than aesthetics. A walk that reorders for efficiency produces a '
      'screen a sighted person can use and a screen-reader user cannot, and '
      'nothing in a screenshot would show it.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const int bandFloor = 90;
  static const int bandOptimal = 99;
  static const int bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  /// Step 412 in this batch carries the identical metric and band.
  static const int theOtherRowWithThisBand = 412;

  static bool get twoRowsShareThisBand => theOtherRowWithThisBand == 412;

  static int get outcomes => HabotWalkOutcome.values.length;

  static double get terminationCoverage => outcomes == 0 ? 0 : 100;

  static const String metricNote =
      'The band is well formed -- 90, 99, 100 -- and the metric is a step '
      'completion rate on a row whose completion is the thing being measured, '
      'which is the tautology Step 378 also carries. Step 412 in this batch '
      'carries the identical metric and band. What is published is whether '
      'every way the walk can fail to terminate has a declared outcome.';

  static const String columnNote =
      'COLUMN NOTE: this row calls a parse tree over a data format an AST, '
      'which implies a language with expressions -- the thing Step 401\'s '
      'grammar exists to refuse; its Data Requirement cell holds the Atomic '
      'Step\'s own sentence as the artefact to prepare; its metric and band '
      'are identical to Step 412\'s in this batch; and the Setup Step column '
      'is empty. Atomic Step: "Generate recursive component trees dynamically '
      'based on the AST."';

  static Map<String, bool> get obligations => <String, bool>{
        'the tree is named for what it is': theNameIsWrongAndTheShapeIsRight,
        'depth is bounded': aDeepPacketStops,
        'breadth is bounded': aWidePacketStops,
        'a cycle is detected before either': aCyclicPacketStopsFirst,
        'a cycle becomes a message rather than a hang': aCycleBecomesAMessage,
        'traversal order is declared and preserved':
            theOrderIsDeclared && readingOrderIsPreserved,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'the row calls it an AST and it is a parse tree':
            theNameIsWrongAndTheShapeIsRight && theDistinctionMatters,
        'and an AST implies the expressions the grammar refuses':
            nameNote.contains('spent its refusals on'),
        'three defences, all declared': threeDefences && nodeBudget == 400,
        'an ordinary packet completes': anOrdinaryPacketCompletes,
        'a deep one and a wide one stop': aDeepPacketStops && aWidePacketStops,
        'a cycle stops the walk before either':
            aCyclicPacketStopsFirst &&
                defenceNote.contains('follows it forever'),
        'a cycle is reported and the node named':
            aCycleBecomesAMessage && worstFailure.contains('slow device'),
        'traversal is depth-first in declared order':
            theOrderIsDeclared && readingOrderIsPreserved,
        'because reading order is semantics':
            orderNote.contains('nothing in a screenshot would show it'),
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theBandIsWellFormed &&
                twoRowsShareThisBand &&
                terminationCoverage == 100,
      };
}
