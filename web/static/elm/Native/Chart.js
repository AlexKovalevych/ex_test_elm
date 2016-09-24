window.onresize = function() {
    for (var i in Chart.instances) {
        Chart.instances[i].chart.controller.resize();
    }
};

var charts = {};

var getDatasets = function(type, datasets, colors, labels) {
    var data = [];
    for (var i = 0; i < datasets.length; i++) {
        var points = [];
        for (var j = 0; j < datasets[i].length; j++) {
            points.push({
                label: labels[j],
                y: parseInt(datasets[i][j].replace(/[^\d\.]/g, '')),
            });
        }
        var color = colors.table[i]._0 + ',' + colors.table[i]._1 + ',' + colors.table[i]._2;
        data.push({
            // toolTipContent: '<span style=\'"\'color: {color};\'"\'>{label}:</span> ${y}',
            type: type,
            color: 'rgba(' + color + ', 0.7)',
            lineColor: 'rgba(' + color + ', 1)',
            dataPoints: points
        });
    }
    return data;
};

var chartConfig = {
    axisX: {
        valueFormatString: ' ',
        lineThickness: 1,
        gridThickness: 1,
        tickLength: 0,
        margin: -10
    },
    axisY: {
        valueFormatString: ' ',
        lineThickness: 0,
        gridThickness: 0,
        tickLength: 0,
        margin: 0
    },
    axisY2: {
        valueFormatString: ' ',
        lineThickness: 0,
        gridThickness: 0,
        tickLength: 0,
        margin: 0
    }
};

var _user$project$Native_Chart = function() {
    function renderAreaChart(canvasId, colors, index, data, labels)
    {
        var ctx = document.getElementById(canvasId);
        if (ctx === null) {
            return;
        }
        if (charts[canvasId] !== undefined
            && charts[canvasId].data == data
            && ctx.classList.contains('rendered')
            && (!index || ctx.classList.contains(index))
        ) {
            return;
        }

        ctx.setAttribute('class', 'rendered ' + index);
        charts[canvasId] = {
            data: data
        };
        var config = chartConfig;
        config.data = getDatasets('area', JSON.parse(data), colors, JSON.parse(labels));
        charts[canvasId]['chart'] = new CanvasJS.Chart(canvasId, config);
        charts[canvasId]['chart'].render();
    }

    function renderBarChart(canvasId, colors, index, data, labels)
    {
        var ctx = document.getElementById(canvasId);
        if (ctx === null) {
            return;
        }
        if (charts[canvasId] !== undefined
            && charts[canvasId].data == data
            && ctx.classList.contains('rendered')
            && (!index || ctx.classList.contains(index))
        ) {
            return;
        }

        ctx.setAttribute('class', 'rendered ' + index);
        charts[canvasId] = {data: data};
        var config = chartConfig;
        config.data = getDatasets('column', JSON.parse(data), colors, JSON.parse(labels));
        charts[canvasId]['chart'] = new CanvasJS.Chart(canvasId, config);
        charts[canvasId]['chart'].render();
    }

    return {
        area: F5(renderAreaChart),
        bar: F5(renderBarChart)
    };
}();
