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
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require popper
//= require bootstrap
//= require Chart.bundle
//= require chartkick


$( document ).on('turbolinks:load', function() {
  $(function () {
    $('[data-toggle="tooltip"]').tooltip({
      template: '<div class="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-head"><dl><dt>Upload Requirements:</dt><dd>- Uploaded file must be a csv</dd><dd>- Uploaded csv must contain header fields first_name, last_name, email, and company</dd><dt>CSV fields:</dt><dd>- first_name</dd><dd>- last_name</dd><dd>- email</dd><dd>- phone_type</dd><dd>- phone_number</dd><dd>- title</dd><dd>- linkedin</dd><dd>- timezone</dd><dd>- company</dd><dd>- company_domain</dd><dd>- address</dd><dd>- city</dd><dd>- state</dd><dd>- country</dd><dd>- company_description</dd><dd>- number_of_employees</dd><dd>- last_funding_type</dd><dd>- last_funding_date</dd><dd>- last_funding_amount</dd><dd>- total_funding_amount</dd><dd>- email_snippet</dd></dl></div></div>'
    });
  });
});
