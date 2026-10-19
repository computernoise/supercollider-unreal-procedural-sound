////////////////////// \system
(
s = Server.local;
ServerOptions.devices;
// s.options.outDevice_("Babyface Pro (72994168)");
// s.options.outDevice_("MOTU UltraLite mk3 Hybrid");
s.options.numOutputBusChannels_(12);
// s.options.inDevice_("Babyface Pro (72994168)");
// s.options.inDevice_("MOTU UltraLite mk3 Hybrid");
s.options.numInputBusChannels_(4);
s.options.sampleRate_(48000);
s.options.blockSize = 64;
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 128;
s.scope;
s.meter;
s.freeAll;
s.waitForBoot({
})
)