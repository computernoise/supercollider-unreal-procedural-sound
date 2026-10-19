(
// unreal OSC — 64 slot monitor

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

// gui

~cellWindow = Window(
	"UNREAL / OSC SLOT MONITOR",
	Rect(100, 100, 460, 360)
).front;

~cellWindow.view.background = Color.black;

~cellSlot = 0;

// slot selector
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

// data display

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

// gui refresh

~refreshCellGUI = {

	var d = ~cellData[~cellSlot];

	~cellDisplay[0].string = d.active.asString;
	~cellDisplay[1].string = d.cellId.asString;
	~cellDisplay[2].string = d.tag.asString;
	~cellDisplay[3].string = d.x.round(0.001).asString;
	~cellDisplay[4].string = d.y.round(0.001).asString;
	~cellDisplay[5].string = d.z.round(0.001).asString;
};

// OSC receiver

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

			// store latest values
			~cellData[id] = data;

			// refresh GUI only if this slot is selected
			if(id == ~cellSlot) {

				{
					~refreshCellGUI.();
				}.defer;
			};
		};
	};

}, '/game/cell', recvPort: 57128);

// initial display

~refreshCellGUI.();

)