# mod_callcenter

本文英文部分是来自<https://freeswitch.org/confluence/display/FREESWITCH/mod_callcenter>，中文部分是通过分析mod_callcenter.c的代码根据个人的理解整理而成。


## 关于作者
鼎鼎：cdevelop@qq.com qq:1280791187。 本文会不定期更新,最新版本在<http://www.ddrj.com/?p=79>。

## 配置 

### callcenter.conf.xml 范例


	<configuration name="callcenter.conf" description="CallCenter">
	  <settings>
	    <!--<param name="odbc-dsn" value="dsn:user:pass"/>-->
	    <!--<param name="dbname" value="/dev/shm/callcenter.db"/>-->
	    <!--<param name="reserve-agents" value="true"/>-->
	  </settings>
	
	  <queues>
	
	    <queue name="support@default">
	      <param name="strategy" value="longest-idle-agent"/>
	      <param name="moh-sound" value="$${hold_music}"/>
	      <!--<param name="record-template" value="$${base_dir}/recordings/${strftime(%Y-%m-%d-%H-%M-%S)}.${destination_number}.${caller_id_number}.${uuid}.wav"/>-->
	      <param name="time-base-score" value="system"/>
	      <param name="max-wait-time" value="0"/>
	      <param name="max-wait-time-with-no-agent" value="0"/>
	      <param name="max-wait-time-with-no-agent-time-reached" value="5"/>
	      <param name="tier-rules-apply" value="false"/>
	      <param name="tier-rule-wait-second" value="300"/>
	      <param name="tier-rule-wait-multiply-level" value="true"/>
	      <param name="tier-rule-no-agent-no-wait" value="false"/>
	      <param name="discard-abandoned-after" value="60"/>
	      <param name="abandoned-resume-allowed" value="false"/>
	    </queue>
	
	  </queues>
	
	<!-- WARNING: Configuration of XML Agents will be updated into the DB upon restart. -->
	<!-- WARNING: Configuration of XML Tiers will reset the level and position if those were supplied. -->
	<!-- WARNING: Agents and Tiers XML config shouldn't be used in a multi FS shared DB setup (Not currently supported anyway) -->
	  <agents>
	    <!--<agent name="1000@default" type="callback" contact="[leg_timeout=10]user/1000@default" status="Available" max-no-answer="3" wrap-up-time="10" reject-delay-time="10" busy-delay-time="60" />-->
	  </agents>
	  <tiers>
	    <!-- If no level or position is provided, they will default to 1.  You should do this to keep db value on restart. -->
	    <!-- <tier agent="1000@default" queue="support@default" level="1" position="1"/> -->
	  </tiers>
	
	</configuration>




### settings 配置详解

#### odbc-dsn
The callcenter will use the supplied ODBC database instead of the default behavior, which is to use the internal SQLite database.

使用ODBC数据源，需要配置这个参数

1. 使用odbc.ini配置的数据源:`dsn:user:pass`或者`dns` 
2. 不配置数据源直接连接方法:`odbc://DRIVER=driver;SERVER=host;UID=username;PWD=password;DATABASE=db;OPTION=67108864`。 driver(驱动，windows系统在ODBC数据源可以看到如“MySQL ODBC 5.3 Unicode Driver”,linux系统odbcinst.ini里面配置),host(数据库主机IP，本机：localhost),username(数据库用户名),password(数据库密码),db(数据库名)。

#### dbname
This is to specify a different name or path and name of the SQLite database. Useful to put into a ram disk for better performance.

使用SQLite数据库时，用来设置SQLite 数据库文件路径。如果odbc-dsn和dbname都不设置，会使用SQLite数据库，默认路径是`.\db\callcenter`。

#### reserve-agents
If defined to true, agent state is changed to Reserved if the old state is Receiving, the call will only be sent to him if the state get's changed.

This is useful if you're manipulating agent state external to mod_callcenter. false by default.

这个参数的作用是在呼叫坐席之前把`agents.state`设置为Reserved。默认值是false，就是不启动这个功能。


#### truncate-tiers-on-load
If defined to true, we'll delete all the agents when the module is loaded. false by default.

默认false,设置true时,load的时候清空数据库里的tiers表。

#### truncate-agents-on-load
If defined to true, we'll delete all the tiers when the module is loaded. false by default.

默认false,设置true时load的时候清空数据量里的agetns表。

### queues 配置详解
#### strategy
The strategy defines how calls are distributed in a queue. A table of different strategies can be found below.

* **ring-all**:	Rings all agents simultaneously.（全响）

	全部坐席响铃。

