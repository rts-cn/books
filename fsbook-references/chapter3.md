# APP



## answer

'Answer the call'
'Answer the call for a channel.'
answer_function
''
SAF_SUPPORT_NOMEDIA


## att_xfer

'Attended Transfer'
'Attended Transfer'
att_xfer_function
'<channel_url>'
SAF_NONE


## bgsystem

'Execute a system command in the background'
'Execute a background system command'
bgsystem_session_function
'<command>',

## bind_digit_action

'bind a key sequence or regex to an action',

## bind_meta_app

'Bind a key to an application'
'Bind a key to an application'
dtmf_bind_function
'<key> [a|b|ab] [a|b|o|s|i|1] <app>',

## blind_transfer_ack

''
''
blind_transfer_ack_function
'[true|false]'
SAF_NONE


## block_dtmf

'Block DTMF'
'Block DTMF'
dtmf_block_function
''
SAF_SUPPORT_NOMEDIA


## break

'Break'
'Set the break flag.'
break_function
''
SAF_SUPPORT_NOMEDIA


## bridge

'Bridge Audio'
'Bridge the audio between two sessions'
audio_bridge_function
'<channel_url>',

## bridge_export

'Export a channel variable across a bridge'
'Set and export a channel variable for the channel calling the application.'
bridge_export_function
'<varname>=<value>',

## capture

'capture data into a var'
'capture data into a var',

## capture_text

'capture text'
'capture text'
capture_text_function
''
SAF_NONE


## check_acl

'Check an ip against an ACL list'
'Check an ip against an ACL list'
check_acl_function,

## clear_digit_action

'clear all digit bindings'
'',

## clear_speech_cache

'Clear Speech Handle Cache'
'Clear Speech Handle Cache'
clear_speech_cache_function
'',

## cng_plc

'Do PLC on CNG frames'
''
cng_plc_function
'',

## deduplicate_dtmf

'Prevent duplicate inband + 2833 dtmf'
''
deduplicate_dtmf_app_function
'[only_rtp]'
SAF_SUPPORT_NOMEDIA


## deflect

'Send call deflect'
'Send a call deflect.'
deflect_function
'<deflect_data>'
SAF_SUPPORT_NOMEDIA


## delay_echo

'echo audio at a specified delay'
'Delay n ms'
delay_function
'<delay ms>'
SAF_NONE


## detect_audio

'detect_audio'
'detect_audio'
detect_audio_function
'<threshold> <audio_hits> <timeout_ms> [<file>]',

## detect_silence

'detect_silence'
'detect_silence'
detect_silence_function
'<threshold> <silence_hits> <timeout_ms> [<file>]',

## detect_speech

'Detect speech'
'Detect speech on a channel.'
detect_speech_function
'<mod_name> <gram_name> <gram_path> [<addr>] OR grammar <gram_name> [<path>] OR nogrammar <gram_name> OR grammaron/grammaroff <gram_name> OR grammarsalloff OR pause OR resume OR start_input_timers OR stop OR param <name> <value>'
SAF_NONE


## digit_action_set_realm

'change binding realm'
'',

## displace_session

'Displace File'
'Displace audio from a file to the channels input'
displace_session_function
'<path> [<flags>] [+time_limit_ms]',

## early_hangup

'Enable early hangup'
''
early_hangup_function
''
SAF_SUPPORT_NOMEDIA | SAF_ROUTING_EXEC


## eavesdrop

'eavesdrop on a uuid'
'eavesdrop on a uuid'
eavesdrop_function
'[all | <uuid>]'
SAF_MEDIA_TAP


## echo

'Echo'
'Perform an echo test against the calling channel'
echo_function
''
SAF_NONE


## enable_heartbeat

'Enable Media Heartbeat'
'Enable Media Heartbeat',

## enable_keepalive

'Enable Keepalive'
'Enable Keepalive',

## endless_playback

'Playback File Endlessly'
'Endlessly Playback a file to the channel',

## eval

'Do Nothing'
'Do Nothing'
eval_function
''
SAF_SUPPORT_NOMEDIA | SAF_ROUTING_EXEC | SAF_ZOMBIE_EXEC


## event

'Fire an event'
'Fire an event'
event_function
''
SAF_SUPPORT_NOMEDIA | SAF_ROUTING_EXEC | SAF_ZOMBIE_EXEC


## execute_extension

'Execute an extension'
'Execute an extension'
exe_function
'<extension> <dialplan> <context>'
SAF_SUPPORT_NOMEDIA


