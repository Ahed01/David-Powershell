﻿pushd
e:
cd videos
cd build
cd 2013
cd videos

$overwrite = $false
$webClient = New-Object System.Net.WebClient 
$feeds =  (("Day_1_Keynote.mp4","http://media.ch9.ms/ch9/dc22/e2f20af8-1b56-4e2a-8d55-d2700dbadc22/KEY01_high.mp4"),("Day_2_Keynote.mp4","http://media.ch9.ms/ch9/ac65/bf0b7ecd-0459-4380-8829-4c461b15ac65/KEY02_high.mp4"),("Design_differences_between_iOS_and_Windows_8.mp4","http://video.ch9.ms/sessions/build/2013/2-004.mp4"),("Building_Apps_that_Work_Together.mp4","http://video.ch9.ms/sessions/build/2013/2-010.mp4"),("Building_Apps_That_Connect_with_Devices.mp4","http://video.ch9.ms/sessions/build/2013/2-023.mp4"),("Strong_authentication_Building_apps_that_leverage_virtual_smart_cards_in_enterprise_BYOD_and_.mp4","http://video.ch9.ms/sessions/build/2013/2-041.mp4"),("Building_Games_for_Windows.mp4","http://video.ch9.ms/sessions/build/2013/2-047.mp4"),("Bringing_Halo_Spartan_Assault_to_Windows_tablets_and_mobile_devices.mp4","http://video.ch9.ms/sessions/build/2013/2-049.mp4"),("Creating_World_Ready_Apps.mp4","http://video.ch9.ms/sessions/build/2013/2-058.mp4"),("Lessons_Learned_from_Building_Alarms_and_Calculator_for_Windows_8_1.mp4","http://video.ch9.ms/sessions/build/2013/2-060.mp4"),("New_Internet_Explorer_Developer_Tools.mp4","http://video.ch9.ms/sessions/build/2013/2-066.mp4"),("New_Platform_Capabilities_for_Advancing_Web_Development.mp4","http://video.ch9.ms/sessions/build/2013/2-067.mp4"),("What_s_New_in_Windows_Runtime_for_Windows_8_1.mp4","http://video.ch9.ms/sessions/build/2013/2-075.mp4"),("Creating_your_first_app_using_HTML_and_JavaScript.mp4","http://video.ch9.ms/sessions/build/2013/2-081.mp4"),("Creating_your_first_app_using_XAML.mp4","http://video.ch9.ms/sessions/build/2013/2-082.mp4"),("Creating_Apps_that_Use_Video_and_Audio.mp4","http://video.ch9.ms/sessions/build/2013/2-087.mp4"),("First_Impressions_Matter_Delighting_your_user_from_the_moment_they_click_Buy_.mp4","http://video.ch9.ms/sessions/build/2013/2-095.mp4"),("App_Performance_Planning_Costs_Less_Than_Rearchitecting.mp4","http://video.ch9.ms/sessions/build/2013/2-098.mp4"),("What_every_developer_should_know_about_building_trustworthy_apps.mp4","http://video.ch9.ms/sessions/build/2013/2-111.mp4"),("What_s_New_for_Working_with_Files.mp4","http://video.ch9.ms/sessions/build/2013/2-119.mp4"),("Windows_Store_Overview_for_Windows_8_1_New_Design_New_Promotion_and_Monetization_Opportunities.mp4","http://video.ch9.ms/sessions/build/2013/2-123.mp4"),("The_Wow_Factor_Making_Your_Windows_Store_App_promotable.mp4","http://video.ch9.ms/sessions/build/2013/2-130.mp4"),("Improving_app_health_with_crash_analytics.mp4","http://video.ch9.ms/sessions/build/2013/2-138.mp4"),("Beautiful_apps_at_any_size_on_any_screen.mp4","http://video.ch9.ms/sessions/build/2013/2-150.mp4"),("Reusing_your_web_development_skills_in_Windows_Store_apps.mp4","http://video.ch9.ms/sessions/build/2013/2-161.mp4"),("What_s_New_in_XAML.mp4","http://video.ch9.ms/sessions/build/2013/2-164.mp4"),("What_s_New_in_WinJS.mp4","http://video.ch9.ms/sessions/build/2013/2-165.mp4"),("Designing_and_Building_User_Interfaces_for_Windows.mp4","http://video.ch9.ms/sessions/build/2013/2-168.mp4"),("Make_your_Windows_Store_apps_talk.mp4","http://video.ch9.ms/sessions/build/2013/2-171.mp4"),("Building_a_UI_What_Does_it_Cost_.mp4","http://video.ch9.ms/sessions/build/2013/2-192.mp4"),("Windows_8_1_in_the_Enterprise.mp4","http://video.ch9.ms/sessions/build/2013/2-194.mp4"),("Windows_Phone_Introducing_App_Development.mp4","http://video.ch9.ms/sessions/build/2013/2-201.mp4"),("Windows_Phone_Design_for_Developers.mp4","http://video.ch9.ms/sessions/build/2013/2-202.mp4"),("Windows_Phone_Building_UI_in_XAML.mp4","http://video.ch9.ms/sessions/build/2013/2-203.mp4"),("Windows_Phone_App_Foundation.mp4","http://video.ch9.ms/sessions/build/2013/2-204.mp4"),("Windows_Phone_This_App_Is_Brought_to_You_by_MVVM_Hulu_Case_Study.mp4","http://video.ch9.ms/sessions/build/2013/2-205.mp4"),("Windows_Phone_Tiles_Lock_Notifications.mp4","http://video.ch9.ms/sessions/build/2013/2-206.mp4"),("Windows_Phone_Game_Development_Basics.mp4","http://video.ch9.ms/sessions/build/2013/2-207.mp4"),("Quickly_Add_and_Enhance_Capabilities_to_Windows_Phone_Apps_Thru_Partner_Offerings.mp4","http://video.ch9.ms/sessions/build/2013/2-208.mp4"),("Windows_Phone_Building_a_Camera_App_Presented_by_Nokia.mp4","http://video.ch9.ms/sessions/build/2013/2-210.mp4"),("Windows_Phone_Using_Native_C_Code_in_Your_Apps.mp4","http://video.ch9.ms/sessions/build/2013/2-211.mp4"),("Windows_Phone_App_to_App_Communications.mp4","http://video.ch9.ms/sessions/build/2013/2-212.mp4"),("Windows_Phone_Maximizing_App_Revenue.mp4","http://video.ch9.ms/sessions/build/2013/2-213.mp4"),("Real_Talk_Sharing_Code_between_the_Windows_Windows_Phone_Platforms.mp4","http://video.ch9.ms/sessions/build/2013/2-215.mp4"),("Windows_Phone_Developer_Best_Practices_How_to_Maximize_Performance.mp4","http://video.ch9.ms/sessions/build/2013/2-216.mp4"),("Windows_Phone_Learn_from_the_Winners.mp4","http://video.ch9.ms/sessions/build/2013/2-218.mp4"),("The_Story_of_Bringing_Nokia_Music_from_Windows_Phone_to_Windows_8.mp4","http://media.ch9.ms/ch9/7903/8aa66574-6126-4e3d-b2f5-39cdf1497903/2-219_high.mp4"),("Windows_Phone_Building_the_best_mapping_apps_for_Windows_Phone_using_the_Here_platform.mp4","http://video.ch9.ms/sessions/build/2013/2-220.mp4"),("Windows_Phone_Low_Mem_Hardware_Constraints.mp4","http://video.ch9.ms/sessions/build/2013/2-221.mp4"),("Windows_Phone_Networking.mp4","http://video.ch9.ms/sessions/build/2013/2-222.mp4"),("What_s_new_in_NET_Development.mp4","http://video.ch9.ms/sessions/build/2013/2-303.mp4"),("What_s_New_in_Visual_Studio_2013_for_C_Developers.mp4","http://video.ch9.ms/sessions/build/2013/2-305.mp4"),("The_Future_of_C_.mp4","http://video.ch9.ms/sessions/build/2013/2-306.mp4"),("What_s_New_in_Blend_for_HTML_Developers.mp4","http://video.ch9.ms/sessions/build/2013/2-311.mp4"),("Getting_Started_with_Team_Foundation_Service.mp4","http://video.ch9.ms/sessions/build/2013/2-345.mp4"),("Cloud_powered_Load_Testing_with_Team_Foundation_Service.mp4","http://video.ch9.ms/sessions/build/2013/2-346.mp4"),("Developing_Neural_Networks_Using_Visual_Studio.mp4","http://video.ch9.ms/sessions/build/2013/2-401.mp4"),("Designing_for_Ubiquitous_Computing.mp4","http://video.ch9.ms/sessions/build/2013/2-402.mp4"),("Mobile_Services_Soup_to_Nuts.mp4","http://video.ch9.ms/sessions/build/2013/2-542.mp4"),("What_s_New_in_ASP_NET_and_Visual_Studio_2013.mp4","http://video.ch9.ms/sessions/build/2013/2-546.mp4"),("Windows_Azure_Web_Sites_Exploring_the_platform.mp4","http://video.ch9.ms/sessions/build/2013/2-550.mp4"),("Building_Windows_Second_Screen_Experiences_using_Xbox_SmartGlass.mp4","http://video.ch9.ms/sessions/build/2013/2-703.mp4"),("Introduction_to_Windows_Store_App_Development_for_iOS_developers.mp4","http://video.ch9.ms/sessions/build/2013/3-003.mp4"),("Introduction_to_Windows_Store_App_Development_for_Android_Programmers.mp4","http://video.ch9.ms/sessions/build/2013/3-006.mp4"),("Building_apps_that_integrate_with_People_and_Events.mp4","http://video.ch9.ms/sessions/build/2013/3-007.mp4"),("Power_Up_Your_Desktop_App_with_Windows_8_1.mp4","http://video.ch9.ms/sessions/build/2013/3-017.mp4"),("Building_Windows_apps_that_use_scanners.mp4","http://video.ch9.ms/sessions/build/2013/3-025.mp4"),("Apps_for_Bluetooth_HID_and_USB_Devices.mp4","http://video.ch9.ms/sessions/build/2013/3-026.mp4"),("How_to_use_point_of_sale_devices_in_your_app.mp4","http://video.ch9.ms/sessions/build/2013/3-029.mp4"),("Cutting_Edge_Games_on_Windows_tablets.mp4","http://video.ch9.ms/sessions/build/2013/3-043.mp4"),("Tales_from_the_trenches_Developing_The_Harvest_and_Gunpowder_with_Unity.mp4","http://video.ch9.ms/sessions/build/2013/3-044.mp4"),("Play_together_Leaderboards_with_Windows_Azure_and_Multiplayer_with_Wi_Fi_Direct.mp4","http://video.ch9.ms/sessions/build/2013/3-051.mp4"),("What_s_New_in_Direct3D_11_2.mp4","http://video.ch9.ms/sessions/build/2013/3-062.mp4"),("Web_Runtime_Performance.mp4","http://video.ch9.ms/sessions/build/2013/3-068.mp4"),("Lighting_Up_Your_Site_on_Windows_8_1.mp4","http://video.ch9.ms/sessions/build/2013/3-071.mp4"),("Upgrading_Windows_8_Apps_to_Windows_8_1.mp4","http://video.ch9.ms/sessions/build/2013/3-077.mp4"),("Building_Apps_That_Use_the_Camera.mp4","http://video.ch9.ms/sessions/build/2013/3-088.mp4"),("Building_Media_Streaming_Apps_and_Sites_Without_Plug_Ins_Using_MPEG_DASH.mp4","http://video.ch9.ms/sessions/build/2013/3-089.mp4"),("Building_great_service_connected_apps.mp4","http://video.ch9.ms/sessions/build/2013/3-090.mp4"),("App_Performance_The_Mental_Model_for_Interacting_with_the_Platform.mp4","http://video.ch9.ms/sessions/build/2013/3-097.mp4"),("App_performance_From_UX_to_API_for_5_Key_Scenarios.mp4","http://video.ch9.ms/sessions/build/2013/3-099.mp4"),("App_Performance_The_Windows_Performance_Toolkit.mp4","http://video.ch9.ms/sessions/build/2013/3-100.mp4"),("Stories_from_Building_the_New_Windows_Mail_App.mp4","http://video.ch9.ms/sessions/build/2013/3-104.mp4"),("Running_in_the_Background_Using_Background_Tasks.mp4","http://video.ch9.ms/sessions/build/2013/3-108.mp4"),("Building_trustworthy_Windows_Store_apps_From_design_to_servicing.mp4","http://video.ch9.ms/sessions/build/2013/3-112.mp4"),("Building_a_great_authentication_experience_into_your_app.mp4","http://video.ch9.ms/sessions/build/2013/3-113.mp4"),("Build_connected_Windows_8_1_Apps_with_Mobile_services.mp4","http://video.ch9.ms/sessions/build/2013/3-116.mp4"),("Monetization_Opportunities_for_Windows_Store_apps_in_Windows_8_1.mp4","http://video.ch9.ms/sessions/build/2013/3-121.mp4"),("The_fast_lane_for_app_certification.mp4","http://video.ch9.ms/sessions/build/2013/3-125.mp4"),("Validating_Windows_store_purchases_for_your_app.mp4","http://video.ch9.ms/sessions/build/2013/3-126.mp4"),("Testing_Your_C_Based_Windows_Store_App_Top_10_Areas_to_Look_for_Bugs_.mp4","http://video.ch9.ms/sessions/build/2013/3-133.mp4"),("Making_your_Windows_Store_apps_more_reliable.mp4","http://video.ch9.ms/sessions/build/2013/3-136.mp4"),("DirectX_Graphics_Debugging_Tools.mp4","http://video.ch9.ms/sessions/build/2013/3-141.mp4"),("Design_and_Build_a_great_search_experience_in_your_app.mp4","http://video.ch9.ms/sessions/build/2013/3-144.mp4"),("Create_fast_and_fluid_interfaces_with_HTML_and_JavaScript.mp4","http://video.ch9.ms/sessions/build/2013/3-156.mp4"),("XAML_Performance_Fundamentals.mp4","http://video.ch9.ms/sessions/build/2013/3-157.mp4"),("Dramatically_increase_performance_when_users_interact_with_large_amounts_of_data_in_GridView_and_.mp4","http://video.ch9.ms/sessions/build/2013/3-158.mp4"),("Alive_with_Activity_Tiles_Notifications_and_Background_Tasks.mp4","http://video.ch9.ms/sessions/build/2013/3-159.mp4"),("Extending_the_UI_platform.mp4","http://video.ch9.ms/sessions/build/2013/3-173.mp4"),("Rendering_PDF_content_in_Windows_Store_Apps.mp4","http://video.ch9.ms/sessions/build/2013/3-175.mp4"),("WebView_Bringing_the_web_to_your_app.mp4","http://video.ch9.ms/sessions/build/2013/3-179.mp4"),("Tips_for_building_LOB_apps_for_the_Windows_Store.mp4","http://video.ch9.ms/sessions/build/2013/3-185.mp4"),("Accelerating_Windows_Store_Game_Development_with_Middleware.mp4","http://video.ch9.ms/sessions/build/2013/3-187.mp4"),("From_Android_or_iOS_bringing_your_OpenGL_ES_game_to_the_Windows_Store.mp4","http://video.ch9.ms/sessions/build/2013/3-189.mp4"),("Bringing_Desktop_PC_Games_to_the_Windows_Store.mp4","http://video.ch9.ms/sessions/build/2013/3-190.mp4"),("Innovations_in_High_Performance_2D_Graphics_with_DirectX.mp4","http://video.ch9.ms/sessions/build/2013/3-191.mp4"),("Async_ing_Your_Way_to_a_Successful_App_with_NET.mp4","http://video.ch9.ms/sessions/build/2013/3-301.mp4"),("Building_NET_Applications_for_Devices_and_Services.mp4","http://video.ch9.ms/sessions/build/2013/3-304.mp4"),("C_CX_Best_Practices.mp4","http://video.ch9.ms/sessions/build/2013/3-308.mp4"),("Building_Modern_HTML5_based_Business_Applications_on_Windows_Azure_and_Office_365_with_Visual_.mp4","http://video.ch9.ms/sessions/build/2013/3-310.mp4"),("Diagnosing_issues_in_JavaScript_Windows_Store_Apps_with_Visual_Studio_2013.mp4","http://video.ch9.ms/sessions/build/2013/3-312.mp4"),("TypeScript_Application_Scale_JavaScript.mp4","http://video.ch9.ms/sessions/build/2013/3-314.mp4"),("Developing_high_performance_websites_and_modern_apps_with_JavaScript_performance_tools.mp4","http://video.ch9.ms/sessions/build/2013/3-316.mp4"),("Developing_Apps_for_SharePoint_2013_with_Visual_Studio_2013.mp4","http://video.ch9.ms/sessions/build/2013/3-319.mp4"),("Flexible_Source_Control_with_TFS_and_Git.mp4","http://video.ch9.ms/sessions/build/2013/3-320.mp4"),("What_s_New_in_Visual_Studio_Blend_for_XAML_Developers.mp4","http://video.ch9.ms/sessions/build/2013/3-321.mp4"),("Visual_Studio_2013_Diagnostics_Tools_for_XAML_based_Windows_Store_Apps.mp4","http://video.ch9.ms/sessions/build/2013/3-322.mp4"),("Automated_Testing_of_XAML_based_Windows_Store_apps.mp4","http://video.ch9.ms/sessions/build/2013/3-323.mp4"),("Creating_Structured_and_Meaningful_Logs_with_Semantic_Logging.mp4","http://video.ch9.ms/sessions/build/2013/3-336.mp4"),("Improving_Developer_Productivity_and_Software_Quality_With_Visual_Studio_Application_Lifecycle_Tools.mp4","http://video.ch9.ms/sessions/build/2013/3-338.mp4"),("What_s_New_in_the_Visual_Studio_2013_IDE.mp4","http://video.ch9.ms/sessions/build/2013/3-339.mp4"),("MSR_and_Visual_Studio_Image_Watch_Smart_Programming_Assistant.mp4","http://video.ch9.ms/sessions/build/2013/3-403.mp4"),("Voice_Interaction_Design.mp4","http://video.ch9.ms/sessions/build/2013/3-404.mp4"),("Using_Bing_platform_controls_to_build_great_Windows_apps.mp4","http://video.ch9.ms/sessions/build/2013/3-405.mp4"),("Windows_Azure_Storage_What_s_Coming_Best_Practices_and_Internals.mp4","http://video.ch9.ms/sessions/build/2013/3-541.mp4"),("Protips_for_Windows_Azure_Mobile_Services.mp4","http://video.ch9.ms/sessions/build/2013/3-543.mp4"),("Who_s_that_user_Identity_with_Mobile_Services.mp4","http://video.ch9.ms/sessions/build/2013/3-544.mp4"),("Building_Cross_Platform_Apps_with_Windows_Azure_Mobile_Services.mp4","http://video.ch9.ms/sessions/build/2013/3-545.mp4"),("Debugging_and_Troubleshooting_Windows_Azure_Applications_Using_Visual_Studio.mp4","http://video.ch9.ms/sessions/build/2013/3-547.mp4"),("Connected_Windows_Phone_apps_made_easy_with_Azure_Mobile_Services.mp4","http://video.ch9.ms/sessions/build/2013/3-548.mp4"),("Build_End_to_End_Video_Experiences_with_Windows_Azure_Media_Services.mp4","http://video.ch9.ms/sessions/build/2013/3-549.mp4"),("Continuous_integration_and_scripting_with_Windows_Azure_Web_Sites.mp4","http://video.ch9.ms/sessions/build/2013/3-551.mp4"),("Building_and_maintaining_Internet_scale_applications_with_Windows_Azure_Web_Sites.mp4","http://video.ch9.ms/sessions/build/2013/3-552.mp4"),("Create_connected_business_applications_with_Windows_Azure_Websites.mp4","http://video.ch9.ms/sessions/build/2013/3-553.mp4"),("Building_Your_Dev_and_Test_Sandbox_with_Windows_Azure_Infrastructure_Services.mp4","http://video.ch9.ms/sessions/build/2013/3-556.mp4"),("Monitoring_Management_DevOps_in_Windows_Azure.mp4","http://video.ch9.ms/sessions/build/2013/3-558.mp4"),("0_to_60_Developing_Apps_for_Microsoft_Office_2013.mp4","http://video.ch9.ms/sessions/build/2013/3-601.mp4"),("0_to_60_Developing_Apps_for_Microsoft_SharePoint_2013.mp4","http://video.ch9.ms/sessions/build/2013/3-602.mp4"),("Understanding_Authentication_and_Permissions_with_Apps_for_SharePoint_and_Office.mp4","http://video.ch9.ms/sessions/build/2013/3-603.mp4"),("Advanced_Patterns_using_Windows_Azure_Web_Sites_for_apps_for_Office_and_SharePoint.mp4","http://video.ch9.ms/sessions/build/2013/3-604.mp4"),("Building_Enterprise_Web_and_Mobile_Apps_with_the_Yammer_Platform.mp4","http://video.ch9.ms/sessions/build/2013/3-605.mp4"),("Kinect_Interactions_Get_a_Grip_in_C_or_HTML5_Javascript.mp4","http://video.ch9.ms/sessions/build/2013/3-705.mp4"),("DirectComposition_Smooth_Composition_and_Animation_for_Desktop_Applications.mp4","http://video.ch9.ms/sessions/build/2013/4-021.mp4"),("Make_Your_Desktop_App_Great_with_Touch_Mouse_and_Pen.mp4","http://video.ch9.ms/sessions/build/2013/4-022.mp4"),("Massive_Virtual_Textures_for_Games_Direct3D_Tiled_Resources.mp4","http://video.ch9.ms/sessions/build/2013/4-063.mp4"),("Unlocking_the_power_of_DirectX_in_apps_that_use_XAML.mp4","http://video.ch9.ms/sessions/build/2013/4-065.mp4"),("Hyper_Fast_Web_Graphics_with_WebGL.mp4","http://video.ch9.ms/sessions/build/2013/4-072.mp4"),("Inspecting_debugging_using_the_New_F12_Developer_Tools_in_IE.mp4","http://video.ch9.ms/sessions/build/2013/4-073.mp4"),("Five_great_reasons_to_use_the_new_HttpClient_API_to_connect_to_web_services.mp4","http://video.ch9.ms/sessions/build/2013/4-092.mp4"),("Windows_Runtime_internals_Understanding_the_threading_model.mp4","http://video.ch9.ms/sessions/build/2013/4-107.mp4"),("Build_a_great_Windows_Store_library_SDK_and_become_the_most_popular_kid_in_school.mp4","http://video.ch9.ms/sessions/build/2013/4-142.mp4"),("Making_Your_Desktop_Apps_Shine_on_High_DPI_Displays.mp4","http://video.ch9.ms/sessions/build/2013/4-184.mp4"),("Fast_Apps_and_Sites_with_JavaScript.mp4","http://video.ch9.ms/sessions/build/2013/4-313.mp4"),("Native_Code_Performance_and_Memory_The_Elephant_in_the_CPU.mp4","http://video.ch9.ms/sessions/build/2013/4-329.mp4"),("Building_Big_Lessons_learned_from_Windows_Azure_customers.mp4","http://video.ch9.ms/sessions/build/2013/4-554.mp4"),("Introduction_to_Node_js_on_Windows_Azure.mp4","http://video.ch9.ms/sessions/build/2013/2-509.mp4"),("Optimizing_your_app_s_Disk_Footprint.mp4","http://media.ch9.ms/ch9/7c1b/e8d7273c-19b4-4744-9913-f06b4f347c1b/29061_high.mp4"),("Biometrics_Fingerprints_for_Apps.mp4","http://media.ch9.ms/ch9/e09c/f1d07f80-fc54-4569-909d-9200403de09c/29110_high.mp4"),("LOB_lessons_learned_Microsoft_Dynamics_AX.mp4","http://media.ch9.ms/ch9/337d/5cb89bc0-9cdf-4dde-ac01-1d9c0ae1337d/29193_high.mp4"),("Apps_for_HID_Devices.mp4","http://media.ch9.ms/ch9/6d4d/a142c599-727b-4c1b-870c-23a68c5f6d4d/2924b_high.mp4"),("Scaling_the_Real_time_Web_with_ASP_NET_SignalR.mp4","http://video.ch9.ms/sessions/build/2013/3-502.mp4"),("Visual_Studio_2013_for_Web_Developers_Deep_Dive.mp4","http://video.ch9.ms/sessions/build/2013/3-503.mp4"),("ASP_NET_Web_API_2_Web_Services_for_Websites_Modern_Apps_and_Mobile_Apps.mp4","http://video.ch9.ms/sessions/build/2013/3-504.mp4"),("Going_Live_and_Beyond_with_Windows_Azure_Mobile_Services.mp4","http://video.ch9.ms/sessions/build/2013/3-511.mp4"),("Delivering_Push_Notifications_to_Millions_of_Mobile_Devices.mp4","http://video.ch9.ms/sessions/build/2013/3-515.mp4"),("Building_REST_Services_with_JavaScript.mp4","http://video.ch9.ms/sessions/build/2013/3-516.mp4"),("Build_a_Rich_Windows_Store_Video_App_and_Monetize_Your_Content.mp4","http://video.ch9.ms/sessions/build/2013/3-517.mp4"),("Securing_Windows_Store_applications_and_REST_services_with_Active_Directory.mp4","http://video.ch9.ms/sessions/build/2013/3-518.mp4"),("Patterns_Practices_for_Composing_Cloud_Services.mp4","http://video.ch9.ms/sessions/build/2013/3-526.mp4"),("Make_Your_Apps_Smarter_with_Azure_HDInsight.mp4","http://video.ch9.ms/sessions/build/2013/3-529.mp4"),("Building_Scalable_N_Tier_Apps_with_Windows_Azure_Cloud_Services_Virtual_Machines.mp4","http://video.ch9.ms/sessions/build/2013/3-530.mp4"),("Scanning_Printing_the_Real_World_using_Kinect_for_Windows_and_preview_of_Kinect_vNext.mp4","http://video.ch9.ms/sessions/build/2013/3-702.mp4"),("Real_World_Machine_Learning_How_Kinect_Gesture_Recognition_Works.mp4","http://video.ch9.ms/sessions/build/2013/3-704.mp4"),("3D_Printing_with_Windows.mp4","http://media.ch9.ms/ch9/c269/d4d0cb38-6d45-46cb-ab19-4677de1cc269/39027_high.mp4"),("Apps_for_Bluetooth_Smart_Devices.mp4","http://media.ch9.ms/ch9/0a49/5e13694d-ec46-414c-8d6b-d0c8318c0a49/39028_high.mp4"),("Building_Windows_apps_that_use_Wi_Fi_Direct.mp4","http://media.ch9.ms/ch9/e4a5/982f5db3-4639-4f22-bc80-279a3b37e4a5/39030_high.mp4"),("Using_Geolocation_and_Geofencing_in_Windows_Store_apps.mp4","http://media.ch9.ms/ch9/7af0/db0b177b-fee6-4927-a608-de3a02d87af0/39034_high.mp4"),("Advances_in_Driver_Development.mp4","http://media.ch9.ms/ch9/cc77/f66af21c-8b39-49f4-8964-462f584bcc77/39036_high.mp4"),("Web_Compatibility_and_Same_Markup.mp4","http://media.ch9.ms/ch9/63b3/27485dbd-aa4c-4e2d-affe-e9f13cb663b3/WebCompatAndSameMarkup_high.mp4"),("The_Story_of_State_App_Data_Settings_and_The_Process_Lifecycle.mp4","http://media.ch9.ms/ch9/e5ff/5cf101c6-a55f-4bd8-a709-5cc7c755e5ff/39118_high.mp4"),("Add_Pen_Inking_Capabilities_to_your_Windows_Store_apps.mp4","http://media.ch9.ms/ch9/75e1/59992e43-48dc-43bd-b24a-b4022bed75e1/39148_high.mp4"),("Apps_need_Maps_.mp4","http://media.ch9.ms/ch9/982f/b53d5b25-1e56-4094-b4b2-7db34466982f/39176_high.mp4"),("Apps_for_USB_devices.mp4","http://media.ch9.ms/ch9/9d55/588bf0a6-d21a-49b7-b7c4-e075dc1a9d55/3924a_high.mp4"),("Exploring_Customized_Touch_Interactions_for_Your_Windows_Store_App.mp4","http://media.ch9.ms/ch9/fddc/b2144b7f-0c21-4e5e-b671-5ecec34efddc/CustomTouchInteraction_high.mp4"),("Welcome_to_the_Show_with_Steven_Guggenheimer.mp4","http://media.ch9.ms/ch9/645e/7dcfd539-145b-48e7-b5ae-9c682595645e/C9LiveBUILD2013WelcometotheShowStevenGuggenheimer_high.mp4"),("Visual_Studio_2013_Preview_with_Soma_Somasegar.mp4","http://media.ch9.ms/ch9/358f/fac6da41-c440-47d0-b4e4-c88a0570358f/C9LiveBUILD2013VisualStudio2013PreviewSoma_high.mp4"),("Windows_8_1_for_Developers_with_Ales_Holecek_and_John_Sheehan.mp4","http://media.ch9.ms/ch9/6136/684ca6a2-fbf0-4fa6-88d2-427398556136/C9LiveBUILD2013withAlesHolecekandJohnSheehan_high.mp4"),("Larry_Osterman_and_Martyn_Lovell.mp4","http://media.ch9.ms/ch9/587b/f12cbae6-0862-4d14-8be9-88f0971d587b/C9LiveBUILD2013withLarryOstermanandMartynLovell_high.mp4"),("Tim_Heuer_and_Chris_Anderson.mp4","http://media.ch9.ms/ch9/2b12/01d93bc8-f7dd-4d05-a6c8-e98cca7e2b12/C9LiveBUILD2013withTimHeuerandChrisAnderson_high.mp4"),("Anders_Hejlsberg.mp4","http://media.ch9.ms/ch9/ef9d/c223b8ec-b426-4da8-abc1-c50b429bef9d/C9LiveBUILD2013withAndersHejlsberg_high.mp4"),("John_Shewshuk.mp4","http://media.ch9.ms/ch9/e4f2/a96fa8c5-d833-4e5a-9243-28036820e4f2/C9LiveBUILD2013withJohnShewshuk_high.mp4"),("Habib_Heydarian.mp4","http://media.ch9.ms/ch9/38b3/33b070dc-f801-4a94-b860-68df205c38b3/C9LiveBUILD2013withHabibHeydarian_high.mp4"),("Scott_2.mp4","http://media.ch9.ms/ch9/6f73/e5ceaa88-a02c-4983-b08a-d75d368c6f73/C9LiveBUILD2013ScottGu_high.mp4"),("Azure_Mobile_Services_with_Josh_Twist.mp4","http://media.ch9.ms/ch9/bf6e/6b1f78e4-c2dd-4440-8a97-1f5e3cbdbf6e/C9LiveBUILD2013AzureMobileServiceswithJoshTwist_high.mp4"),("JavaScript_AMA_Doug_Crockford_and_Steve_Lucco.mp4","http://media.ch9.ms/ch9/5925/481c6871-7e76-4bf5-b124-0b918ddc5925/C9LiveBUILD2013JavaScriptAMADougCrockfordandSteve_high.mp4"),("Designing_Apps_for_the_Bing_Platform.mp4","http://media.ch9.ms/ch9/fc0e/c8431dd5-d2fc-43fa-83db-44b44fcbfc0e/C9LiveBUILD2013DesigningAppsfortheBingPlatform_high.mp4"),("Live_from_Build_It_s_GoingNative_.mp4","http://media.ch9.ms/ch9/b858/e7d043c6-2975-45a5-bd03-6901909fb858/C9LiveBUILD2013GoingNative_high.mp4"),("Hackathon_Winners.mp4","http://media.ch9.ms/ch9/ba88/cc4d7da7-fc8f-49e5-8a4f-2b35a4fcba88/C9LiveBUILD2013HackathonWinners_high.mp4"),("Channel_9_Event_Close.mp4","http://media.ch9.ms/ch9/c507/e5ae0817-bbf7-4275-848b-057bd583c507/C9LiveBUILD2013Channel9EventClose_high.mp4"),("Adobe_Creative_Cloud_tools_for_Microsoft_Developers.mp4","http://media.ch9.ms/ch9/3758/38d228cf-370d-4589-a11e-bdb9eb263758/C9LiveBUILD2013AdobeCreativeCloudtoolsforMicrosof_high.mp4"))  
$entries = $feeds.Length
$progress = 0 
$pagepercent = 0 
$dir = get-location
foreach ($item in $feeds){
    $name,$link = $item
    $saveFileName = join-path $dir $name
    if ((-not $overwrite) -and (Test-Path -path $saveFileName))     
    {        
        write-progress -activity "$saveFileName already downloaded" -status "$pagepercent% ($progress / $entries) complete" -percentcomplete $pagepercent    
    }    
    else     
    {        
        write-progress -activity "Downloading $saveFileName" -status "$pagepercent% ($progress / $entries) complete" -percentcomplete $pagepercent       
        &{#TRY
            $webClient.DownloadFile($link, $saveFileName)
        }
        trap [Exception]{
            write-host
            write-host ("Unable to download " + $saveFileName)
            continue; 
        }
    }    
    $pagepercent = [Math]::floor((++$progress)/$entries*100) 
}
popd