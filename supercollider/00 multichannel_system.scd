////////////////////// \system
(
s = Server.local;
ServerOptions.devices;
s.options.outDevice_("Babyface Pro (72994168)");
s.options.numOutputBusChannels_(12);
 s.options.inDevice_("Babyface Pro (72994168)");
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