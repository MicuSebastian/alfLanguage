"use strict";


var parser = require ('./grammar.js').parser;
var fs = require ('fs');

try {
    var data = fs.readFileSync(process.argv[2]).toString();
    parser.parse (data);
    /* if (process.argv[3] == undefined) {
        let loc = './' + process.argv[2] + '.json';
        fs.writeFileSync(loc, JSON.stringify(parser.parse (data), null, 3));
    } else {
        fs.writeFileSync(process.argv[3], JSON.stringify(parser.parse (data), null, 3));
    } */
}
catch (e) {
    console.log (e.message);
}

/*
var parser = require ('./grammar.js').parser;
var fs = require ('fs');

try {
    var data = fs.readFileSync('script.alf').toString();
    fs.writeFileSync('./output.json', JSON.stringify(parser.parse (data), null, 3));
}
catch (e) {
    console.log (e.message);
}
*/