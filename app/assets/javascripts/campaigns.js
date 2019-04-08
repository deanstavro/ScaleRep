// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

$( document ).on('turbolinks:load', function() {
  $(function () {
    $('[data-toggle="tooltip"]').tooltip({
      template: '<div class="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-head"><dl><dt>Upload Requirements:</dt><dd>File must be a csv</dd><dt>CSV fields:</dt><ddd> first_name*<br>email*<br>last_name<br>company_name<br>company_website<br>phone_type<br>phone_number<br>title<br>linkedin<br>timezone<br>address<br>city<br>state<br>country</ddd></dl></div></div>'
    });
  });
});