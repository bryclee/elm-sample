var express = require('express');
var app = express();

app.use('/', express.static('public'));

var server = app.listen(process.env.PORT || 8000, () => {
    console.log(`Listening on ${server.address().port}`);
});
