/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'icons/obj/Cryogenic2_vr.dmi' //VOREStation Edit - New Icon
	icon_state = "cellconsole"
	circuit = /obj/item/weapon/circuitboard/cryopodcontrol
	density = 0
	interact_offline = 1
	var/mode = null

	//Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	var/list/frozen_items = list()
	var/list/_admin_logs = list() // _ so it shows first in VV

	var/storage_type = "crewmembers"
	var/storage_name = "Cryogenic Oversight Control"
	var/allow_items = 1

	req_one_access = list(access_heads) //VOREStation Add

/obj/machinery/computer/cryopod/robot
	name = "robotic storage console"
	desc = "An interface between crew and the robotic storage systems"
	icon = 'icons/obj/robot_storage.dmi'
	icon_state = "console"
	circuit = /obj/item/weapon/circuitboard/robotstoragecontrol

	storage_type = "cyborgs"
	storage_name = "Robotic Storage Control"
	allow_items = 0

/obj/machinery/computer/cryopod/dorms
	name = "residential oversight console"
	desc = "An interface between visitors and the residential oversight systems tasked with keeping track of all visitors in the deeper section of the colony."
	icon = 'icons/obj/robot_storage.dmi' //placeholder
	icon_state = "console" //placeholder
	circuit = "/obj/item/weapon/circuitboard/robotstoragecontrol"

	storage_type = "visitors"
	storage_name = "Residential Oversight Control"
	allow_items = 1

/obj/machinery/computer/cryopod/travel
	name = "docking oversight console"
	desc = "An interface between visitors and the docking oversight systems tasked with keeping track of all visitors who enter or exit from the docks."
	icon = 'icons/obj/robot_storage.dmi' //placeholder
	icon_state = "console" //placeholder
	circuit = "/obj/item/weapon/circuitboard/robotstoragecontrol"

	storage_type = "visitors"
	storage_name = "Travel Oversight Control"
	allow_items = 1

/obj/machinery/computer/cryopod/gateway
	name = "gateway oversight console"
	desc = "An interface between visitors and the gateway oversight systems tasked with keeping track of all visitors who enter or exit from the gateway."
	icon = 'icons/obj/robot_storage.dmi' //placeholder
	icon_state = "console" //placeholder
	circuit = "/obj/item/weapon/circuitboard/robotstoragecontrol"

	storage_type = "visitors"
	storage_name = "Travel Oversight Control"
	allow_items = 1

/obj/machinery/computer/cryopod/attack_ai()
	attack_hand()

/obj/machinery/computer/cryopod/attack_hand(mob/user = usr)
	if(stat & (NOPOWER|BROKEN))
		return

	user.set_machine(src)
	add_fingerprint(usr)

	var/dat

	if(!(ticker))
		return

	dat += "<hr/><br/><b>[storage_name]</b><br/>"
	dat += "<i>Welcome, [user.real_name].</i><br/><br/><hr/>"
	dat += "<a href='?src=\ref[src];log=1'>View storage log</a>.<br>"
	if(allow_items)
		dat += "<a href='?src=\ref[src];view=1'>View objects</a>.<br>"
		dat += "<a href='?src=\ref[src];item=1'>Recover object</a>.<br>"
		dat += "<a href='?src=\ref[src];allitems=1'>Recover all objects</a>.<br>"

	user << browse(dat, "window=cryopod_console")
	onclose(user, "cryopod_console")

/obj/machinery/computer/cryopod/Topic(href, href_list)

	if(..())
		return

	var/mob/user = usr

	add_fingerprint(user)

	if(href_list["log"])

		var/dat = "<b>Recently stored [storage_type]</b><br/><hr/><br/>"
		for(var/person in frozen_crew)
			dat += "[person]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryolog")

	if(href_list["view"])
		if(!allow_items) return

		var/dat = "<b>Recently stored objects</b><br/><hr/><br/>"
		for(var/obj/item/I in frozen_items)
			dat += "[I.name]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryoitems")

	else if(href_list["item"])
		if(!allow_items) return

		if(frozen_items.len == 0)
			user << "<span class='notice'>There is nothing to recover from storage.</span>"
			return

		var/obj/item/I = input(usr, "Please choose which object to retrieve.","Object recovery",null) as null|anything in frozen_items
		if(!I)
			return

		if(!(I in frozen_items))
			user << "<span class='notice'>\The [I] is no longer in storage.</span>"
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges \the [I].</span>", 3)

		I.forceMove(get_turf(src))
		frozen_items -= I

	else if(href_list["allitems"])
		if(!allow_items) return

		if(frozen_items.len == 0)
			user << "<span class='notice'>There is nothing to recover from storage.</span>"
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges the desired objects.</span>", 3)

		for(var/obj/item/I in frozen_items)
			I.forceMove(get_turf(src))
			frozen_items -= I

	updateUsrDialog()
	return