* **longest-idle-agent**:	Rings the agent who has been idle the longest taking into account tier level.（空闲时间）

	下面是`longest-idle-agent`模式派话使用的SQL，通过分析下面的SQL，可以看出是 根据  `tiers.level`, `agents.last_bridge_end`, `tiers.position` 这3个参数来排序的。`last_bridge_end`是坐席最后通话结束时间。

		SELECT system, name, status, contact, no_answer_count, max_no_answer, reject_delay_time, busy_delay_time, no_answer_delay_time, tiers.state, agents.last_bridge_end, agents.wrap_up_time, agents.state, agents.ready_time, tiers.position, tiers.level, agents.type, agents.uuid, external_calls_count FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND (agents.status = 'Available' OR agents.status = 'On Break' OR agents.status = 'Available (On Demand)') ORDER BY level, agents.last_bridge_end, position


* **round-robin**:	Rings the agent in position but remember last tried agent.（循环）

	下面是`round-robin`模式派话使用的SQL，通过分析下面的SQL，可以看出是按照 *tiers\_level* 从小到大, *tiers\_position* 从小到大,*agents\_last\_offered_call* 从小到大 循环分配坐席的。  。`agents.last_offered_call` 是最近一次呼叫坐席的时间。

		SELECT system, name, status, contact, no_answer_count, max_no_answer, reject_delay_time, busy_delay_time, no_answer_delay_time, tiers.state, agents.last_bridge_end, agents.wrap_up_time, agents.state, agents.ready_time, tiers.position as tiers_position, tiers.level as tiers_level, agents.type, agents.uuid, external_calls_count, agents.last_offered_call as agents_last_offered_call, 1 as dyn_order FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND (agents.status = 'Available' OR agents.status = 'On Break' OR agents.status = 'Available (On Demand)') AND tiers.position > (SELECT tiers.position FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND agents.last_offered_call > 0 ORDER BY agents.last_offered_call DESC LIMIT 1) AND tiers.level = (SELECT tiers.level FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND agents.last_offered_call > 0 ORDER BY agents.last_offered_call DESC LIMIT 1) UNION SELECT system, name, status, contact, no_answer_count, max_no_answer, reject_delay_time, busy_delay_time, no_answer_delay_time, tiers.state, agents.last_bridge_end, agents.wrap_up_time, agents.state, agents.ready_time, tiers.position as tiers_position, tiers.level as tiers_level, agents.type, agents.uuid, external_calls_count, agents.last_offered_call as agents_last_offered_call, 2 as dyn_order FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND (agents.status = 'Available' OR agents.status = 'On Break' OR agents.status = 'Available (On Demand)') ORDER BY dyn_order asc, tiers_level, tiers_position, agents_last_offered_call


* **top-down**:	Rings the agent in order position starting from 1 for every member.（指定开始位置）

	通道变量 *cc\_last\_agent\_tier\_level* 和 *cc\_last\_agent\_tier\_position* 默认值为0.

	查找座席的排序算法为，先查找 level 等于 *cc\_last\_agent\_tier\_level* ，position 大于  *cc\_last\_agent\_tier\_position* 的坐席，然后按照 *tiers\_level* , *tiers\_position* , *agents\_last\_offered_call* 排序所有坐席。
	

		SELECT system, name, status, contact, no_answer_count, max_no_answer, reject_delay_time, busy_delay_time, no_answer_delay_time, tiers.state, agents.last_bridge_end, agents.wrap_up_time, agents.state, agents.ready_time, tiers.position as tiers_position, tiers.level as tiers_level, agents.type, agents.uuid, external_calls_count, agents.last_offered_call as agents_last_offered_call, 1 as dyn_order FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND (agents.status = 'Available' OR agents.status = 'On Break' OR agents.status = 'Available (On Demand)') AND tiers.position > 0 AND tiers.level = 0 UNION SELECT system, name, status, contact, no_answer_count, max_no_answer, reject_delay_time, busy_delay_time, no_answer_delay_time, tiers.state, agents.last_bridge_end, agents.wrap_up_time, agents.state, agents.ready_time, tiers.position as tiers_position, tiers.level as tiers_level, agents.type, agents.uuid, external_calls_count, agents.last_offered_call as agents_last_offered_call, 2 as dyn_order FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND (agents.status = 'Available' OR agents.status = 'On Break' OR agents.status = 'Available (On Demand)') ORDER BY dyn_order asc, tiers_level, tiers_position, agents_last_offered_call

