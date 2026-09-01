// ============================================================================
// ARCHITECTURAL TRACKING METADATA BLOCK
// Architecture Pattern: Asynchronous Consensus Board Workspace
// Component Hierarchy: AsynchronousConsensusBoardWorkspace -> AsynchronousConsensusBoard -> Dismissible Card
// Poka-Yoke: Auto-Abstain Expiration Countdown Timer
// Completion Status: Complete (Ref: AWCV-013-A01)
// ============================================================================

import 'package:flutter/material.dart';
import 'asynchronous_consensus_board.dart';

/// AWCV-013-A01: Asynchronous Consensus Board Standalone Workspace
class AsynchronousConsensusBoardWorkspace extends StatefulWidget {
  const AsynchronousConsensusBoardWorkspace({super.key});

  @override
  State<AsynchronousConsensusBoardWorkspace> createState() =>
      _AsynchronousConsensusBoardWorkspaceState();
}

class _AsynchronousConsensusBoardWorkspaceState
    extends State<AsynchronousConsensusBoardWorkspace> {
  final List<ConsensusProposal> _proposals = const [
    ConsensusProposal(
      id: 'PROP-401',
      title: 'Authorize Multi-Region VPC Peering Migration',
      description:
          'Migrate European regional clusters to private multi-region VPC peering meshes to reduce latency by 35% and eliminate public egress overhead.',
      author: 'VP Infrastructure Architecture',
      category: 'Cloud Networking & Security',
    ),
    ConsensusProposal(
      id: 'PROP-402',
      title: 'Adopt Strict Poka-Yoke Linter Gates Across All Repos',
      description:
          'Enforce compile-time blockers for unvalidated input keys, raw color hexes, and arbitrary font sizing.',
      author: 'Staff Principal Engineer',
      category: 'Developer Velocity & Safety',
    ),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final proposal = _proposals[_currentIndex % _proposals.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AsynchronousConsensusBoard(
          key: ValueKey(proposal.id),
          proposal: proposal,
          initialDurationSeconds: 15,
          onVoteSubmitted: (vote) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Consensus vote "$vote" logged for ${proposal.id}'),
                backgroundColor: vote == 'Agree'
                    ? Colors.green
                    : (vote == 'Disagree' ? Colors.red : Colors.grey),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.skip_next),
            label: const Text('Next Proposal in Queue'),
            onPressed: () {
              setState(() {
                _currentIndex++;
              });
            },
          ),
        ),
      ],
    );
  }
}
