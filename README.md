# SuperCollider, Unreal Engine & Procedural Sound Synthesis
Real-time sound synthesis and procedural audio using SuperCollider and Unreal Engine, connected via OSC for interactive sound control and communication.

The FM synth listens on UDP port `57128` for `/game/cell` messages in the format
`slot, active, cellId, tag, x, y, z`. Active slot 0 maps `x` (-10 to 10) to
stereo spread and operator ratios, `y` to FM indices, and `z` to envelope
times. Values outside the coordinate range are clamped; inactive cells and
other slots are ignored. Evaluate `supercollider/fmSynth.scd` to start the synth
and its OSC mapping.
