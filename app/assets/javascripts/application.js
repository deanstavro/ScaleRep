// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require turbolinks
//= require jquery_ujs
//= require popper
//= require bootstrap
//= require Chart.bundle
//= require chartkick
//= require bootstrap-datepicker
//= require bootstrap-toggle
//= require_tree .


$( document ).on('turbolinks:load', function() {
  $(function () {
    $('[data-toggle="tooltip"]').tooltip({
      template: '<div class="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-head"><dl><dt>Upload Requirements:</dt><dd>- Uploaded file must be a csv</dd><dt>CSV fields:</dt><ddd> first_name*, last_name, email*, company_name*, phone_type, </ddd><ddd>phone_number, title, linkedin, timezone, </ddd><ddd>company_website, address, city, state, </ddd><ddd> country, email_snippet</ddd></dl></div></div>'
    });
  });
});
