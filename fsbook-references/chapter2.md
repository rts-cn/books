# API

`本章是`mod_commands`中的API列表，而在各模块中实现的API，则分别在各模块中讲述。`


参见：<https://freeswitch.org/confluence/display/FREESWITCH/mod_commands> 。

...
Shutdown
`shutdown_function`


acl
Compare an ip to an acl list
`acl_function`


alias
Alias
`alias_function`

coalesce
Return first nonempty parameter
`coalesce_function`


banner
Return the system banner
`banner_function`


`bg_system`
Execute a system command in the background
`bg_system_function`


bgapi
Execute an api command in a thread
`bgapi_function`


break
`uuid_break`
`break_function`


complete
Complete
`complete_function`


cond
Evaluate a conditional
`cond_function`


`console_complete`

`console_complete_function`


`console_complete_xml`

`console_complete_xml_function`


`create_uuid`
Create a uuid
`uuid_function`


`db_cache`
Manage db cache
`db_cache_function`


`domain_exists`
Check if a domain exists
`domain_exists_function`


echo
Echo
`echo_function`


escape
Escape a string
`escape_function`


eval
eval (noop)
`eval_function`


`event_channel_broadcast`
Broadcast
`event_channel_broadcast_api_function`


expand
Execute an api with variable expansion
`expand_function`


`file_exists`
Check if a file exists on server
`file_exists_function`


`find_user_xml`
Find a user
`find_user_function`


fsctl
FS control messages
`ctl_function`


getcputime
Gets CPU time in milliseconds (user,kernel)
`getcputime_function`


getenv
getenv
`getenv_function`


gethost
gethostbyname
`gethost_api_function`


`global_getvar`
Get global var
`global_getvar_function`


`global_setvar`
Set global var
`global_setvar_function`


`group_call`
Generate a dial string to call a group
`group_call_function`


help
Show help for all the api commands
`help_function`


`host_lookup`
Lookup host
`host_lookup_function`


hostname
Return the system hostname
`hostname_api_function`


hupall
hupall
`hupall_api_function`


`in_group`
Determine if a user is in a group
`in_group_function`


`interface_ip`
Return the primary IP of an interface
`interface_ip_function`


`is_lan_addr`
See if an ip is a lan addr
`lan_addr_function`


json
JSON API
`json_function`


`limit_hash_usage`
Deprecated: gets the usage count of a limited resource
`limit_hash_usage_function`


`limit_interval_reset`
Reset the interval counter for a limited resource
`limit_interval_reset_function`


`limit_reset`
Reset the counters of a limit backend
`limit_reset_function`


`limit_status`
Get the status of a limit backend
`limit_status_function`


`limit_usage`
Get the usage count of a limited resource
`limit_usage_function`


`list_users`
List Users configured in Directory
`list_users_function`


load
Load Module
`load_function`


log
Log
`log_function`


md5
Return md5 hash
`md5_function`


`module_exists`
Check if module exists
`module_exists_function`


msleep
Sleep N milliseconds
`msleep_function`


`nat_map`
Manage NAT
`nat_map_function`


originate
Originate a call
`originate_function`


pause
Pause media on a channel
`pause_function`


`quote_shell_arg`
Quote/escape a string for use on shell command line
`quote_shell_arg_function`


`reg_url`

`reg_url_function`


regex
Evaluate a regex
`regex_function`


reload
Reload module
`reload_function`


reloadacl
Reload XML
`reload_acl_function`


reloadxml
Reload XML
`reload_xml_function`


replace
Replace a string
`replace_function`


`say_string`

`say_string_function`


`sched_api`
Schedule an api command
`sched_api_function`


`sched_broadcast`
Schedule a broadcast event to a running call
`sched_broadcast_function`


`sched_del`
Delete a scheduled task
`sched_del_function`


`sched_hangup`
Schedule a running call to hangup
`sched_hangup_function`


`sched_transfer`
Schedule a transfer for a running call
`sched_transfer_function`


show
Show various reports
`show_function`


shutdown
Shutdown
`shutdown_function`


`sql_escape`
Escape a string to prevent sql injection
`sql_escape`


status
Show current status
`status_function`


`strftime_tz`
Display formatted time of timezone
`strftime_tz_api_function`


stun
Execute STUN lookup
`stun_function`


switchname
Return the switch name
`switchname_api_function`


system
Execute a system command
`system_function`


`time_test`
Show time jitter
`time_test_function`


`timer_test`
Exercise FS timer
`timer_test_function`


`tone_detect`
Start tone detection on a channel
`tone_detect_session_function`


unload
Unload module
`unload_function`


`unsched_api`
Unschedule an api command
`unsched_api_function`


uptime
Show uptime
`uptime_function`


`url_decode`
Url decode a string
`url_decode_function`


`url_encode`
Url encode a string
`url_encode_function`


