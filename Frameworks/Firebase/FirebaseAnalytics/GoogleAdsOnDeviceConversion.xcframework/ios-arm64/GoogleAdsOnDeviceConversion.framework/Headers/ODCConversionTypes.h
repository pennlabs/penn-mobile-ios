#import <Foundation/Foundation.h>

/// The type of interaction for fetching conversion info.
typedef NS_ENUM(NSInteger, ODCInteractionType) {
  ODCInteractionTypeInstallation,
  ODCInteractionTypeSessionStart,
} NS_SWIFT_NAME(InteractionType);
