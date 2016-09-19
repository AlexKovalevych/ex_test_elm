window.onresize = function() {
    for (var i in Chart.instances) {
        Chart.instances[i].chart.controller.resize();
    }
};

var charts = {};

var getDatasets = function(points) {
    return [{
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
    }];
};

var getLabels = function(points) {
    var labels = [];
    for (var i = 0; i < points.length; i++) {
        labels.push(i);
    }
    return labels;
};

var _user$project$Native_Chart = function() {
    function renderAreaChart(canvasId, data)
    {
        var ctx = document.getElementById(canvasId);
        if (ctx === null) {
            return;
        }
        if (charts[canvasId] !== undefined && charts[canvasId].data == data) {
            // clearInterval(interval);
            return;
        }

        var points = JSON.parse(data);
        if (ctx.classList.contains('rendered')) {
            charts[canvasId].data = data;
            charts[canvasId].chart.data.labels = getLabels(points);
            charts[canvasId].chart.data.datasets = getDatasets(points);
            charts[canvasId].chart.update();
        } else {
            ctx.setAttribute('class', 'rendered');
            charts[canvasId] = {data: data};
            charts[canvasId]['chart'] = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: getLabels(points),
                    datasets: getDatasets(points)
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
        }

        // var interval = setInterval(function() {
            // clearInterval(interval);
        // }, 100);
    }

    return {
        area: F2(renderAreaChart)
    };
}();
