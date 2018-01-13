var node = document.getElementById('main');
var geoAllowed = 'geolocation' in window.navigator;
var geoPermission = false;
var deviceOrientationSupported = 'ondeviceorientation' in window;

if (geoAllowed && 'permissions' in window.navigator) {
  window.navigator.permissions.query({name: 'geolocation'}).then(function(permission) {
    geoPermission = permission.state;

    initApp();
  });
} else {
  initApp();
}


function initApp() {
  var app = Elm.Main.embed(node, {
    geolocation: geoAllowed,
    geolocationGranted: geoPermission,
    deviceOrientation: deviceOrientationSupported
  });

  app.ports.requestGeolocation.subscribe(function() {
    if (!geoAllowed) return;

    window.navigator.geolocation.getCurrentPosition(function(position) {
      app.ports.receiveGeolocation.send({
        latitude: position.coords.latitude || 0,
        longitude: position.coords.longitude || 0,
        heading: 'heading' in position.coords ? position.coords.heading : null
      });
    });
  });

  if (deviceOrientationSupported) {
    var deviceOrientationEvent = 'ondeviceorientationabsolute' in window ?
      'deviceorientationabsolute' :
      'deviceorientation';

    function handleDeviceOrientation(event) {
      var absolute = event.absolute || false;
      var hasHeading = 'webkitCompassHeading' in event;
      var heading =
        absolute ? event.alpha :
        hasHeading ? event.webkitCompassHeading :
        0;

      app.ports.receiveDeviceOrientation.send({
        heading: heading || 0,
        absolute: absolute || hasHeading,
        alpha: event.alpha
      });
    }

    window.addEventListener(deviceOrientationEvent, handleDeviceOrientation);
  }
}
