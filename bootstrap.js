var node = document.getElementById('main');
var geoAllowed = 'geolocation' in window.navigator;
var app = Elm.Main.embed(node, {
  geolocation: geoAllowed
});

app.ports.requestGeolocation.subscribe(function() {
  console.log('Received request for geolocation!');
  if (!geoAllowed) return;

  window.navigator.geolocation.getCurrentPosition(function(position) {
    console.log('Sending data for geolocation!', position);
    app.ports.receiveGeolocation.send(position);
  });
});
