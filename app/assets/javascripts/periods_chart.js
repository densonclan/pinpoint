(function() {
  var PeriodsChart = function(options) {
    this.periods = options.periods;
    this.series = options.series;

    new Highcharts.Chart({
      chart: {
        renderTo: options.element
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
        categories: this.periods
      },
      series: this.prepare_series(this.series)
    })
  }

  PeriodsChart.prototype.prepare_series = function(series) {
    var that = this;

    return series.map(function(serie) {
      return that.convert_serie_keys_to_indexes(serie)
    });
  }

  PeriodsChart.prototype.convert_serie_keys_to_indexes = function(serie) {
    var that = this;

    return {
      name: serie.name,
      data: this.sort_data(serie.data.map(function(el) {
        var el2 = [that.periods.indexOf(el[0]), el[1]];
        return el2;
      }))
    }
  }

  PeriodsChart.prototype.sort_data = function(data) {
    return data.sort(function(a, b) {
      return a[0] - b[0];
    })


  }


  window.PeriodsChart = PeriodsChart;
})()
