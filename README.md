# MaskView
you can push/present Custom Control like UIActionSheetView  UIAlertView NotificationView and so on
you can use like this

present customController like ActionSheet

CustomController *actionSheetView = [[CustomController_ActionSheet alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
[MaskView showActionSheetTypeView:actionSheetView maskViewTouchableDismiss:YES];

present customController like AlertView
CustomController *alertView = [[CustomController_Alert alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
[MaskView showAlertTypeView:alertView maskViewTouchableDismiss:YES];

MaskViewType has this types

MaskViewAlertType = 1,
MaskViewActionSheetType,
MaskViewNotificationType, // have blackground
MaskViewNotificationClearType, // no blackground