/obj/item/weapon/circuitboard/cryopodcontrol
	name = "Circuit board (Cryogenic Oversight Console)"
	build_path = "/obj/machinery/computer/cryopod"
	origin_tech = list(TECH_DATA = 3)

/obj/item/weapon/circuitboard/robotstoragecontrol
	name = "Circuit board (Robotic Storage Console)"
	build_path = "/obj/machinery/computer/cryopod/robot"
	origin_tech = list(TECH_DATA = 3)

/obj/item/weapon/circuitboard/dormscontrol
	name = "Circuit board (Residential Oversight Console)"
	build_path = "/obj/machinery/computer/cryopod/door/dorms"
	origin_tech = list(TECH_DATA = 3)

/obj/item/weapon/circuitboard/travelcontrol
	name = "Circuit board (Travel Oversight Console - Docks)"
	build_path = "/obj/machinery/computer/cryopod/door/travel"
	origin_tech = list(TECH_DATA = 3)

/obj/item/weapon/circuitboard/gatewaycontrol
	name = "Circuit board (Travel Oversight Console - Gateway)"
	build_path = "/obj/machinery/computer/cryopod/door/gateway"
	origin_tech = list(TECH_DATA = 3)

//Decorative structures to go alongside cryopods.
/obj/structure/cryofeed

	name = "cryogenic feed"
	desc = "A bewildering tangle of machinery and pipes."
	icon = 'icons/obj/Cryogenic2_vr.dmi' //VOREStation Edit - New Icon
	icon_state = "cryo_rear"
	anchored = 1
	dir = WEST

//Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "A man-sized pod for entering suspended animation."
	icon = 'icons/obj/Cryogenic2_vr.dmi' //VOREStation Edit - New Icon
	icon_state = "cryopod_0" //VOREStation Edit - New Icon
	density = 1
	anchored = 1
	dir = WEST

	var/base_icon_state = "cryopod_0" //VOREStation Edit - New Icon
	var/occupied_icon_state = "cryopod_1" //VOREStation Edit - New Icon
	var/on_store_message = "has entered long-term storage."
	var/on_store_name = "Cryogenic Oversight"
	var/on_enter_visible_message = "starts climbing into the"
	var/on_enter_occupant_message = "You feel cool air surround you. You go numb as your senses turn inward."
	var/on_store_visible_message_1 = "hums and hisses as it moves" //We need two variables because byond doesn't let us have variables inside strings at compile-time.
	var/on_store_visible_message_2 = "into storage."
	var/allow_occupant_types = list(/mob/living/carbon/human)
	var/disallow_occupant_types = list()

	var/mob/occupant = null       // Person waiting to be despawned.
	var/time_till_despawn = 599  // Down to 1 minute to reflect Vorestation respawn times.
	var/time_entered = 0          // Used to keep track of the safe period.
	var/obj/item/device/radio/intercom/announce //

	var/obj/machinery/computer/cryopod/control_computer
	var/last_no_computer_message = 0
	var/applies_stasis = 1

	// These items are preserved when the process() despawn proc occurs.
	var/list/preserve_items = list(
		/obj/item/weapon/hand_tele,
		/obj/item/weapon/card/id/captains_spare,
		/obj/item/device/aicard,
		/obj/item/device/paicard,
		/obj/item/weapon/gun,
		/obj/item/weapon/cell/device,
		/obj/item/ammo_magazine,
		/obj/item/ammo_casing,
		/obj/item/weapon/pinpointer,
		/obj/item/clothing/suit,
		/obj/item/clothing/shoes/magboots,
		/obj/item/blueprints,
		/obj/item/clothing/head/helmet/space,
		/obj/item/weapon/storage/internal
	)

/obj/machinery/cryopod/robot
	name = "robotic storage unit"
	desc = "A storage unit for robots."
	icon = 'icons/obj/robot_storage.dmi'
	icon_state = "pod_0"
	base_icon_state = "pod_0"
	occupied_icon_state = "pod_1"
	on_store_message = "has entered robotic storage."
	on_store_name = "Robotic Storage Oversight"
	on_enter_occupant_message = "The storage unit broadcasts a sleep signal to you. Your systems start to shut down, and you enter low-power mode."
	allow_occupant_types = list(/mob/living/silicon/robot)
	disallow_occupant_types = list(/mob/living/silicon/robot/drone)
	applies_stasis = 0

