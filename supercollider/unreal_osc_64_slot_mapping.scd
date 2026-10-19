(
// --------------------------------------------------
// UNREAL OSC — 64 SLOT MAPPING SYSTEM
// --------------------------------------------------

~cellData = Array.fill(64, {
	(
		active: 0,
		cellId: -1,
		tag: "",
		x: 0.0,
		y: 0.0,
		z: 0.0
	)
});

~cellMaps = Array.fill(64, nil);
~cellMapEnabled = Array.fill(64, false);

// --------------------------------------------------
// GUI
// --------------------------------------------------

~cellWindow = Window(
	"UNREAL / OSC SLOT MAPPER",
	Rect(100, 100, 460, 390)
).front;

~cellWindow.view.background = Color.black;

~cellSlot = 0;

// Slot selector
~slotMenu = PopUpMenu(
	~cellWindow,
	Rect(20, 20, 200, 30)
);

~slotMenu.items = Array.fill(64, { |i|
	"Slot %".format(i)
});

~slotMenu.action = { |menu|
	~cellSlot = menu.value;
	~refreshCellGUI.();
};

// Mapping enable checkbox
~mapEnable = Button(
	~cellWindow,
	Rect(250, 20, 180, 30)
);

~mapEnable.states = [
	["MAPPING OFF", Color.white, Color.gray(0.2)],
	["MAPPING ON", Color.black, Color.green]
];

~mapEnable.action = { |button|
	~cellMapEnabled[~cellSlot] = button.value == 1;
};

// --------------------------------------------------
// DATA DISPLAY
// --------------------------------------------------

~cellDisplay = ();

[
	["Active", 70],
	["Cell ID", 115],
	["Tag", 160],
	["X", 205],
	["Y", 250],
	["Z", 295]
].do { |item, i|

	StaticText(
		~cellWindow,
		Rect(25, item[1], 100, 30)
	)
	.string_(item[0])
	.stringColor_(Color.gray(0.7))
	.font_(Font("Monaco", 14));

	~cellDisplay[i] = StaticText(
		~cellWindow,
		Rect(140, item[1], 280, 30)
	)
	.string_("---")
	.stringColor_(Color.white)
	.font_(Font("Monaco", 14));
};

// --------------------------------------------------
// GUI REFRESH
// --------------------------------------------------

~refreshCellGUI = {

	var d = ~cellData[~cellSlot];

	~mapEnable.value = ~cellMapEnabled[~cellSlot];

	~cellDisplay[0].string = d.active.asString;
	~cellDisplay[1].string = d.cellId.asString;
	~cellDisplay[2].string = d.tag.asString;
	~cellDisplay[3].string = d.x.round(0.001).asString;
	~cellDisplay[4].string = d.y.round(0.001).asString;
	~cellDisplay[5].string = d.z.round(0.001).asString;
};

// --------------------------------------------------
// OSC RECEIVER
// --------------------------------------------------

OSCdef(\greenCell, { |msg, time, addr, recvPort|

	var id, data;

	// OSC message:
	// /game/cell, slot, active, cellId, tag, x, y, z

	if(msg.size >= 8) {

		id = msg[1].asInteger;

		if(id >= 0 and: { id < 64 }) {

			data = (
				active: msg[2].asInteger,
				cellId: msg[3].asInteger,
				tag: msg[4].asString,
				x: msg[5].asFloat,
				y: msg[6].asFloat,
				z: msg[7].asFloat
			);

			// Store latest values
			~cellData[id] = data;

			// Execute mapping for this slot
			if(~cellMapEnabled[id] == true) {
				if(~cellMaps[id].notNil) {
					~cellMaps[id].value(data, id);
				};
			};

			// Refresh GUI only if this slot is selected
			if(id == ~cellSlot) {

				{
					~refreshCellGUI.();
				}.defer;
			};
		};
	};

}, '/game/cell', recvPort: 57128);

// --------------------------------------------------
// INITIAL DISPLAY
// --------------------------------------------------

~refreshCellGUI.();

)

~cellMapEnabled = Array.fill(64, false);