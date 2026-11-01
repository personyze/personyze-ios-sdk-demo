import PersonyzeNotificationService

/// The demo's Notification Service Extension: Personyze's pushed notifications get their picture and
/// buttons, and are reported shown - all of it the SDK's `PersonyzeNotificationService`. An app's own
/// pushes pass through untouched.
final class NotificationService: PersonyzeNotificationService, @unchecked Sendable
{
}
