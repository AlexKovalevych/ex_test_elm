window.onresize = function() {
    for (var i in Chart.instances) {
        Chart.instances[i].chart.controller.resize();
    }
};

var _user$project$Native_Chart = function() {
    function renderAreaChart(canvasId, data)
    {
        var ctx = document.getElementById(canvasId);
        if (ctx === null) {
            return;
        }
        if (ctx.classList.contains('rendered')) {
            // clearInterval(interval);
            return;
        }

        // var interval = setInterval(function() {
            ctx.setAttribute('class', 'rendered');
            var points = JSON.parse(data);
            var labels = [];
            for (var i = 0; i < points.length; i++) {
                labels.push(i);
            }
            var myChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '',
                        fill: true,
                        data: points,
                        backgroundColor: 'rgba(255, 99, 132, 0.2)',
                        borderColor: 'rgba(255,99,132,1)',
                        borderWidth: 1,
                        pointRadius: 1,
                        pointBorderWidth: 0,
                        pointHoverBorderWidth: 3,
                        pointHitRadius: 10
                    }]
                },
                options: {
                    insertIframe: false,
                    scales: {
                        xAxes: [{
                            display: false
                        }],
                        yAxes: [{
                            display: false
                        }]
                    },
                    legend: {
                        display: false
                    },
                    tooltips: {
                        enabled: false,
                        custom: function(tooltip) {
                            if (tooltip.body) {
                                app.ports.splineTooltip.send({
                                    canvasId: canvasId,
                                    index: parseInt(tooltip.title[0])
                                });
                            }
                        }
                    },
                    title: {
                        display: false
                    }
                }
            });
            // clearInterval(interval);
        // }, 100);
    }

    return {
        area: F2(renderAreaChart)
    };
}();