## export

'Export a channel variable across a bridge'
'Set and export a channel variable for the channel calling the application.'
export_function
'<varname>=<value>',

## fax_detect

'Detect faxes'
'Detect fax send tone'
fax_detect_session_function
''
SAF_MEDIA_TAP


## flush_dtmf

'flush any queued dtmf'
'flush any queued dtmf'
flush_dtmf_function
''
SAF_SUPPORT_NOMEDIA


## gentones

'Generate Tones'
'Generate tones to the channel'
gentones_function
'<tgml_script>[|<loops>]'
SAF_NONE


## hangup

'Hangup the call'
'Hangup the call for a channel.'
hangup_function
'[<cause>]'
SAF_SUPPORT_NOMEDIA


## hold

'Send a hold message'
'Send a hold message'
hold_function
'[<display message>]'
SAF_SUPPORT_NOMEDIA


## info

'Display Call Info'
'Display Call Info'
info_function
''
SAF_SUPPORT_NOMEDIA | SAF_ROUTING_EXEC | SAF_ZOMBIE_EXEC


## intercept

'intercept'
'intercept'
intercept_function
'[-bleg] <uuid>'
SAF_NONE


## ivr

'Run an ivr menu'
'Run an ivr menu.'
ivr_application_function
'<menu_name>'
SAF_NONE


## jitterbuffer

'Send session jitterbuffer'
'Send a jitterbuffer message to a session.',

## limit

'Limit'
'limit access to a resource and transfer to an extension if the limit is exceeded'
limit_function
'<backend> <realm> <id> [<max>[/interval]] [number [dialplan [context]]]'
SAF_SUPPORT_NOMEDIA


## limit_execute

'Limit'
'limit access to a resource. the specified application will only be executed if the resource is available'
limit_execute_function
'<backend> <realm> <id> <max>[/interval] <application> [application arguments]'
SAF_SUPPORT_NOMEDIA


## limit_hash

'Limit'
'DEPRECATED: limit access to a resource and transfer to an extension if the limit is exceeded'
limit_hash_function
'<realm> <id> [<max>[/interval]] [number [dialplan [context]]]'
SAF_SUPPORT_NOMEDIA


## limit_hash_execute

'Limit'
'DEPRECATED: limit access to a resource. the specified application will only be executed if the resource is available'
limit_hash_execute_function
'<realm> <id> <max>[/interval] <application> [application arguments]'
SAF_SUPPORT_NOMEDIA


## log

'Logs to the logger'
'Logs a channel variable for the channel calling the application.'
log_function
'<log_level> <log_string>',

## loop_playback

'Playback File looply'
'Playback a file to the channel looply for limted times',

## media_reset

'Reset all bypass/proxy media flags'
'Reset all bypass/proxy media flags'
media_reset_function
''
SAF_SUPPORT_NOMEDIA


## mkdir

'Create a directory'
'Create a directory'
mkdir_function
'<path>'
SAF_SUPPORT_NOMEDIA


## multiset

'Set many channel variables'
'Set a channel variable for the channel calling the application.'
multiset_function
'[^^<delim>]<varname>=<value> <var2>=<val2>',

## multiunset

'Unset many channel variables'
'Set a channel variable for the channel calling the application.'
multiunset_function
'[^^<delim>]<varname> <var2> <var3>',

## mutex

'block on a call flow only allowing one at a time'
''
mutex_function
'<keyname>[ on|off]'
SAF_SUPPORT_NOMEDIA


## novideo

'Refuse Inbound Video'
'Refuse Inbound Video'
novideo_function
'',

## page

''
''
page_function
'<var1=val1,var2=val2><chan1>[:_:<chanN>]'
SAF_NONE


## park

'Park'
'Park'
park_function
''
SAF_SUPPORT_NOMEDIA


## park_state

'Park State'
'Park State'
park_state_function
''
SAF_NONE


## phrase

'Say a Phrase'
'Say a Phrase'
phrase_function
'<macro_name>,<data>'
SAF_NONE


## pickup

'Pickup'
'Pickup a call'
pickup_function
'[<key>]'
SAF_SUPPORT_NOMEDIA


## play_and_detect_speech

'Play and do speech recognition'
'Play and do speech recognition'
play_and_detect_speech_function
'<file> detect:<engine> {param1=val1,param2=val2}<grammar>'
SAF_NONE


## play_and_get_digits

'Play and get Digits'
'Play and get Digits',

