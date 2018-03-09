function initFlags(cb) {
  var flags = {
    geoAllowed: 'geolocation' in window.navigator,
    geoPermission: false,
    deviceOrientationSupported: 'ondeviceorientation' in window
  };

  // Check for permissions, if api available
  if (flags.geoAllowed && 'permissions' in window.navigator) {
    window.navigator.permissions.query({name: 'geolocation'}).then(function(permission) {
      flags.geoPermission = permission.state;

      cb(null, flags);
    });
  } else {
    cb(null, flags);
  }
}

function initApp(flags) {
  var node = document.getElementById('main');
  var app = Elm.Main.embed(node, {
    geolocation: flags.geoAllowed,
    geolocationPermission: flags.geoPermission,
    deviceOrientation: flags.deviceOrientationSupported
  });

  // Handle geolocation
  app.ports.requestGeolocation.subscribe(function() {
    if (!flags.geoAllowed) return;

    window.navigator.geolocation.watchPosition(function(position) {
      app.ports.receiveGeolocation.send({
        latitude: position.coords.latitude || 0,
        longitude: position.coords.longitude || 0,
        heading: position.coords.speed && 'heading' in position.coords ?
          position.coords.heading :
          null
      });
    });
  });

  // Handle deviceorientation
  if (flags.deviceOrientationSupported) {
    var deviceOrientationEvent = 'ondeviceorientationabsolute' in window ?
      'deviceorientationabsolute' :
      'deviceorientation';

    function handleDeviceOrientation(event) {
      var absolute = event.absolute || false;
      var hasHeading = 'webkitCompassHeading' in event;
      var heading =
        hasHeading ? 360 - event.webkitCompassHeading :
        absolute ? event.alpha :
        0;

      app.ports.receiveDeviceOrientation.send({
        heading: heading || 0,
        absolute: absolute || hasHeading,
        browserAbsolute: absolute,
        hasHeading: hasHeading,
        alpha: event.alpha || 0
      });
    }

    window.addEventListener(deviceOrientationEvent, handleDeviceOrientation);
  }

  // Handle date
  app.ports.requestDate.subscribe(function() {
    var date = new Date();

    app.ports.receiveDate.send({
      year: date.getUTCFullYear(),
      day: date.getUTCDate(),
      month: date.getUTCMonth() + 1, // month is 0-11, so add 1
      time: date.getUTCHours() / 24,
      timezoneOffset: date.getTimezoneOffset()
    });
  });
}

initFlags(function(err, flags) {
  initApp(flags);
});
