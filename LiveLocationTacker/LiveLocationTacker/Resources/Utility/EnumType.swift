//
//  EnumFile.swift
//  LiveLocationTacker
//
//  Created by Nexios Mac 4 on 15/07/25.
//

import Foundation
import UIKit

enum AnalyticsEventName: String {
    
    //MARK: welcomescreen
    case welcome_click_start
    case strat1_click_next
    case start2_click_next
    case start3_click_next
    
    //MARK: subscription_startscreen
    case subscription_click_yearly
    case subscription_click_monthly
    case subscription_click_weekly
    case subscription_click_continue
    
    //MARK: permission_screen
    case permission_locationsharing_enable
    case permission_locationsharing_disable
    case permission_acesscamera_enable
    case permission_acesscamera_disable
    case permission_notification_enable
    case permission_notification_disable
    case permission_motion_enable
    case permission_motion_disable
    case permission_click_continue
    
    
    //MARK: enternumber_screen
    case enter_click_addnumber
    case enter_click_choose_from_contact
    case enter_click_continue
    
    //MARK: otp_screen
    case otp_click_resend
    case otp_click_verify
    
    
    //MARK: createprofile_screen
    case createprofile_click_uploadphoto
    case createprofile_uploadphoto_click_takephoto
    case createprofile_uploadphoto_click_choose_from_gallery
    case createprofile_uploadphoto_click_cancel
    case createprofile_click_entername
    case createprofile_click_male
    case createprofile_clik_female
    case createprofile_click_done
    
    //MARK:  home_screen
    case home_click_circle
    case home_click_compass
    case home_click_setting
    case home_click_sos
    case home_click_premium
    case home_click_addmember
    
    //MARK:  addmember_screen
//    case addmember_click_scanqr
//    case addmember_click_shareqr
    case addmember_click_addinvitecode
    case addmember_click_joincircle
    
    //MARK:  sos_screen
    case sos_click_stop
    
    //MARK:  circle_screen
    case circle_click_create
    case circle_click_join
    
    //MARK:  map_screen
    case map_click_standard
    case map_click_satellite
    case map_click_hybrid
    
    //MARK:  setting_screen
    case setting_click_profile
    case setting_click_premium
    case setting_locationsharing_enable
    case setting_locationsharing_diable
    case setting_batterylevalsharing_enable
    case setting_betterylevalsharing_diable
    case setting_notification_enable
    case setting_notification_diable
    case setting_accesscamera_enable
    case setting_accesscamera_disable
    case setting_motion_enable
    case setting_motion_disable
    case setting_darkmode_enable
    case setting_darkmode_disable
    case setting_click_childmode
    case setting_click_ratenow
    case setting_click_share
    case setting_click_feedback
    case setting_click_privecy_policy
    case setting_click_terms
    case setting_click_subscription
    
    //MARK:  profile_screen
    case profile_click_uploadphoto
    case profile_uploadphoto_click_takephoto
    case profile_uploadphoto_click_choose_from_gallery
    case profile_uploadphoto_click_cancel
    case profile_click_entername
    case profile_click_male
    case profile_clik_female
    case profile_click_update
    case profile_click_delete
    case profile_delete_click_yes
    case profile_delete_click_no
    
    //MARK:  subscription_screen
    case subscription_click_
    //case subscription_click_continue
    case subscription_click_changeplan
    case subscription_click_manageplan
    case subscription_click_subscribeplan
    
    //MARK:  childmode_screen
    case childmode_click_enable
    case childmode_click_circle
    case childmode_click_setting
    case childmode_click_invite
    
    //MARK: childmode_setting_screen
   case childmode_setting_click_profile
   case childmode_setting_click_childmode
   case childmode_setting_click_rateus
   case childmode_setting_click_share
   case childmode_setting_click_feedback
   case childmode_setting_click_privacy
   case childmode_setting_click_terms
   case childmode_darkmode_enable
   case childmode_darkmode_diable

   case setting_childmode_click_diable
   case setting_childmode_diable_click_send
   case setting_childmode_diable_click_cancel

//    case clickAddMemberButton = "click_add_member_button"
//    case clickSubscribeButton = "click_subscribe_button"
//    case clickShowCircleList = "click_show_circle_list"
//    case clickMapTypeButton = "click_map_type_button"
//    case clickCurrentLocationButton = "click_current_location_button"
//    case clickSosButton = "click_sos_button"
//    case clickListUser = "click_list_user"
//    case clickMapPin = "click_map_pin"
//    case clickUserInfoInMapPin = "click_user_info_in_map_pin"
//    case changeMapStyle = "change_map_style"
//    case clickCreateCircleButton = "click_create_circle_button"
//    case clickJoinCircleButton = "click_join_circle_button"
//    case changeCircleSelection = "change_circle_selection"
//    case clickShareCircleCodeButton = "click_share_circle_code_button"
//    case joinCircle = "join_circle"
//    
//    case clickProfile = "click_profile"
//    case clickViewPlan = "click_view_plan"
//    case toggleLocationSharing = "toggle_location_sharing"
//    case toggleBatteryLevelSharing = "toggle_battery_level_sharing"
//    case togglePlaceNotification = "toggle_place_notifications"
//    case toggleAccessCamera = "toggle_access_camera"
//    case toggleMotionActivity = "toggle_motion_activity"
//    case clickChildMode = "click_child_mode"
//    case clickRate = "click_rate"
//    case clickShareApp = "click_share_app"
//    case clickFeedback = "click_feedback"
//    case clickPrivacyPolicy = "click_privacy_policy"
//    case clickTermCondition = "click_term_condition"
//    case clickRestorePurchase = "click_restore_purchase"
//    case clickInactivePurchase = "click_inactive_purchase"
//    case clickChangeProfileImage = "click_change_profile_image"
//    case clickChangeName = "click_change_name"
//    case updateProfile = "update_profile"
//    case updateGender = "update_gender"
//    case deleteAccount = "delete_account"
//    case clickPurchaseSubscriptions = "click_purchase_subscriptions"
//    case clickInviteUser = "click_invite_user"
//    case childModeEnabled = "child_mode_enabled"
//    case childModeDisable = "child_mode_disable"
//    case sendChildModeDisableRequest = "send_child_mode_disable_request"
//    
//    case clickStartApp = "click_start_app"
//    case clickOnBoardNext = "click_on_board_next"
//    case clickPermissionNext = "click_permission_next"
//    case clickSendOTP = "click_send_otp"
//    case clickCountryPicker = "click_country_picker"
//    case clickChooseFromContact = "click_choose_from_contact"
//    case clickVerifyOTP = "click_verify_otp"
}

enum AdDisplayPreference: String {
    case yes  // show ads
    case no   // do not show ads
    case none // do not load ads at all
}

extension AdDisplayPreference {
    init?(caseInsensitive rawValue: String) {
        self.init(rawValue: rawValue.lowercased())
    }
}
