var node = document.getElementById('main');
var geoAllowed = 'geolocation' in window.navigator;
var deviceOrientationSupported = 'DeviceOrientationEvent' in window;
var app = Elm.Main.embed(node, {
  geolocation: geoAllowed,
  deviceOrientation: deviceOrientationSupported
});

app.ports.requestGeolocation.subscribe(function() {
  console.log('Received request for geolocation!');
  if (!geoAllowed) return;

  window.navigator.geolocation.getCurrentPosition(function(position) {
    console.log('Sending data for geolocation!', position);
    app.ports.receiveGeolocation.send({
        latitude: position.coords.latitude || 0,
        longitude: position.coords.longitude || 0
    });
  });
});

if (deviceOrientationSupported) {
    function handleDeviceOrientation(event) {
        console.log('Sending data for device orientation');
        app.ports.receiveDeviceOrientation.send({
            alpha: event.alpha || 0,
            beta: event.beta || 0,
            gamma: event.gamma || 0
        });
    }
    window.addEventListener('deviceorientation', handleDeviceOrientation);
}
