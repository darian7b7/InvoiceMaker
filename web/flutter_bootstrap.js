{{flutter_js}}
{{flutter_build_config}}

// Render the app inside #app (see index.html) instead of the whole page,
// so the browser centers it with CSS. Flutter's own full-page sizing is off
// by a few pixels in Firefox at fractional display scaling.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      hostElement: document.querySelector('#app'),
    });
    await appRunner.runApp();
  },
});
