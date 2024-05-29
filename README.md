# Expo Additive Synth

Additive synthesizer for Expo

## Installation in managed Expo projects

For [managed](https://docs.expo.dev/versions/latest/introduction/managed-vs-bare/) Expo projects, please follow the installation instructions in the [API documentation for the latest stable release](#api-documentation). If you follow the link and there is no documentation available then this library is not yet usable within managed projects &mdash; it is likely to be included in an upcoming Expo SDK release.

## Installation in bare React Native projects

For bare React Native projects, you must ensure that you have [installed and configured the `expo` package](https://docs.expo.dev/bare/installing-expo-modules/) before continuing.

## Install the package (TODO: upload to NPM Package Registry)

    $ npm install expo-additive-synth


## Configure for iOS

Run `npx pod-install` after installing the npm package.

## Additive Synthesis

Additive synthesis is a sound synthesis technique that creates complex sounds by combining simple sine waves. Each sine wave is referred to as a partial, and together these partials form a complex tone. The key aspects of additive synthesis in this context are:

1. **Frequency Control:**
   - The base frequency, or fundamental frequency, is the primary pitch of the tone.
   - This frequency can be adjusted to change the overall pitch of the synthesized sound.

2. **Amplitude Control:**
   - Each partial has its own amplitude, which determines its loudness relative to the other partials.
   - By adjusting the amplitude of each partial, you can shape the harmonic content of the sound, making it richer or more subdued.

3. **ADSR Envelope:**
   - ADSR stands for Attack, Decay, Sustain, Release.
   - This envelope shapes the amplitude of the sound over time, though its impact is minimal for a continuous tone.
   - In a continuous tone setup, the ADSR values can be set to minimal values to maintain a steady sound.

### Components in Additive Synthesis

- **Frequency Slider:** Adjusts the fundamental frequency of the tone. For example, moving the slider from 440 Hz (A4) to another value will change the pitch.
- **Amplitude Sliders:** Control the volume of each harmonic. For instance, amplitudes set to `[1.0, 0.5, 0.25]` means the first harmonic is at full volume, the second at half volume, and the third at a quarter volume.
- **Real-Time Updates:** Changes in frequency and amplitude are applied immediately, allowing for real-time sound manipulation.

## Usage

### Basic Example

```javascript
import React, { useState, useEffect } from "react";
import { StyleSheet, View, Button, Text } from "react-native";
import Slider from "@react-native-community/slider";
import { play, stop, getIsPlaying } from "expo-additive-synth";

export default function HomeScreen() {
	const [frequency, setFrequencyValue] = useState(440);
	const [isPlaying, setIsPlaying] = useState(false);
	const [amplitudes, setAmplitudes] = useState([1.0, 0.5, 0.25]);
	const [adsr] = useState([0.1, 0.1, 0.7, 0.1]); // Default ADSR values

	useEffect(() => {
		const checkIfPlaying = async () => {
			const playing = await getIsPlaying();
			setIsPlaying(playing);
		};

		checkIfPlaying();
	}, []);

	const handlePlay = async () => {
		console.log("Playing with frequency:", frequency);
		console.log("Playing with amplitudes:", amplitudes);
		await play(frequency, amplitudes, adsr);
		setIsPlaying(true);
	};

	const handleStop = async () => {
		await stop();
		setIsPlaying(false);
	};

	const handleSetFrequency = async (newFrequency) => {
		setFrequencyValue(newFrequency);
		if (isPlaying) {
			await play(newFrequency, amplitudes, adsr);
		}
	};

	const handleSetAmplitude = async (index, value) => {
		const newAmplitudes = [...amplitudes];
		newAmplitudes[index] = value;
		setAmplitudes(newAmplitudes);
		console.log("Updated amplitudes:", newAmplitudes);
		if (isPlaying) {
			await play(frequency, newAmplitudes, adsr);
		}
	};

	return (
		<View style={styles.container}>
			<Text>Frequency: {frequency} Hz</Text>
			<Slider
				style={styles.slider}
				minimumValue={20}
				maximumValue={2000}
				value={frequency}
				onValueChange={setFrequencyValue}
				onSlidingComplete={handleSetFrequency}
			/>
			<Button title="Play Tone" onPress={handlePlay} disabled={isPlaying} />
			<Button title="Stop Tone" onPress={handleStop} disabled={!isPlaying} />
			<Text>Amplitudes</Text>
			{amplitudes.map((amplitude, index) => (
				<View key={index} style={styles.sliderContainer}>
					<Text>
						Amplitude {index + 1}: {amplitude}
					</Text>
					<Slider
						style={styles.slider}
						minimumValue={0}
						maximumValue={1}
						value={amplitude}
						onValueChange={(value) => handleSetAmplitude(index, value)}
					/>
				</View>
			))}
		</View>
	);
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		justifyContent: "center",
		alignItems: "center",
	},
	sliderContainer: {
		width: "80%",
		marginTop: 20,
	},
	slider: {
		width: 200,
		height: 40,
	},
});
```

## Attribution

This code was adapted from [expo-tone-generator](https://github.com/bedrich-schindler/expo-tone-generator).
