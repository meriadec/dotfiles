import type { Plugin } from "@opencode-ai/plugin";

const soundFile = `${process.env.HOME}/Documents/success.mp3`;

function play() {
	// Fire-and-forget so it doesn't block the UI.
	Bun.spawn(["mpv", "--no-video", "--volume=40", soundFile], {
		stdout: "ignore",
		stderr: "ignore",
	});
}

export const SuccessSound: Plugin = async () => {
	return {
		event: async ({ event }) => {
			// Plays when the assistant is done responding / session goes idle.
			if (event.type === "session.idle") play();
			// Optional: plays when OpenCode is asking *you* (permissions prompt).
			if (event.type === "permission.replied") play();
		},
	};
};