* **agent-with-least-talk-time**:	Rings the agent with least talk time.（通话时间）

	按照`tiers.level`, `agents.talk_time`, `tiers.position`排序坐席。`agents.talk_time`是坐席的通话时间。

	启动或者坐席签入时`agents.talk_time`会复位为0.

		SELECT system, name, status, contact, no_answer_count, max_no_answer, reject_delay_time, busy_delay_time, no_answer_delay_time, tiers.state, agents.last_bridge_end, agents.wrap_up_time, agents.state, agents.ready_time, tiers.position, tiers.level, agents.type, agents.uuid, external_calls_count FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND (agents.status = 'Available' OR agents.status = 'On Break' OR agents.status = 'Available (On Demand)') ORDER BY level, agents.talk_time, position

* **agent-with-fewest-calls**:	Rings the agent with fewest calls.（通话次数）

	按照`tiers.level`, `agents.calls_answered`, `tiers.position`排序坐席。`agents.calls_answered`是坐席的通话次数。

	启动或者坐席签入时`agents.calls_answered`会复位为0.

* **sequentially-by-agent-order**:	Rings agents sequentially by tier & order.（顺序）

	按照 *tiers\_level* , *tiers\_position* , *agents\_last\_offered_call* 排序所有坐席

		SELECT system, name, status, contact, no_answer_count, max_no_answer, reject_delay_time, busy_delay_time, no_answer_delay_time, tiers.state, agents.last_bridge_end, agents.wrap_up_time, agents.state, agents.ready_time, tiers.position, tiers.level, agents.type, agents.uuid, external_calls_count FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND (agents.status = 'Available' OR agents.status = 'On Break' OR agents.status = 'Available (On Demand)') ORDER BY level, position, agents.last_offered_call

* **random**:	Rings agents in random order.（随机）

	按照`tiers.level`顺序然后随机排序。

	如果连接mysql数据库，mod_callcenter.源代码需要修改一下。

		2550 	sql_order_by = switch_mprintf("level, random()");

	修改为

		2550 	sql_order_by = switch_mprintf("level, rand()");

	派话SQL

		SELECT system, name, status, contact, no_answer_count, max_no_answer, reject_delay_time, busy_delay_time, no_answer_delay_time, tiers.state, agents.last_bridge_end, agents.wrap_up_time, agents.state, agents.ready_time, tiers.position, tiers.level, agents.type, agents.uuid, external_calls_count FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND (agents.status = 'Available' OR agents.status = 'On Break' OR agents.status = 'Available (On Demand)') ORDER BY level, random()

* <a name = "ring-progressively">**ring-progressively**</a>:	Rings agents in the same way as top-down, but keeping the previous members ringing (it basically leads to ring-all in the end).（渐进）

	按照`tiers.level`和`tiers.position`排序坐席。每 *ring\_progressively\_delay* 秒，增加分配一个坐席。
	
	派话SQL

		SELECT system, name, status, contact, no_answer_count, max_no_answer, reject_delay_time, busy_delay_time, no_answer_delay_time, tiers.state, agents.last_bridge_end, agents.wrap_up_time, agents.state, agents.ready_time, tiers.position, tiers.level, agents.type, agents.uuid, external_calls_count FROM agents LEFT JOIN tiers ON (agents.name = tiers.agent) WHERE tiers.queue = 'support@default' AND (agents.status = 'Available' OR agents.status = 'On Break' OR agents.status = 'Available (On Demand)') ORDER BY level, position
	

默认值*longest-idle-agent*.

#### moh-sound
The system will playback whatever you specify to incoming callers. You can use any type of input here that is supported by the FreeSWITCH playback system:

1. A direct path to a .wav file will play in a loop indefinitely.
2. The local stream, e.g. (local_stream://moh) or use $${hold_music} as defined in the default configuration.
3. The FreeSWITCH phrase system, e.g., (phrase:my-special-phrase). (I use this to play multiple prompts after each other.)
4. A tone stream as with ringing, e.g., (tone_stream://${us-ring};loops=-1).

等待音乐，通道变量`cc_moh_override`可以覆盖这个设置。


#### announce-sound
坐席没接听之前周期性播放的通知声音，比如（现在是电话高峰期，请你耐心等待。）

#### announce-frequency
*announce-sound* 的播放周期，单位秒。注意播放声音文件的时间也包含在内。

#### record-template
Use the record-template to save your recording wherever you would like on the filesystem. It's not uncommon for this setting to start with "$${base_dir}/recordings/". Whatever directory you choose, make sure it already exists and that FreeSWITCH has the required permissions to write to it.

#### time-base-score
When a caller goes into a queue, we can add to their base score the total number of seconds they have been in the system. This enables the caller to get in front of other callers by the amount of time they have already spent waiting elsewhere.

The time-base-score param in a queue can be set as 'queue' (base score counts only the time the caller is in this queue) or 'system' (base score accounts for the total time of the call).

This can be either 'queue' or 'system' (queue is the default). If set to system, it will add the number of seconds since the call was originally answered (or entered the system) to the caller's base score. Raising the caller's score allows them to receive priority over other calls that might have been in the queue longer but not in the system as long. If set to queue, you get the default behavior, i.e., nobody's score gets increased upon entering the queue (regardless of the total length of their call).

默认值 *queue* 。为 *queue* 时，数据库`members.base_score`值是 进入队列的时间+`cc_base_score`。为 *system* 时`members.base_score`值是 应答时间+`cc_base_score`。

	/* Add manually imported score */
	if (cc_base_score) {
		cc_base_score_int += atoi(cc_base_score);
	}

	/* If system, will add the total time the session is up to the base score */
	if (!switch_strlen_zero(start_epoch) && !strcasecmp("system", queue->time_base_score)) {
		cc_base_score_int += ((long) local_epoch_time_now(NULL) - atol(start_epoch));
	}

#### ring-progressively-delay
Default to 10. The value is in seconds, and it will define the delay to wait before starting call to the next agent when using the 'ring-progressively' queue strategy.

strategy等于[ring-progressively](ring-progressively)时，增加坐席间隔。默认10秒。


#### tier-rules-apply
Can be True or False. This defines if we should apply the following tier rules when a caller advances through a queue's tiers. If False, they will use all tiers with no wait.

是否启动tier规则，默认值False。启动等级规则后，需要等待一定时间后，才会分配高等级的坐席。下面是mod_callcenter.c的实现代码。

	/* Check if we switch to a different tier, if so, check if we should continue further for that member */

	if (cbt->tier_rules_apply == SWITCH_TRUE && atoi(agent_tier_level) > cbt->tier) {
		/* Continue if no agent was logged in in the previous tier and noagent = true */
		if (cbt->tier_rule_no_agent_no_wait == SWITCH_TRUE && cbt->tier_agent_available == 0) {
			cbt->tier = atoi(agent_tier_level);
			/* Multiple the tier level by the tier wait time */
		} else if (cbt->tier_rule_wait_multiply_level == SWITCH_TRUE && (long) local_epoch_time_now(NULL) - atol(cbt->member_joined_epoch) >= atoi(agent_tier_level) * (int)cbt->tier_rule_wait_second) {
			cbt->tier = atoi(agent_tier_level);
			cbt->tier_agent_available = 0;
			/* Just check if joined is bigger than next tier wait time */
		} else if (cbt->tier_rule_wait_multiply_level == SWITCH_FALSE && (long) local_epoch_time_now(NULL) - atol(cbt->member_joined_epoch) >= (int)cbt->tier_rule_wait_second) {
			cbt->tier = atoi(agent_tier_level);
			cbt->tier_agent_available = 0;
		} else {
			/* We are not allowed to continue to the next tier of agent */
			return 1;
		}
	}
	cbt->tier_agent_available++;

#### tier-rule-wait-second
The time in seconds that a caller is required to wait before advancing to the next tier. This will be multiplied by the tier level if tier-rule-wait-multiply-level is set to True. If tier-rule-wait-multiply-level is set to false, then after tier-rule-wait-second's have passed, all tiers are open for calls in the tier-order and no advancement (in terms of waiting) to another tier is made.

等待时间。


#### tier-rule-wait-multiply-level
Can be True or False. If False, then once tier-rule-wait-second is passed, the caller is offered to all tiers in order (level/position). If True, the tier-rule-wait-second will be multiplied by the tier level and the caller will have to wait on every tier tier-rule-wait-second's before advancing to the next tier.

为True时，等待时间大于 `tier-rule-wait-second` * `tier.level` 才会分配下一个等级的坐席。为False时，等待时间大于 `tier-rule-wait-second` 才会分配下一个等级的坐席。默认值False。


#### tier-rule-no-agent-no-wait
Can be True or False. If True, callers will skip tiers that don't have agents available. Otherwise, they are be required to wait before advancing. Agents must be logged off to be considered not available.

最低level等级没有坐席是不用等待。默认值:False。

#### discard-abandoned-after
The number of seconds before we completely remove an abandoned member from the queue. When used in conjunction with abandoned-resume-allowed, callers can come back into a queue and resume their previous position.

未被坐席接通的排队信息保存时间，默认值60秒。

#### abandoned-resume-allowed
Can be True or False. If True, a caller who has abandoned the queue can re-enter and resume their previous position in that queue. In order to maintain their position in the queue, they must not abandoned it for longer than the number of seconds defined in 'discard-abandoned-after'.

根据caller_id_number恢复之前的排队信息，默认False。

详解：如果上一次加入对列，未被坐席接听就挂断了，再次呼叫时可以恢复上次的排队信息，被更优先的分配到坐席。*discard-abandoned-after* 之前的信息是不能恢复的。

#### max-wait-time
Default to 0 to be disabled. Any value are in seconds, and will define the delay before we quit the callcenter application IF the member haven't been answered by an agent. Can be used for sending call in voicemail if wait time is too long.

最大等待时间，单位秒。默认值0，就是禁用这个设置。例如，超过3分钟没坐席接听可以转到IVR或者语音信箱。


#### max-wait-time-with-no-agent
Default to 0 to be disabled. The value is in seconds, and it will define the amount of time the queue has to be empty (without logged agents, on a call or not) before we disconnect all members. This principle protects kicking all members waiting if all agents are logged off by accident.

队列为空时的最大等待时间。单位秒，默认值0，就是禁用这个设置。

什么是队列为空：队列没有坐席状态([Agent Status](#Agent-Status))是 *Available* 、 *Available (On Demand)* 、 *On Break* 的坐席。

#### max-wait-time-with-no-agent-time-reached
Default to 5. Any value are in seconds, and will define the length of time after the max-wait-time-with-no-agent is reached to reject new caller. This allow for kicking caller if no agent are logged in for over 5 seconds, but new caller after that 5 seconds is reached can have a lower limit.

`max-wait-time-with-no-agent`不为0时这个值才有效，最小的等待时间为`max-wait-time-with-no-agent+max-wait-time-with-no-agent-time-reached`，默认值5。设置0就是禁用这个设置。

参数作用：为了解决加入队列时，队列就为空时`queue->last_agent_exist`为0，`queue->last_agent_exist_check - queue->last_agent_exist`无法计算队列空闲时间，进行第二次判段， `queue->last_agent_exist_check - m->t_member_called` 的结果是加入队列总共时间，当加入队列总时间大于`max-wait-time-with-no-agent+max-wait-time-with-no-agent-time-reached`，就离开队列。

		/* Make the Caller Leave if he went over his max wait time */
		if (queue->max_wait_time > 0 && queue->max_wait_time <=  time_now - m->t_member_called) {
			switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_DEBUG, "Member %s <%s> in queue '%s' reached max wait time\n", m->member_cid_name, m->member_cid_number, m->queue_name);
			m->member_cancel_reason = CC_MEMBER_CANCEL_REASON_TIMEOUT;
			switch_channel_set_flag_value(member_channel, CF_BREAK, 2);
		}

		/* Check if max wait time no agent is Active AND if there is no Agent AND if the last agent check was after the member join */
		if (queue->max_wait_time_with_no_agent > 0 && queue->last_agent_exist_check > queue->last_agent_exist && m->t_member_called <= queue->last_agent_exist_check) {
			/* Check if the time without agent is bigger or equal than out threshold */
			if (queue->last_agent_exist_check - queue->last_agent_exist >= queue->max_wait_time_with_no_agent) {
				/* Check for grace period with no agent when member join */
				if (queue->max_wait_time_with_no_agent_time_reached > 0) {
					/* Check if the last agent check was after the member join, and we waited atless the extra time  */
					if (queue->last_agent_exist_check - m->t_member_called >= queue->max_wait_time_with_no_agent_time_reached + queue->max_wait_time_with_no_agent) {
						switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_DEBUG, "Member %s <%s> in queue '%s' reached max wait of %d sec. with no agent plus join grace period of %d sec.\n", m->member_cid_name, m->member_cid_number, m->queue_name, queue->max_wait_time_with_no_agent, queue->max_wait_time_with_no_agent_time_reached);
						m->member_cancel_reason = CC_MEMBER_CANCEL_REASON_NO_AGENT_TIMEOUT;
						switch_channel_set_flag_value(member_channel, CF_BREAK, 2);

					}
				} else {
					switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_DEBUG, "Member %s <%s> in queue '%s' reached max wait of %d sec. with no agent\n", m->member_cid_name, m->member_cid_number, m->queue_name, queue->max_wait_time_with_no_agent);
					m->member_cancel_reason = CC_MEMBER_CANCEL_REASON_NO_AGENT_TIMEOUT;
					switch_channel_set_flag_value(member_channel, CF_BREAK, 2);

				}
			}
		}

#### <a name="agent-no-answer-status">agent-no-answer-status</a>
如果坐席不应答次数超过[max-no-answer](#max-no-answer)(Agent中设置)，则设置坐席的状态为 *agent-no-answer-status* 的值。默认值 *On Break* 。其他值请参考[Agent Status](Agent-Status)。

#### skip-agents-with-external-calls

跳过有外部呼叫的座席，默认值true。意思就是如果一个坐席在呼出电话，或者接听不是mod_callcenter分配的电话时，是否跳过它，不分配话务给这个坐席。

仅仅设置这个参数，还是实现不了上面说的功能的，还需要`callcenter_track`这个app配合才可以。比如 1001坐席呼出时先执行一下`callcenter_track`。

		<action application="callcenter_track" data="1001@default"/>
		<action application="bridge" data="sofia/external/138XXXXXXXXX@sipserver"/>




### Agent 配置详解
Agents have Status and States. The Status is the general state of the agent. Statuses are not updated by the system automatically, so they must be set or changed as needed. States are the specific state of an agent with regard to the calls in the queue. States are dynamic and are updated by the system based on the progress of a agent in a call. The reason for separating the two is so that an agent can logout (change Status to 'Logged Out') without affecting his current call State (possibly set to 'In a queue call').

If an agent changes his status to Logged Out, any active callback attempts will be halted and the queue will try to place that caller with another agent.

Status only applies to the next call. So for example, if you change user from Available to Available (On Demand) while they are in a call, they will receive one more call when the current one finishes. 

Agent Status and States follow:

* *<a name = "Agent-Status">Agent Status</a>*:

<table><tr><td>
String</td><td>Description
</td></tr><tr><td>
Logged Out</td><td>Cannot receive queue calls.（签出）
</td></tr><tr><td>
Available</td><td>Ready to receive queue calls.
</td></tr><tr><td>
Available (On Demand)</td><td>State will be set to 'Idle' once the call ends (not automatically set to 'Waiting').
</td></tr><tr><td>
On Break</td><td>Still Logged in, but will not receive queue calls.（休息/示忙）
</td></tr></table>

*Available* 和 *Available (On Demand)* 的区别： *Available* 接完一个电话后 *Agent State* 会设置为 *Waiting* ， *Available (On Demand)* 接完一个电话后 *Agent State* 会设置为 *Idle* 。

* *<a name = "Agent-State">Agent State</a>*:

<table><tr><td>
String</td><td>Description
</td></tr><tr><td>
Idle</td><td>Does nothing, no calls are given.
</td></tr><tr><td>
Waiting</td><td>Ready to receive calls.
</td></tr><tr><td>
Receiving</td><td>A queue call is currently being offered to the agent.（振铃/呼叫）
</td></tr><tr><td>
In a queue call</td><td>Currently on a queue call.（通话）
</td></tr></table>

*Idle* 和 *Waiting* 的区别: *Idle* 坐席空闲中，但是不会分配话务。 *Waiting* 坐席空闲中，正在等待分配话务。

* *No Answer*

If you define the max-no-answer for an agent, and that agent fails to answer that many calls, then the agent's Status will changed to 'On Break'.（请参考[max-no-answer](#max-no-answer)）

* *Rejecting Calls*

Rejecting a call does not act as a 'no-answer'.

A delay can be added before calling an agent who has just rejected a call from the queue by setting `reject_delay_time` on an agent.（请参考[reject-delay-time](#reject-delay-time)）

* *Do not disturb*

An agent who is set to "do not disturb" can have a delay added before he is offered his next call by using the `busy_delay_time` parameter on the agent.(请参考[busy-delay-time](#busy-delay-time))


#### name
Agent name

#### type
We currently support 2 types, 'callback' and 'uuid-standby'. callback will try to reach the agent via the contact fields value. uuid-standby will try to bridge the call directly using the agent uuid.

1. **Callback**: 
	* Available
	>
While an agent's State is 'Waiting', calls will be directed to them. Whenever an agent completes one of those calls, their State is set back to 'Waiting'.
	* Available (On Demand)
	>
This is the same as the regular 'Available' Status, except that when the call is terminated, the agent's State is set to 'Idle'. This means the agent won't receive additional calls until his State is changed to 'Waiting'.

2. **uuid-standby**:This is used when agents call into the system and wait to receive a calls.

#### contact
A simple dial string can be put in here, like: user/1000@default. If using verto: ${verto_contact(1000@default)}

坐席的呼叫串。例如sip分机:`user/1000`，外线电话:`sofia/gateway/gatewayname/138XXXXXXXX`。可以通过变量设置呼叫参数比如呼叫超时主叫号码例：`[origination_caller_id_name='Queue Caller',leg_timeout=10]user/1001`。

#### status
Define the current status of an agent. Check the Agents Status table for more information.

坐席签入状态,参考[Agent Status](#Agent-Status)



#### <a name="max-no-answer">max-no-answer</a>
If the agent fails to answer calls this number of times, his status is changed to On Break automatically.


连续 *max-no-answer* 次呼叫坐席超时，就设置坐席状态为[agent-no-answer-status](#agent-no-answer-status)（Queues中设置，默认是 *On Break* ）

默认值0，就是不启动这个功能。

注意：只有呼叫超时才是不应答，用户拒接，用户忙，用户未注册等原因导致的呼叫失败不属于 *no-answer* 。具体可以参考下面源代码：

		switch (cause) {
			/* When we hang-up agents that did not answer in ring-all strategy */
			case SWITCH_CAUSE_ORIGINATOR_CANCEL:
				break;
			/* Busy: Do Not Disturb, Circuit congestion */
			case SWITCH_CAUSE_NORMAL_CIRCUIT_CONGESTION:
			case SWITCH_CAUSE_USER_BUSY:
				delay_next_agent_call = (h->busy_delay_time > delay_next_agent_call? h->busy_delay_time : delay_next_agent_call);
				break;
			/* Reject: User rejected the call */
			case SWITCH_CAUSE_CALL_REJECTED:
				delay_next_agent_call = (h->reject_delay_time > delay_next_agent_call? h->reject_delay_time : delay_next_agent_call);
				break;
			/* Protection againts super fast loop due to unregistrer */
			case SWITCH_CAUSE_USER_NOT_REGISTERED:
				delay_next_agent_call = 5;
				break;
			/* No answer: Destination does not answer for some other reason */
			default:
				delay_next_agent_call = (h->no_answer_delay_time > delay_next_agent_call? h->no_answer_delay_time : delay_next_agent_call);

				tiers_state = CC_TIER_STATE_NO_ANSWER;

				/* Update Agent NO Answer count */
				sql = switch_mprintf("UPDATE agents SET no_answer_count = no_answer_count + 1 WHERE name = '%q' AND system = '%q';",
						h->agent_name, h->agent_system);
				cc_execute_sql(NULL, sql, NULL);
				switch_safe_free(sql);

				/* Change Agent Status because he didn't answer often */
				if (h->max_no_answer > 0 && (h->no_answer_count + 1) >= h->max_no_answer) {
					switch_log_printf(SWITCH_CHANNEL_SESSION_LOG(member_session), SWITCH_LOG_DEBUG, "Agent %s reach maximum no answer of %d, setting agent status to %s\n",
							h->agent_name, h->max_no_answer, cc_agent_status2str(h->agent_no_answer_status));



#### wrap-up-time
The amount of time to wait before putting the agent back in the available queue to receive another call, to allow her to complete notes or other tasks.

话后处理时间，也就是坐席接完一个电话后， *wrap-up-time* 秒内不在分配话务给这个坐席。

#### <a name = "reject-delay-time">reject-delay-time</a>
If the agent presses the reject button on her phone, wait this defined time amount.

用户拒接时， *reject-delay-time* 秒内不再呼叫这个坐席。

只有 switch_ivr_originate 返回 SWITCH_CAUSE_CALL_REJECTED(sip消息603) 才是用户拒接。

#### <a name = "busy-delay-time">busy-delay-time</a>
If the agent is on Do Not Disturb, wait this defined time before trying him again.

用户忙时， *busy-delay-time* 秒内不再呼叫这个坐席。

只有 switch_ivr_originate 返回 SWITCH_CAUSE_NORMAL_CIRCUIT_CONGESTION(sip消息503) 和 SWITCH_CAUSE_USER_BUSY(sip消息486)，才是用户用户忙。

#### <a name = "no-answer-delay-time">no-answer-delay-time </a>
If the agent does not answer the call, wait this defined time before trying him again.

呼叫坐席超时时， *no-answer-delay-time* 秒内不再呼叫这个坐席。

可以参考[max-no-answer](#max-no-answer)的说明

## 通道变量
 * **cc\_export\_vars**

Export variables to the b-leg(s) of call center (the agents)

This is necessary because mod_callcenter originates B-leg calls in its own separate thread, therefore it has no access to variables set in the A-leg (as 'bridge' would).

Example usage:

	<action application="set" data="hold_music=local_stream://example_moh"/>
	<action application="set" data="origination_caller_id_name=Call Center"/>
	<action application="set" data="origination_caller_id_number=9000"/>
	<action application="set" data="cc_export_vars=hold_music,origination_caller_id_name,origination_caller_id_number"/>
	<action application="callcenter" data="9000@callcenter"/>

* **cc\_moh\_override**

Overrides the queue's default Music On Hold.

Example usage from mail list:

	<action application="set" data="cc_moh_override=/var/sounds/custom_moh.wav"/>
	<action application="set" data="cc_moh_override=/var/sounds/custom_moh.mp3"/>
	<action application="set" data="cc_moh_override=file_string:///var/sounds/custom_moh.wav!/var/sounds/custom_moh.mp3"/>
	<action application="set" data="cc_moh_override=tone_stream://%(2000,4000,440,480)"/>
	cc_base_score

Adds the specified amount to the caller's base score, potential putting him in front other callers in the queue.

* **cc\_exit\_keys**

Caller can exit the queue by pressing this key.
* **cc_outbound_cid_name_prefix**

Adds prefix to the Caller ID Name of the caller.

* **cc\_outbound\_announce**

Playback specific audio, or an array of audios, to the agent prior to bridging the member.

* **cc\_bridge\_failed\_outbound\_announce**

Playback specific audio to the agent if we can't bridge him because member hangup the call just before the bridge occurs. You can play a busy tone here or a custom audio, for example:
<action application="set" data="cc_bridge_failed_outbound_announce=tone_stream://%(250,250,425);loops=3"/>
<action application="callcenter" data="support@default"/>

* **cc\_warning\_tone**

This variable is only valid for agents in 'uuid-standby' mode. It plays the specified tone when a call is sent to the agent.

* **cc\_record_\filename**

Contains the filename of the call recording if a record-template was provided in the queue's configuration. (read-only)

* **cc\_side**

Contains the leg side of the call. Can be either member or agent. (read-only)

* **cc\_member\_uuid**

Contains the unique callcenter member uuid (Different from the member session uuid) (read-only)

* **cc\_member\_session\_uuid**

Contains the member session uuid. (Different from the member_uuid) (read-only)

* **cc\_agent**

Contains the agent who accepted the call from the queue. (read-only)

* **cc\_queue\_answered\_epoch**

Contains the epoch time that the agent answered the call. (read only)

* **cc\_queue\_terminated\_epoch**

Contains the epoch time that the bridge with the agent was terminated. (read-only)

* **cc\_queue\_joined\_epoch**

Contains the epoch time that the caller joined the queue and started waiting. (read-only)

* **cc\_queue\_canceled\_epoch**

Contains the epoch time when a caller leaves the queue and aborts the call. (read-only)

* **cc\_agent\_bridged**

Contains a boolean value indicating if this call was successfully bridged or not. We may call the agent and the member can hangup just before bridging them. (read-only)
* 
## APP
* callcenter
* callcenter_track

## API
* callcenter_config agent add [name] [type] 
* callcenter_config agent del [name] 
* callcenter_config agent reload [name] 
* callcenter_config agent set status [agent_name] [status] 
* callcenter_config agent set state [agent_name] [state] 
* callcenter_config agent set contact [agent_name] [contact] 
* callcenter_config agent set ready_time [agent_name] [wait till epoch] 
* callcenter_config agent set reject_delay_time [agent_name] [wait second] 
* callcenter_config agent set busy_delay_time [agent_name] [wait second] 
* callcenter_config agent set no_answer_delay_time [agent_name] [wait second] 
* callcenter_config agent get status [agent_name] 
* callcenter_config agent get state [agent_name] 
* callcenter_config agent get uuid [agent_name] 
* callcenter_config agent list [[agent_name]] 
* callcenter_config tier add [queue_name] [agent_name] [[level]] [[position]] 
* callcenter_config tier set state [queue_name] [agent_name] [state] 
* callcenter_config tier set level [queue_name] [agent_name] [level] 
* callcenter_config tier set position [queue_name] [agent_name] [position] 
* callcenter_config tier del [queue_name] [agent_name] 
* callcenter_config tier reload [queue_name] [agent_name] 
* callcenter_config tier list 
* callcenter_config queue load [queue_name] 
* callcenter_config queue unload [queue_name] 
* callcenter_config queue reload [queue_name] 
* callcenter_config queue list 
* callcenter_config queue list agents [queue_name] [status] [state] 
* callcenter_config queue list members [queue_name] 
* callcenter_config queue list tiers [queue_name] 
* callcenter_config queue count 
* callcenter_config queue count agents [queue_name] [status] [state] 
* callcenter_config queue count members [queue_name] 
* callcenter_config queue count tiers [queue_name] 