/obj/machinery/cryopod/robot/door
	//This inherits from the robot cryo, so synths can be properly cryo'd.  If a non-synth enters and is cryo'd, ..() is called and it'll still work.
	name = "Airlock of Wonders"
	desc = "An airlock that isn't an airlock, and shouldn't exist.  Yell at a coder/mapper."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door_open"
	base_icon_state = "door_open"
	occupied_icon_state = "door_closed"
	on_enter_visible_message = "steps into the"

	time_till_despawn = 600 //1 minute. We want to be much faster then normal cryo, since waiting in an elevator for half an hour is a special kind of hell.

	allow_occupant_types = list(/mob/living/silicon/robot,/mob/living/carbon/human)
	disallow_occupant_types = list(/mob/living/silicon/robot/drone)

/obj/machinery/cryopod/robot/door/dorms
	name = "Residential District Elevator"
	desc = "A small elevator that goes down to the deeper section of the colony."
	on_store_message = "has departed for the residential district."
	on_store_name = "Residential Oversight"
	on_enter_occupant_message = "The elevator door closes slowly, ready to bring you down to the residential district."
	on_store_visible_message_1 = "makes a ding as it moves"
	on_store_visible_message_2 = "to the residential district."

/obj/machinery/cryopod/robot/door/travel
	name = "Passenger Elevator"
	desc = "A small elevator that goes down to the passenger section of the vessel."
	on_store_message = "is slated to depart from the colony."
	on_store_name = "Travel Oversight"
	on_enter_occupant_message = "The elevator door closes slowly, ready to bring you down to the hell that is economy class travel."
	on_store_visible_message_1 = "makes a ding as it moves"
	on_store_visible_message_2 = "to the passenger deck."

/obj/machinery/cryopod/robot/door/gateway
	name = "Gateway"
	desc = "The gateway you might've came in from.  You could leave the colony easily using this."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "offcenter"
	base_icon_state = "offcenter"
	occupied_icon_state = "oncenter"
	on_store_message = "has departed from the colony."
	on_store_name = "Travel Oversight"
	on_enter_occupant_message = "The gateway activates, and you step into the swirling portal."
	on_store_visible_message_1 = "'s portal disappears just after"
	on_store_visible_message_2 = "finishes walking across it."

	time_till_despawn = 60 //1 second, because gateway.

/obj/machinery/cryopod/New()
	announce = new /obj/item/device/radio/intercom(src)
	..()

/obj/machinery/cryopod/Destroy()
	if(occupant)
		occupant.forceMove(loc)
		occupant.resting = 1
	return ..()

/obj/machinery/cryopod/initialize()
	..()

	find_control_computer()

/obj/machinery/cryopod/proc/find_control_computer(urgent=0)
	//control_computer = locate(/obj/machinery/computer/cryopod) in src.loc.loc // Broken due to http://www.byond.com/forum/?post=2007448
	control_computer = locate(/obj/machinery/computer/cryopod) in range(6,src)

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer && urgent && last_no_computer_message + 5*60*10 < world.time)
		log_admin("Cryopod in [src.loc.loc] could not find control computer!")
		message_admins("Cryopod in [src.loc.loc] could not find control computer!")
		last_no_computer_message = world.time

	return control_computer != null

/obj/machinery/cryopod/proc/check_occupant_allowed(mob/M)
	var/correct_type = 0
	for(var/type in allow_occupant_types)
		if(istype(M, type))
			correct_type = 1
			break

	if(!correct_type) return 0

	for(var/type in disallow_occupant_types)
		if(istype(M, type))
			return 0

	return 1

//Lifted from Unity stasis.dm and refactored. ~Zuhayr
/obj/machinery/cryopod/process()
	if(occupant)
		//Allow a ten minute gap between entering the pod and actually despawning.
		if(world.time - time_entered < time_till_despawn)
			return

		if(!occupant.client && occupant.stat<2) //Occupant is living and has no client.
			if(!control_computer)
				if(!find_control_computer(urgent=1))
					return

			despawn_occupant(occupant)

// This function can not be undone; do not call this unless you are sure
// Also make sure there is a valid control computer
/obj/machinery/cryopod/robot/despawn_occupant()
	var/mob/living/silicon/robot/R = occupant
	if(!istype(R)) return ..()

	qdel(R.mmi)
	for(var/obj/item/I in R.module) // the tools the borg has; metal, glass, guns etc
		for(var/obj/item/O in I) // the things inside the tools, if anything; mainly for janiborg trash bags
			O.forceMove(R)
		qdel(I)
	qdel(R.module)

	return ..()

