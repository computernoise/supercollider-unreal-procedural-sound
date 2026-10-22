//luissanz.ch
//important evaluate this buffer for a single sample feedback possibility
//free buffers if you have buffers evaluated: Buffer.freeAll;
//Buffer.freeAll;
b = Buffer.alloc(s, 1);
//thanks to Joonas Siren [forces] / ffforces.bandcamp.com


(
SynthDef(\fm,{ arg amp=0.8,freq=20,splay=0.4, index2, index3, index4, index5, index6=10, ratio1=1,ratio2=2,ratio3=3,ratio4=3,ratio5=6,ratio6=2,env1att=0.007,env1rel=3, env2att=0.007,env2rel=3, env3att=0.007,env3rel=3;
	var osc1, osc2, osc3,osc4,osc5,osc6, env1, env2,env3,env4,env5,env6,env7,env8,env9,sound, osc2fb;
	//modulation envelope
	env2=EnvGen.ar(Env.perc(env2att,env2rel),doneAction:0);


	//osc block 1
	osc2fb = Dbufrd(b); // read from buffer
	osc2fb = SinOsc.ar(freq + (ratio2*freq * env2* Duty.ar(SampleDur.ir,0,osc2fb) ), mul:freq*ratio2*env2*index2);
	osc2 = Dbufwr(osc2fb, b); // write to buffer
	osc2 = Duty.ar(SampleDur.ir, 0, osc2);
	osc1=LeakDC.ar(SinOsc.ar((ratio1*freq)+osc2,mul:0.5));

	//osc block 2

	osc3=SinOsc.ar(freq*ratio3*env2,mul:freq*ratio3*env2*index3);
	osc4=SinOsc.ar(((freq*ratio4*env2)+osc3),mul:freq*ratio4*env2*index4);
	osc5=SinOsc.ar(((freq*ratio5*env2)+osc4),mul:freq*ratio5*env2*index5);
	osc6=LeakDC.ar(SinOsc.ar((freq*ratio6)+osc5,mul:0.5));


	//envelopes
	env1=EnvGen.ar(Env.perc(env1att,env1rel),doneAction:2);
	env3=EnvGen.ar(Env.perc(env3att,env3rel),doneAction:2);

	//free the synth
	FreeSelf.kr(Done.kr(env1) * Done.kr(env3));


	sound=Limiter.ar(((osc1*env1)+(osc6*env3))*amp);

	sound=Splay.ar(sound,splay,1,0.0);
	Out.ar(0, sound);
}
).add;
)

// Map active OSC cell slot 0 coordinates (-10..10) to synth controls.
(
~fmOscSlot = 0; // change slot
~fmOscControls = (
	splay: 0.0,
	ratio1: 0.0, ratio2: 9.0, ratio3: 0.0,
	ratio4: 0.0, ratio5: 0.0, ratio6: 9.0,
	index2: 9.0, index3: 9.0, index4: 0.0, index5: 9.0,
	env1att: 8.0, env1rel: 20.0,
	env2att: 10.007, env2rel: 10.007,
	env3att: 8.0, env3rel: 20.0
);

~fmMapOscCoordinate = { |value, outMin, outMax|
	value.clip(-10.0, 10.0).linlin(-10.0, 10.0, outMin, outMax)
};

OSCdef(\fmSynthCellMap, { |msg|
	var slot, active, x, y, z;

	if(msg.size >= 8) {
		slot = msg[1].asInteger;
		active = msg[2].asInteger;

		if((slot == ~fmOscSlot) and: { active != 0 }) {
			x = msg[5].asFloat;
			y = msg[6].asFloat;
			z = msg[7].asFloat;

			~fmOscControls = (
				splay: ~fmMapOscCoordinate.(x, 0.0, 0.9),
				ratio1: ~fmMapOscCoordinate.(x, 0.1, 9.0),
				ratio2: ~fmMapOscCoordinate.(x, 0.0, 0.1),
				ratio3: ~fmMapOscCoordinate.(x, 0.0, 1.0),
				ratio4: ~fmMapOscCoordinate.(x, 0.1, 9.0),
				ratio5: ~fmMapOscCoordinate.(x, 0.1, 9.0),
				ratio6: ~fmMapOscCoordinate.(x, 0.1, 9.0),
				index2: ~fmMapOscCoordinate.(y, 0.0, 9.0),
				index3: ~fmMapOscCoordinate.(y, 0.0, 9.0),
				index4: ~fmMapOscCoordinate.(y, 0.0, 9.0),
				index5: ~fmMapOscCoordinate.(y, 0.0, 9.0),
				env1att: ~fmMapOscCoordinate.(z, 0.007, 8.0),
				env1rel: ~fmMapOscCoordinate.(z, 0.1, 20.0),
				env2att: ~fmMapOscCoordinate.(z, 5.0, 10.0),
				env2rel: ~fmMapOscCoordinate.(z, 5.0, 10.0),
				env3att: ~fmMapOscCoordinate.(z, 0.007, 8.0),
				env3rel: ~fmMapOscCoordinate.(z, 0.1, 20.0)
			);
		};
	};
}, '/game/cell', recvPort: 57128);
)

// pattern
(
Pbindef(\a,
    \instrument, \fm,

        // Rhythm
        \dur, 4, // * PSVsymdif_i([3, 5, 6, 7, 9, 10, 11, 12, 14, 15]),

        // Pitch
        \scale, Scale.minor,
        \octave, 4,
        \degree, Pseq([
            [0, 2, 5, 9],
            [2, 5, 9, 12],
            [4, 7, 11, 14],
            [5, 9, 12, 16]
        ], inf).collect { |chord|
            chord.collect { |degree|
                degree + (0.1 * (0.5.rand - 0.5))
            }
        },

        // Stereo
		\splay, Pfunc { ~fmOscControls[\splay] },

        // Operator ratios
        \ratio1, 9, //Pfunc { ~fmOscControls[\ratio1] },
        \ratio2, 0, //Pfunc { ~fmOscControls[\ratio2] },
        \ratio3, 9, //Pfunc { ~fmOscControls[\ratio3] },
        \ratio4, Pfunc { ~fmOscControls[\ratio4] },
        \ratio5, Pfunc { ~fmOscControls[\ratio5] },
        \ratio6, Pfunc { ~fmOscControls[\ratio6] },

        // Amplitude envelopes
        \env1att, 0, //5.004, // Pfunc { ~fmOscControls[\env1att] },
        \env1rel, 20, //20, // Pfunc { ~fmOscControls[\env1rel] },
        \env3att, Pfunc { ~fmOscControls[\env3att] },
        \env3rel, Pfunc { ~fmOscControls[\env3rel] },

        // Modulation envelope
        \env2att, 10.007, //Pfunc { ~fmOscControls[\env2att] },
        \env2rel, 10.007, //Pfunc { ~fmOscControls[\env2rel] },

        // FM indices
        \index2, Pfunc { ~fmOscControls[\index2] },
        \index3, Pfunc { ~fmOscControls[\index3] },
        \index4, Pfunc { ~fmOscControls[\index4] },
        \index5, Pfunc { ~fmOscControls[\index5] },

        // Output level
        \amp, 0.025
).play;
)

Pbindef(\a).stop;


