/datum/quirk/dumb_for_cum
	name = "Dumb For Cum"
	desc = "For one reason or another, you're totally obsessed with seminal fluids. The heat of it, the smell... the taste... It's quite simply euphoric."
	value = -2
	gain_text = span_purple("You feel an insatiable craving for seminal fluids.")
	lose_text = span_purple("Cum didn't even taste that good, anyways.")
	medical_record_text = "Patient seems to have an unhealthy psychological obsession with seminal fluids."
	mob_trait = TRAIT_DUMB_CUM
	icon = FA_ICON_DROPLET
	erp_quirk = TRUE
	mail_goodies = list (
		/datum/glass_style/drinking_glass/cum = 1
	)
	var/timer
	var/timer_trigger = 15 MINUTES

/datum/quirk/dumb_for_cum/add(client/client_source)
	. = ..()

	// Set timer
	timer = addtimer(CALLBACK(src, PROC_REF(crave)), timer_trigger, TIMER_STOPPABLE)

/datum/quirk/dumb_for_cum/remove()
	. = ..()

	// Remove status trait
	REMOVE_TRAIT(quirk_holder, TRAIT_DUMB_CUM_CRAVE, QUIRK_TRAIT)

	// Remove penalty traits
	REMOVE_TRAIT(quirk_holder, TRAIT_ILLITERATE, QUIRK_TRAIT)
	REMOVE_TRAIT(quirk_holder, TRAIT_DUMB, QUIRK_TRAIT)
	REMOVE_TRAIT(quirk_holder, TRAIT_PACIFISM, QUIRK_TRAIT)

	// Remove mood event
	quirk_holder.clear_mood_event(QMOOD_DUMB_CUM)

	// Remove timer
	deltimer(timer)

/datum/quirk/dumb_for_cum/proc/crave()
	// Check if conscious
	if(quirk_holder.stat == CONSCIOUS)
		// Display emote
		quirk_holder.emote("sigh")

		// Define list of phrases
		var/list/trigger_phrases = list(
										"Your stomach rumbles a bit and cum comes to your mind.",\
										"Urgh, you should really get some cum...",\
										"Some jizz wouldn't be so bad right now!",\
										"You're starting to long for some more cum..."
									)
		// Alert user in chat
		to_chat(quirk_holder, span_love("[pick(trigger_phrases)]"))

	// Add active status trait
	ADD_TRAIT(quirk_holder, TRAIT_DUMB_CUM_CRAVE, QUIRK_TRAIT)

	// Add illiterate, dumb, and pacifist
	ADD_TRAIT(quirk_holder, TRAIT_ILLITERATE, QUIRK_TRAIT)
	ADD_TRAIT(quirk_holder, TRAIT_DUMB, QUIRK_TRAIT)
	ADD_TRAIT(quirk_holder, TRAIT_PACIFISM, QUIRK_TRAIT)

	// Add negative mood effect
	quirk_holder.add_mood_event(QMOOD_DUMB_CUM, /datum/mood_event/cum_craving)

/datum/quirk/dumb_for_cum/proc/uncrave()
	// Remove active status trait
	REMOVE_TRAIT(quirk_holder, TRAIT_DUMB_CUM_CRAVE, QUIRK_TRAIT)

	// Remove penalty traits
	REMOVE_TRAIT(quirk_holder, TRAIT_ILLITERATE, QUIRK_TRAIT)
	REMOVE_TRAIT(quirk_holder, TRAIT_DUMB, QUIRK_TRAIT)
	REMOVE_TRAIT(quirk_holder, TRAIT_PACIFISM, QUIRK_TRAIT)

	// Add positive mood event
	quirk_holder.add_mood_event(QMOOD_DUMB_CUM, /datum/mood_event/cum_stuffed)

	// Remove timer
	deltimer(timer)
	timer = null

	// Add new timer
	timer = addtimer(CALLBACK(src, PROC_REF(crave)), timer_trigger, TIMER_STOPPABLE)

// Equal to 'decharged' mood event
/datum/mood_event/cum_craving
	description = span_warning("I... NEED... CUM...")
	mood_change = -10

// Equal to 'charged' mood event
/datum/mood_event/cum_stuffed
	description = span_nicegreen("The cum feels so good inside me!")
	mood_change = 8
	timeout = 5 MINUTES