/obj/machinery/cryopod/robot/door/gateway/despawn_occupant()
	for(var/obj/machinery/gateway/G in range(1,src))
		G.icon_state = "off"
	..()

// This function can not be undone; do not call this unless you are sure
// Also make sure there is a valid control computer
/obj/machinery/cryopod/proc/despawn_occupant(var/mob/to_despawn)
	//Recursively despawn mobs
	for(var/mob/M in to_despawn)
		despawn_occupant(M)

	// VOREStation
	hook_vr("despawn", list(to_despawn, src))
	// VOREStation

	//Drop all items into the pod.
	for(var/obj/item/W in to_despawn)
		to_despawn.drop_from_inventory(W)
		W.forceMove(src)

		if(W.contents.len) //Make sure we catch anything not handled by qdel() on the items.
			for(var/obj/item/O in W.contents)
				if(istype(O,/obj/item/weapon/storage/internal)) //Stop eating pockets, you fuck!
					continue
				O.forceMove(src)

	//Delete all items not on the preservation list.
	var/list/items = contents.Copy()
	items -= to_despawn // Don't delete the occupant
	items -= announce // or the autosay radio.

	for(var/obj/item/W in items)

		var/preserve = null

		for(var/T in preserve_items)
			if(istype(W,T))
				preserve = 1
				break

		if(istype(W,/obj/item/weapon/implant/health))
			for(var/obj/machinery/computer/cloning/com in world)
				for(var/datum/dna2/record/R in com.records)
					if(locate(R.implant) == W)
						qdel(R)
						qdel(W)

		if(!preserve)
			qdel(W)
		else
			if(control_computer && control_computer.allow_items)
				control_computer.frozen_items += W
				W.loc = control_computer //VOREStation Edit
			else
				W.forceMove(src.loc)

	//Update any existing objectives involving this mob.
	for(var/datum/objective/O in all_objectives)
		// We don't want revs to get objectives that aren't for heads of staff. Letting
		// them win or lose based on cryo is silly so we remove the objective.
		if(O.target == to_despawn.mind)
			if(O.owner && O.owner.current)
				O.owner.current << "<span class='warning'>You get the feeling your target is no longer within your reach...</span>"
			qdel(O)

	//VOREStation Edit - Resleeving.
	if(to_despawn.mind)
		if(to_despawn.mind.name in SStranscore.backed_up)
			var/datum/transhuman/mind_record/MR = SStranscore.backed_up[to_despawn.mind.name]
			SStranscore.stop_backup(MR)
		if(to_despawn.mind.name in SStranscore.body_scans) //This uses mind names to avoid people cryo'ing a printed body to delete body scans.
			var/datum/transhuman/body_record/BR = SStranscore.body_scans[to_despawn.mind.name]
			SStranscore.remove_body(BR)
	//VOREStation Edit End - Resleeving.

	//Handle job slot/tater cleanup.
	var/job = to_despawn.mind.assigned_role

	job_master.FreeRole(job)

	if(to_despawn.mind.objectives.len)
		qdel(to_despawn.mind.objectives)
		to_despawn.mind.special_role = null

	//else
		//if(ticker.mode.name == "AutoTraitor")
			//var/datum/game_mode/traitor/autotraitor/current_mode = ticker.mode
			//current_mode.possible_traitors.Remove(to_despawn)

	// Delete them from datacore.

	if(PDA_Manifest.len)
		PDA_Manifest.Cut()
	for(var/datum/data/record/R in data_core.medical)
		if((R.fields["name"] == to_despawn.real_name))
			qdel(R)
	for(var/datum/data/record/T in data_core.security)
		if((T.fields["name"] == to_despawn.real_name))
			qdel(T)
	for(var/datum/data/record/G in data_core.general)
		if((G.fields["name"] == to_despawn.real_name))
			qdel(G)

	icon_state = base_icon_state

	//TODO: Check objectives/mode, update new targets if this mob is the target, spawn new antags?


	//Make an announcement and log the person entering storage.
	control_computer.frozen_crew += "[to_despawn.real_name], [to_despawn.mind.role_alt_title] - [stationtime2text()]"
	control_computer._admin_logs += "[key_name(to_despawn)] ([to_despawn.mind.role_alt_title]) at [stationtime2text()]"
	log_and_message_admins("[key_name(to_despawn)] ([to_despawn.mind.role_alt_title]) entered cryostorage.")

	announce.autosay("[to_despawn.real_name], [to_despawn.mind.role_alt_title], [on_store_message]", "[on_store_name]")
	//visible_message("<span class='notice'>\The [initial(name)] hums and hisses as it moves [to_despawn.real_name] into storage.</span>", 3)
	visible_message("<span class='notice'>\The [initial(name)] [on_store_visible_message_1] [to_despawn.real_name] [on_store_visible_message_2].</span>", 3)

	//This should guarantee that ghosts don't spawn.
	to_despawn.ckey = null

	// Delete the mob.
	qdel(to_despawn)
	set_occupant(null)

