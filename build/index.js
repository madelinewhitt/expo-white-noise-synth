import ToneGeneratorModule from "./ToneGeneratorModule";
export const getIsPlaying = () => ToneGeneratorModule.getIsPlaying();
export const play = async (frequency, amplitudes, adsr) => ToneGeneratorModule.play(frequency, amplitudes, adsr);
export const setFrequency = async (frequency, amplitudes, adsr) => ToneGeneratorModule.setFrequency(frequency, amplitudes, adsr);
export const stop = async () => ToneGeneratorModule.stop();
//# sourceMappingURL=index.js.map