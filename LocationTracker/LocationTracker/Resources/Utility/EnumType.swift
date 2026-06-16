//
//  EnumType.swift
//  LocationTracker
//
//  Created by Vishal Vaghasiya on 05/08/25.
//
import UIKit

enum AppWindow {
    static var current: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: { $0.isKeyWindow })
    }
}


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

enum LanguageType: Int {
    case NONE = 0
    case English = 1
    case Spanish = 2
    case German = 3
    case French = 4
    case Hausa = 5
    case Italian = 6
    case Japanese = 7
    case Malay = 8
    case Dutch = 9
    case Polish = 10
    case Hindi = 11
    case Portuguese = 12
    case Romanian = 13
    case Swedish = 14
    case Thai = 15
    case Turkish = 16
    case Vietnamese = 17
    case Bulgarian = 18
    case Danish = 19
    case Filipino = 20
    case Russian = 21
    case Indonesian = 22
    case Greek = 23
    case Latvian = 24
    case Somali = 25
    case Afrikaans = 26
    case Latin = 27
    
    var value: String {
        switch self{
        case .NONE : return ("")
        case .English : return ("English")
        case .Spanish : return ("Spanish")
        case .German : return ("German")
        case .French : return ("French")
        case .Hausa : return ("Hausa")
        case .Italian : return ("Italian")
        case .Japanese : return ("Japanese")
        case .Malay : return ("Malay")
        case .Dutch : return ("Dutch")
        case .Polish : return ("Polish")
        case .Hindi : return ("Hindi")
        case .Portuguese : return ("Portuguese")
        case .Romanian : return ("Romanian")
        case .Swedish : return ("Swedish")
        case .Thai : return ("Thai")
        case .Turkish : return ("Turkish")
        case .Vietnamese : return ("Vietnamese")
        case .Bulgarian : return ("Bulgarian")
        case .Danish : return ("Danish")
        case .Filipino : return ("Filipino")
        case .Russian : return ("Russian")
        case .Indonesian : return ("Indonesian")
        case .Greek : return ("Greek")
        case .Latvian : return ("Latvian")
        case .Somali : return ("Somali")
        case .Afrikaans : return ("Afrikaans")
        case .Latin  : return ("Latin ")
        }
    }
    
    var languageText: String {
        switch self{
        case .NONE : return ("")
        case .English : return ("English")
        case .Spanish : return ("Española")
        case .German : return ("Deutsch")
        case .French : return ("français")
        case .Hausa : return ("Hausa")
        case .Italian : return ("Italian")
        case .Japanese : return ("日本")
        case .Malay : return ("Melayu")
        case .Dutch : return ("Nederland")
        case .Polish : return ("Polanski")
        case .Hindi : return ("हिन्दी")
        case .Portuguese : return ("Portuguese")
        case .Romanian : return ("Română")
        case .Swedish : return ("svenska")
        case .Thai : return ("ไทย")
        case .Turkish : return ("Türk")
        case .Vietnamese : return ("tiếng Việt")
        case .Bulgarian : return ("български")
        case .Danish : return ("dansk")
        case .Filipino : return ("Filipino")
        case .Russian : return ("русский")
        case .Indonesian : return ("Bahasa Indonesia")
        case .Greek : return ("Ελληνικά")
        case .Latvian : return ("latviski")
        case .Somali : return ("somaliyeed")
        case .Afrikaans : return ("Afrikaans")
        case .Latin  : return ("Latin ")
        }
    }
    
