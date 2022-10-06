/mob/living/simple_animal/hostile/abnormality/fairy_festival
	name = "Fairy Festival"
	desc = "The abnormality is similar to a fairy, having two pairs of wings and a small body. The small fairies around it act as a cluster."
	icon = 'ModularTegustation/Teguicons/tegumobs.dmi'
	icon_state = "fairy"
	icon_living = "fairy"
	maxHealth = 83
	health = 83
	is_flying_animal = TRUE
	threat_level = ZAYIN_LEVEL
	work_chances = list(
		ABNORMALITY_WORK_INSTINCT = 70,
		ABNORMALITY_WORK_INSIGHT = list(50, 40, 30, 30, 30),
		ABNORMALITY_WORK_ATTACHMENT = list(70, 60, 50, 50, 50),
		ABNORMALITY_WORK_REPRESSION = list(50, 40, 30, 30, 30)
		)
	work_damage_amount = 6
	work_damage_type = RED_DAMAGE
	max_boxes = 10

	ego_list = list(
		/datum/ego_datum/weapon/wingbeat,
		/datum/ego_datum/armor/wingbeat
		)
	gift_type =  /datum/ego_gifts/wingbeat
	gift_message = "Fairy Dust covers your hands..."

	var/heal_duration = 90 SECONDS
	var/heal_amount = 0.02
	var/heal_cooldown = 2 SECONDS
	var/heal_cooldown_base = 2 SECONDS
	var/list/mob/living/carbon/human/protected_people = list()

/mob/living/simple_animal/hostile/abnormality/fairy_festival/proc/FairyHeal()
	for(var/mob/living/carbon/human/P in protected_people)
		if(heal_cooldown <= world.time)
			P.adjustBruteLoss(-heal_amount*P.getMaxHealth())
			P.adjustFireLoss(-heal_amount*P.getMaxHealth())
			P.adjustSanityLoss(heal_amount*P.getMaxSanity())
	heal_cooldown = (world.time + heal_cooldown_base)
	return

/mob/living/simple_animal/hostile/abnormality/fairy_festival/success_effect(mob/living/carbon/human/user, work_type, pe)
	if(user.stat != DEAD && istype(user))
		if(user in protected_people)
			return
		protected_people += user
		RegisterSignal(user, COMSIG_WORK_STARTED, .proc/FairyGib)
		to_chat(user, "<span class='nicegreen'>You feel at peace under the fairies' care.</span>")
		playsound(get_turf(user), 'sound/abnormalities/fairyfestival/fairylaugh.ogg', 50, 0, 2)
		user.add_overlay(mutable_appearance('ModularTegustation/Teguicons/tegu_effects.dmi', "fairy_heal", -MUTATIONS_LAYER))
		addtimer(CALLBACK(src, .proc/FairyEnd, user), heal_duration)
	return

/mob/living/simple_animal/hostile/abnormality/fairy_festival/neutral_effect(mob/living/carbon/human/user, work_type, pe)
	success_effect(user, work_type, pe)
	return

/mob/living/simple_animal/hostile/abnormality/fairy_festival/Life()
	. = ..()
	if(protected_people.len)
		FairyHeal()

/mob/living/simple_animal/hostile/abnormality/fairy_festival/proc/FairyEnd(mob/living/carbon/human/user)
	protected_people.Remove(user)
	user.cut_overlay(mutable_appearance('ModularTegustation/Teguicons/tegu_effects.dmi', "fairy_heal", -MUTATIONS_LAYER))
	to_chat(user, "<span class='notice'>The fairies giggle before returning to their queen.</span>")
	UnregisterSignal(user, COMSIG_WORK_STARTED)
	return

/mob/living/simple_animal/hostile/abnormality/fairy_festival/proc/FairyGib(datum/source, datum/abnormality/datum_sent, mob/living/carbon/human/user, work_type)
	SIGNAL_HANDLER
	if(((user in protected_people) && datum_sent != datum_reference) && !(GODMODE in user.status_flags))
		to_chat(user, "<span class='userdanger'>With a beat of their wings, the fairies pounce on you and ravenously consume your body!</span>")
		playsound(get_turf(user), 'sound/magic/demon_consume.ogg', 75, 0)
		UnregisterSignal(user, COMSIG_WORK_STARTED)
		protected_people.Remove(user)
		user.gib()
	return

/mob/living/simple_animal/hostile/abnormality/fairy_festival/breach_effect(mob/living/carbon/human/user)
	var/mob/living/simple_animal/hostile/ordeal/pink_midnight/pink = null
	for(var/mob/living/simple_animal/hostile/ordeal/pink_midnight/target in GLOB.mob_living_list)
		pink = target
		break
	for(var/i = 1 to 6)
		if(!isnull(pink))
			var/turf/target_turf = get_turf(pink)
			var/mob/living/simple_animal/hostile/mini_fairy/new_fairy = new /mob/living/simple_animal/hostile/mini_fairy(target_turf)
			new_fairy.faction += "pink_midnight"
		else
			new /mob/living/simple_animal/hostile/mini_fairy(get_turf(src))
	return

/mob/living/simple_animal/hostile/mini_fairy
	name = "\improper Lost Fairy"
	desc = "They wander in search of food."
	icon = 'ModularTegustation/Teguicons/tegumobs.dmi'
	icon_state = "fairy_bastard"
	icon_living = "fairy_bastard"
	maxHealth = 83
	health = 83
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	is_flying_animal = TRUE
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 1.2, WHITE_DAMAGE = 1.2, BLACK_DAMAGE = 1.2, PALE_DAMAGE = 1.2)
	faction = list("hostile", "fairy")
	melee_damage_lower = 1
	melee_damage_upper = 5
	melee_damage_type = RED_DAMAGE
	rapid_melee = 3
	attack_sound = 'sound/abnormalities/mountain/bite.ogg'
	density = FALSE
	move_to_delay = 2
	del_on_death = TRUE
	stat_attack = DEAD

/mob/living/simple_animal/hostile/mini_fairy/Initialize()
	. = ..()
	AddComponent(/datum/component/swarming)
	summon_backup()

/mob/living/simple_animal/hostile/mini_fairy/AttackingTarget()
	. = ..()
	var/friends = 0
	for(var/mob/living/simple_animal/hostile/mini_fairy/fren in view(6, src))
		friends++
	if(friends < 3)
		summon_backup()
	if(ishuman(target))
		var/mob/living/L = target
		if(L.health < 0 || L.stat == DEAD)
			var/mob/living/simple_animal/hostile/mini_fairy/MF = new(get_turf(L))
			MF.faction = src.faction
			playsound(get_turf(src), 'sound/magic/demon_consume.ogg', 75, 0)
			L.spawn_gibs()
			QDEL_NULL(L)
			summon_backup()

/mob/living/simple_animal/hostile/mini_fairy/summon_backup(distance = 6)
	for(var/mob/living/simple_animal/hostile/M in oview(distance, targets_from))
		if(faction_check_mob(M, TRUE))
			if(M.AIStatus == AI_OFF)
				return
			else
				M.Goto(src,M.move_to_delay,M.minimum_distance)