## playback

'Playback File'
'Playback a file to the channel'
playback_function
'<path>'
SAF_NONE


## pre_answer

'Pre-Answer the call'
'Pre-Answer the call for a channel.'
pre_answer_function
''
SAF_SUPPORT_NOMEDIA


## preprocess

'pre-process'
'pre-process'
preprocess_session_function
''
SAF_NONE


## presence

'Send Presence'
'Send Presence.'
presence_function
'<rpid> <status> [<id>]',

## privacy

'Set privacy on calls'
'Set caller privacy on calls.'
privacy_function
'off|on|name|full|number',

## push

'Set a channel variable'
'Set a channel variable for the channel calling the application.'
push_function
'<varname>=<value>',

## queue_dtmf

'Queue dtmf to be sent'
'Queue dtmf to be sent from a session'
queue_dtmf_function
'<dtmf_data>',

## read

'Read Digits'
'Read Digits'
read_function,

## record

'Record File'
'Record a file from the channels input'
record_function,

## record_session

'Record Session'
'Starts a background recording of the entire session'
record_session_function
'<path> [+<timeout>]'
SAF_MEDIA_TAP


## record_session_mask

'Mask audio in recording'
'Replace audio in a recording with blank data to mask critical voice sections'
record_session_mask_function
'<path>'
SAF_MEDIA_TAP


## record_session_unmask

'Resume recording'
'Resume normal operation after calling mask'
record_session_unmask_function
'<path>'
SAF_MEDIA_TAP


## recovery_refresh

'Send call recovery_refresh'
'Send a call recovery_refresh.'
recovery_refresh_function
''
SAF_SUPPORT_NOMEDIA


## redirect

'Send session redirect'
'Send a redirect message to a session.'
redirect_function
'<redirect_data>',

## remove_bugs

'Remove media bugs'
'Remove all media bugs from a channel.'
remove_bugs_function
'[<function>]'
SAF_NONE


## rename

'Rename file'
'Rename file'
rename_function
'<from_path> <to_path>'
SAF_SUPPORT_NOMEDIA | SAF_ZOMBIE_EXEC


## respond

'Send session respond'
'Send a respond message to a session.'
respond_function
'<respond_data>',

## ring_ready

'Indicate Ring_Ready'
'Indicate Ring_Ready on a channel.'
ring_ready_function
''
SAF_SUPPORT_NOMEDIA


## say

'say'
'say'
say_function
'<module_name>[:<lang>] <say_type> <say_method> [<say_gender>] <text>'
SAF_NONE


## sched_broadcast

'Schedule a broadcast in the future'
'Schedule a broadcast in the future'
sched_broadcast_function,

## sched_cancel

'cancel scheduled tasks'
'cancel scheduled tasks'
sched_cancel_function
'[group]',

## sched_hangup

'Schedule a hangup in the future'
'Schedule a hangup in the future'
sched_hangup_function
'[+]<time> [<cause>]',

## sched_heartbeat

'Enable Scheduled Heartbeat'
'Enable Scheduled Heartbeat',

## sched_transfer

'Schedule a transfer in the future'
'Schedule a transfer in the future'
sched_transfer_function,

## send_display

'Send session a new display'
'Send session a new display.'
display_function
'<text>',

## send_dtmf

'Send dtmf to be sent'
'Send dtmf to be sent from a session'
send_dtmf_function
'<dtmf_data>',

## send_info

'Send info'
'Send info'
send_info_function
'<info>'
SAF_SUPPORT_NOMEDIA


## session_loglevel

'session_loglevel'
'session_loglevel'
session_loglevel_function
'<level>',

## set

'Set a channel variable'
'Set a channel variable for the channel calling the application.'
set_function
'<varname>=<value>',

## set_audio_level

'set volume'
'set volume'
set_audio_level_function
''
SAF_NONE


## set_global

'Set a global variable'
'Set a global variable.'
set_global_function
'<varname>=<value>',

## set_media_stats

'Set Media Stats'
'Set Media Stats'
set_media_stats_function
''
SAF_SUPPORT_NOMEDIA | SAF_ROUTING_EXEC | SAF_ZOMBIE_EXEC


## set_mute

'set mute'
'set mute'
set_mute_function
''
SAF_NONE


## set_name

'Name the channel'
'Name the channel'
set_name_function
'<name>'
SAF_SUPPORT_NOMEDIA


## set_profile_var

'Set a caller profile variable'
'Set a caller profile variable for the channel calling the application.'
set_profile_var_function,

