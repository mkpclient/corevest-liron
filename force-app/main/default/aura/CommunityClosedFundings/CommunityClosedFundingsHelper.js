({
  drawChart: function(component) {
    let action = component.get("c.getLOCChartData");

    action.setParams({ recordId: component.get("v.recordId") });

    let helper = this;
    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        //component.set("v.recordType", response.getReturnValue());

        let resp = response.getReturnValue();

        let chartData = {
          type: "pie",
          data: {
            datasets: [{ data: [], backgroundColor: ["#ff671b", "#1393d1"] }],
            labels: []
          },
          options: {}
        };

        for (let key in resp) {
          chartData.data.datasets[0].data.push(resp[key]);
          chartData.data.labels.push(key);
        }

        let commitment = helper.formatMoney(resp.Drawn + resp.Undrawn);
        let title = `$${commitment} Line of Credit`;

        chartData.options.title = { display: true, text: title };
        chartData.options.tooltips = {
          callbacks: {
            label: function(tooltipItem, data) {
              console.log(JSON.parse(JSON.stringify(tooltipItem)));
              console.log(data);
              let val =
                data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
              return (
                "$" +
                Number(val)
                  .toFixed(0)
                  .replace(/./g, function(c, i, a) {
                    return i > 0 && c !== "." && (a.length - i) % 3 === 0
                      ? "," + c
                      : c;
                  })
              );
            }
          }
        };
        component.find("fundingChart").drawChart(chartData);
      } else if (state === "ERROR") {
        console.log("--error--");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  queryFundings: function(component, event, helper) {
    let action = component.get("c.getClosedFundings");

    action.setParams({ recordId: component.get("v.recordId") });

    action.setCallback(this, function(response) {
      let state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        component.set("v.properties", response.getReturnValue());
      } else {
        console.log("error");
        console.log(response.getError());
      }
    });

    $A.enqueueAction(action);
  },

  formatMoney: function(n, c, d, t) {
    var c = isNaN((c = Math.abs(c))) ? 0 : c,
      d = d == undefined ? "." : d,
      t = t == undefined ? "," : t,
      s = n < 0 ? "-" : "",
      i = String(parseInt((n = Math.abs(Number(n) || 0).toFixed(c)))),
      j = (j = i.length) > 3 ? j % 3 : 0;

    return (
      s +
      (j ? i.substr(0, j) + t : "") +
      i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) +
      (c
        ? d +
          Math.abs(n - i)
            .toFixed(c)
            .slice(2)
        : "")
    );
  }
});