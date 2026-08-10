# Collaboration Feature — Invite + Share

**Owner:** @team-collab
**Allowed:** Core/Models Trip TripMember Invite TripShareLink Permission Role, Core/DesignSystem TagChip BadgeView PrimaryButton, SwiftUI ShareLink
**Forbidden:** Other Features

## Purpose
Spec 7: Invite family or friends to shared trip plan + Share vacation plan with others.

## Files
- CollaborationView.swift — trip + inviteEmail State selectedRole TripMemberRole viewer + showShareSheet Bool + tripURL computed https://serperior.travel/trip/<id> + List Section Trip title shared dates + Members ForEach MockDataProvider.collaborators initials circle backgroundSecondary name email Editor badge + Invite Section TextField email keyboard email none role picker + PrimaryButton Send invite TODO invite service + Share Section Generate share link secondary icon link + SwiftUI.ShareLink explicit namespace item tripURL subject Text Join my trip + message Text vacation plan + dateRange + Label Share plan via system sheet + sheet VStack link.circle.fill primary 48 Share Link title2 URL caption1 secondary textSelection enabled PrimaryButton Copy link UIPasteboard + padding medium detent background grouped.

## Models
- TripMember + Invite isPending isExpired + TripShareLink url permission isValid + Permission rank canPerform.

## DI
No service yet — uses MockDataProvider collaborators + trip. Future LiveInviteService.

## TODOs
- Implement invite API sending email + permission handling.
- ShareLink backend generation maxUses expiresAt.
- Permission enforcement UI edit vs view.

## Testing
UITests navigation to collaboration via trip detail.