## set_user

'Set a User'
'Set a User'
set_user_function
'<user>@<domain> [prefix]'
SAF_SUPPORT_NOMEDIA | SAF_ROUTING_EXEC


## set_zombie_exec

'Enable Zombie Execution'
'Enable Zombie Execution',

## sleep

'Pause a channel'
'Pause the channel for a given number of milliseconds

## consuming the audio for that period of time.

sleep_function
'<pausemilliseconds>'
SAF_SUPPORT_NOMEDIA


## soft_hold

'Put a bridged channel on hold'
'Put a bridged channel on hold'
soft_hold_function
'<unhold key> [<moh_a>] [<moh_b>]',

## sound_test

'Analyze Audio'
'Analyze Audio'
sound_test_function
''
SAF_NONE


## speak

'Speak text'
'Speak text to a channel via the tts interface'
speak_function
'<engine>|<voice>|<text>'
SAF_NONE


## start_dtmf

'Detect dtmf'
'Detect inband dtmf on the session'
dtmf_session_function
''
SAF_MEDIA_TAP


## start_dtmf_generate

'Generate dtmf'
'Generate inband dtmf on the session'
dtmf_session_generate_function
'',

## stop

'Do Nothing'
'Do Nothing'
eval_function
''
SAF_SUPPORT_NOMEDIA | SAF_ROUTING_EXEC


## stop_displace_session

'Stop Displace File'
'Stop Displacing to a file'
stop_displace_session_function
'<path>',

## stop_dtmf

'stop inband dtmf'
'Stop detecting inband dtmf.'
stop_dtmf_session_function
''
SAF_NONE


## stop_dtmf_generate

'stop inband dtmf generation'
'Stop generating inband dtmf.',

## stop_record_session

'Stop Record Session'
'Stops a background recording of the entire session'
stop_record_session_function
'<path>'
SAF_NONE


## stop_tone_detect

'stop detecting tones'
'Stop detecting tones'
stop_fax_detect_session_function
''
SAF_NONE


## stop_video_write_overlay

'Stop video write overlay'
'Stop video write overlay'
stop_video_write_overlay_session_function
'<path>'
SAF_NONE


## strftime

'strftime'
'strftime'
strftime_function
'[<epoch>|]<format string>'
SAF_SUPPORT_NOMEDIA


## system

'Execute a system command'
'Execute a system command'
system_session_function
'<command>',

## three_way

'three way call with a uuid'
'three way call with a uuid'
three_way_function
'<uuid>',

## tone_detect

'Detect tones'
'Detect tones'
tone_detect_session_function
''
SAF_MEDIA_TAP


## transfer

'Transfer a channel'
'Immediately transfer the calling channel to a new extension'
transfer_function
'<exten> [<dialplan> <context>]',

## transfer_vars

'Transfer variables'
'Transfer variables'
transfer_vars_function
'<~variable_prefix|variable>',

## unbind_meta_app

'Unbind a key from an application'
'Unbind a key from an application'
dtmf_unbind_function,

## unblock_dtmf

'Stop blocking DTMF'
'Stop blocking DTMF'
dtmf_unblock_function
''
SAF_SUPPORT_NOMEDIA


## unhold

'Send a un-hold message'
'Send a un-hold message'
unhold_function
''
SAF_SUPPORT_NOMEDIA


## unset

'Unset a channel variable'
'Unset a channel variable for the channel calling the application.'
unset_function
'<varname>',

## unshift

'Set a channel variable'
'Set a channel variable for the channel calling the application.'
unshift_function
'<varname>=<value>',

## verbose_events

'Make ALL Events verbose.'
'Make ALL Events verbose.'
verbose_events_function
'',

## video_decode

'Set video decode.'
'Set video decode.'
video_set_decode_function
'[[on|wait]|off]',

## video_refresh

'Send video refresh.'
'Send video refresh.'
video_refresh_function
'',

## video_write_overlay

'Video write overlay'
'Video write overlay'
video_write_overlay_session_function
'<path> [<pos>] [<alpha>]'
SAF_MEDIA_TAP


## wait_for_answer

'Wait for call to be answered'
'Wait for call to be answered.'
wait_for_answer_function
''
SAF_SUPPORT_NOMEDIA


## wait_for_silence

'wait_for_silence'
'wait_for_silence'
wait_for_silence_function
'<silence_thresh> <silence_hits> <listen_hits> <timeout_ms> [<file>]',
