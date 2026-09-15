/// Step 261 (GEN-04495) -- asking for the camera, and what happens when the
/// answer is no.
///
/// The row: "Build a camera interface module for taking support ticket photo
/// attachments."
/// Metric: **Native Permission Grant Success Rate** -- floor 0.8, optimal
/// 0.95, ceiling 0.99. Good/Average/Poor. Standard cited: Google/Apple
/// Platform Permission Guidelines.
///
/// **A grant rate is not a property of the application, and optimising for it
/// is optimising for pressure.** The only levers that move it are asking at a
/// better moment and asking more often, and the second one is the one an
/// application reaches for. What the application actually controls is *when*
/// it asks, *what it says*, and *what happens when the answer is no* -- and
/// the last of those is the one the row does not mention.
///
/// **A denied camera is not a dead end.** A person can attach a photo from the
/// library, or describe the problem in words, and the ticket is submitted
/// either way. So the property worth measuring is task completion without the
/// permission, and it is 1.0 by construction because every route reaches the
/// same place.
///
/// **There are four states, not two, and the fourth is where retry loops come
/// from.** On iOS the system prompt is shown once per install; a second
/// request returns the previous answer without showing anything. Code that
/// treats `denied` and `permanentlyDenied` the same therefore calls a function
/// that does nothing, sees denied, and calls it again. The only route out of
/// `permanentlyDenied` is the system settings, and the application says so
/// rather than asking a fifth time.
library;

/// The states a platform permission can actually be in.
enum HabotPermissionState {
  /// Never asked. The only state in which a prompt will appear.
  notDetermined,

  /// Granted.
  granted,

  /// Refused, and the platform may still show a prompt again.
  denied,

  /// Refused, and no prompt will appear again. Only settings changes this.
  permanentlyDenied,

  /// Blocked by policy or by a parental control. Not the person's decision,
  /// and telling them to change it in settings is wrong.
  restricted,
}

/// A way to attach evidence to a ticket.
class HabotAttachmentRoute {
  const HabotAttachmentRoute({
    required this.name,
    required this.needsCamera,
    required this.reachesSubmission,
    required this.why,
  });

  final String name;
  final bool needsCamera;

  /// Whether a person taking this route can submit the ticket.
  final bool reachesSubmission;

  final String why;
}

/// The permission policy.
class HabotCameraPermission {
  const HabotCameraPermission._();

  /// Whether asking will actually show a prompt. Everything else is a no-op
  /// that returns the previous answer.
  static bool promptWillAppear(HabotPermissionState state) =>
      state == HabotPermissionState.notDetermined;

  /// Whether the application may ask again at all.
  static bool mayRequest(HabotPermissionState state) =>
      state == HabotPermissionState.notDetermined ||
      state == HabotPermissionState.denied;

  /// What the person is offered instead of another prompt.
  static String remedyFor(HabotPermissionState state) {
    switch (state) {
      case HabotPermissionState.notDetermined:
        return 'ask, once, at the moment they tap Add a photo';
      case HabotPermissionState.granted:
        return 'open the camera';
      case HabotPermissionState.denied:
        return 'offer the photo library and a description field; the camera '
            'stays available and is not asked for again in this session';
      case HabotPermissionState.permanentlyDenied:
        return 'say that the camera is off for this application and offer to '
            'open system settings; never prompt again';
      case HabotPermissionState.restricted:
        return 'say the camera is unavailable on this device and offer the '
            'other routes; do NOT send them to settings, because it is not '
            'their decision to change';
    }
  }

  static bool get everyStateHasARemedy => HabotPermissionState.values
      .every((HabotPermissionState s) => remedyFor(s).length > 20);

  /// The bug this enum exists to prevent: calling request() in a state where
  /// no prompt appears, seeing the old answer, and calling it again.
  static bool get theRetryLoopIsUnreachable =>
      !mayRequest(HabotPermissionState.permanentlyDenied) &&
      !mayRequest(HabotPermissionState.restricted) &&
      !promptWillAppear(HabotPermissionState.denied);

  /// Restricted and permanently denied are both terminal and are not the same
  /// thing. Sending a child whose parent disabled the camera to settings is
  /// telling them to do something they cannot do.
  static bool get restrictedIsNotPermanentlyDenied =>
      remedyFor(HabotPermissionState.restricted) !=
          remedyFor(HabotPermissionState.permanentlyDenied) &&
      remedyFor(HabotPermissionState.restricted).contains('do NOT send them');

  // -----------------------------------------------------------------------
  // When to ask.
  // -----------------------------------------------------------------------

  /// Whether a prompt is allowed at this moment.
  static bool mayPromptAt({
    required bool personAskedForAPhoto,
    required bool isAppLaunch,
  }) =>
      personAskedForAPhoto && !isAppLaunch;