    var icon: UIImage {
        switch self{
        case .NONE : return UIImage()
        case .English : return Asset.iconFlagEnglish.image
        case .Spanish : return Asset.iconFlagSpanish.image
        case .German : return Asset.iconFlagGerman.image
        case .French : return Asset.iconFlagFrench.image
        case .Hausa : return Asset.iconFlagHausa.image
        case .Italian : return Asset.iconFlagItalian.image
        case .Japanese : return Asset.iconFlagJapanese.image
        case .Malay : return Asset.iconFlagMalay.image
        case .Dutch : return Asset.iconFlagDutch.image
        case .Polish : return Asset.iconFlagPolish.image
        case .Hindi : return Asset.iconFlagHindi.image
        case .Portuguese : return Asset.iconFlagPortuguese.image
        case .Romanian : return Asset.iconFlagRomanian.image
        case .Swedish : return Asset.iconFlagSwedish.image
        case .Thai : return Asset.iconFlagThai.image
        case .Turkish : return Asset.iconFlagTurkish.image
        case .Vietnamese : return Asset.iconFlagVietnamese.image
        case .Bulgarian : return Asset.iconFlagBulgarian.image
        case .Danish : return Asset.iconFlagDanish.image
        case .Filipino : return Asset.iconFlagFilipino.image
        case .Russian : return Asset.iconFlagRussian.image
        case .Indonesian : return Asset.iconFlagIndonesian.image
        case .Greek : return Asset.iconFlagGreek.image
        case .Latvian : return Asset.iconFlagLatvian.image
        case .Somali : return Asset.iconFlagSomali.image
        case .Afrikaans : return Asset.iconFlagAfrikaans.image
        case .Latin  : return Asset.iconFlagLatin.image
        }
    }
    
    var langCode: String {
        switch self {
        case .NONE: return "en"
        case .English: return "en"
        case .Spanish: return "es"
        case .German: return "de"
        case .French: return "fr"
        case .Hausa: return "ha"
        case .Italian: return "it"
        case .Japanese: return "ja"
        case .Malay: return "ms"
        case .Dutch: return "nl"
        case .Polish: return "pl"
        case .Hindi: return "hi"
        case .Portuguese: return "pt-PT"
        case .Romanian: return "ro"
        case .Swedish: return "sv"
        case .Thai: return "th"
        case .Turkish: return "tr"
        case .Vietnamese: return "vi"
        case .Bulgarian: return "bg"
        case .Danish: return "da"
        case .Filipino: return "fil"
        case .Russian: return "ru"
        case .Indonesian: return "id"
        case .Greek: return "el"
        case .Latvian: return "lv"
        case .Somali: return "so"
        case .Afrikaans: return "af"
        case .Latin: return "la"
        }
    }
}


enum LocalizationKey: String {
    
    // Permission Screen
    case Permissions
    case Permission_description
    case Location_Sharing
    case Access_Camera
    case Notification
    case Motion_Activity
    
    // Common
    case Continue
    case Select_Language
    case Choose_Map
    case Done
    case Create_Circle
    case Circle_Name
    case Enter_circle_name
    case Edit_Circle
    case Create
    case Invitation_Code
    case Members
    case Add
    case Exit
    case Cancel
    case Delete
    case Ok
    case Yes
    case Join_Circle
    case Join
    case Enter_Invitation_Code
    case Join_Circle_Description
    case Please_enter_valid_code
    case Add_Member
    case Add_member_Description
    case Choose_From_Contact
    case Enter_your_phone_number
    case Member_Detail
    case Address
    case Last_Update
    case SOS_Calling
    case SOS_Description
    case Stop
    case Save
    
