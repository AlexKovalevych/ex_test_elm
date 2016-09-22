window.onresize = function() {
    for (var i in Chart.instances) {
        Chart.instances[i].chart.controller.resize();
    }
};

var charts = {};

var getDatasets = function(datasets, colors) {
    var data = [];
    for (var i = 0; i < datasets.length; i++) {
        data.push({
            label: '',
            fill: true,
            data: datasets[i],
            backgroundColor: 'rgba(' + colors[i]._0 + ',' + colors[i]._1 + ',' + colors[i]._2 + ', 0.2)',
            borderColor: 'rgba(' + colors[i]._0 + ',' + colors[i]._1 + ',' + colors[i]._2 + ', 1)',
            borderWidth: 1,
            pointRadius: 1,
            pointBorderWidth: 0,
            pointHoverBorderWidth: 3,
            pointHitRadius: 10
        });
    }
};

var getLabels = function(points) {
    var labels = [];
    for (var i = 0; i < points.length; i++) {
        labels.push(i);
    }
    return labels;
};

var _user$project$Native_Chart = function() {
    function renderAreaChart(canvasId, colors, data)
    {
        var ctx = document.getElementById(canvasId);
        if (ctx === null) {
            return;
        }
        if (charts[canvasId] !== undefined && charts[canvasId].data.length == data.length && ctx.classList.contains('rendered')) {
            return;
        }

        var datasets = JSON.parse(data);
        if (ctx.classList.contains('rendered')) {
            charts[canvasId].data = data;
            charts[canvasId].chart.data.labels = getLabels(datasets._0);
            charts[canvasId].chart.data.datasets = getDatasets(datasets, colors);
            charts[canvasId].chart.update();
        } else {
            ctx.setAttribute('class', 'rendered');
            charts[canvasId] = {data: data};
            charts[canvasId]['chart'] = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: getLabels(datasets[0]),
                    datasets: getDatasets(datasets, colors)
                },
                options: {
                    insertIframe: false,
                    scales: {
                        xAxes: [{
                            display: true,
                            paddingLeft: 0,
                            paddingRight: 0,
                            paddingTop: 0,
                            paddingBottom: 0,
                            margins: {
                                left: 0,
                                right: 0,
                                top: 0,
                                bottom: 0
                            },
                            ticks: {
                                // autoSkip: false,
                                display: false,
                                maxTicksLimit: 20
                            }
                        }],
                        yAxes: [{
                            display: false,
                            paddingLeft: 0,
                            paddingRight: 0,
                            paddingTop: 0,
                            paddingBottom: 0,
                            margins: {
                                left: 0,
                                right: 0,
                                top: 0,
                                bottom: 0
                            }
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
                        display: false,
                        padding: 0
                    }
                }
            });
        }
    }

    function renderBarChart(canvasId, colors, data)
    {
        var ctx = document.getElementById(canvasId);
        if (ctx === null) {
            return;
        }
        if (charts[canvasId] !== undefined && charts[canvasId].data.length == data.length && ctx.classList.contains('rendered')) {
            return;
        }

        var datasets = JSON.parse(data);
        if (ctx.classList.contains('rendered')) {
            charts[canvasId].data = data;
            charts[canvasId].chart.data.labels = getLabels(datasets);
            charts[canvasId].chart.data.datasets = getDatasets(datasets, colors);
            charts[canvasId].chart.update();
        } else {
            ctx.setAttribute('class', 'rendered');
            charts[canvasId] = {data: data};
            charts[canvasId]['chart'] = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: getLabels(datasets),
                    datasets: getDatasets(datasets, colors)
                },
                options: {
                    insertIframe: false,
                    scales: {
                        xAxes: [{
                            display: true,
                            categoryPercentage: 1.0,
                            barPercentage: 1.0,
                            paddingLeft: 0,
                            paddingRight: 0,
                            paddingTop: 0,
                            paddingBottom: 0,
                            margins: {
                                left: 0,
                                right: 0,
                                top: 0,
                                bottom: 0
                            },
                            gridLines: {
                                maxLines: 20
                            },
                            ticks: {
                                display: false,
                                maxTicksLimit: 20
                            }
                        }],
                        yAxes: [{
                            display: false,
                            paddingLeft: 0,
                            paddingRight: 0,
                            paddingTop: 0,
                            paddingBottom: 0,
                            margins: {
                                left: 0,
                                right: 0,
                                top: 0,
                                bottom: 0
                            }
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
                        display: false,
                        padding: 0
                    }
                }
            });
        }
    }

    return {
        area: F3(renderAreaChart),
        bar: F3(renderBarChart)
    };
}();
