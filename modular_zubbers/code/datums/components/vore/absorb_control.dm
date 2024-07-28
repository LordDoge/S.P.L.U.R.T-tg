/datum/component/absorb_control
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/reverted = FALSE
	var/mob/living/controller
	var/mob/living/pred_backseat/pred_backseat

/datum/component/absorb_control/Initialize(mob/living/new_controller)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(!istype(new_controller))
		return COMPONENT_INCOMPATIBLE
	controller = new_controller
	pred_backseat = new(parent, src)

	RegisterSignal(controller, COMSIG_QDELETING, PROC_REF(revert))
	RegisterSignal(controller, COMSIG_MOVABLE_MOVED, PROC_REF(revert))

	put_pred_in_backseat()

/datum/component/absorb_control/Destroy()
	revert()
	QDEL_NULL(pred_backseat)
	UnregisterSignal(controller, COMSIG_QDELETING)
	UnregisterSignal(controller, COMSIG_MOVABLE_MOVED)
	controller = null
	. = ..()

// Blindly swaps between pred and prey
/datum/component/absorb_control/proc/unsafe_swap()
	PRIVATE_PROC(TRUE)

	var/mob/living/puppet = parent
	to_chat(puppet, span_userdanger("You feel your control being taken away..."))

	var/mob/living/puppetmaster
	var/mob/living/backseat
	if(pred_backseat.ckey)
		puppetmaster = pred_backseat
		backseat = controller
	else
		puppetmaster = controller
		backseat = pred_backseat
		backseat.name = puppet.name

	to_chat(puppetmaster, span_userdanger("You take control of [puppet]!"))

	// Swap puppet to backseat
	var/puppet_id = puppet.computer_id
	var/puppet_ip = puppet.lastKnownIP
	puppet.computer_id = null
	puppet.lastKnownIP = null

	backseat.ckey = puppet.ckey
	if(puppet.mind)
		backseat.mind = puppet.mind
	if(!backseat.computer_id)
		backseat.computer_id = puppet_id
	if(!backseat.lastKnownIP)
		backseat.lastKnownIP = puppet_ip

	// Swap puppetmaster to puppet
	var/master_id = puppetmaster.computer_id
	var/master_ip = puppetmaster.lastKnownIP
	puppetmaster.computer_id = null
	puppetmaster.lastKnownIP = null

	puppet.ckey = puppetmaster.ckey
	puppet.mind = puppetmaster.mind
	if(!puppet.computer_id)
		puppet.computer_id = master_id
	if(!puppet.lastKnownIP)
		puppet.lastKnownIP = master_ip

/datum/component/absorb_control/proc/put_pred_in_backseat()
	if(!pred_backseat.ckey)
		unsafe_swap()

/datum/component/absorb_control/proc/revert()
	if(reverted)
		return
	reverted = TRUE

	if(pred_backseat.ckey)
		unsafe_swap()

	qdel(src)

/mob/living/pred_backseat
	name = "pred backseat"
	var/mob/living/body
	var/datum/component/absorb_control/absorb_control

/mob/living/pred_backseat/Initialize(mapload, datum/component/absorb_control/new_absorb_control)
	. = ..()
	if(isliving(loc))
		body = loc
		absorb_control = new_absorb_control

/mob/living/pred_backseat/Life(seconds_per_tick, times_fired)
	if(QDELETED(body))
		qdel(src)

	if(body.stat == DEAD)
		absorb_control.revert()

	if(!body.client)
		absorb_control.revert()

	. = ..()

/mob/living/pred_backseat/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, message_range, datum/saymode/saymode, list/message_mods)
	SHOULD_CALL_PARENT(FALSE)
	if(!message)
		return
	if(!try_speak(message, ignore_spam, forced, filterproof))
		return

	to_chat(src, span_notice("You whisper into [body]'s mind, ") + span_game_say("\"[message]\""))
	to_chat(body, span_notice("You hear [src]'s voice in your head... ") + span_game_say("\"[message]\""))
	return FALSE

/mob/living/pred_backseat/emote(act, m_type = null, message = null, intentional = FALSE, force_silence = FALSE)
	return FALSE