    var text: String {
        switch self {
        case .Permissions: return "Permissions"
        case .Permission_description: return "Enable notification and allow access to your location and motion activity for the app to run properly."
        case .Location_Sharing: return "Location Sharing"
        case .Access_Camera: return "Access Camera"
        case .Notification: return "Notification"
        case .Motion_Activity: return "Motion Activity"
        case .Continue: return "Continue"
        case .Select_Language: return "Select Language"
        case .Choose_Map: return "Choose Map"
        case .Done: return "Done"
        case .Create_Circle: return "Create Circle"
        case .Circle_Name: return "Circle Name"
        case .Enter_circle_name: return "Enter circle name"
        case .Edit_Circle: return "Edit Circle"
        case .Create: return "Create"
        case .Invitation_Code: return "Invitation Code"
        case .Members: return "Members"
        case .Add: return "Add"
        case .Exit: return "Exit"
        case .Cancel: return "Cancel"
        case .Delete: return "Delete"
        case .Ok: return "Ok"
        case .Yes: return "Yes"
        case .Join_Circle: return "Join Circle"
        case .Join: return "Join"
        case .Enter_Invitation_Code: return "Enter Invitation Code"
        case .Join_Circle_Description: return "Get an invitation code from the person who made the circle."
        case .Please_enter_valid_code: return "Please enter valid code"
        case .Add_Member: return "Add Member"
        case .Add_member_Description: return "Add someone you know into circle to start getting notified about location"
        case .Choose_From_Contact: return "Choose From Contact"
        case .Enter_your_phone_number: return "Enter your phone number"
        case .Member_Detail: return "Member Detail"
        case .Address: return "Address"
        case .Last_Update: return "Last Update"
        case .SOS_Calling: return "SOS Calling"
        case .SOS_Description: return "Once the countdown ends, your location will be shared with your circle."
        case .Stop: return "Stop"
        case .Save: return "Save"
        }
    }
}

enum GenderType: String {
    case Male = "Male"
    case Female = "Female"
    
    var value: String {
        switch self{
        case .Male : return (L10n.male)
        case .Female : return (L10n.female)
        }
    }
}

enum CommonAlertPopupType {
    case Remove_Member
    case SOS_Not_Sent
    case SOS_Sent_Successfully
    case Leave_without_alert
    case Alert_Saved
    case Delete_Alert
    case Leave_App
    case Disable_Child_Mode
    case Child_Mode_Disabled
    
    var title: String {
        switch self {
        case .Remove_Member : return L10n.removeMember
        case .SOS_Not_Sent : return L10n.sosNotSent
        case .SOS_Sent_Successfully : return L10n.sosSentSuccessfully
        case .Leave_without_alert : return L10n.leaveWithoutAlert
        case .Alert_Saved : return L10n.alertSaved
        case .Delete_Alert : return L10n.deleteAlert
        case .Leave_App : return "Leave App ?"
        case .Disable_Child_Mode : return L10n.disableChildMode
        case .Child_Mode_Disabled : return L10n.ChildModeDisabled
        }
    }
    
    var description: String {
        switch self {
        case .Remove_Member : return L10n.areYouSureWantToRemoveThisMemberFromCircle
        case .SOS_Not_Sent : return L10n.noCircleMembers
        case .SOS_Sent_Successfully : return L10n.yourAlertHasBeenSharedWithAllCircleMembers
        case .Leave_without_alert : return L10n.noAlertAddedGoBack
        case .Alert_Saved : return L10n.yourAlertHasBeenSavedSuccessfully
        case .Delete_Alert : return L10n.areYouSureYouWantToDeleteThisAlert
        case .Leave_App : return "Do you really want to exit now?"
        case .Disable_Child_Mode : return L10n.areYouSureYouWantToDisableChildModeForUserName
        case .Child_Mode_Disabled : return L10n.ChildModeIsDisableForUserNameSuccessfully
        }
    }
    
}

enum SettingOptionType: Int {
    case childMode = 0
    case language = 1
    case rateNow = 2
    case share = 3
    case feedback = 4
    case privacyPolicy = 5
    case termsAndCondition = 6
}

enum SettingPermissionType: Int {
    case batteryLevel = 1
    case proximityNotifications = 2
}

enum PermissionType: Int {
    case All = 1
    case Location_Sharing = 2
    case Motion_Activity = 3
    
    var title: String {
        switch self {
        case .All : return L10n.permissions
        case .Location_Sharing : return L10n.locationSharing
        case .Motion_Activity : return L10n.motionActivity
        }
    }
    
    var subTitle: String {
        switch self {
        case .All : return L10n.enablePermissions
        case .Location_Sharing : return L10n.enableLocationPermissions
        case .Motion_Activity : return L10n.enableMotionPermissions
        }
    }
}
