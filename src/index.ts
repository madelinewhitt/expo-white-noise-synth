import ToneGeneratorModule from "./ToneGeneratorModule";

export const getIsPlaying = () => ToneGeneratorModule.getIsPlaying();

export const play = async (
	frequency: number,
	amplitudes: number[],
	adsr: number[],
) => ToneGeneratorModule.play(frequency, amplitudes, adsr);

export const setFrequency = async (
	frequency: number,
	amplitudes: number[],
	adsr: number[],
) => ToneGeneratorModule.setFrequency(frequency, amplitudes, adsr);

export const stop = async () => ToneGeneratorModule.stop();
