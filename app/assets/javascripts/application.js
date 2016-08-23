// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery.ui.all
//= require twitter/bootstrap/bootstrap-transition
//= require twitter/bootstrap/bootstrap-alert
//= require twitter/bootstrap/bootstrap-modal
//= require twitter/bootstrap/bootstrap-dropdown
//= require twitter/bootstrap/bootstrap-scrollspy
//= require twitter/bootstrap/bootstrap-tab
//= require twitter/bootstrap/bootstrap-tooltip
//= require twitter/bootstrap/bootstrap-popover
//= require twitter/bootstrap/bootstrap-button
//= require twitter/bootstrap/bootstrap-collapse
//= require twitter/bootstrap/bootstrap-carousel
//= require twitter/bootstrap/bootstrap-affix
//= require bootstrap-datepicker
//= require dropzone
//= require_tree .

(function($){

  /**
   * Render a Chart using HighCharts
   * @param {Array} series  Series of data that will be rendered
   * @param {String} element DOM Element ( #element )
   */
  window.RenderChart = function(series, element) {
      new Highcharts.Chart({
      chart: {
        renderTo: element
      },
      title: {
        text: 'Orders over time'
      },
      yAxis: {
        min: 0,
        title: {
          text: 'Total orders'
        }
      },
      xAxis: {
        title: {
          text: 'Period number'
        },
        allowDecimals: false
      },
      series: series
    })
  };

  /*
   * On DOM Ready
   */
  $(window).ready(function(){

    /**
     * Bootstrap functions => Datepicker, Tooltpi and Typeahead
     */
    $('.datepicker').datepicker();
    $('.hello-tooltip').tooltip();

    $('#dynamicTab a').on('click', function(event){

      event.preventDefault();
      $(this).tab('show');

    });

    /**
     * Advanced search section toggling (Show|Hide)
     */
    $('.btn-advanced').on('click', function(event){
      event.preventDefault();
      $('.advanced-form').toggle(250);
      $(this).toggleClass('active');
    });

    /**
     * Dynamic Nav bar
     */
    $('#dynamicTab a').click(function (e) {
      e.preventDefault();
      $(this).tab('show');
    });

    $('#dynamicTab a:first').tab('show');

  });

})(jQuery, window);