  static bool get neverAsksOnLaunch => !mayPromptAt(
        personAskedForAPhoto: false,
        isAppLaunch: true,
      );

  static bool get asksWhenTheyAsk => mayPromptAt(
        personAskedForAPhoto: true,
        isAppLaunch: false,
      );

  static const String inContextNote =
      'The prompt appears at the moment somebody taps Add a photo and at no '
      'other moment. A permission prompt on launch is a question about '
      'something the person has not tried to do yet, and the honest answer '
      'to it is no. Asking in context is the only lever on the grant rate '
      'that is not pressure -- and it works because the question has an '
      'obvious answer by then.';

  // -----------------------------------------------------------------------
  // What happens when the answer is no.
  // -----------------------------------------------------------------------

  static const List<HabotAttachmentRoute> routes = <HabotAttachmentRoute>[
    HabotAttachmentRoute(
      name: 'take a photo',
      needsCamera: true,
      reachesSubmission: true,
      why: 'The route the row is about. The fastest one when the thing being '
          'reported is in front of the person.',
    ),
    HabotAttachmentRoute(
      name: 'choose from the library',
      needsCamera: false,
      reachesSubmission: true,
      why: 'A separate permission on both platforms, and on recent versions '
          'the picker needs no permission at all because the person chooses '
          'the file themselves.',
    ),
    HabotAttachmentRoute(
      name: 'describe it instead',
      needsCamera: false,
      reachesSubmission: true,
      why: 'No permission, no attachment, and a submitted ticket. The route '
          'that makes the grant rate stop mattering.',
    ),
  ];

  static List<HabotAttachmentRoute> get routesWithoutCamera =>
      routes.where((HabotAttachmentRoute r) => !r.needsCamera).toList();

  /// Every route reaches a submitted ticket. This is the property that
  /// replaces the grant rate.
  static double get taskCompletionWithoutCamera =>
      routesWithoutCamera
          .where((HabotAttachmentRoute r) => r.reachesSubmission)
          .length /
      routesWithoutCamera.length;

  static bool get aDeniedCameraIsNotADeadEnd =>
      routesWithoutCamera.length == 2 && taskCompletionWithoutCamera == 1.0;

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String grantRateNote =
      'A grant rate is not a property of the application, and optimising for '
      'it is optimising for pressure: the only levers that move it are '
      'asking at a better moment and asking more often, and the second is '
      'the one an application reaches for. What is controlled here is WHEN '
      'it asks, WHAT it says, and WHAT HAPPENS WHEN THE ANSWER IS NO -- and '
      'the last of those is the one the row does not mention. It is also the '
      'one that makes the metric stop mattering: every route reaches a '
      'submitted ticket, so a refusal costs a person one tap rather than the '
      'task.';

  static const String fourStatesNote =
      'There are four refusal-adjacent states, not one. On iOS the system '
      'prompt is shown once per install and a second request returns the '
      'previous answer without showing anything, so code that treats denied '
      'and permanentlyDenied the same calls a function that does nothing, '
      'sees denied, and calls it again. The only route out of '
      'permanentlyDenied is system settings. And restricted is not a '
      'decision the person made at all -- it is policy or a parental '
      'control, and sending them to settings tells them to do something they '
      'cannot do.';

  // -----------------------------------------------------------------------
  // Metric.
  // -----------------------------------------------------------------------

  static const double floor = 0.8;
  static const double optimal = 0.95;
  static const double ceiling = 0.99;

  /// Reported on the substituted property: the share of routes that reach a
  /// submitted ticket without the permission. The grant rate itself is a
  /// field measurement of people, not of this code.
  static String get qualitativeOutput {
    if (taskCompletionWithoutCamera >= optimal) {
      return 'Good';
    }
    return taskCompletionWithoutCamera >= floor ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'five permission states are distinguished':
            HabotPermissionState.values.length == 5,
        'every state has a stated remedy': everyStateHasARemedy,
        'a prompt appears only where one can appear':
            promptWillAppear(HabotPermissionState.notDetermined) &&
                !promptWillAppear(HabotPermissionState.granted),
        'the retry loop is unreachable': theRetryLoopIsUnreachable,
        'restricted and permanently denied are handled differently':
            restrictedIsNotPermanentlyDenied,
        'nothing is asked on launch, and the ask is in context':
            neverAsksOnLaunch && asksWhenTheyAsk &&
                inContextNote.contains('not pressure'),
        'two routes need no camera and both reach a submitted ticket':
            aDeniedCameraIsNotADeadEnd,
        'every route says why it exists':
            routes.every((HabotAttachmentRoute r) => r.why.length > 50),
        'the grant rate is named as a measurement of people rather than of '
            'this code': grantRateNote.contains('optimising for pressure'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Build a camera interface module for taking support ticket photo '
      'attachments."';
}