`user_data`
Find user data
`user_data_function`


`user_exists`
Find a user
`user_exists_function`


`uuid_answer`
answer
`uuid_answer_function`


`uuid_audio`
`uuid_audio`
`session_audio_function`


`uuid_break`
Break out of media sent to channel
`break_function`


`uuid_bridge`
Bridge call legs
`uuid_bridge_function`


`uuid_broadcast`
Execute dialplan application
`uuid_broadcast_function`


`uuid_buglist`
List media bugs on a session
`uuid_buglist_function`


`uuid_capture_text`
`start/stop capture_text`
`uuid_capture_text`


`uuid_chat`
Send a chat message
`uuid_chat`


`uuid_codec_debug`
Send codec a debug message
`uuid_codec_debug_function`


`uuid_codec_param`
Send codec a param
`uuid_codec_param_function`


`uuid_debug_media`
Debug media
`uuid_debug_media_function`


`uuid_deflect`
Send a deflect
`uuid_deflect`


`uuid_displace`
Displace audio
`session_displace_function`


`uuid_display`
Update phone display
`uuid_display_function`


`uuid_drop_dtmf`
Drop all DTMF or replace it with a mask
`uuid_drop_dtmf`


`uuid_dual_transfer`
Transfer a session and its partner
`dual_transfer_function`


`uuid_dump`
Dump session vars
`uuid_dump_function`


`uuid_early_ok`
stop ignoring early media
`uuid_early_ok_function`


`uuid_exists`
Check if a uuid exists
`uuid_exists_function`


`uuid_fileman`
Manage session audio
`uuid_fileman_function`


`uuid_flush_dtmf`
Flush dtmf on a given uuid
`uuid_flush_dtmf_function`


`uuid_getvar`
Get a variable from a channel
`uuid_getvar_function`


`uuid_hold`
Place call on hold
`uuid_hold_function`


`uuid_jitterbuffer`
`uuid_jitterbuffer`
`uuid_jitterbuffer_function`


`uuid_kill`
Kill channel
`kill_function`


`uuid_limit`
Increase limit resource
`uuid_limit_function`


`uuid_limit_release`
Release limit resource
`uuid_limit_release_function`


`uuid_limit_release`
Release limit resource
`uuid_limit_release_function`


`uuid_loglevel`
Set loglevel on session
`uuid_loglevel`


`uuid_media`
Reinvite FS in or out of media path
`uuid_media_function`


`uuid_media_3p`
Reinvite FS in or out of media path using 3pcc
`uuid_media_3p_function`


`uuid_media_reneg`
Media negotiation
`uuid_media_neg_function`


`uuid_outgoing_answer`
Answer outgoing channel
`outgoing_answer_function`


`uuid_park`
Park channel
`park_function`


`uuid_pause`
Pause media on a channel
`pause_function`


`uuid_phone_event`
Send an event to the phone
`uuid_phone_event_function`


`uuid_pre_answer`
`pre_answer`
`uuid_pre_answer_function`


`uuid_preprocess`
Pre-process Channel
`preprocess_function`


`uuid_record`
Record session audio
`session_record_function`


`uuid_recovery_refresh`
`Send a recovery_refresh`
`uuid_recovery_refresh`


`uuid_recv_dtmf`
Receive dtmf digits
`uuid_recv_dtmf_function`


`uuid_redirect`
Send a redirect
`uuid_redirect`


`uuid_ring_ready`
Sending ringing to a channel
`uuid_ring_ready_function`


`uuid_send_dtmf`
Send dtmf digits
`uuid_send_dtmf_function`


`uuid_send_info`
Send info to the endpoint
`uuid_send_info_function`


`uuid_send_message`
Send MESSAGE to the endpoint
`uuid_send_message_function`


`uuid_send_text`
Send text in real-time
`uuid_send_text`


`uuid_session_heartbeat`
`uuid_session_heartbeat`
`uuid_session_heartbeat_function`


`uuid_set_media_stats`
Set media stats
`uuid_set_media_stats`


`uuid_setvar`
Set a variable
`uuid_setvar_function`


`uuid_setvar_multi`
Set multiple variables
`uuid_setvar_multi_function`


`uuid_simplify`
Try to cut out of a call path / attended xfer
`uuid_simplify_function`


`uuid_transfer`
Transfer a session
`transfer_function`


`uuid_video_bitrate`
Send video bitrate req.
`uuid_video_bitrate_function`


`uuid_video_refresh`
Send video refresh.
`uuid_video_refresh_function`


`uuid_zombie_exec`
`Set zombie_exec flag on the specified uuid`
`uuid_zombie_exec_function`


version
Version
`version_function`


`xml_flush_cache`
Clear xml cache
`xml_flush_function`


`xml_locate`
Find some xml
`xml_locate_function`


`xml_wrap`
Wrap another api command in xml
`xml_wrap_api_function`



