# API

`本章是`mod_commands`中的API列表，而在各模块中实现的API，则分别在各模块中讲述。`


参见：<https://freeswitch.org/confluence/display/FREESWITCH/mod_commands> 。


## ...

关闭FreeSWITCH。等于`shutdown`。

参数：无。

## acl

比较IP地址是与有访问控制列表匹配。

参数：`<ip> <list_name>`

例子：

```
freeswitch> acl 192.168.3.1 localnet.auto
true
freeswitch> acl 192.168.4.1 localnet.auto
false
```


## alias

Alias
alias_function
`[add|stickyadd] <alias> <command> | del [<alias>|*]`
 SWITCH_ADD_API(


commands_api_interface
coalesce
Return first nonempty parameter
coalesce_function
`[^^<delim>]<value1>,<value2>,...`

## banner

Return the system banner
banner_function
``

bg_system
Execute a system command in the background
bg_system_function
`<command>`

## bgapi

Execute an api command in a thread
bgapi_function
`<command>[ <arg>]`

## break

## uuid_break

break_function
`<uuid> [all]`

## complete

Complete
complete_function
`add <word>|del [<word>|*]`

## cond

Evaluate a conditional
cond_function
`<expr> ? <true val> : <false val>`

console_complete

console_complete_function
`<line>`

console_complete_xml

console_complete_xml_function
`<line>`

create_uuid
Create a uuid
## uuid_function

`<uuid> <other_uuid>`

db_cache
Manage db cache
db_cache_function
`status`

domain_exists
Check if a domain exists
domain_exists_function
`<domain>`

## echo

Echo
echo_function
`<data>`

## escape

Escape a string
escape_function
`<data>`

## eval

eval (noop)
eval_function
`[uuid:<uuid> ]<expression>`

event_channel_broadcast
Broadcast
event_channel_broadcast_api_function
`<channel> <json>`

## expand

Execute an api with variable expansion
expand_function
`[uuid:<uuid> ]<cmd> <args>`

file_exists
Check if a file exists on server
file_exists_function
`<file>`

find_user_xml
Find a user
find_user_function
`<key> <user> <domain>`

## fsctl

FS control messages
ctl_function
`[recover|send_sighup|hupall|pause [inbound|outbound]|resume [inbound|outbound]|shutdown [cancel|elegant|asap|now|restart]|sps|sps_peak_reset|sync_clock|sync_clock_when_idle|reclaim_mem|max_sessions|min_dtmf_duration [num]|max_dtmf_duration [num]|default_dtmf_duration [num]|min_idle_cpu|loglevel [level]|debug_level [level]]`

## getcputime

Gets CPU time in milliseconds (user,kernel)
getcputime_function
`[reset]`

## getenv

getenv
getenv_function
`<name>`

## gethost

gethostbyname
gethost_api_function
``

global_getvar
Get global var
global_getvar_function
`<var>`

global_setvar
Set global var
global_setvar_function
`<var>=<value> [=<value2>]`

group_call
Generate a dial string to call a group
group_call_function
`<group>[@<domain>]`

## help

Show help for all the api commands
help_function
``

host_lookup
Lookup host
host_lookup_function
`<hostname>`

## hostname

Return the system hostname
hostname_api_function
``

## hupall

hupall
hupall_api_function
`<cause> [<var> <value>]`

in_group
Determine if a user is in a group
in_group_function
`<user>[@<domain>] <group_name>`

interface_ip
Return the primary IP of an interface
interface_ip_function
`[auto|ipv4|ipv6] <ifname>`

is_lan_addr
See if an ip is a lan addr
lan_addr_function
`<ip>`

## json

JSON API
json_function
`JSON`

limit_hash_usage
Deprecated: gets the usage count of a limited resource
limit_hash_usage_function
`<realm> <id>`

limit_interval_reset
Reset the interval counter for a limited resource
limit_interval_reset_function
`<backend> <realm> <resource>`

limit_reset
Reset the counters of a limit backend
limit_reset_function
`<backend>`

limit_status
Get the status of a limit backend
limit_status_function
`<backend>`

limit_usage
Get the usage count of a limited resource
limit_usage_function
`<backend> <realm> <id>`

list_users
List Users configured in Directory
list_users_function
`[group <group>] [domain <domain>] [user <user>] [context <context>]`

## load

Load Module
load_function
`<mod_name>`

## log

Log
log_function
`<level> <message>`

## md5

Return md5 hash
md5_function
`<data>`

module_exists
Check if module exists
module_exists_function
`<module>`

## msleep

Sleep N milliseconds
msleep_function
`<milliseconds>`

nat_map
Manage NAT
nat_map_function
`[status|republish|reinit] | [add|del] <port> [tcp|udp] [static]`

## originate

Originate a call
originate_function
`<call url> <exten>|&<application_name>(<app_args>) [<dialplan>] [<context>] [<cid_name>] [<cid_num>] [<timeout_sec>]`

## pause

Pause media on a channel
pause_function
`<uuid> <on|off>`

quote_shell_arg
Quote/escape a string for use on shell command line
quote_shell_arg_function
`<data>`

reg_url

reg_url_function
`<user>@<realm>`

## regex

Evaluate a regex
regex_function
`<data>|<pattern>[|<subst string>][n|b]`

## reload

Reload module
reload_function
`[-f] <mod_name>`

## reloadacl

Reload XML
reload_acl_function
``

## reloadxml

Reload XML
reload_xml_function
``

## replace

Replace a string
replace_function
`<data>|<string1>|<string2>`

say_string

say_string_function
`<module_name>[.<ext>] <lang>[.<ext>] <say_type> <say_method> [<say_gender>] <text>`

sched_api
Schedule an api command
sched_api_function
`[+@]<time> <group_name> <command_string>[&]`

sched_broadcast
Schedule a broadcast event to a running call
sched_broadcast_function
`[[+]<time>|@time] <uuid> <path> [aleg|bleg|both]`

sched_del
Delete a scheduled task
sched_del_function
`<task_id>|<group_id>`

sched_hangup
Schedule a running call to hangup
sched_hangup_function
`[+]<time> <uuid> [<cause>]`

sched_transfer
Schedule a transfer for a running call
sched_transfer_function
`[+]<time> <uuid> <extension> [<dialplan>] [<context>]`

## show

Show various reports
show_function
`codec|endpoint|application|api|dialplan|file|timer|calls [count]|channels [count|like <match string>]|calls|detailed_calls|bridged_calls|detailed_bridged_calls|aliases|complete|chat|management|modules|nat_map|say|interfaces|interface_types|tasks|limits|status`

## shutdown

Shutdown
shutdown_function
``

sql_escape
Escape a string to prevent sql injection
sql_escape
`<string>`

## status

Show current status
status_function
``

strftime_tz
Display formatted time of timezone
strftime_tz_api_function
`<timezone_name> [<epoch>|][format string]`

## stun

Execute STUN lookup
stun_function
`<stun_server>[:port] [<source_ip>[:<source_port]]`

## switchname

Return the switch name
switchname_api_function
``

## system

Execute a system command
system_function
`<command>`

## time_test

Show time jitter
time_test_function
`<mss> [count]`

## timer_test

Exercise FS timer
timer_test_function
`<10|20|40|60|120> [<1..200>] [<timer_name>]`

## tone_detect

Start tone detection on a channel
tone_detect_session_function
`<uuid> <key> <tone_spec> [<flags> <timeout> <app> <args> <hits>]`

## unload

Unload module
unload_function
`[-f] <mod_name>`

unsched_api
Unschedule an api command
unsched_api_function
`<task_id>`

## uptime

Show uptime
uptime_function
`[us|ms|s|m|h|d|microseconds|milliseconds|seconds|minutes|hours|days]`

## url_decode

Url decode a string
url_decode_function
`<string>`

## url_encode

Url encode a string
url_encode_function
`<string>`

## user_data

Find user data
user_data_function
`<user>@<domain> [var|param|attr] <name>`

## user_exists

Find a user
user_exists_function
`<key> <user> <domain>`

## uuid_answer

answer
## uuid_answer_function

`<uuid>`

## uuid_audio

## uuid_audio

session_audio_function
`<uuid> [start [read|write] [mute|level <level>]|stop]`

## uuid_break

Break out of media sent to channel
break_function
`<uuid> [all]`

## uuid_bridge

Bridge call legs
## uuid_bridge_function

``

## uuid_broadcast

Execute dialplan application
## uuid_broadcast_function

`<uuid> <path> [aleg|bleg|holdb|both]`

## uuid_buglist

List media bugs on a session
## uuid_buglist_function

`<uuid>`

## uuid_capture_text

start/stop capture_text
## uuid_capture_text

`<uuid> <on|off>`

## uuid_chat

Send a chat message
## uuid_chat

`<uuid> <text>`

## uuid_codec_debug

Send codec a debug message
## uuid_codec_debug_function

`<uuid> audio|video <level>`

## uuid_codec_param

Send codec a param
## uuid_codec_param_function

`<uuid> audio|video read|write <param> <val>`

## uuid_debug_media

Debug media
## uuid_debug_media_function

`<uuid> <read|write|both|vread|vwrite|vboth|all> <on|off>`

## uuid_deflect

Send a deflect
## uuid_deflect

`<uuid> <uri>`

## uuid_displace

Displace audio
session_displace_function
`<uuid> [start|stop] <path> [<limit>] [mux]`

## uuid_display

Update phone display
## uuid_display_function

`<uuid> <display>`

## uuid_drop_dtmf

Drop all DTMF or replace it with a mask
## uuid_drop_dtmf

`<uuid> [on | off ] [ mask_digits <digits> | mask_file <file>]`

## uuid_dual_transfer

Transfer a session and its partner
dual_transfer_function
`<uuid> <A-dest-exten>[/<A-dialplan>][/<A-context>] <B-dest-exten>[/<B-dialplan>][/<B-context>]`

## uuid_dump

Dump session vars
## uuid_dump_function

`<uuid> [format]`

## uuid_early_ok

stop ignoring early media
## uuid_early_ok_function

`<uuid>`

## uuid_exists

Check if a uuid exists
## uuid_exists_function

`<uuid>`

## uuid_fileman

Manage session audio
## uuid_fileman_function

`<uuid> <cmd>:<val>`

## uuid_flush_dtmf

Flush dtmf on a given uuid
## uuid_flush_dtmf_function

`<uuid>`

## uuid_getvar

Get a variable from a channel
## uuid_getvar_function

`<uuid> <var>`

## uuid_hold

Place call on hold
## uuid_hold_function

`[off|toggle] <uuid> [<display>]`

## uuid_jitterbuffer

## uuid_jitterbuffer

## uuid_jitterbuffer_function

`<uuid> [0|<min_msec>[:<max_msec>]]`

## uuid_kill

Kill channel
kill_function
`<uuid> [cause]`

## uuid_limit

Increase limit resource
## uuid_limit_function

`<uuid> <backend> <realm> <resource> [<max>[/interval]] [number [dialplan [context]]]`

## uuid_limit_release

Release limit resource
## uuid_limit_release_function

`<uuid> <backend> [realm] [resource]`

## uuid_limit_release

Release limit resource
## uuid_limit_release_function

`<uuid> <backend> [realm] [resource]`

## uuid_loglevel

Set loglevel on session
## uuid_loglevel

`<uuid> <level>`

## uuid_media

Reinvite FS in or out of media path
## uuid_media_function

`[off] <uuid>`

## uuid_media_3p

Reinvite FS in or out of media path using 3pcc
## uuid_media_3p_function

`[off] <uuid>`

## uuid_media_reneg

Media negotiation
## uuid_media_neg_function

`<uuid>[ <codec_string>]`

## uuid_outgoing_answer

Answer outgoing channel
outgoing_answer_function
`<uuid>`

## uuid_park

Park channel
park_function
`<uuid>`

## uuid_pause

Pause media on a channel
pause_function
`<uuid> <on|off>`

## uuid_phone_event

Send an event to the phone
## uuid_phone_event_function

`<uuid>`

## uuid_pre_answer

pre_answer
## uuid_pre_answer_function

`<uuid>`

## uuid_preprocess

Pre-process Channel
preprocess_function
`<>`

## uuid_record

Record session audio
session_record_function
`<uuid> [start|stop|mask|unmask] <path> [<limit>]`

## uuid_recovery_refresh

Send a recovery_refresh
## uuid_recovery_refresh

`<uuid> <uri>`

## uuid_recv_dtmf

Receive dtmf digits
## uuid_recv_dtmf_function

`<uuid> <dtmf_data>`

## uuid_redirect

Send a redirect
## uuid_redirect

`<uuid> <uri>`

## uuid_ring_ready

Sending ringing to a channel
## uuid_ring_ready_function

`<uuid> [queued]`

## uuid_send_dtmf

Send dtmf digits
## uuid_send_dtmf_function

`<uuid> <dtmf_data>`

## uuid_send_info

Send info to the endpoint
## uuid_send_info_function

`<uuid> [<mime_type> <mime_subtype>] <message>`

## uuid_send_message

Send MESSAGE to the endpoint
## uuid_send_message_function

`<uuid> <message>`

## uuid_send_text

Send text in real-time
## uuid_send_text

`<uuid> <text>`

## uuid_session_heartbeat

## uuid_session_heartbeat

## uuid_session_heartbeat_function

`<uuid> [sched] [0|<seconds>]`

## uuid_set_media_stats

Set media stats
## uuid_set_media_stats

`<uuid>`

## uuid_setvar

Set a variable
## uuid_setvar_function

`<uuid> <var> [value]`

## uuid_setvar_multi

Set multiple variables
## uuid_setvar_multi_function

`<uuid> <var>=<value>;<var>=<value>...`

## uuid_simplify

Try to cut out of a call path / attended xfer
## uuid_simplify_function

`<uuid>`

## uuid_transfer

Transfer a session
transfer_function
`<uuid> [-bleg|-both] <dest-exten> [<dialplan>] [<context>]`

## uuid_video_bitrate

Send video bitrate req.
## uuid_video_bitrate_function

`<uuid> <bitrate>`

## uuid_video_refresh

Send video refresh.
## uuid_video_refresh_function

`<uuid>`

## uuid_zombie_exec

Set zombie_exec flag on the specified uuid
## uuid_zombie_exec_function

`<uuid>`

## version

Version
version_function
`[short]`

xml_flush_cache
Clear xml cache
xml_flush_function
`<id> <key> <val>`

xml_locate
Find some xml
xml_locate_function
`[root | <section> <tag> <tag_attr_name> <tag_attr_val>]`

xml_wrap
Wrap another api command in xml
xml_wrap_api_function
`<command> <args>`


以下API来自于`mod_dptools`：

## chat

chat
chat_api_function
`<proto>|<from>|<to>|<message>|[<content-type>]`

## page

Send a file as a page
page_api_function
`(var1=val1,var2=val2)<var1=val1,var2=val2><chan1>[:_:<chanN>]`

## presence

presence
presence_api_function
`[in|out] <user> <rpid> <message>`

## strepoch

Convert a date string into epoch time
strepoch_api_function
`<string>`

## strftime

strftime
strftime_api_function
`<format_string>`

## strmicroepoch

Convert a date string into micoepoch time
strmicroepoch_api_function
`<string>`



