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
//= require jquery_ujs
//= require turbolinks
//= require popper
//= require bootstrap
//= require Chart.bundle
//= require chartkick



$( document ).on('turbolinks:load', function() {
  $(function () {
    $('[data-toggle="tooltip"]').tooltip({
      template: '<div class="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-head"><dl><dt>Upload Requirements:</dt><dd>- Uploaded file must be a csv</dd><dt>CSV fields:</dt><dd>- first_name*</dd><dd>- last_name*</dd><dd>- email*</dd><dd>- company_name*</dd><dd>- phone_type</dd><dd>- phone_number</dd><dd>- title</dd><dd>- linkedin</dd><dd>- timezone</dd><dd>- company_website</dd><dd>- address</dd><dd>- city</dd><dd>- state</dd><dd>- country</dd><dd>- email_snippet</dd></dl></div></div>'
    });
  });
});
