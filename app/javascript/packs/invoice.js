
import 'jquery';
import './maphilight'

$(document).on('turbolinks:load',(function() {

    console.log('maphilight loading')
    $('.map').maphilight();
}));