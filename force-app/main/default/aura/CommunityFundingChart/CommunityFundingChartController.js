({
  drawChart: function(component, event, helper) {
    Chart.pluginService.register({
      beforeRender: function(chart) {
        if (chart.config.options.showAllTooltips) {
          // create an array of tooltips
          // we can't use the chart tooltip because there is only one tooltip per chart
          chart.pluginTooltips = [];
          chart.config.data.datasets.forEach(function(dataset, i) {
            chart.getDatasetMeta(i).data.forEach(function(sector, j) {
              chart.pluginTooltips.push(
                new Chart.Tooltip(
                  {
                    _chart: chart.chart,
                    _chartInstance: chart,
                    _data: chart.data,
                    _options: chart.options.tooltips,
                    _active: [sector]
                  },
                  chart
                )
              );
            });
          });

          // turn off normal tooltips
          chart.options.tooltips.enabled = false;
        }
      },
      afterDraw: function(chart, easing) {
        if (chart.config.options.showAllTooltips) {
          // we don't want the permanent tooltips to animate, so don't do anything till the animation runs atleast once
          if (!chart.allTooltipsOnce) {
            if (easing !== 1) return;
            chart.allTooltipsOnce = true;
          }

          // turn on tooltips
          chart.options.tooltips.enabled = true;
          Chart.helpers.each(chart.pluginTooltips, function(tooltip) {
            tooltip.initialize();
            tooltip.update();
            // we don't actually need this since we are not animating tooltips
            tooltip.pivot();
            tooltip.transition(easing).draw();
          });
          chart.options.tooltips.enabled = false;
        }
      }
    });

    let ctx = component
      .find("chart")
      .getElement()
      .getContext("2d");

    let params = event.getParam("arguments");
    // let data = {
    //   datasets: [
    //     {
    //       data: [10, 20, 30]
    //     }
    //   ],

    //   // These labels appear in the legend and in the tooltips when hovering different arcs
    //   labels: ["Red", "Yellow", "Blue"]
    // };
    let defaultOptions = {
      responsive: false
    };
    let options = Object.assign(defaultOptions, params.payload.options);
    options.showAllTooltips = true;
    var chrt = new Chart(ctx, {
      type: params.payload.type,
      data: params.payload.data,
      options: options
      //options: options
    });
  }
});