/obj/machinery/cryopod/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)

	if(istype(G, /obj/item/weapon/grab))

		var/obj/item/weapon/grab/grab = G
		if(occupant)
			user << "<span class='notice'>\The [src] is in use.</span>"
			return

		if(!ismob(grab.affecting))
			return
		else
			go_in(grab.affecting,user)



/obj/machinery/cryopod/verb/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return

	icon_state = base_icon_state

	//Eject any items that aren't meant to be in the pod.
	var/list/items = contents
	if(occupant) items -= occupant
	if(announce) items -= announce

	for(var/obj/item/W in items)
		W.forceMove(get_turf(src))

	go_out()
	add_fingerprint(usr)

	name = initial(name)
	return

/obj/machinery/cryopod/verb/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0 || !check_occupant_allowed(usr))
		return

	if(occupant)
		usr << "<span class='notice'><B>\The [src] is in use.</B></span>"
		return

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "You're too busy getting your life sucked out of you."
			return

	visible_message("[usr] [on_enter_visible_message] [src].", 3)

	if(do_after(usr, 20))

		if(!usr || !usr.client)
			return

		if(occupant)
			usr << "<span class='notice'><B>\The [src] is in use.</B></span>"
			return

		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.forceMove(src)
		set_occupant(usr)
		if(ishuman(usr) && applies_stasis)
			var/mob/living/carbon/human/H = occupant
			H.Stasis(1000)

		icon_state = occupied_icon_state

		usr << "<span class='notice'>[on_enter_occupant_message]</span>"
		usr << "<span class='notice'><b>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</b></span>"

		time_entered = world.time

		add_fingerprint(usr)

	return

/obj/machinery/cryopod/robot/door/gateway/move_inside()
	..()
	//locate(/obj/machinery/computer/cryopod) in range(6,src)
	for(var/obj/machinery/gateway/G in range(1,src))
		G.icon_state = "on"

/obj/machinery/cryopod/robot/door/gateway/go_out()
	..()
	for(var/obj/machinery/gateway/G in range(1,src))
		G.icon_state = "off"

/obj/machinery/cryopod/proc/go_out()

	if(!occupant)
		return

	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE

	occupant.forceMove(get_turf(src))
	if(ishuman(occupant) && applies_stasis)
		var/mob/living/carbon/human/H = occupant
		H.Stasis(0)
	set_occupant(null)

	icon_state = base_icon_state

	return

/obj/machinery/cryopod/proc/set_occupant(var/new_occupant)
	occupant = new_occupant
	name = initial(name)
	if(occupant)
		name = "[name] ([occupant])"

/obj/machinery/cryopod/MouseDrop_T(var/mob/target, var/mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user))
		return
	go_in(target, user)

/obj/machinery/cryopod/proc/go_in(var/mob/M, var/mob/user)
	if(!check_occupant_allowed(M))
		return
	if(!M)
		return
	if(occupant)
		to_chat(user,"<span class='warning'>\The [src] is already occupied.</span>")
		return

	var/willing = null //We don't want to allow people to be forced into despawning.

	if(M.client)
		if(alert(M,"Would you like to enter long-term storage?",,"Yes","No") == "Yes")
			if(!M) return
			willing = 1
	else
		willing = 1

	if(willing)
		if(M == user)
			visible_message("[usr] [on_enter_visible_message] [src].", 3)
		else
			visible_message("\The [user] starts putting [M] into \the [src].", 3)

		if(do_after(user, 20))
			if(occupant)
				to_chat(user,"<span class='warning'>\The [src] is already occupied.</span>")
				return
			M.forceMove(src)

			if(M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
		else return

		icon_state = occupied_icon_state

		M << "<span class='notice'>[on_enter_occupant_message]</span>"
		M << "<span class='notice'><b>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</b></span>"
		set_occupant(M)
		time_entered = world.time
		if(ishuman(M) && applies_stasis)
			var/mob/living/carbon/human/H = M
			H.Stasis(1000)

		// Book keeping!
		var/turf/location = get_turf(src)
		log_admin("[key_name_admin(M)] has entered a stasis pod. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[location.x];Y=[location.y];Z=[location.z]'>JMP</a>)")
		message_admins("<span class='notice'>[key_name_admin(M)] has entered a stasis pod.</span>")

		//Despawning occurs when process() is called with an occupant without a client.
		add_fingerprint(M)