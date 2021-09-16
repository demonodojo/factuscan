
import 'jquery';
import './maphilight'

console.log("invoice")

$(document).on('turbolinks:load',(function() {

    console.log('maphilight loading')
    $('.map').maphilight();
}));