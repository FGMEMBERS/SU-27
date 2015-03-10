
#### NAV LIGHTS ####
#nav light fade animation is done in a dirty way 
#(the material animation does not accept interpolation tables)

var lightsPath = "controls/lighting/";

setprop(lightsPath ~ "nav-lights-state", 0);
setprop(lightsPath ~ "nav-lights", 1);
var nav_lights_cycle = 2.2; #cycle time in seconds
var nav_lights_fade = 0.4; #fade in/out time
var nav_lights_stayOn = nav_lights_cycle-(2*nav_lights_fade); #stable on period

#phase to be run on next nav_lights() call 
#0 -> fade in, 1 -> stay on, 2 -> fade out
var nav_lights_phase = 0; 

#loop manipulating lightsPath ~ "nav-lights-state"
#this property is picked up by light animations
var nav_lights_timer = maketimer(0.1, 
func {
	
	if(getprop("sim/multiplay/generic/int[0]")) {
		if(nav_lights_phase == 0) {
			interpolate(lightsPath ~ "nav-lights-state", 1, 
				nav_lights_fade ); 
			nav_lights_phase = 1;
			nav_lights_timer.restart(nav_lights_fade);
		}
		else if(nav_lights_phase == 1){
			nav_lights_phase = 2;
			nav_lights_timer.restart(nav_lights_stayOn);
		}
		else if(nav_lights_phase == 2){
			interpolate(lightsPath ~ "nav-lights-state", 0, 
				nav_lights_fade ); 
			nav_lights_phase = 0;
			nav_lights_timer.restart(nav_lights_fade);
		}
	}
	else {
		#trick to eliminate previous interpolate if running (when 
		#nav light switch is toggled), sets value 0 immediatelly
		interpolate(lightsPath ~ "nav-lights-state", 0, 0 ); 
		nav_lights_phase = 0;
		nav_lights_timer.stop();
	}
}

);
nav_lights_timer.singleShot = 1;

var nav_lights = func {
	nav_lights_timer.restart(0.1);
}

setlistener(lightsPath ~ "nav-lights", nav_lights);

nav_lights(); #start the looping


### BEACON ###
aircraft.light.new(lightsPath ~ "beacon-state", 
	[0.0, 1.0], "/controls/lighting/beacon");


print("L-159 light system initialized");

